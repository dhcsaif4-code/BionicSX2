# AUDIT REFERENCE: Section 8.3, 13.5
find_library(GameController_LIBRARY GameController)
find_path(GameController_INCLUDE_DIR GameController/GameController.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GameController DEFAULT_MSG
    GameController_LIBRARY GameController_INCLUDE_DIR)
set(GameController_LIBRARIES ${GameController_LIBRARY})
set(GameController_INCLUDE_DIRS ${GameController_INCLUDE_DIR})
