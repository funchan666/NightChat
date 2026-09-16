import AuthenticationServices
import UIKit

final class AfterglowWelcomeGateController: NightSocialWashController {
    private var applePassage: NightSocialApplePassage?
    private var covenantBar: NightSocialCovenantBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        applePassage = NightSocialApplePassage(host: self)

        let mark = attachStageMark(edge: 92, topOffset: 148)
        let headline = attachHeadline("Welcome")
        let kicker = attachKicker("Live rooms. Night talk. New friends.")
        NSLayoutConstraint.activate([
            headline.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headline.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 16),
            kicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            kicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            kicker.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
        ])

        let accountReturn = SnowPillControl(spokenTitle: "Account login")
        let openEnrollment = FoyerStagePill(spokenTitle: "Create Account", kind: .frost)
        let appleEnter = FoyerStagePill(spokenTitle: "Sign in with Apple", kind: .apple, glyphName: "apple.logo")
        let spine = FoyerContinueSpine()

        accountReturn.addTarget(self, action: #selector(openReturnBoard), for: .touchUpInside)
        openEnrollment.addTarget(self, action: #selector(openEnrollmentBoard), for: .touchUpInside)
        appleEnter.addTarget(self, action: #selector(openApplePassage), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [accountReturn, openEnrollment, spine, appleEnter])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(18, after: openEnrollment)
        stack.setCustomSpacing(18, after: spine)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let covenantBar = NightSocialCovenantBar()
        bindHouseCovenant(covenantBar)
        view.addSubview(covenantBar)
        self.covenantBar = covenantBar

        NSLayoutConstraint.activate([
            covenantBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            covenantBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            covenantBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.bottomAnchor.constraint(equalTo: covenantBar.topAnchor, constant: -16),
        ])
    }

    @objc private func openReturnBoard() {
        guard let covenantBar, requireHouseCovenant(covenantBar) else { return }
        navigationController?.pushViewController(NightDeskReturnBoardController(), animated: true)
    }

    @objc private func openEnrollmentBoard() {
        guard let covenantBar, requireHouseCovenant(covenantBar) else { return }
        navigationController?.pushViewController(NightDeskEnrollmentBoardController(), animated: true)
    }

    @objc private func openApplePassage() {
        guard let covenantBar, requireHouseCovenant(covenantBar) else { return }
        applePassage?.requestPassage { [weak self] result in
            DispatchQueue.main.async {
                self?.finishApple(result)
            }
        }
    }

    private func finishApple(_ result: Result<NightSocialAppleOutcome, Error>) {
        switch result {
        case .failure(let error):
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return }
            FoyerNotice.present(
                on: self,
                spokenTitle: "Apple passage paused",
                spokenBody: "The night desk could not finish Sign in with Apple. Try the mailbox door, or try Apple again."
            )
        case .success(let outcome):
            NightSocialSessionDrawer.shared.beginApplePassage(
                appleIdentityToken: outcome.appleIdentityToken,
                stageSpokenName: outcome.stageSpokenName,
                mailboxAddress: outcome.mailboxAddress
            )
            if NightSocialSessionDrawer.shared.isSeatedAtLounge {
                AfterglowRootCoordinator.revealLoungeFloor(from: self)
            } else {
                navigationController?.pushViewController(
                    NightSocialDeskCardController(arrival: .applePassage),
                    animated: true
                )
            }
        }
    }
}
