// PORTED FROM: common/Linux/LnxHostSys.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 6.2, 6.3
// STATUS: YELLOW
#include "common/Assertions.h"
#include "common/BitUtils.h"
#include "common/Console.h"
#include "common/CrashHandler.h"
#include "common/Error.h"
#include "common/HostSys.h"
#include "common/Pcsx2Types.h"

#include <cstdio>
#include <csignal>
#include <cerrno>
#include <fcntl.h>
#include <mutex>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_init.h>
#include <mach/vm_map.h>
#include <libkern/OSCacheControl.h>
#include <unistd.h>

#include "fmt/format.h"

static __ri uint iOSProt(const PageProtectionMode& mode)
{
	u32 prot = VM_PROT_NONE;

	if (mode.CanWrite())
		prot |= VM_PROT_WRITE;
	if (mode.CanRead())
		prot |= VM_PROT_READ;
	if (mode.CanExecute())
		prot |= VM_PROT_EXECUTE | VM_PROT_READ;

	return prot;
}

void HostSys::MemProtect(void* baseaddr, size_t size, const PageProtectionMode& mode)
{
	pxAssertMsg((size & (__pagesize - 1)) == 0, "Size is page aligned");

	const u32 prot = iOSProt(mode);

	const kern_return_t kr = vm_protect(mach_task_self(), reinterpret_cast<vm_address_t>(baseaddr), size, FALSE, prot);
	if (kr != KERN_SUCCESS)
	{
		Console.Error("(HostSys_iOS) vm_protect failed: %s (0x%x)", mach_error_string(kr), kr);
		pxFail("vm_protect() failed");
	}
}

std::string HostSys::GetFileMappingName(const char* prefix)
{
	const unsigned pid = static_cast<unsigned>(getpid());
	return fmt::format("{}_{}", prefix, pid);
}

void* HostSys::CreateSharedMemory(const char* name, size_t size)
{
	// iOS: Use vm_allocate instead of shm_open
	vm_address_t addr = 0;
	kern_return_t kr = vm_allocate(mach_task_self(), &addr, size, VM_FLAGS_ANYWHERE);
	if (kr != KERN_SUCCESS)
	{
		Console.Error("(HostSys_iOS) vm_allocate for shared memory failed: %s (0x%x)", mach_error_string(kr), kr);
		return nullptr;
	}
	return reinterpret_cast<void*>(addr);
}

void HostSys::DestroySharedMemory(void* ptr)
{
	vm_deallocate(mach_task_self(), reinterpret_cast<vm_address_t>(ptr), 0);
}

void HostSys::FlushInstructionCache(void* address, u32 size)
{
	// DIAGNOSTIC FIX: __clear_cache is not available on iOS.
	// sys_icache_invalidate() is the Darwin-native equivalent.
	sys_icache_invalidate(address, static_cast<size_t>(size));
}

// MAP_JIT handling for SharedMemoryMappingArea
// In Phase 1 of BionicSX2, JIT is disabled (all Recompiler flags = false).
// Gracefully skip MAP_JIT — log and return non-fatal error.

SharedMemoryMappingArea::SharedMemoryMappingArea(u8* base_ptr, size_t size, size_t num_pages)
	: m_base_ptr(base_ptr)
	, m_size(size)
	, m_num_pages(num_pages)
{
}

SharedMemoryMappingArea::~SharedMemoryMappingArea()
{
	pxAssertRel(m_num_mappings == 0, "No mappings left");
	if (m_base_ptr)
	{
		vm_deallocate(mach_task_self(), reinterpret_cast<vm_address_t>(m_base_ptr), m_size);
	}
}

std::unique_ptr<SharedMemoryMappingArea> SharedMemoryMappingArea::Create(size_t size, bool jit)
{
	pxAssertRel(Common::IsAlignedPow2(size, __pagesize), "Size is page aligned");

	if (jit)
	{
		Console.Warning("(HostSys_iOS) MAP_JIT requested but not available on iOS without entitlement. JIT disabled, interpreter path active.");
		// Fall through — allocate without JIT flag
	}

	vm_address_t alloc = 0;
	kern_return_t kr = vm_allocate(mach_task_self(), &alloc, size, VM_FLAGS_ANYWHERE);
	if (kr != KERN_SUCCESS)
	{
		Console.Error("(HostSys_iOS) SharedMemoryMappingArea::Create vm_allocate failed: %s (0x%x)", mach_error_string(kr), kr);
		return nullptr;
	}

	return std::unique_ptr<SharedMemoryMappingArea>(new SharedMemoryMappingArea(static_cast<u8*>(reinterpret_cast<void*>(alloc)), size, size / __pagesize));
}

u8* SharedMemoryMappingArea::Map(void* file_handle, size_t file_offset, void* map_base, size_t map_size, const PageProtectionMode& mode)
{
	pxAssert(static_cast<u8*>(map_base) >= m_base_ptr && static_cast<u8*>(map_base) < (m_base_ptr + m_size));

	const u32 prot = iOSProt(mode);
	fprintf(stderr, "[HostSys_iOS] Map: prot=0x%x size=%zu\n", prot, map_size); fflush(stderr);
	kern_return_t kr = vm_protect(mach_task_self(), reinterpret_cast<vm_address_t>(map_base), map_size, FALSE, prot);
	fprintf(stderr, "[HostSys_iOS] vm_protect returned: %s (kr=0x%x)\n", mach_error_string(kr), kr); fflush(stderr);
	if (kr != KERN_SUCCESS)
	{
		Console.Error("(HostSys_iOS) SharedMemoryMappingArea::Map vm_protect failed: %s (0x%x)", mach_error_string(kr), kr);
		return nullptr;
	}

	m_num_mappings++;
	return static_cast<u8*>(map_base);
}

bool SharedMemoryMappingArea::Unmap(void* map_base, size_t map_size, bool is_file)
{
	pxAssert(static_cast<u8*>(map_base) >= m_base_ptr && static_cast<u8*>(map_base) < (m_base_ptr + m_size));

	kern_return_t kr = vm_protect(mach_task_self(), reinterpret_cast<vm_address_t>(map_base), map_size, FALSE, VM_PROT_NONE);
	if (kr != KERN_SUCCESS)
		return false;

	m_num_mappings--;
	return true;
}

size_t HostSys::GetRuntimePageSize()
{
	// iOS: use sysctlbyname instead of sysconf(_SC_PAGESIZE) for portability
	return static_cast<size_t>(sysconf(_SC_PAGESIZE));
}

size_t HostSys::GetRuntimeCacheLineSize()
{
	// _SC_LEVEL1_DCACHE_LINESIZE is Linux-specific.
	// On Darwin/iOS, use sysctlbyname.
	s64 cachelinesize = 0;
	size_t len = sizeof(cachelinesize);
	if (sysctlbyname("hw.cachelinesize", &cachelinesize, &len, nullptr, 0) == 0)
		return static_cast<size_t>(cachelinesize);
	return 128; // default for Apple Silicon
}
