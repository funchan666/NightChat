import UIKit

final class AfterglowLampClothController: NightSocialWashController {
    private var didAdvance = false
    private let emberPulse = NeonAfterglowDotPulse()

    override func viewDidLoad() {
        super.viewDidLoad()
        let mark = attachCenteredStageMark(edge: 96)
        view.addSubview(emberPulse)
        NSLayoutConstraint.activate([
            emberPulse.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emberPulse.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 22),
        ])
        emberPulse.ignitePulse()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAdvance else { return }
        didAdvance = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) { [weak self] in
            AfterglowRootCoordinator.advanceFromLaunchCloth(in: self?.view.window)
        }
    }
}
