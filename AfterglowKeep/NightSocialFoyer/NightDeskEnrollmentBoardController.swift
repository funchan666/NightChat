import UIKit

final class NightDeskEnrollmentBoardController: NightSocialWashController, UITextFieldDelegate {
    private let spokenNameField = FoyerInkField(whisper: "Please enter your name", glyphName: "person")
    private let mailboxField = FoyerInkField(whisper: "Please enter your email", glyphName: "envelope")
    private let secretField = FoyerInkField(whisper: "Please enter your Password", glyphName: "lock")
    private let scroller = UIScrollView()
    private var covenantBar: NightSocialCovenantBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.alwaysBounceVertical = true
        scroller.keyboardDismissMode = .onDrag
        scroller.insetsLayoutMarginsFromSafeArea = false
        scroller.contentInsetAdjustmentBehavior = .never
        view.addSubview(scroller)
        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let mark = UIImageView(image: NightSocialImageCabinet.stageMark)
        mark.contentMode = .scaleAspectFit
        mark.layer.cornerRadius = 20
        mark.clipsToBounds = true
        mark.translatesAutoresizingMaskIntoConstraints = false

        let headline = UILabel()
        headline.text = "Sign Up"
        headline.textColor = AfterHoursPalette.titleSnow
        headline.font = AfterHoursType.foyerHeadline(34)
        headline.textAlignment = .center
        headline.clipsToBounds = false
        headline.translatesAutoresizingMaskIntoConstraints = false

        let kicker = UILabel()
        kicker.text = "A name, a mailbox, and a secret."
        kicker.textColor = UIColor.white.withAlphaComponent(0.82)
        kicker.font = AfterHoursType.foyerBody(15)
        kicker.textAlignment = .center
        kicker.translatesAutoresizingMaskIntoConstraints = false

        spokenNameField.autocapitalizationType = .words
        spokenNameField.textContentType = .name
        spokenNameField.delegate = self
        mailboxField.keyboardType = .emailAddress
        mailboxField.textContentType = .username
        mailboxField.delegate = self
        secretField.isSecureTextEntry = true
        secretField.textContentType = .newPassword
        secretField.delegate = self
        secretField.returnKeyType = .go

        let cluster = FoyerCredentialCluster(rows: [spokenNameField, mailboxField, secretField])
        let enter = MidnightPillControl(spokenTitle: "Sign up")
        enter.addTarget(self, action: #selector(beginEnrollment), for: .touchUpInside)
        let covenantBar = NightSocialCovenantBar()
        bindHouseCovenant(covenantBar)
        let footer = makeFooter()

        scroller.addSubview(mark)
        scroller.addSubview(headline)
        scroller.addSubview(kicker)
        scroller.addSubview(cluster)
        view.addSubview(enter)
        view.addSubview(covenantBar)
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            mark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mark.topAnchor.constraint(equalTo: scroller.topAnchor, constant: 118),
            mark.widthAnchor.constraint(equalToConstant: 78),
            mark.heightAnchor.constraint(equalToConstant: 78),

            headline.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headline.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 16),
            kicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            kicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            kicker.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),

            cluster.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            cluster.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            cluster.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 24),

            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),

            covenantBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            covenantBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            covenantBar.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -12),

            enter.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            enter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            enter.bottomAnchor.constraint(equalTo: covenantBar.topAnchor, constant: -14),

            scroller.contentLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: cluster.bottomAnchor, constant: 220),
        ])
        attachFoyerBackControl(action: #selector(foldTowardFoyer))
        self.covenantBar = covenantBar

        NotificationCenter.default.addObserver(self, selector: #selector(liftForKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeFooter() -> UIView {
        let wrap = UIButton(type: .system)
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let spoken = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [
                .foregroundColor: AfterHoursPalette.footerSnow,
                .font: AfterHoursType.foyerBody(14),
            ]
        )
        spoken.append(NSAttributedString(
            string: "Log in  ›",
            attributes: [
                .foregroundColor: AfterHoursPalette.titleSnow,
                .font: AfterHoursType.foyerBody(14, weight: .semibold),
            ]
        ))
        wrap.setAttributedTitle(spoken, for: .normal)
        wrap.addTarget(self, action: #selector(jumpReturn), for: .touchUpInside)
        return wrap
    }

    @objc private func jumpReturn() {
        if let existing = navigationController?.viewControllers.first(where: { $0 is NightDeskReturnBoardController }) {
            navigationController?.popToViewController(existing, animated: true)
        } else {
            navigationController?.pushViewController(NightDeskReturnBoardController(), animated: true)
        }
    }

    @objc private func beginEnrollment() {
        foldKeyboard()
        guard let covenantBar, requireHouseCovenant(covenantBar) else { return }
        let spoken = NightSocialFoyerGuard.trimmed(spokenNameField.text)
        let mailbox = NightSocialFoyerGuard.trimmed(mailboxField.text)
        let secret = secretField.text ?? ""
        if spoken.isEmpty || mailbox.isEmpty || secret.isEmpty {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Enrollment still open",
                spokenBody: "Give this night desk a name, a mailbox, and a secret before you sign up."
            )
            return
        }
        if !NightSocialFoyerGuard.mailboxLooksValid(mailbox) {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Mailbox looks unfinished",
                spokenBody: "Use a full mailbox address before this desk can be opened."
            )
            return
        }
        if !NightSocialFoyerGuard.secretLooksValid(secret) {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Secret is too short",
                spokenBody: "Use at least six characters for the desk secret."
            )
            return
        }
        NightSocialSessionDrawer.shared.beginEnrollment(
            stageSpokenName: spoken,
            mailboxAddress: mailbox,
            deskSecret: secret
        )
        navigationController?.pushViewController(
            NightSocialDeskCardController(arrival: .mailboxEnrollment),
            animated: true
        )
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === spokenNameField {
            mailboxField.becomeFirstResponder()
        } else if textField === mailboxField {
            secretField.becomeFirstResponder()
        } else {
            beginEnrollment()
        }
        return true
    }

    @objc private func liftForKeyboard(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = view.convert(frame, from: nil).intersection(view.bounds).height
        scroller.contentInset.bottom = overlap
        scroller.verticalScrollIndicatorInsets.bottom = overlap
    }
}
