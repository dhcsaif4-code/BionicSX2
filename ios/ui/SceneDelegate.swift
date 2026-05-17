import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)

        // Install on-screen log overlay before any UI
        LogOverlay.shared().install(in: window)
        LogOverlay.shared().addEntry("Window created", isError: false)

        window?.rootViewController = MetalViewController()
        window?.makeKeyAndVisible()
        LogOverlay.shared().addEntry("UI loaded", isError: false)

        iOSConfigureAudioSession()
        GameControllerManager.shared.startMonitoring()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        GameControllerManager.shared.stopMonitoring()
    }
}
