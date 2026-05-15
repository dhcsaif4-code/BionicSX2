// AUDIT REFERENCE: Section 4.3, 8.3, 8.4
// STATUS: NEW
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        iOSConfigureAudioSession()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MetalViewController()
        window?.makeKeyAndVisible()
        application.isIdleTimerDisabled = true

        GameControllerManager.shared.startMonitoring()

        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        NSLog("[BionicSX2] Memory pressure warning received")
    }
}
