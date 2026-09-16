import UIKit

enum NightSocialLampNotices {
    static func presentReportSettled(from host: UIViewController, then fold: (() -> Void)? = nil) {
        host.present(EmberReportSettledPane(onFold: fold), animated: true)
    }

    static func presentBlockSettled(from host: UIViewController, then fold: (() -> Void)? = nil) {
        host.present(EmberBlockSettledPane(onFold: fold), animated: true)
    }

    static func presentReviewHold(from host: UIViewController, then fold: (() -> Void)? = nil) {
        host.present(EmberReviewHoldPane(onFold: fold), animated: true)
    }

    static func presentMutualFollow(from host: UIViewController) {
        host.present(EmberMutualFollowPane(), animated: true)
    }

    static func presentFriendAskSent(from host: UIViewController) {
        host.present(EmberFriendAskPane(), animated: true)
    }

    static func presentSeatExit(
        from host: UIViewController,
        delete: Bool,
        onSettled: @escaping () -> Void
    ) {
        host.present(EmberSeatExitLoader(delete: delete, onSettled: onSettled), animated: true)
    }
}

private func lampDimCloth() -> UIColor {
    UIColor(red: 0.07, green: 0.02, blue: 0.08, alpha: 0.62)
}

final class EmberReportSettledPane: UIViewController {
    private let onFold: (() -> Void)?
    init(onFold: (() -> Void)?) {
        self.onFold = onFold
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.22, green: 0.05, blue: 0.20, alpha: 1)
        card.layer.cornerRadius = 28
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 1, green: 0.82, blue: 0.38, alpha: 0.55).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let glow = UIView()
        glow.backgroundColor = UIColor(red: 1, green: 0.82, blue: 0.38, alpha: 0.16)
        glow.layer.cornerRadius = 36
        glow.translatesAutoresizingMaskIntoConstraints = false
        let shield = UIImageView(image: NightSocialImageCabinet.named("SafetyShieldMark", fallback: "Frame@2x(12)"))
        shield.contentMode = .scaleAspectFit
        shield.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "The lamp took this report"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = UIColor(red: 1, green: 0.90, blue: 0.62, alpha: 1)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "This sitting is hidden from your night. House review keeps NightChat free of anonymous harm."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = UIColor.white.withAlphaComponent(0.82)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: "Keep the house kind")
        ok.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(glow)
        card.addSubview(shield)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 312),
            glow.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            glow.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            glow.widthAnchor.constraint(equalToConstant: 72),
            glow.heightAnchor.constraint(equalToConstant: 72),
            shield.centerXAnchor.constraint(equalTo: glow.centerXAnchor),
            shield.centerYAnchor.constraint(equalTo: glow.centerYAnchor),
            shield.widthAnchor.constraint(equalToConstant: 44),
            shield.heightAnchor.constraint(equalToConstant: 44),
            title.topAnchor.constraint(equalTo: glow.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 20),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func fold() {
        let done = onFold
        dismiss(animated: true) { done?() }
    }
}

final class EmberBlockSettledPane: UIViewController {
    private let onFold: (() -> Void)?
    init(onFold: (() -> Void)?) {
        self.onFold = onFold
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.16, green: 0.04, blue: 0.14, alpha: 1)
        card.layer.cornerRadius = 28
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 1, green: 0.45, blue: 0.32, alpha: 0.55).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let disc = UIView()
        disc.backgroundColor = UIColor(red: 1, green: 0.42, blue: 0.28, alpha: 1)
        disc.layer.cornerRadius = 28
        disc.translatesAutoresizingMaskIntoConstraints = false
        let minus = UIView()
        minus.backgroundColor = .white
        minus.layer.cornerRadius = 2
        minus.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "This desk left your night"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = UIColor(red: 1, green: 0.72, blue: 0.62, alpha: 1)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "Their clips, rooms, and chats stay hidden. You can lift the block later from Blacklist."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = UIColor.white.withAlphaComponent(0.82)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: "Close the curtain")
        ok.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(disc)
        disc.addSubview(minus)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 312),
            disc.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            disc.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            disc.widthAnchor.constraint(equalToConstant: 56),
            disc.heightAnchor.constraint(equalToConstant: 56),
            minus.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            minus.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            minus.widthAnchor.constraint(equalToConstant: 22),
            minus.heightAnchor.constraint(equalToConstant: 4),
            title.topAnchor.constraint(equalTo: disc.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 20),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func fold() {
        let done = onFold
        dismiss(animated: true) { done?() }
    }
}

final class EmberReviewHoldPane: UIViewController {
    private let onFold: (() -> Void)?
    init(onFold: (() -> Void)?) {
        self.onFold = onFold
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let mascot = UIImageView(image: NightSocialImageCabinet.named("LampReviewMascot", fallback: "image_652"))
        mascot.contentMode = .scaleAspectFit
        mascot.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = UIColor(red: 1, green: 0.93, blue: 0.96, alpha: 1)
        card.layer.cornerRadius = 30
        card.layer.shadowColor = AfterHoursPalette.magentaPeak.cgColor
        card.layer.shadowOpacity = 0.35
        card.layer.shadowRadius = 22
        card.layer.shadowOffset = CGSize(width: 0, height: 12)
        card.translatesAutoresizingMaskIntoConstraints = false
        let wax = UIView()
        wax.backgroundColor = AfterHoursPalette.loungePink
        wax.layer.cornerRadius = 16
        wax.translatesAutoresizingMaskIntoConstraints = false
        let waxMark = UILabel()
        waxMark.text = "HOLD"
        waxMark.font = AfterHoursType.foyerCaption(10)
        waxMark.textColor = .white
        waxMark.textAlignment = .center
        waxMark.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "Held at the night desk"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = AfterHoursPalette.inkOnSnow
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "Your clip reached the house. A reviewer reads it before it can glow in the lounge. Nothing posts live until it passes."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.72)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: "I'll wait by the lamp")
        ok.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(card)
        view.addSubview(mascot)
        card.addSubview(wax)
        wax.addSubview(waxMark)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 36),
            card.widthAnchor.constraint(equalToConstant: 318),
            mascot.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            mascot.bottomAnchor.constraint(equalTo: card.topAnchor, constant: 36),
            mascot.widthAnchor.constraint(equalToConstant: 168),
            mascot.heightAnchor.constraint(equalToConstant: 168),
            wax.topAnchor.constraint(equalTo: card.topAnchor, constant: 44),
            wax.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            wax.widthAnchor.constraint(equalToConstant: 58),
            wax.heightAnchor.constraint(equalToConstant: 32),
            waxMark.centerXAnchor.constraint(equalTo: wax.centerXAnchor),
            waxMark.centerYAnchor.constraint(equalTo: wax.centerYAnchor),
            title.topAnchor.constraint(equalTo: wax.bottomAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 18),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func fold() {
        let done = onFold
        dismiss(animated: true) { done?() }
    }
}

final class EmberMutualFollowPane: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 28
        card.translatesAutoresizingMaskIntoConstraints = false
        let left = UIView()
        left.backgroundColor = AfterHoursPalette.loungePink
        left.layer.cornerRadius = 22
        left.translatesAutoresizingMaskIntoConstraints = false
        let right = UIView()
        right.backgroundColor = UIColor(red: 1, green: 0.72, blue: 0.42, alpha: 1)
        right.layer.cornerRadius = 22
        right.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "Not a mutual sitting yet"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "NightChat does not allow anonymous chats. Follow each other first. Then you can send a line or start a video call."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = UIColor.white.withAlphaComponent(0.82)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: "Back to the desk")
        ok.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(left)
        card.addSubview(right)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 312),
            left.centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: -16),
            left.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            left.widthAnchor.constraint(equalToConstant: 44),
            left.heightAnchor.constraint(equalToConstant: 44),
            right.centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: 16),
            right.topAnchor.constraint(equalTo: left.topAnchor),
            right.widthAnchor.constraint(equalTo: left.widthAnchor),
            right.heightAnchor.constraint(equalTo: left.heightAnchor),
            title.topAnchor.constraint(equalTo: left.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 18),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func fold() { dismiss(animated: true) }
}

final class EmberFriendAskPane: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 28
        card.translatesAutoresizingMaskIntoConstraints = false
        let pic = UIImageView(image: NightSocialImageCabinet.named("LampReviewMascot", fallback: "image_652"))
        pic.contentMode = .scaleAspectFit
        pic.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "Ask sent into the night"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "They have to agree before you sit as friends. Follows stay one-way until both sides choose each other."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = UIColor.white.withAlphaComponent(0.82)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: "Understood")
        ok.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(pic)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 312),
            pic.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            pic.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            pic.widthAnchor.constraint(equalToConstant: 72),
            pic.heightAnchor.constraint(equalToConstant: 72),
            title.topAnchor.constraint(equalTo: pic.bottomAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 18),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func fold() { dismiss(animated: true) }
}

final class EmberSeatExitLoader: UIViewController {
    private let delete: Bool
    private let onSettled: () -> Void
    private let pulse = NeonAfterglowDotPulse()

    init(delete: Bool, onSettled: @escaping () -> Void) {
        self.delete = delete
        self.onSettled = onSettled
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.10, green: 0.02, blue: 0.10, alpha: 0.72)
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 26
        card.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = delete ? "Closing this night desk" : "Leaving this sitting"
        title.font = AfterHoursType.foyerHeadline(18)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = delete ? "The house is packing your portrait and keys." : "The lamp is dimming this desk for now."
        body.font = AfterHoursType.foyerBody(13)
        body.textColor = UIColor.white.withAlphaComponent(0.75)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        card.addSubview(title)
        card.addSubview(pulse)
        card.addSubview(body)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 280),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            pulse.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            pulse.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            body.topAnchor.constraint(equalTo: pulse.bottomAnchor, constant: 16),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
        pulse.ignitePulse()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) { [weak self] in
            self?.revealSettled()
        }
    }

    private func revealSettled() {
        let delete = self.delete
        let done = onSettled
        dismiss(animated: true) {
            guard let host = AfterglowRootCoordinator.frontController() else {
                done()
                return
            }
            host.present(EmberSeatExitSettled(delete: delete, onSettled: done), animated: true)
        }
    }
}

final class EmberSeatExitSettled: UIViewController {
    private let delete: Bool
    private let onSettled: () -> Void
    init(delete: Bool, onSettled: @escaping () -> Void) {
        self.delete = delete
        self.onSettled = onSettled
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lampDimCloth()
        let card = UIView()
        card.backgroundColor = UIColor(red: 1, green: 0.94, blue: 0.97, alpha: 1)
        card.layer.cornerRadius = 28
        card.translatesAutoresizingMaskIntoConstraints = false
        let disc = UIView()
        disc.backgroundColor = AfterHoursPalette.loungePink
        disc.layer.cornerRadius = 26
        disc.translatesAutoresizingMaskIntoConstraints = false
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)))
        check.tintColor = .white
        check.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = delete ? "Desk erased" : "You left the lamp"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = AfterHoursPalette.inkOnSnow
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = delete
            ? "This night desk is gone. The foyer will greet you as a new sitting."
            : "Come back through Account login when you want the lounge again."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.72)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let ok = NightSocialLoungeChrome.pinkPill(title: delete ? "To the foyer" : "To login")
        ok.addTarget(self, action: #selector(settle), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(disc)
        disc.addSubview(check)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(ok)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 300),
            disc.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            disc.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            disc.widthAnchor.constraint(equalToConstant: 52),
            disc.heightAnchor.constraint(equalToConstant: 52),
            check.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            title.topAnchor.constraint(equalTo: disc.bottomAnchor, constant: 14),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 18),
            ok.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            ok.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func settle() {
        let done = onSettled
        dismiss(animated: true) { done() }
    }
}
