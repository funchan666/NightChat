import UIKit

final class NightSocialStageShellController: UIViewController, UINavigationControllerDelegate {
    private let loungeNav: UINavigationController = {
        let nav = UINavigationController(rootViewController: NightSocialLoungeFloorController())
        nav.setNavigationBarHidden(true, animated: false)
        nav.interactivePopGestureRecognizer?.isEnabled = true
        return nav
    }()
    private let waveNav: UINavigationController = {
        let nav = UINavigationController(rootViewController: NightSocialWaveStageController())
        nav.setNavigationBarHidden(true, animated: false)
        nav.interactivePopGestureRecognizer?.isEnabled = true
        return nav
    }()
    private let chimeNav: UINavigationController = {
        let nav = UINavigationController(rootViewController: NightSocialChimeBoardController())
        nav.setNavigationBarHidden(true, animated: false)
        nav.interactivePopGestureRecognizer?.isEnabled = true
        return nav
    }()
    private let smileNav: UINavigationController = {
        let nav = UINavigationController(rootViewController: NightSocialDeskMirrorController())
        nav.setNavigationBarHidden(true, animated: false)
        nav.interactivePopGestureRecognizer?.isEnabled = true
        return nav
    }()
    private let dock = NightSocialStageDock()
    private var litLane = 0

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var childForStatusBarStyle: UIViewController? {
        visibleLane()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        edgesForExtendedLayout = .all
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        loungeNav.delegate = self
        waveNav.delegate = self
        chimeNav.delegate = self
        smileNav.delegate = self

        let lanes: [UIViewController] = [loungeNav, waveNav, chimeNav, smileNav]
        for lane in lanes {
            addChild(lane)
            lane.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(lane.view)
            NSLayoutConstraint.activate([
                lane.view.topAnchor.constraint(equalTo: view.topAnchor),
                lane.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                lane.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                lane.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            lane.didMove(toParent: self)
        }

        dock.onPickLane = { [weak self] index in
            self?.showLane(index)
        }
        view.addSubview(dock)
        NSLayoutConstraint.activate([
            dock.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dock.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dock.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        showLane(0)
    }

    private func visibleLane() -> UIViewController {
        [loungeNav, waveNav, chimeNav, smileNav][litLane]
    }

    private func visibleNav() -> UINavigationController? {
        if litLane == 0 { return loungeNav }
        if litLane == 1 { return waveNav }
        if litLane == 2 { return chimeNav }
        if litLane == 3 { return smileNav }
        return nil
    }

    private func showLane(_ index: Int) {
        litLane = index
        let lanes = [loungeNav.view, waveNav.view, chimeNav.view, smileNav.view]
        for (offset, lane) in lanes.enumerated() {
            lane?.isHidden = offset != index
        }
        view.bringSubviewToFront(dock)
        dock.lightLane(index)
        dock.isHidden = (visibleNav()?.viewControllers.count ?? 1) > 1
        setNeedsStatusBarAppearanceUpdate()
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        dock.isHidden = navigationController.viewControllers.count > 1
        if !dock.isHidden {
            view.bringSubviewToFront(dock)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}
