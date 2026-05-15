# AUDIT REFERENCE: Section 10.1 — Zstd target needed by libzip
# Creates the Zstd::Zstd target that pcsx2/3rdparty/libzip expects.
# zstd cmake config uses zstd::libzstd_static; this binds to Zstd::Zstd.

find_path(Zstd_INCLUDE_DIR NAMES zstd.h PATHS "${CMAKE_PREFIX_PATH}/include" NO_DEFAULT_PATH)
find_library(Zstd_LIBRARY NAMES zstd libzstd_static zstd_static PATHS "${CMAKE_PREFIX_PATH}/lib" NO_DEFAULT_PATH)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Zstd DEFAULT_MSG Zstd_LIBRARY Zstd_INCLUDE_DIR)

if(Zstd_FOUND AND NOT TARGET Zstd::Zstd)
    add_library(Zstd::Zstd STATIC IMPORTED)
    set_target_properties(Zstd::Zstd PROPERTIES
        IMPORTED_LOCATION "${Zstd_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Zstd_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(Zstd_INCLUDE_DIR Zstd_LIBRARY)
