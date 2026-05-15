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
        # ---- common/ (pcsx2/common) ----
        pcsx2/common/FastJmp.cpp

        # ---- EE Core, IOP, VU, System (pcsx2/pcsx2/) ----
        pcsx2/pcsx2/Achievements.cpp
        pcsx2/pcsx2/BuildVersion.cpp
        pcsx2/pcsx2/Cache.cpp
        pcsx2/pcsx2/COP0.cpp
        pcsx2/pcsx2/COP2.cpp
        pcsx2/pcsx2/Counters.cpp
        pcsx2/pcsx2/Dmac.cpp
        pcsx2/pcsx2/Elfheader.cpp
        pcsx2/pcsx2/FiFo.cpp
        pcsx2/pcsx2/FPU.cpp
        pcsx2/pcsx2/FW.cpp
        # pcsx2/pcsx2/GameDatabase.cpp  # needs ryml (rapidyaml) — excluded
        pcsx2/pcsx2/GameList.cpp
        pcsx2/pcsx2/Gif.cpp
        pcsx2/pcsx2/Gif_Logger.cpp
        pcsx2/pcsx2/Gif_Unit.cpp
        pcsx2/pcsx2/GS.cpp
        pcsx2/pcsx2/GSDumpReplayer.cpp
        pcsx2/pcsx2/Host.cpp
        pcsx2/pcsx2/Hotkeys.cpp
        pcsx2/pcsx2/Hw.cpp
        pcsx2/pcsx2/HwRead.cpp
        pcsx2/pcsx2/HwWrite.cpp
        # pcsx2/pcsx2/INISettingsInterface.cpp  # needs simpleini — excluded
        pcsx2/pcsx2/Interpreter.cpp
        pcsx2/pcsx2/IopBios.cpp
        pcsx2/pcsx2/IopCounters.cpp
        pcsx2/pcsx2/IopDma.cpp
        pcsx2/pcsx2/IopGte.cpp
        pcsx2/pcsx2/IopHw.cpp
        pcsx2/pcsx2/IopIrq.cpp
        pcsx2/pcsx2/IopMem.cpp
        # pcsx2/pcsx2/IopModuleNames.cpp  # debug-only, macro expansion issues
        pcsx2/pcsx2/LayeredSettingsInterface.cpp
        pcsx2/pcsx2/Mdec.cpp
        pcsx2/pcsx2/Memory.cpp
        pcsx2/pcsx2/MMI.cpp
        pcsx2/pcsx2/MTGS.cpp
        pcsx2/pcsx2/MTVU.cpp
        pcsx2/pcsx2/Patch.cpp
        pcsx2/pcsx2/Pcsx2Config.cpp
        pcsx2/pcsx2/PerformanceMetrics.cpp
        pcsx2/pcsx2/PINE.cpp
        pcsx2/pcsx2/R3000A.cpp
        pcsx2/pcsx2/R3000AInterpreter.cpp
        pcsx2/pcsx2/R3000AOpcodeTables.cpp
        pcsx2/pcsx2/R5900.cpp
        pcsx2/pcsx2/R5900OpcodeImpl.cpp
        pcsx2/pcsx2/R5900OpcodeTables.cpp
        pcsx2/pcsx2/SaveState.cpp
        pcsx2/pcsx2/ShiftJisToUnicode.cpp
        pcsx2/pcsx2/Sif.cpp
        pcsx2/pcsx2/Sif0.cpp
        pcsx2/pcsx2/Sif1.cpp
        pcsx2/pcsx2/sif2.cpp
        pcsx2/pcsx2/SourceLog.cpp
        pcsx2/pcsx2/SPR.cpp
        pcsx2/pcsx2/StateWrapper.cpp
        pcsx2/pcsx2/Vif.cpp
        pcsx2/pcsx2/Vif0_Dma.cpp
        pcsx2/pcsx2/Vif1_Dma.cpp
        pcsx2/pcsx2/Vif1_MFIFO.cpp
        pcsx2/pcsx2/Vif_Codes.cpp
        pcsx2/pcsx2/Vif_Transfer.cpp
        pcsx2/pcsx2/Vif_Unpack.cpp
        pcsx2/pcsx2/VMManager.cpp
        pcsx2/pcsx2/vtlb.cpp
        pcsx2/pcsx2/VU0.cpp
        pcsx2/pcsx2/VU0micro.cpp
        pcsx2/pcsx2/VU0microInterp.cpp
        pcsx2/pcsx2/VU1micro.cpp
        pcsx2/pcsx2/VU1microInterp.cpp
        pcsx2/pcsx2/VUflags.cpp
        pcsx2/pcsx2/VUmicro.cpp
        pcsx2/pcsx2/VUmicroMem.cpp
        pcsx2/pcsx2/VUops.cpp

        # ---- CDVD ----
        pcsx2/pcsx2/CDVD/BlockdumpFileReader.cpp
        pcsx2/pcsx2/CDVD/CDVD.cpp
        pcsx2/pcsx2/CDVD/CDVDcommon.cpp
        pcsx2/pcsx2/CDVD/CDVDdiscReader.cpp
        pcsx2/pcsx2/CDVD/CDVDdiscThread.cpp
        pcsx2/pcsx2/CDVD/CDVDisoReader.cpp
        pcsx2/pcsx2/CDVD/ChdFileReader.cpp
        pcsx2/pcsx2/CDVD/CsoFileReader.cpp
        pcsx2/pcsx2/CDVD/FlatFileReader.cpp
        pcsx2/pcsx2/CDVD/GzippedFileReader.cpp
        pcsx2/pcsx2/CDVD/InputIsoFile.cpp
        pcsx2/pcsx2/CDVD/IsoHasher.cpp
        pcsx2/pcsx2/CDVD/IsoReader.cpp
        pcsx2/pcsx2/CDVD/OutputIsoFile.cpp
        pcsx2/pcsx2/CDVD/Ps1CD.cpp
        pcsx2/pcsx2/CDVD/ThreadedFileReader.cpp

        # ---- SIO, SIO/Pad, SIO/Memcard, SIO/Multitap ----
        pcsx2/pcsx2/SIO/Sio.cpp
        pcsx2/pcsx2/SIO/Sio0.cpp
        pcsx2/pcsx2/SIO/Sio2.cpp
        pcsx2/pcsx2/SIO/Memcard/MemoryCardFile.cpp
        # pcsx2/pcsx2/SIO/Memcard/MemoryCardFolder.cpp  # needs ryml — excluded for bringup
        pcsx2/pcsx2/SIO/Memcard/MemoryCardProtocol.cpp
        pcsx2/pcsx2/SIO/Multitap/MultitapProtocol.cpp
        pcsx2/pcsx2/SIO/Pad/Pad.cpp
        pcsx2/pcsx2/SIO/Pad/PadBase.cpp
        pcsx2/pcsx2/SIO/Pad/PadDualshock2.cpp
        pcsx2/pcsx2/SIO/Pad/PadGuitar.cpp
        pcsx2/pcsx2/SIO/Pad/PadJogcon.cpp
        pcsx2/pcsx2/SIO/Pad/PadNegcon.cpp
        pcsx2/pcsx2/SIO/Pad/PadNotConnected.cpp
        pcsx2/pcsx2/SIO/Pad/PadPopn.cpp

        # ---- GS Core ----
        pcsx2/pcsx2/GS/GS.cpp
        pcsx2/pcsx2/GS/GSBlock.cpp
        pcsx2/pcsx2/GS/GSCapture.cpp
        pcsx2/pcsx2/GS/GSClut.cpp
        pcsx2/pcsx2/GS/GSDrawingContext.cpp
        pcsx2/pcsx2/GS/GSDrawingEnvironment.cpp
        pcsx2/pcsx2/GS/GSDump.cpp
        pcsx2/pcsx2/GS/GSLocalMemory.cpp
        pcsx2/pcsx2/GS/GSLocalMemoryMultiISA.cpp
        pcsx2/pcsx2/GS/GSLzma.cpp
        pcsx2/pcsx2/GS/GSPerfMon.cpp
        pcsx2/pcsx2/GS/GSPng.cpp
        pcsx2/pcsx2/GS/GSRingHeap.cpp
        pcsx2/pcsx2/GS/GSState.cpp
        pcsx2/pcsx2/GS/GSTables.cpp
        pcsx2/pcsx2/GS/GSUtil.cpp
        pcsx2/pcsx2/GS/GSVector.cpp
        pcsx2/pcsx2/GS/GSXXH.cpp
        pcsx2/pcsx2/GS/MultiISA.cpp

        # ---- GS/Renderers/Common ----
        pcsx2/pcsx2/GS/Renderers/Common/GSDevice.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSDirtyRect.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSFunctionMap.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSRenderer.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSTexture.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSVertexTrace.cpp
        pcsx2/pcsx2/GS/Renderers/Common/GSVertexTraceFMM.cpp

        # ---- GS/Renderers/Null ----
        pcsx2/pcsx2/GS/Renderers/Null/GSRendererNull.cpp

        # ---- GS/Renderers/HW ----
        pcsx2/pcsx2/GS/Renderers/HW/GSHwHack.cpp
        pcsx2/pcsx2/GS/Renderers/HW/GSRendererHW.cpp
        pcsx2/pcsx2/GS/Renderers/HW/GSRendererHWMultiISA.cpp
        pcsx2/pcsx2/GS/Renderers/HW/GSTextureCache.cpp
        pcsx2/pcsx2/GS/Renderers/HW/GSTextureReplacementLoaders.cpp
        pcsx2/pcsx2/GS/Renderers/HW/GSTextureReplacements.cpp

        # ---- GS/Renderers/SW ----
        pcsx2/pcsx2/GS/Renderers/SW/GSDrawScanline.cpp
        pcsx2/pcsx2/GS/Renderers/SW/GSDrawScanlineCodeGenerator.arm64.cpp
        pcsx2/pcsx2/GS/Renderers/SW/GSRasterizer.cpp
        pcsx2/pcsx2/GS/Renderers/SW/GSRendererSW.cpp
        pcsx2/pcsx2/GS/Renderers/SW/GSSetupPrimCodeGenerator.arm64.cpp
        pcsx2/pcsx2/GS/Renderers/SW/GSTextureCacheSW.cpp

        # ---- IPU ----
        pcsx2/pcsx2/IPU/IPU.cpp
        pcsx2/pcsx2/IPU/IPU_Fifo.cpp
        pcsx2/pcsx2/IPU/IPU_MultiISA.cpp
        pcsx2/pcsx2/IPU/IPUdither.cpp
        pcsx2/pcsx2/IPU/IPUdma.cpp
        pcsx2/pcsx2/IPU/yuv2rgb.cpp

        # ---- DebugTools ----
        pcsx2/pcsx2/DebugTools/BiosDebugData.cpp
        pcsx2/pcsx2/DebugTools/Breakpoints.cpp
        pcsx2/pcsx2/DebugTools/DebugInterface.cpp
        pcsx2/pcsx2/DebugTools/DisR3000A.cpp
        pcsx2/pcsx2/DebugTools/DisR5900asm.cpp
        pcsx2/pcsx2/DebugTools/DisVU0Micro.cpp
        pcsx2/pcsx2/DebugTools/DisVU1Micro.cpp
        pcsx2/pcsx2/DebugTools/DisassemblyManager.cpp
        pcsx2/pcsx2/DebugTools/ExpressionParser.cpp
        pcsx2/pcsx2/DebugTools/MIPSAnalyst.cpp
        pcsx2/pcsx2/DebugTools/MipsAssembler.cpp
        pcsx2/pcsx2/DebugTools/MipsAssemblerTables.cpp
        pcsx2/pcsx2/DebugTools/MipsStackWalk.cpp
        pcsx2/pcsx2/DebugTools/SymbolGuardian.cpp
        pcsx2/pcsx2/DebugTools/SymbolImporter.cpp

        # ---- Recording ----
        pcsx2/pcsx2/Recording/InputRecording.cpp
        pcsx2/pcsx2/Recording/InputRecordingControls.cpp
        pcsx2/pcsx2/Recording/InputRecordingFile.cpp
        pcsx2/pcsx2/Recording/PadData.cpp
        pcsx2/pcsx2/Recording/Utilities/InputRecordingLogger.cpp

        # ---- Host ----
        pcsx2/pcsx2/Host/AudioStream.cpp
        pcsx2/pcsx2/Host/CubebAudioStream.cpp

        # ---- ImGui ----
        pcsx2/pcsx2/ImGui/FullscreenUI.cpp
        # FullscreenUI_Settings.cpp excluded — includes DEV9/pcap_io.h and USB/USB.h unconditionally
        # ImGuiFullscreen.cpp excluded — needs plutosvg for SVG icons, not functional in bringup
        # pcsx2/pcsx2/ImGui/ImGuiFullscreen.cpp
        pcsx2/pcsx2/ImGui/ImGuiManager.cpp
        pcsx2/pcsx2/ImGui/ImGuiOverlays.cpp

        # ---- Input ----
        pcsx2/pcsx2/Input/InputManager.cpp
        pcsx2/pcsx2/Input/InputSource.cpp

        # ---- PS2 ----
        pcsx2/pcsx2/ps2/BiosTools.cpp
        pcsx2/pcsx2/ps2/Iop/IopHwRead.cpp
        pcsx2/pcsx2/ps2/Iop/IopHwWrite.cpp
        pcsx2/pcsx2/ps2/Iop/PsxBios.cpp
        pcsx2/pcsx2/ps2/pgif.cpp

        # ---- DEV9 — excluded on iOS per Phase 14 (Audit Sec 1.2 RED) ----

        # ---- USB — excluded entirely on iOS (needs SDL/libjpeg, not needed for bringup) ----

        # ---- RDebug — excluded on iOS (debug tools, needs IopBios2.h, Threading, psxRegs) ----
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

    # Catch-all: collect ALL available 3rdparty include directories
    # so newly added libraries resolve without editing CMakeLists.txt.
    # Each glob is expanded at cmake-configure time, not build time.
    file(GLOB THIRDPARTY_INCLUDE_DIRS
        pcsx2/3rdparty/*/include
        pcsx2/3rdparty/*/src
    )
    # Also add the root 3rdparty and key variant directories
    list(APPEND THIRDPARTY_INCLUDE_DIRS
        pcsx2/3rdparty
        pcsx2/3rdparty/promptfont
        pcsx2/3rdparty/soundtouch/soundtouch
        pcsx2/3rdparty/libzip/lib
        pcsx2/3rdparty/cubeb/include
        pcsx2/3rdparty/imgui/src
        pcsx2/3rdparty/include        # xxhash.h, pcap.h, Icons* (no subdir)
    )

    # freetype headers — built into ios-deps (Phase 3, Tier 3)
    # ft2build.h lives at <prefix>/include/freetype2/ft2build.h
    if(EXISTS "${IOS_DEPS}/include/freetype2")
        list(APPEND THIRDPARTY_INCLUDE_DIRS "${IOS_DEPS}/include/freetype2")
    endif()

    target_include_directories(BionicSX2 PRIVATE
        "${IOS_DEPS}/include"
        "${CMAKE_SOURCE_DIR}/generated"
        ios/platform
        metal
        pcsx2              # for #include "common/xxx.h" and "pcsx2/xxx.h" style
        pcsx2/pcsx2        # for direct #include "GS/xxx.h" style
        pcsx2/common       # for #include "Pcsx2Defs.h" without prefix
        ${THIRDPARTY_INCLUDE_DIRS}
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
