# AUDIT REFERENCE: Section 13.5
find_library(UIKit_LIBRARY UIKit)
find_path(UIKit_INCLUDE_DIR UIKit/UIKit.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(UIKit DEFAULT_MSG
    UIKit_LIBRARY UIKit_INCLUDE_DIR)
set(UIKit_LIBRARIES ${UIKit_LIBRARY})
set(UIKit_INCLUDE_DIRS ${UIKit_INCLUDE_DIR})
