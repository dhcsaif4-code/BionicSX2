import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Swift do/catch does NOT catch ObjC exceptions — those go to the
        // NSSetUncaughtExceptionHandler installed by BXSX2InstallCrashHandlers().
        do {
            LogOverlay.shared().addEntry("SceneDelegate — willConnectToSession fired", isError: false)
            LogOverlay.shared().addEntry("Scene — checking Info.plist config", isError: false)
            LogOverlay.shared().addEntry("Scene — getting window scene", isError: false)

            guard let windowScene = scene as? UIWindowScene else {
                LogOverlay.shared().addEntry("SceneDelegate FAILED: scene is not UIWindowScene", isError: true)
                return
            }
            LogOverlay.shared().addEntry("Scene — creating UIWindow", isError: false)

            let w = UIWindow(windowScene: windowScene)
            LogOverlay.shared().addEntry("Scene — window frame: \(Int(w.bounds.size.width))x\(Int(w.bounds.size.height))", isError: false)

            LogOverlay.shared().addEntry("Scene — creating rootViewController", isError: false)
            let vc = MetalViewController()

            LogOverlay.shared().addEntry("Scene — setting rootViewController", isError: false)
            w.rootViewController = vc

            window = w
            LogOverlay.shared().addEntry("Scene — makeKeyAndVisible", isError: false)
            w.makeKeyAndVisible()

            LogOverlay.shared().installInWindow(w)
            LogOverlay.shared().addEntry("Scene — DONE", isError: false)

        } catch {
            // Catches Swift Throwable errors (rare in UIKit); ObjC exceptions
            // are handled by the global uncaught exception handler.
            LogOverlay.shared().addEntry("SceneDelegate EXCEPTION: \(error)", isError: true)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        GameControllerManager.shared.stopMonitoring()
    }
}
