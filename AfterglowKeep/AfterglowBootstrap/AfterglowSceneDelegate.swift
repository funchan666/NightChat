import UIKit

final class AfterglowSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = AfterHoursPalette.magentaPeak
        AfterglowRootCoordinator.install(in: window)
        self.window = window
        window.makeKeyAndVisible()
    }
}
