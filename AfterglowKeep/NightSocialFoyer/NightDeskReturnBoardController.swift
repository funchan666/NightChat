import UIKit

final class NightDeskReturnBoardController: NightSocialWashController, UITextFieldDelegate {
    private let mailboxField = FoyerInkField(whisper: "Please enter your email", glyphName: "envelope")
    private let secretField = FoyerInkField(whisper: "Please enter your Password", glyphName: "lock")
    private let scroller = UIScrollView()
    private let enter = MidnightPillControl(spokenTitle: "Start")
    private let covenantBar = NightSocialCovenantBar()
    private let kindleOrbit = MidnightKindleOrbit()
    private var isOpeningDesk = false

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
        headline.text = "Login"
        headline.textColor = AfterHoursPalette.titleSnow
        headline.font = AfterHoursType.foyerHeadline(34)
        headline.textAlignment = .center
        headline.translatesAutoresizingMaskIntoConstraints = false

        let kicker = UILabel()
        kicker.text = "Welcome back to the night desk."
        kicker.textColor = UIColor.white.withAlphaComponent(0.82)
        kicker.font = AfterHoursType.foyerBody(15)
        kicker.textAlignment = .center
        kicker.translatesAutoresizingMaskIntoConstraints = false

        mailboxField.keyboardType = .emailAddress
        mailboxField.textContentType = .username
        mailboxField.delegate = self
        secretField.isSecureTextEntry = true
        secretField.textContentType = .password
        secretField.delegate = self
        secretField.returnKeyType = .go

        let cluster = FoyerCredentialCluster(rows: [mailboxField, secretField])
        enter.addTarget(self, action: #selector(attemptReturn), for: .touchUpInside)
        enter.addSubview(kindleOrbit)
        kindleOrbit.isHidden = true
        NSLayoutConstraint.activate([
            kindleOrbit.centerXAnchor.constraint(equalTo: enter.centerXAnchor),
            kindleOrbit.centerYAnchor.constraint(equalTo: enter.centerYAnchor),
        ])

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
            cluster.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 28),

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

        NotificationCenter.default.addObserver(self, selector: #selector(liftForKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeFooter() -> UIView {
        let wrap = UIButton(type: .system)
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let spoken = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [
                .foregroundColor: AfterHoursPalette.footerSnow,
                .font: AfterHoursType.foyerBody(14),
            ]
        )
        spoken.append(NSAttributedString(
            string: "Sign up  ›",
            attributes: [
                .foregroundColor: AfterHoursPalette.titleSnow,
                .font: AfterHoursType.foyerBody(14, weight: .semibold),
            ]
        ))
        wrap.setAttributedTitle(spoken, for: .normal)
        wrap.addTarget(self, action: #selector(jumpEnrollment), for: .touchUpInside)
        return wrap
    }

    @objc private func jumpEnrollment() {
        navigationController?.pushViewController(NightDeskEnrollmentBoardController(), animated: true)
    }

    @objc private func attemptReturn() {
        foldKeyboard()
        guard !isOpeningDesk else { return }
        guard requireHouseCovenant(covenantBar) else { return }

        let mailbox = NightSocialFoyerGuard.trimmed(mailboxField.text)
        let secret = secretField.text ?? ""
        if mailbox.isEmpty || secret.isEmpty {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Mailbox still empty",
                spokenBody: "Write the mailbox and secret for this night desk before you step in."
            )
            return
        }
        if !NightSocialFoyerGuard.mailboxLooksValid(mailbox) {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Mailbox looks unfinished",
                spokenBody: "Use a full mailbox address before this desk can open."
            )
            return
        }

        igniteLoginKindle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.finishReturn(mailbox: mailbox, secret: secret)
        }
    }

    private func igniteLoginKindle() {
        isOpeningDesk = true
        enter.isUserInteractionEnabled = false
        enter.setTitle("", for: .normal)
        kindleOrbit.igniteKindle()
    }

    private func quenchLoginKindle() {
        isOpeningDesk = false
        enter.isUserInteractionEnabled = true
        enter.setTitle("Start", for: .normal)
        kindleOrbit.quenchKindle()
    }

    private func finishReturn(mailbox: String, secret: String) {
        guard NightSocialSessionDrawer.shared.attemptReturn(mailboxAddress: mailbox, deskSecret: secret) else {
            quenchLoginKindle()
            FoyerNotice.present(
                on: self,
                spokenTitle: "Desk did not open",
                spokenBody: "No night desk matches that mailbox and secret yet. Create an account from the foyer, or check the spelling."
            )
            return
        }
        quenchLoginKindle()
        if NightSocialSessionDrawer.shared.isSeatedAtLounge
            || NightSocialSessionDrawer.shared.restoredSession()?.deskCardCompleted == true {
            NightSocialSessionDrawer.shared.markSeatedAfterReturn()
            AfterglowRootCoordinator.revealLoungeFloor(from: self)
        } else {
            navigationController?.pushViewController(
                NightSocialDeskCardController(arrival: .mailboxEnrollment),
                animated: true
            )
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === mailboxField {
            secretField.becomeFirstResponder()
        } else {
            attemptReturn()
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
