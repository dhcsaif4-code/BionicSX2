// AUDIT REFERENCE: Section 2.3-ADDENDUM, 6.2, 12.2
// STATUS: NEW — Header for iOSVMManager
#pragma once

namespace iOSVMManager {
    bool StartVM(const char* isoPath = nullptr);
    void StopVM();
}
