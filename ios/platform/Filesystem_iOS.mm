// AUDIT REFERENCE: Section 6.4, 10.3
// STATUS: NEW
#import <Foundation/Foundation.h>
#include <string>

std::string iOSGetDocumentsDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths firstObject];
    return std::string([documents UTF8String]);
}

std::string iOSGetCachesDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
        NSCachesDirectory, NSUserDomainMask, YES);
    NSString *caches = [paths firstObject];
    return std::string([caches UTF8String]);
}

std::string iOSGetAppDataPath() {
    return iOSGetDocumentsDirectory();
}

std::string iOSGetBIOSPath() {
    return iOSGetDocumentsDirectory() + "/BIOS/";
}

std::string iOSGetMemcardPath() {
    return iOSGetDocumentsDirectory() + "/Memcards/";
}

std::string iOSGetGamesPath() {
    return iOSGetDocumentsDirectory() + "/Games/";
}
