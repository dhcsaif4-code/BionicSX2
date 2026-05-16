// PCSX2Stubs.cpp — BionicSX2 iOS Port
// All C-ABI stubs use extern "C" to prevent C++ name mangling

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <malloc/malloc.h>

#ifdef __cplusplus
extern "C" {
#endif

// ── DEV9 ──────────────────────────────────────────────────────────────
void DEV9init(void) {}
void DEV9open(void) {}
void DEV9close(void) {}
void DEV9shutdown(void) {}
void DEV9async(unsigned int x) {}
void DEV9irqHandler(void) {}
unsigned char  DEV9read8(unsigned int addr)  { return 0; }
unsigned short DEV9read16(unsigned int addr) { return 0; }
unsigned int   DEV9read32(unsigned int addr) { return 0; }
void DEV9write8(unsigned int addr, unsigned char val)  {}
void DEV9write16(unsigned int addr, unsigned short val) {}
void DEV9write32(unsigned int addr, unsigned int val)  {}
void DEV9readDMA8Mem(unsigned int* dst, int size)  {}
void DEV9writeDMA8Mem(unsigned int* src, int size) {}

// ── USB ───────────────────────────────────────────────────────────────
void USBinit(void) {}
void USBopen(void) {}
void USBclose(void) {}
void USBshutdown(void) {}
void USBreset(void) {}
void USBasync(unsigned int x) {}
unsigned char  USBread8(unsigned int addr)  { return 0; }
unsigned short USBread16(unsigned int addr) { return 0; }
unsigned int   USBread32(unsigned int addr) { return 0; }
void USBwrite8(unsigned int addr, unsigned char val)  {}
void USBwrite16(unsigned int addr, unsigned short val) {}
void USBwrite32(unsigned int addr, unsigned int val)  {}

// ── VIF / JIT stubs ───────────────────────────────────────────────────
void VifUnpackSSE_Init(void) {}
void vtlb_DynBackpatchLoadStore(unsigned long a, unsigned int b,
    unsigned int c, unsigned int d, unsigned int e, unsigned int f,
    unsigned char g, unsigned char h, unsigned char i,
    int j, int k, int l) {}

// ── Drive / Disc ──────────────────────────────────────────────────────
void GetValidDrive(void* s) {}
void GetOpticalDriveList(void) {}

// ── Memory alignment (MSVC compat) ───────────────────────────────────
void* _aligned_malloc(unsigned long size, unsigned long align) {
    void* p = NULL;
    posix_memalign(&p, align < sizeof(void*) ? sizeof(void*) : align, size);
    return p;
}
void _aligned_free(void* p) { free(p); }

// ── Assert ────────────────────────────────────────────────────────────
void pxOnAssertFail(const char* msg, int line,
                    const char* file, const char* func) {
    fprintf(stderr, "[BionicSX2] Assert %s:%d %s: %s\n", file, line, func, msg);
    abort();
}

// ── Misc ──────────────────────────────────────────────────────────────
void ShortSpin(void) {}
void GetMetalAdapterList(void) {}

// ── BC Texture Decompression ──────────────────────────────────────────
void DecompressBlockBC1(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* src, unsigned char* dst) {}
void DecompressBlockBC2(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* src, unsigned char* dst) {}
void DecompressBlockBC3(unsigned int x, unsigned int y, unsigned int z,
    const unsigned char* src, unsigned char* dst) {}

#ifdef __cplusplus
} // extern "C"
#endif

// ── C++ symbols (no extern "C") ───────────────────────────────────────
// dVifRelease / dVifReset — declared as C++ in Vif_Dynarec.h
void dVifRelease(int idx) {}
void dVifReset(int idx) {}

// DEV9CheckChanges takes a C++ reference — must be C++ linkage
struct Pcsx2Config;
void DEV9CheckChanges(const Pcsx2Config&) {}
