import UIKit

final class NightSocialStageShellController: UIViewController {
    private let loungeLane = NightSocialLoungeFloorController()
    private let waveLane = NightSocialWaveStageController()
    private let chimeLane = NightSocialChimeBoardController()
    private let smileLane = NightSocialDeskMirrorController()
    private let dock = NightSocialStageDock()
    private var litLane = 0

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.magentaPeak
        edgesForExtendedLayout = .all
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false

        let lanes = [loungeLane, waveLane, chimeLane, smileLane]
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

    private func showLane(_ index: Int) {
        litLane = index
        let lanes = [loungeLane.view, waveLane.view, chimeLane.view, smileLane.view]
        for (offset, lane) in lanes.enumerated() {
            lane?.isHidden = offset != index
        }
        view.bringSubviewToFront(dock)
        dock.lightLane(index)
    }
}
