import UIKit

enum AfterglowRootCoordinator {
    static func applyChrome() {
        let bar = UINavigationBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = AfterHoursPalette.walnut
        bar.titleTextAttributes = [
            .foregroundColor: AfterHoursPalette.creamPaper,
            .font: AfterHoursType.sittingTitle(17),
        ]
        bar.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = bar
        UINavigationBar.appearance().scrollEdgeAppearance = bar
        UINavigationBar.appearance().compactAppearance = bar
        UINavigationBar.appearance().tintColor = AfterHoursPalette.brass

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = AfterHoursPalette.walnut
        tab.shadowColor = .clear
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = AfterHoursPalette.brass
        UITabBar.appearance().unselectedItemTintColor = AfterHoursPalette.teaStain
    }

    static func install(in window: UIWindow) {
        window.rootViewController = AfterglowLampClothController()
    }

    static func replaceRoot(in window: UIWindow, with next: UIViewController) {
        UIView.transition(with: window, duration: 0.32, options: .transitionCrossDissolve, animations: {
            window.rootViewController = next
        })
    }
}
