cmake_minimum_required(VERSION 3.20)
project(BionicSX2)

# ============================================================================
# AUDIT REFERENCE: Sections 10.1, 10.2, 1.4, 1.5, Phase 14
# STATUS: NEW
# ============================================================================

# iOS guard block — Phase 14 (Audit Sec 10.1, 10.2)
if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(IOS_DEPS "${CMAKE_SOURCE_DIR}/ios-deps/install")

    # Disable everything that doesn't exist on iOS
    set(ENABLE_QT     OFF CACHE BOOL "" FORCE)   # Audit Sec 1.1 — RED
    set(ENABLE_OPENGL OFF CACHE BOOL "" FORCE)   # Audit Sec 1.2 — N/A
    set(ENABLE_VULKAN OFF CACHE BOOL "" FORCE)   # Audit Sec 1.2 — N/A
    set(USE_SDL       OFF CACHE BOOL "" FORCE)
    set(BUILD_TESTS   OFF CACHE BOOL "" FORCE)

    add_compile_definitions(TARGET_OS_IOS=1)
    add_compile_definitions(VIXL_CODE_BUFFER_MMAP=0)
    add_compile_definitions(PCSX2_TARGET_IOS=1)

    # Phase 0-D2: Register missing global-variable source files
    add_compile_definitions(ARCH_ARM64=1)

    set(CMAKE_FIND_ROOT_PATH "${IOS_DEPS};${CMAKE_OSX_SYSROOT}")
    list(PREPEND CMAKE_PREFIX_PATH "${IOS_DEPS};${CMAKE_OSX_SYSROOT}")
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

    find_package(ZLIB      QUIET)
    find_package(PNG       QUIET)
    find_package(Freetype  QUIET)

    find_library(LZ4_LIB        lz4        PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    find_library(ZSTD_LIB       zstd       PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    find_library(LZMA_LIB       pcsx2-lzma PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    if(NOT LZMA_LIB)
        find_library(LZMA_LIB   lzma       PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    endif()
    find_library(ZIP_LIB        zip        PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    find_library(CHDR_LIB       chdr       PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    find_library(CUBEB_LIB      cubeb      PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    # soundtouch builds as pcsx2-soundtouch in pcsx2/3rdparty
    find_library(SOUNDTOUCH_LIB pcsx2-soundtouch PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    if(NOT SOUNDTOUCH_LIB)
        find_library(SOUNDTOUCH_LIB SoundTouch PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    endif()
    find_library(FMT_LIB        fmt        PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)
    find_library(PNG_LIB        png16      PATHS "${IOS_DEPS}/lib" NO_DEFAULT_PATH)

    find_library(AUDIOTOOLBOX_FW   AudioToolbox   REQUIRED)
    find_library(AVFOUNDATION_FW   AVFoundation   REQUIRED)
    # CoreAudio framework is macOS-only; iOS uses AudioToolbox for audio
    find_library(COREAUDIO_FW      CoreAudio)
    find_library(COREFOUNDATION_FW CoreFoundation REQUIRED)
    find_library(UIKIT_FW          UIKit          REQUIRED)
    find_library(METAL_FW          Metal          REQUIRED)
    find_library(QUARTZCORE_FW     QuartzCore     REQUIRED)
    find_library(GAMECONTROLLER_FW GameController REQUIRED)
    find_library(SECURITY_FW       Security       REQUIRED)
    find_library(FOUNDATION_FW     Foundation     REQUIRED)

    # ==========================================================================
    # Source files
    # ==========================================================================

    # Phase 0-D2: Core PCSX2 sources with missing globals
    # NOTE: File names match actual PCSX2 source tree, not exec order spec
    set(PCSX2_CORE_SOURCES
        pcsx2/pcsx2/Pcsx2Config.cpp         # EmuConfig
        pcsx2/pcsx2/SIO/Sio0.cpp            # g_Sio0
        pcsx2/pcsx2/SIO/Sio2.cpp            # g_Sio2
        pcsx2/pcsx2/PerformanceMetrics.cpp  # g_perfmon
        pcsx2/pcsx2/Sif.cpp                 # sif0/sif1/sif2
        pcsx2/pcsx2/MTVU.cpp                # vu1Thread
        pcsx2/pcsx2/CDVD/CDVD.cpp           # cdvd global
        pcsx2/pcsx2/DebugTools/Breakpoints.cpp   # CBreakPoints
        pcsx2/pcsx2/DebugTools/SymbolGuardian.cpp # R3000SymbolGuardian
        pcsx2/pcsx2/DebugTools/SymbolImporter.cpp
        pcsx2/common/FastJmp.cpp            # fastjmp_jmp/fastjmp_set
    )

    # Phase 0-E: SPU2 internal files
    set(PCSX2_SPU2_SOURCES
        pcsx2/pcsx2/SPU2/spu2.cpp
        pcsx2/pcsx2/SPU2/spu2sys.cpp
        pcsx2/pcsx2/SPU2/spu2freeze.cpp
        pcsx2/pcsx2/SPU2/ADSR.cpp
        pcsx2/pcsx2/SPU2/Dma.cpp
        pcsx2/pcsx2/SPU2/Mixer.cpp
        pcsx2/pcsx2/SPU2/ReadInput.cpp
        pcsx2/pcsx2/SPU2/RegTable.cpp
        pcsx2/pcsx2/SPU2/Reverb.cpp
        pcsx2/pcsx2/SPU2/ReverbResample.cpp
        pcsx2/pcsx2/SPU2/Debug.cpp
        pcsx2/pcsx2/SPU2/Wavedump_wav.cpp
    )

    # Phase 0-D: LnxHostSys for iOS (DarwinMisc excluded — uses macOS-only
    # CoreGraphics/IOKit; our PageFaultHandler.cpp handles Mach exceptions)
    set(PCSX2_PLATFORM_SOURCES
        pcsx2/common/Linux/LnxHostSys.cpp     # SharedMemoryMappingArea (has __APPLE__ guards)
    )

    # Phase 0-A, 0-F: iOS platform layer
    set(IOS_PLATFORM_SOURCES
        ios/platform/iOSVMManager.mm
        ios/platform/HostSys_iOS.cpp
        ios/platform/Host_iOS.mm
        ios/platform/CocoaTools_iOS.mm
        ios/platform/AudioStream_iOS.mm
        ios/platform/Filesystem_iOS.mm
        ios/platform/PCSX2Stubs.mm
        ios/platform/Threading_iOS.cpp
        ios/platform/PageFaultHandler.cpp
        ios/ui/BionicSX2Bridge.mm
    )

    set(IOS_SWIFT_SOURCES
        ios/ui/BionicSX2App.swift
        ios/ui/ContentView.swift
        ios/ui/MetalViewController.swift
        ios/ui/GameControllerManager.swift
    )

    # Metal renderer (Phase 11-12)
    set(IOS_METAL_SOURCES
        metal/MetalRenderer.mm
        metal/MetalRenderer.h
        metal/MetalDeviceInfo.mm
        metal/MetalTexture.mm
        metal/FrameSync.mm
    )

    # ==========================================================================
    # Main BionicSX2 target
    # ==========================================================================

    add_library(BionicSX2 STATIC
        ${PCSX2_CORE_SOURCES}
        ${PCSX2_SPU2_SOURCES}
        ${PCSX2_PLATFORM_SOURCES}
        ${IOS_PLATFORM_SOURCES}
        ${IOS_METAL_SOURCES}
    )

    add_executable(BionicSX2_App
        ${IOS_SWIFT_SOURCES}
    )

    target_link_libraries(BionicSX2_App PRIVATE BionicSX2)

    target_compile_features(BionicSX2 PUBLIC cxx_std_20)
    target_compile_features(BionicSX2_App PRIVATE cxx_std_20)
    # PCSX2 uses C++20 features: std::countl_zero, concept, etc.

    target_compile_options(BionicSX2 PRIVATE
        -ffp-contract=fast
        -fno-strict-aliasing
        -Wno-parentheses
        -Wno-missing-braces
        -Wno-unknown-pragmas
        -fobjc-arc          # Enable ARC for Objective-C (.mm) files
        -Wno-macro-redefined # ARCH_ARM64 redefined in Pcsx2Defs.h
    )

    target_include_directories(BionicSX2 PRIVATE
        "${IOS_DEPS}/include"
        ios/platform
        metal
        pcsx2              # for #include "common/xxx.h" and "pcsx2/xxx.h" style
        pcsx2/pcsx2        # for direct #include "GS/xxx.h" style
        pcsx2/common       # for #include "Pcsx2Defs.h" without prefix
        pcsx2/3rdparty/fmt/include
        pcsx2/3rdparty/fast_float/include
        pcsx2/3rdparty/ccc/src
        pcsx2/3rdparty/demangler/include
        pcsx2/3rdparty/imgui
        pcsx2/3rdparty/vixl/include
        pcsx2/3rdparty
    )

    target_link_libraries(BionicSX2 PRIVATE
        ZLIB::ZLIB
        $<$<BOOL:${LZ4_LIB}>:${LZ4_LIB}>
        $<$<BOOL:${ZSTD_LIB}>:${ZSTD_LIB}>
        $<$<BOOL:${LZMA_LIB}>:${LZMA_LIB}>
        $<$<BOOL:${ZIP_LIB}>:${ZIP_LIB}>
        $<$<BOOL:${CUBEB_LIB}>:${CUBEB_LIB}>
        $<$<BOOL:${SOUNDTOUCH_LIB}>:${SOUNDTOUCH_LIB}>
        $<$<BOOL:${CHDR_LIB}>:${CHDR_LIB}>
        $<$<BOOL:${PNG_LIB}>:${PNG_LIB}>
        ${AUDIOTOOLBOX_FW}
        $<$<BOOL:${COREAUDIO_FW}>:${COREAUDIO_FW}>
        ${AVFOUNDATION_FW}
        ${COREAUDIO_FW}
        ${COREFOUNDATION_FW}
        ${UIKIT_FW}
        ${METAL_FW}
        ${QUARTZCORE_FW}
        ${GAMECONTROLLER_FW}
        ${SECURITY_FW}
        ${FOUNDATION_FW}
        "-framework Foundation"
        "-lc++"
        "-liconv"
    )

    target_compile_definitions(BionicSX2 PRIVATE
        PCSX2_TARGET_IOS=1
        TARGET_OS_IOS=1
        VIXL_CODE_BUFFER_MMAP=0
    )
    # ARCH_ARM64 is defined by Pcsx2Defs.h — do not duplicate

    # Phase 0-B: Exclude SW JIT files from iOS build
    # These are NOT added to sources for iOS

    # Phase 0-C: nVif forced interpreter (done in Vif_Dynarec.h at source level)

    # Set Metal shader compilation
    set(PCSX2_METAL_SHADERS
        pcsx2/pcsx2/GS/Renderers/Metal/cas.metal
        pcsx2/pcsx2/GS/Renderers/Metal/convert.metal
        pcsx2/pcsx2/GS/Renderers/Metal/present.metal
        pcsx2/pcsx2/GS/Renderers/Metal/merge.metal
        pcsx2/pcsx2/GS/Renderers/Metal/misc.metal
        pcsx2/pcsx2/GS/Renderers/Metal/interlace.metal
        pcsx2/pcsx2/GS/Renderers/Metal/tfx.metal
        pcsx2/pcsx2/GS/Renderers/Metal/fxaa.metal
    )

    # iOS app bundle settings
    set_target_properties(BionicSX2_App PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/ios/Info.plist"
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_SOURCE_DIR}/ios/entitlements/BionicSX2.entitlements"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.bionicsx2.app"
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
        XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Manual"
    )

    message(STATUS "BionicSX2 configured for iOS")
    message(STATUS "iOS deps path: ${IOS_DEPS}")

endif()
