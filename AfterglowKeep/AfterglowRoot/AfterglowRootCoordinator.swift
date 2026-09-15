import UIKit

enum AfterglowRootCoordinator {
    static func applyChrome() {
        let bar = UINavigationBarAppearance()
        bar.configureWithTransparentBackground()
        bar.backgroundColor = .clear
        bar.shadowColor = .clear
        bar.titleTextAttributes = [
            .foregroundColor: AfterHoursPalette.titleSnow,
            .font: AfterHoursType.foyerPill(17),
        ]
        UINavigationBar.appearance().standardAppearance = bar
        UINavigationBar.appearance().scrollEdgeAppearance = bar
        UINavigationBar.appearance().compactAppearance = bar
        UINavigationBar.appearance().tintColor = AfterHoursPalette.titleSnow
        UIBarButtonItem.appearance().tintColor = AfterHoursPalette.titleSnow
    }

    static func install(in window: UIWindow) {
        NightSocialSessionDrawer.shared.openDrawer()
        window.backgroundColor = AfterHoursPalette.magentaPeak
        window.rootViewController = AfterglowLampClothController()
    }

    static func advanceFromLaunchCloth(in window: UIWindow? = nil) {
        guard let window = window ?? keyWindow() else { return }
        let session = NightSocialSessionDrawer.shared.restoredSession()
        let next: UIViewController
        if NightSocialSessionDrawer.shared.isSeatedAtLounge {
            next = NightSocialStageShellController()
        } else if let session {
            next = wrapped(NightSocialDeskCardController(arrival: .fromSession(session)))
        } else {
            next = wrapped(AfterglowWelcomeGateController())
        }
        replaceRoot(in: window, with: next)
    }

    static func revealLoungeFloor(from host: UIViewController? = nil) {
        guard let window = host?.view.window ?? keyWindow() else { return }
        replaceRoot(in: window, with: NightSocialStageShellController())
    }

    static func replaceRoot(in window: UIWindow, with next: UIViewController) {
        UIView.transition(with: window, duration: 0.32, options: .transitionCrossDissolve, animations: {
            window.rootViewController = next
        })
    }

    private static func wrapped(_ root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)
        nav.interactivePopGestureRecognizer?.isEnabled = true
        return nav
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}
