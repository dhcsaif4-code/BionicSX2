import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Wrap entire function body to catch any exception
        do {
            LogOverlay.shared().addEntry("SceneDelegate: Step 1 — got willConnectToSession", isError: false)

            guard let windowScene = scene as? UIWindowScene else {
                LogOverlay.shared().addEntry("SceneDelegate FAILED: scene is not UIWindowScene", isError: true)
                return
            }
            LogOverlay.shared().addEntry("SceneDelegate: Step 2 — windowScene OK", isError: false)

            // Step 3: create window
            let w = UIWindow(windowScene: windowScene)
            LogOverlay.shared().addEntry("SceneDelegate: Step 3 — UIWindow created", isError: false)

            // Step 4: install on-screen log overlay
            LogOverlay.shared().install(in: w)
            LogOverlay.shared().addEntry("SceneDelegate: Step 4 — LogOverlay installed", isError: false)

            // Step 5: set root view controller
            let vc = MetalViewController()
            w.rootViewController = vc
            LogOverlay.shared().addEntry("SceneDelegate: Step 5 — root VC set (MetalViewController)", isError: false)

            // Step 6: make visible
            window = w
            w.makeKeyAndVisible()
            LogOverlay.shared().addEntry("SceneDelegate: Step 6 — window key and visible", isError: false)

            // Step 7: configure audio + controllers
            iOSConfigureAudioSession()
            LogOverlay.shared().addEntry("SceneDelegate: Step 7 — audio session configured", isError: false)

            GameControllerManager.shared.startMonitoring()
            LogOverlay.shared().addEntry("SceneDelegate: Step 8 — game controller monitoring started", isError: false)

            LogOverlay.shared().addEntry("SceneDelegate: all steps complete", isError: false)

        } catch {
            // NOTE: Swift do/catch catches Swift errors, not ObjC exceptions.
            // ObjC exceptions will hit NSSetUncaughtExceptionHandler instead.
            LogOverlay.shared().addEntry("SceneDelegate SWIFT ERROR: \(error)", isError: true)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        GameControllerManager.shared.stopMonitoring()
    }
}
