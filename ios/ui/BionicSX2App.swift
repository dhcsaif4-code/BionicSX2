// AUDIT REFERENCE: Section 4.3, 8.3, 8.4
// STATUS: NEW
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        iOSConfigureAudioSession()
        application.isIdleTimerDisabled = true
        return true
    }

    // MARK: UISceneSession lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration",
                             sessionRole: connectingSceneSession.role)
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        NSLog("[BionicSX2] Memory pressure warning received")
    }
}
