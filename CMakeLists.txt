cmake_minimum_required(VERSION 3.20)
project(BionicSX2)

# ============================================================================
# AUDIT REFERENCE: Sections 10.1, 10.2, 1.4, 1.5, Phase 14
# STATUS: NEW
# ============================================================================

set(COMMON_DIR "${CMAKE_SOURCE_DIR}/pcsx2/common")
set(PCSX2_DIR  "${CMAKE_SOURCE_DIR}/pcsx2/pcsx2")

if(NOT EXISTS "${COMMON_DIR}/FastJmp.cpp")
  message(FATAL_ERROR "COMMON_DIR wrong: ${COMMON_DIR}")
endif()
if(NOT EXISTS "${PCSX2_DIR}/GS/GS.cpp")
  message(FATAL_ERROR "PCSX2_DIR wrong: ${PCSX2_DIR}")
endif()

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
        ${COMMON_DIR}/FastJmp.cpp
        ${COMMON_DIR}/FileSystem.cpp
        # ${COMMON_DIR}/Image.cpp — excluded on iOS, uses webp/jpeg, stubbed via Image_iOS.cpp
        ${COMMON_DIR}/StringUtil.cpp
        ${COMMON_DIR}/SmallString.cpp
        ${COMMON_DIR}/Timer.cpp
        ${COMMON_DIR}/DynamicLibrary.cpp
        ${COMMON_DIR}/HTTPDownloader.cpp
        ${COMMON_DIR}/ProgressCallback.cpp
        ${COMMON_DIR}/SettingsWrapper.cpp
        ${COMMON_DIR}/Error.cpp
        ${COMMON_DIR}/MD5Digest.cpp

        # ---- imgui (3rdparty) ----
        pcsx2/3rdparty/imgui/src/imgui.cpp
        pcsx2/3rdparty/imgui/src/imgui_draw.cpp
        pcsx2/3rdparty/imgui/src/imgui_tables.cpp
        pcsx2/3rdparty/imgui/src/imgui_widgets.cpp

        # ---- freesurround (3rdparty) ----
        pcsx2/3rdparty/freesurround/src/ChannelMaps.cpp
        pcsx2/3rdparty/freesurround/src/FreeSurroundDecoder.cpp
        pcsx2/3rdparty/freesurround/src/kiss_fft.cpp
        pcsx2/3rdparty/freesurround/src/kiss_fftr.cpp

        # ---- simpleini (3rdparty) ----
        pcsx2/3rdparty/simpleini/src/ConvertUTF.c

        # ---- EE Core, IOP, VU, System (${PCSX2_DIR}/) ----
        ${PCSX2_DIR}/Achievements.cpp
        ${PCSX2_DIR}/BuildVersion.cpp
        ${PCSX2_DIR}/Cache.cpp
        ${PCSX2_DIR}/COP0.cpp
        ${PCSX2_DIR}/COP2.cpp
        ${PCSX2_DIR}/Counters.cpp
        ${PCSX2_DIR}/Dmac.cpp
        ${PCSX2_DIR}/Elfheader.cpp
        ${PCSX2_DIR}/FiFo.cpp
        ${PCSX2_DIR}/FPU.cpp
        ${PCSX2_DIR}/FW.cpp
        # ${PCSX2_DIR}/GameDatabase.cpp  # needs ryml (rapidyaml) — excluded
        ${PCSX2_DIR}/GameList.cpp
        ${PCSX2_DIR}/Gif.cpp
        ${PCSX2_DIR}/Gif_Logger.cpp
        ${PCSX2_DIR}/Gif_Unit.cpp
        ${PCSX2_DIR}/GS.cpp
        ${PCSX2_DIR}/GSDumpReplayer.cpp
        ${PCSX2_DIR}/Host.cpp
        ${PCSX2_DIR}/Hotkeys.cpp
        ${PCSX2_DIR}/Hw.cpp
        ${PCSX2_DIR}/HwRead.cpp
        ${PCSX2_DIR}/HwWrite.cpp
        ${PCSX2_DIR}/INISettingsInterface.cpp
        ${PCSX2_DIR}/Interpreter.cpp
        ${PCSX2_DIR}/IopBios.cpp
        ${PCSX2_DIR}/IopCounters.cpp
        ${PCSX2_DIR}/IopDma.cpp
        ${PCSX2_DIR}/IopGte.cpp
        ${PCSX2_DIR}/IopHw.cpp
        ${PCSX2_DIR}/IopIrq.cpp
        ${PCSX2_DIR}/IopMem.cpp
        # ${PCSX2_DIR}/IopModuleNames.cpp  # debug-only, macro expansion issues
        ${PCSX2_DIR}/LayeredSettingsInterface.cpp
        ${PCSX2_DIR}/Mdec.cpp
        ${PCSX2_DIR}/Memory.cpp
        ${PCSX2_DIR}/MMI.cpp
        ${PCSX2_DIR}/MTGS.cpp
        ${PCSX2_DIR}/MTVU.cpp
        ${PCSX2_DIR}/Patch.cpp
        ${PCSX2_DIR}/Pcsx2Config.cpp
        ${PCSX2_DIR}/PerformanceMetrics.cpp
        ${PCSX2_DIR}/PINE.cpp
        ${PCSX2_DIR}/R3000A.cpp
        ${PCSX2_DIR}/R3000AInterpreter.cpp
        ${PCSX2_DIR}/R3000AOpcodeTables.cpp
        ${PCSX2_DIR}/R5900.cpp
        ${PCSX2_DIR}/R5900OpcodeImpl.cpp
        ${PCSX2_DIR}/R5900OpcodeTables.cpp
        ${PCSX2_DIR}/SaveState.cpp
        ${PCSX2_DIR}/ShiftJisToUnicode.cpp
        ${PCSX2_DIR}/Sif.cpp
        ${PCSX2_DIR}/Sif0.cpp
        ${PCSX2_DIR}/Sif1.cpp
        ${PCSX2_DIR}/sif2.cpp
        ${PCSX2_DIR}/SourceLog.cpp
        ${PCSX2_DIR}/SPR.cpp
        ${PCSX2_DIR}/StateWrapper.cpp
        ${PCSX2_DIR}/Vif.cpp
        ${PCSX2_DIR}/Vif0_Dma.cpp
        ${PCSX2_DIR}/Vif1_Dma.cpp
        ${PCSX2_DIR}/Vif1_MFIFO.cpp
        ${PCSX2_DIR}/Vif_Codes.cpp
        ${PCSX2_DIR}/Vif_Transfer.cpp
        ${PCSX2_DIR}/Vif_Unpack.cpp
        ${PCSX2_DIR}/VMManager.cpp
        ${PCSX2_DIR}/vtlb.cpp
        ${PCSX2_DIR}/VU0.cpp
        ${PCSX2_DIR}/VU0micro.cpp
        ${PCSX2_DIR}/VU0microInterp.cpp
        ${PCSX2_DIR}/VU1micro.cpp
        ${PCSX2_DIR}/VU1microInterp.cpp
        ${PCSX2_DIR}/VUflags.cpp
        ${PCSX2_DIR}/VUmicro.cpp
        ${PCSX2_DIR}/VUmicroMem.cpp
        ${PCSX2_DIR}/VUops.cpp

        # ---- CDVD ----
        ${PCSX2_DIR}/CDVD/BlockdumpFileReader.cpp
        ${PCSX2_DIR}/CDVD/CDVD.cpp
        ${PCSX2_DIR}/CDVD/CDVDcommon.cpp
        ${PCSX2_DIR}/CDVD/CDVDdiscReader.cpp
        ${PCSX2_DIR}/CDVD/CDVDdiscThread.cpp
        ${PCSX2_DIR}/CDVD/CDVDisoReader.cpp
        ${PCSX2_DIR}/CDVD/ChdFileReader.cpp
        ${PCSX2_DIR}/CDVD/CsoFileReader.cpp
        ${PCSX2_DIR}/CDVD/FlatFileReader.cpp
        ${PCSX2_DIR}/CDVD/GzippedFileReader.cpp
        ${PCSX2_DIR}/CDVD/InputIsoFile.cpp
        ${PCSX2_DIR}/CDVD/IsoHasher.cpp
        ${PCSX2_DIR}/CDVD/IsoReader.cpp
        ${PCSX2_DIR}/CDVD/OutputIsoFile.cpp
        ${PCSX2_DIR}/CDVD/Ps1CD.cpp
        ${PCSX2_DIR}/CDVD/ThreadedFileReader.cpp

        # ---- SIO, SIO/Pad, SIO/Memcard, SIO/Multitap ----
        ${PCSX2_DIR}/SIO/Sio.cpp
        ${PCSX2_DIR}/SIO/Sio0.cpp
        ${PCSX2_DIR}/SIO/Sio2.cpp
        ${PCSX2_DIR}/SIO/Memcard/MemoryCardFile.cpp
        # ${PCSX2_DIR}/SIO/Memcard/MemoryCardFolder.cpp  # needs ryml — excluded for bringup
        ${PCSX2_DIR}/SIO/Memcard/MemoryCardProtocol.cpp
        ${PCSX2_DIR}/SIO/Multitap/MultitapProtocol.cpp
        ${PCSX2_DIR}/SIO/Pad/Pad.cpp
        ${PCSX2_DIR}/SIO/Pad/PadBase.cpp
        ${PCSX2_DIR}/SIO/Pad/PadDualshock2.cpp
        ${PCSX2_DIR}/SIO/Pad/PadGuitar.cpp
        ${PCSX2_DIR}/SIO/Pad/PadJogcon.cpp
        ${PCSX2_DIR}/SIO/Pad/PadNegcon.cpp
        ${PCSX2_DIR}/SIO/Pad/PadNotConnected.cpp
        ${PCSX2_DIR}/SIO/Pad/PadPopn.cpp

        # ---- GS Core ----
        ${PCSX2_DIR}/GS/GS.cpp
        ${PCSX2_DIR}/GS/GSBlock.cpp
        ${PCSX2_DIR}/GS/GSCapture.cpp
        ${PCSX2_DIR}/GS/GSClut.cpp
        ${PCSX2_DIR}/GS/GSDrawingContext.cpp
        ${PCSX2_DIR}/GS/GSDrawingEnvironment.cpp
        ${PCSX2_DIR}/GS/GSDump.cpp
        ${PCSX2_DIR}/GS/GSLocalMemory.cpp
        ${PCSX2_DIR}/GS/GSLocalMemoryMultiISA.cpp
        ${PCSX2_DIR}/GS/GSLzma.cpp
        ${PCSX2_DIR}/GS/GSPerfMon.cpp
        ${PCSX2_DIR}/GS/GSPng.cpp
        ${PCSX2_DIR}/GS/GSRingHeap.cpp
        ${PCSX2_DIR}/GS/GSState.cpp
        ${PCSX2_DIR}/GS/GSTables.cpp
        ${PCSX2_DIR}/GS/GSUtil.cpp
        ${PCSX2_DIR}/GS/GSVector.cpp
        ${PCSX2_DIR}/GS/GSXXH.cpp
        ${PCSX2_DIR}/GS/MultiISA.cpp

        # ---- GS/Renderers/Common ----
        ${PCSX2_DIR}/GS/Renderers/Common/GSDevice.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSDirtyRect.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSFunctionMap.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSRenderer.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSTexture.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSVertexTrace.cpp
        ${PCSX2_DIR}/GS/Renderers/Common/GSVertexTraceFMM.cpp

        # ---- GS/Renderers/Null ----
        ${PCSX2_DIR}/GS/Renderers/Null/GSRendererNull.cpp

        # ---- GS/Renderers/HW ----
        ${PCSX2_DIR}/GS/Renderers/HW/GSHwHack.cpp
        ${PCSX2_DIR}/GS/Renderers/HW/GSRendererHW.cpp
        ${PCSX2_DIR}/GS/Renderers/HW/GSRendererHWMultiISA.cpp
        ${PCSX2_DIR}/GS/Renderers/HW/GSTextureCache.cpp
        ${PCSX2_DIR}/GS/Renderers/HW/GSTextureReplacementLoaders.cpp
        ${PCSX2_DIR}/GS/Renderers/HW/GSTextureReplacements.cpp

        # ---- GS/Renderers/SW ----
        # ${PCSX2_DIR}/GS/Renderers/SW/GSDrawScanline.cpp — excluded on iOS (pulls in vixl JIT)
        # GSDrawScanlineCodeGenerator.arm64.cpp — excluded on iOS (pulls in vixl JIT)
        ${PCSX2_DIR}/GS/Renderers/SW/GSRasterizer.cpp
        ${PCSX2_DIR}/GS/Renderers/SW/GSRendererSW.cpp
        # GSSetupPrimCodeGenerator.arm64.cpp — excluded on iOS (pulls in vixl JIT)
        ${PCSX2_DIR}/GS/Renderers/SW/GSTextureCacheSW.cpp

        # ---- IPU ----
        ${PCSX2_DIR}/IPU/IPU.cpp
        ${PCSX2_DIR}/IPU/IPU_Fifo.cpp
        ${PCSX2_DIR}/IPU/IPU_MultiISA.cpp
        ${PCSX2_DIR}/IPU/IPUdither.cpp
        ${PCSX2_DIR}/IPU/IPUdma.cpp
        ${PCSX2_DIR}/IPU/yuv2rgb.cpp

        # ---- DebugTools ----
        ${PCSX2_DIR}/DebugTools/BiosDebugData.cpp
        ${PCSX2_DIR}/DebugTools/Breakpoints.cpp
        ${PCSX2_DIR}/DebugTools/DebugInterface.cpp
        ${PCSX2_DIR}/DebugTools/DisR3000A.cpp
        ${PCSX2_DIR}/DebugTools/DisR5900asm.cpp
        ${PCSX2_DIR}/DebugTools/DisVU0Micro.cpp
        ${PCSX2_DIR}/DebugTools/DisVU1Micro.cpp
        ${PCSX2_DIR}/DebugTools/DisassemblyManager.cpp
        ${PCSX2_DIR}/DebugTools/ExpressionParser.cpp
        ${PCSX2_DIR}/DebugTools/MIPSAnalyst.cpp
        ${PCSX2_DIR}/DebugTools/MipsAssembler.cpp
        ${PCSX2_DIR}/DebugTools/MipsAssemblerTables.cpp
        ${PCSX2_DIR}/DebugTools/MipsStackWalk.cpp
        ${PCSX2_DIR}/DebugTools/SymbolGuardian.cpp
        ${PCSX2_DIR}/DebugTools/SymbolImporter.cpp

        # ---- ccc (debug symbol parsing, used by DebugTools) ----
        pcsx2/3rdparty/ccc/src/ccc/ast.cpp
        pcsx2/3rdparty/ccc/src/ccc/elf.cpp
        pcsx2/3rdparty/ccc/src/ccc/elf_symtab.cpp
        pcsx2/3rdparty/ccc/src/ccc/importer_flags.cpp
        pcsx2/3rdparty/ccc/src/ccc/mdebug_analysis.cpp
        pcsx2/3rdparty/ccc/src/ccc/mdebug_importer.cpp
        pcsx2/3rdparty/ccc/src/ccc/mdebug_section.cpp
        pcsx2/3rdparty/ccc/src/ccc/mdebug_symbols.cpp
        pcsx2/3rdparty/ccc/src/ccc/sndll.cpp
        pcsx2/3rdparty/ccc/src/ccc/stabs.cpp
        pcsx2/3rdparty/ccc/src/ccc/stabs_to_ast.cpp
        pcsx2/3rdparty/ccc/src/ccc/symbol_database.cpp
        pcsx2/3rdparty/ccc/src/ccc/symbol_file.cpp
        pcsx2/3rdparty/ccc/src/ccc/symbol_table.cpp
        pcsx2/3rdparty/ccc/src/ccc/util.cpp

        # ---- Recording ----
        ${PCSX2_DIR}/Recording/InputRecording.cpp
        ${PCSX2_DIR}/Recording/InputRecordingControls.cpp
        ${PCSX2_DIR}/Recording/InputRecordingFile.cpp
        ${PCSX2_DIR}/Recording/PadData.cpp
        ${PCSX2_DIR}/Recording/Utilities/InputRecordingLogger.cpp

        # ---- Host ----
        ${PCSX2_DIR}/Host/AudioStream.cpp
        # CubebAudioStream.cpp — excluded on iOS (uses macOS CoreAudio)

        # ---- ImGui ----
        ${PCSX2_DIR}/ImGui/FullscreenUI.cpp
        # FullscreenUI_Settings.cpp excluded — includes DEV9/pcap_io.h and USB/USB.h unconditionally
        ${PCSX2_DIR}/ImGui/ImGuiFullscreen.cpp
        ${PCSX2_DIR}/ImGui/ImGuiManager.cpp
        ${PCSX2_DIR}/ImGui/ImGuiOverlays.cpp

        # ---- Input ----
        ${PCSX2_DIR}/Input/InputManager.cpp
        ${PCSX2_DIR}/Input/InputSource.cpp

        # ---- PS2 ----
        ${PCSX2_DIR}/ps2/BiosTools.cpp
        ${PCSX2_DIR}/ps2/Iop/IopHwRead.cpp
        ${PCSX2_DIR}/ps2/Iop/IopHwWrite.cpp
        ${PCSX2_DIR}/ps2/Iop/PsxBios.cpp
        ${PCSX2_DIR}/ps2/pgif.cpp

        # ---- DEV9 — excluded on iOS per Phase 14 (Audit Sec 1.2 RED) ----

        # ---- USB — excluded entirely on iOS (needs SDL/libjpeg, not needed for bringup) ----

        # ---- RDebug — excluded on iOS (debug tools, needs IopBios2.h, Threading, psxRegs) ----
    )

    # Phase 0-E: SPU2 internal files
    set(PCSX2_SPU2_SOURCES
        ${PCSX2_DIR}/SPU2/spu2.cpp
        ${PCSX2_DIR}/SPU2/spu2sys.cpp
        ${PCSX2_DIR}/SPU2/spu2freeze.cpp
        ${PCSX2_DIR}/SPU2/ADSR.cpp
        ${PCSX2_DIR}/SPU2/Dma.cpp
        ${PCSX2_DIR}/SPU2/Mixer.cpp
        ${PCSX2_DIR}/SPU2/ReadInput.cpp
        ${PCSX2_DIR}/SPU2/RegTable.cpp
        ${PCSX2_DIR}/SPU2/Reverb.cpp
        ${PCSX2_DIR}/SPU2/ReverbResample.cpp
        ${PCSX2_DIR}/SPU2/Debug.cpp
        ${PCSX2_DIR}/SPU2/Wavedump_wav.cpp
    )

    # Phase 0-D: LnxHostSys for iOS (DarwinMisc excluded — uses macOS-only
    # CoreGraphics/IOKit; our PageFaultHandler.cpp handles Mach exceptions)
    set(PCSX2_PLATFORM_SOURCES
        ${COMMON_DIR}/Linux/LnxHostSys.cpp     # SharedMemoryMappingArea (has __APPLE__ guards)
    )

    # Phase 0-A, 0-F: iOS platform layer
    set(IOS_PLATFORM_SOURCES
        ios/platform/iOSVMManager.mm
        ios/platform/HostSys_iOS.cpp
        ios/platform/Host_iOS.mm
        ios/platform/CocoaTools_iOS.mm
        ios/platform/AudioStream_iOS.mm
        ios/platform/Filesystem_iOS.mm
        ios/platform/PCSX2Stubs.cpp
        ios/platform/Threading_iOS.cpp
        ios/platform/PageFaultHandler.cpp
        ios/platform/Image_iOS.cpp
        ios/platform/iOSHost.mm
        ios/ui/BionicSX2Bridge.mm
    )

    set(IOS_SWIFT_SOURCES
        ios/ui/BionicSX2App.swift
        ios/ui/ContentView.swift
        ios/ui/MetalViewController.swift
        ios/ui/GameControllerManager.swift
    )

    # iOS app entry point (Phase 0-A: _main symbol)
    set(IOS_APP_SOURCES
        ios/ui/main.mm
        ios/ui/AppDelegate.mm
        ios/platform/AppStubs.mm
        ios/platform/MissingSymbols.mm
        ios/platform/GSDrawScanlineStub.s
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

    foreach(SRC_FILE ${PCSX2_CORE_SOURCES} ${PCSX2_SPU2_SOURCES} ${PCSX2_PLATFORM_SOURCES} ${IOS_PLATFORM_SOURCES} ${IOS_METAL_SOURCES})
      if(NOT EXISTS "${SRC_FILE}")
        message(STATUS "MISSING SOURCE: ${SRC_FILE}")
      endif()
    endforeach()

    add_library(BionicSX2 STATIC
        ${PCSX2_CORE_SOURCES}
        ${PCSX2_SPU2_SOURCES}
        ${PCSX2_PLATFORM_SOURCES}
        ${IOS_PLATFORM_SOURCES}
        ${IOS_METAL_SOURCES}
    )

    # Log and fmt — add real sources only if submodule is populated
    if(EXISTS "${COMMON_DIR}/Log.cpp")
        target_sources(BionicSX2 PRIVATE ${COMMON_DIR}/Log.cpp)
    else()
        message(STATUS "MISSING SOURCE: ${COMMON_DIR}/Log.cpp")
    endif()

    set(FMT_SRC "${CMAKE_SOURCE_DIR}/pcsx2/3rdparty/fmt/src/format.cc")
    if(EXISTS "${FMT_SRC}")
        target_sources(BionicSX2 PRIVATE ${FMT_SRC})
        target_compile_definitions(BionicSX2 PRIVATE FMT_HEADER_ONLY=0)
    else()
        message(STATUS "MISSING SOURCE: ${FMT_SRC}")
    endif()

    add_executable(BionicSX2_App
        ${IOS_SWIFT_SOURCES}
        ${IOS_APP_SOURCES}
        pcsx2/3rdparty/fmt/src/format.cc
    )

    # NOTE: No LANGUAGE ASM property needed — CMake/Clang auto-detect .s files

    # Force-load the entire static lib — app .o files don't reference core symbols
    # so the linker would otherwise strip libBionicSX2.a to 85KB.
    target_link_libraries(BionicSX2_App PRIVATE
        -Wl,-force_load,$<TARGET_FILE:BionicSX2>
        "${IOS_DEPS}/lib/liblzma.a"
        "${IOS_DEPS}/lib/libzstd.a"
        "${IOS_DEPS}/lib/liblz4.a"
        "${IOS_DEPS}/lib/libzip.a"
        "${IOS_DEPS}/lib/libfreetype.a"
        "${IOS_DEPS}/lib/libpng.a"
        "${IOS_DEPS}/lib/libz.a"
        "${IOS_DEPS}/lib/libSoundTouch.a"
        "${IOS_DEPS}/lib/libchdr-static.a"
        "${IOS_DEPS}/lib/libchdr-lzma.a"
        "${IOS_DEPS}/lib/libcpuinfo.a"
        "${IOS_DEPS}/lib/librcheevos.a"
        "-framework Metal"
        "-framework UIKit"
        "-framework Foundation"
        "-framework AudioToolbox"
        "-framework AVFoundation"
        "-framework GameController"
        "-framework CoreMotion"
        "-framework QuartzCore"
        "-framework CoreGraphics"
    )

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

    # Explicitly mark pure C++ sources so -fobjc-arc doesn't affect name mangling
    set_source_files_properties(
        ios/platform/PCSX2Stubs.cpp
        PROPERTIES LANGUAGE CXX
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
        pcsx2/3rdparty/simpleini/include
        pcsx2/3rdparty/freesurround/include
        pcsx2/3rdparty/ccc/src
    )

    # freetype headers — built into ios-deps (Phase 3, Tier 3)
    # ft2build.h lives at <prefix>/include/freetype2/ft2build.h
    if(EXISTS "${IOS_DEPS}/include/freetype2")
        list(APPEND THIRDPARTY_INCLUDE_DIRS "${IOS_DEPS}/include/freetype2")
    endif()

    if(EXISTS "${IOS_DEPS}/include")
        target_include_directories(BionicSX2 PRIVATE "${IOS_DEPS}/include")
    endif()

    target_include_directories(BionicSX2 PRIVATE
        "${CMAKE_SOURCE_DIR}/generated"
        ios/platform
        ios/ui
        metal
        pcsx2              # for #include "common/xxx.h" and "pcsx2/xxx.h" style
        ${PCSX2_DIR}        # for direct #include "GS/xxx.h" style
        ${COMMON_DIR}       # for #include "Pcsx2Defs.h" without prefix
        ${THIRDPARTY_INCLUDE_DIRS}
    )

    # BionicSX2_App needs fmt headers (and other 3rdparty) for MissingSymbols.mm
    target_include_directories(BionicSX2_App PRIVATE
        ios/platform
        ${CMAKE_SOURCE_DIR}/3rdparty/fmt/include
        ${THIRDPARTY_INCLUDE_DIRS}
        $<$<BOOL:${IOS_DEPS}>:${IOS_DEPS}/include>
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
        ${PCSX2_DIR}/GS/Renderers/Metal/cas.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/convert.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/present.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/merge.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/misc.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/interlace.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/tfx.metal
        ${PCSX2_DIR}/GS/Renderers/Metal/fxaa.metal
    )

    # iOS app bundle settings
    set(CMAKE_MACOSX_BUNDLE YES)
    set(MACOSX_BUNDLE_GUI_IDENTIFIER com.bionicsx2.app)
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
