// AUDIT REFERENCE: Section 4.3, 8.3, 8.4
// STATUS: NEW
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BXSX2InstallCrashHandlers()
        LogOverlay.shared().addEntry("App launched — Swift @main AppDelegate", isError: false)

        LogOverlay.shared().addEntry("Step 1 — crash handlers + LogOverlay initialized", isError: false)
        LogOverlay.shared().addEntry("Step 2 — configuring audio session", isError: false)
        iOSConfigureAudioSession()
        LogOverlay.shared().addEntry("Step 3 — audio session OK", isError: false)

        application.isIdleTimerDisabled = true
        LogOverlay.shared().addEntry("Step 4 — idle timer disabled", isError: false)

        LogOverlay.shared().addEntry("Step 5 — returning YES, scene creation begins", isError: false)
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        LogOverlay.shared().addEntry("Scene configuration requested", isError: false)
        return UISceneConfiguration(name: "Default Configuration",
                                     sessionRole: connectingSceneSession.role)
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        NSLog("[BionicSX2] Memory pressure warning received")
    }
}
