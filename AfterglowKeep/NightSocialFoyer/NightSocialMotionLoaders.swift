import UIKit

final class NeonAfterglowDotPulse: UIView {
    private let beads = [UIView(), UIView(), UIView()]

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 54).isActive = true
        heightAnchor.constraint(equalToConstant: 14).isActive = true

        for (index, bead) in beads.enumerated() {
            bead.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            bead.layer.cornerRadius = 5
            bead.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bead)
            NSLayoutConstraint.activate([
                bead.widthAnchor.constraint(equalToConstant: 10),
                bead.heightAnchor.constraint(equalToConstant: 10),
                bead.centerYAnchor.constraint(equalTo: centerYAnchor),
                bead.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(index) * 22),
            ])
        }
    }

    required init?(coder: NSCoder) { nil }

    func ignitePulse() {
        for (index, bead) in beads.enumerated() {
            bead.layer.removeAllAnimations()
            bead.alpha = 0.22
            bead.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)
            UIView.animate(
                withDuration: 0.46,
                delay: Double(index) * 0.16,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    bead.alpha = 1
                    bead.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
                }
            )
        }
    }
}

final class MidnightKindleOrbit: UIView {
    private let bars = [UIView(), UIView(), UIView(), UIView()]

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        widthAnchor.constraint(equalToConstant: 28).isActive = true
        heightAnchor.constraint(equalToConstant: 18).isActive = true

        let stack = UIStackView(arrangedSubviews: bars)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        for (index, bar) in bars.enumerated() {
            bar.backgroundColor = index % 2 == 0 ? AfterHoursPalette.peachWash : AfterHoursPalette.titleSnow
            bar.layer.cornerRadius = 1.5
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.widthAnchor.constraint(equalToConstant: 3).isActive = true
            bar.heightAnchor.constraint(equalToConstant: 16).isActive = true
            bar.transform = CGAffineTransform(scaleX: 1, y: 0.4)
        }
    }

    required init?(coder: NSCoder) { nil }

    func igniteKindle() {
        isHidden = false
        for (index, bar) in bars.enumerated() {
            bar.layer.removeAllAnimations()
            bar.transform = CGAffineTransform(scaleX: 1, y: 0.4)
            UIView.animate(
                withDuration: 0.32,
                delay: Double(index) * 0.08,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    bar.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            )
        }
    }

    func quenchKindle() {
        bars.forEach {
            $0.layer.removeAllAnimations()
            $0.transform = CGAffineTransform(scaleX: 1, y: 0.4)
        }
        isHidden = true
    }
}

final class VelvetNoticePane: UIViewController {
    private let spokenTitle: String
    private let spokenBody: String
    private let settleTitle: String

    init(spokenTitle: String, spokenBody: String, settleTitle: String) {
        self.spokenTitle = spokenTitle
        self.spokenBody = spokenBody
        self.settleTitle = settleTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { nil }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.18, green: 0.04, blue: 0.12, alpha: 0.46)

        let card = UIView()
        card.backgroundColor = AfterHoursPalette.snowCard
        card.layer.cornerRadius = 28
        card.layer.shadowColor = AfterHoursPalette.magentaPeak.cgColor
        card.layer.shadowOpacity = 0.28
        card.layer.shadowRadius = 24
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        card.translatesAutoresizingMaskIntoConstraints = false

        let blush = UIView()
        blush.backgroundColor = AfterHoursPalette.magentaPeak
        blush.translatesAutoresizingMaskIntoConstraints = false
        blush.layer.cornerRadius = 3

        let headline = UILabel()
        headline.text = spokenTitle
        headline.textColor = AfterHoursPalette.midnightPill
        headline.font = AfterHoursType.foyerHeadline(22)
        headline.numberOfLines = 0
        headline.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = spokenBody
        body.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.72)
        body.font = AfterHoursType.foyerBody(15)
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false

        let settle = MidnightPillControl(spokenTitle: settleTitle)
        settle.addTarget(self, action: #selector(foldPane), for: .touchUpInside)

        view.addSubview(card)
        card.addSubview(blush)
        card.addSubview(headline)
        card.addSubview(body)
        card.addSubview(settle)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            blush.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            blush.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            blush.widthAnchor.constraint(equalToConstant: 42),
            blush.heightAnchor.constraint(equalToConstant: 5),

            headline.topAnchor.constraint(equalTo: blush.bottomAnchor, constant: 18),
            headline.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            headline.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),

            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 10),
            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            settle.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 22),
            settle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            settle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            settle.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }

    @objc private func foldPane() {
        dismiss(animated: true)
    }
}

extension FoyerNotice {
    static func presentVelvet(on host: UIViewController, spokenTitle: String, spokenBody: String, settleTitle: String = "Keep sitting") {
        let pane = VelvetNoticePane(spokenTitle: spokenTitle, spokenBody: spokenBody, settleTitle: settleTitle)
        host.present(pane, animated: true)
    }

    static func presentCovenantNeeded(on host: UIViewController) {
        presentVelvet(
            on: host,
            spokenTitle: "House rules still open",
            spokenBody: "Tick the box for the User Agreement and Privacy Policy before this night desk can let you through.",
            settleTitle: "I'll tick them"
        )
    }
}
