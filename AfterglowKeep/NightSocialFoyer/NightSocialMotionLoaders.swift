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
    private let glyphName: String
    private let dim = UIView()
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card = UIView()
    private let cardWash = CAGradientLayer()
    private let disc = UIView()
    private let discWash = CAGradientLayer()

    init(spokenTitle: String, spokenBody: String, settleTitle: String, glyphName: String) {
        self.spokenTitle = spokenTitle
        self.spokenBody = spokenBody
        self.settleTitle = settleTitle
        self.glyphName = glyphName
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { nil }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        blur.translatesAutoresizingMaskIntoConstraints = false
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(foldPane)))

        card.backgroundColor = AfterHoursPalette.foyerNightCard
        card.layer.cornerRadius = 30
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        card.layer.shadowColor = AfterHoursPalette.magentaPeak.cgColor
        card.layer.shadowOpacity = 0.55
        card.layer.shadowRadius = 28
        card.layer.shadowOffset = CGSize(width: 0, height: 14)
        card.translatesAutoresizingMaskIntoConstraints = false

        cardWash.colors = [
            AfterHoursPalette.loungePink.withAlphaComponent(0.28).cgColor,
            UIColor.clear.cgColor,
        ]
        cardWash.startPoint = CGPoint(x: 0.5, y: 0)
        cardWash.endPoint = CGPoint(x: 0.5, y: 0.55)
        cardWash.cornerRadius = 30
        card.layer.insertSublayer(cardWash, at: 0)

        disc.translatesAutoresizingMaskIntoConstraints = false
        disc.clipsToBounds = true
        disc.layer.cornerRadius = 28
        discWash.colors = [AfterHoursPalette.foyerGlowPink.cgColor, AfterHoursPalette.magentaPeak.cgColor]
        discWash.startPoint = CGPoint(x: 0, y: 0)
        discWash.endPoint = CGPoint(x: 1, y: 1)
        disc.layer.insertSublayer(discWash, at: 0)

        let glyph = UIImageView(
            image: UIImage(
                systemName: glyphName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            )
        )
        glyph.tintColor = .white
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false

        let headline = UILabel()
        headline.text = spokenTitle
        headline.textColor = .white
        headline.font = AfterHoursType.foyerHeadline(22)
        headline.textAlignment = .center
        headline.numberOfLines = 0
        headline.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = spokenBody
        body.textColor = UIColor.white.withAlphaComponent(0.78)
        body.font = AfterHoursType.foyerBody(15)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false

        let settle = MidnightPillControl(spokenTitle: settleTitle)
        settle.addTarget(self, action: #selector(foldPane), for: .touchUpInside)

        view.addSubview(blur)
        view.addSubview(dim)
        view.addSubview(card)
        card.addSubview(disc)
        disc.addSubview(glyph)
        card.addSubview(headline)
        card.addSubview(body)
        card.addSubview(settle)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            disc.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            disc.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            disc.widthAnchor.constraint(equalToConstant: 56),
            disc.heightAnchor.constraint(equalToConstant: 56),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 24),
            glyph.heightAnchor.constraint(equalToConstant: 24),

            headline.topAnchor.constraint(equalTo: disc.bottomAnchor, constant: 16),
            headline.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            headline.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),

            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            settle.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 22),
            settle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            settle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            settle.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])

        card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        card.alpha = 0
        dim.alpha = 0
        blur.alpha = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardWash.frame = card.bounds
        cardWash.cornerRadius = 30
        discWash.frame = disc.bounds
        discWash.cornerRadius = disc.bounds.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(
            withDuration: 0.44,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.7,
            options: [.allowUserInteraction]
        ) {
            self.card.transform = .identity
            self.card.alpha = 1
            self.dim.alpha = 1
            self.blur.alpha = 1
        }
    }

    @objc private func foldPane() {
        UIView.animate(withDuration: 0.2, animations: {
            self.card.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            self.card.alpha = 0
            self.dim.alpha = 0
            self.blur.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}

extension FoyerNotice {
    static func presentVelvet(
        on host: UIViewController,
        spokenTitle: String,
        spokenBody: String,
        settleTitle: String = "Got it",
        glyphName: String = "sparkles"
    ) {
        let pane = VelvetNoticePane(
            spokenTitle: spokenTitle,
            spokenBody: spokenBody,
            settleTitle: settleTitle,
            glyphName: glyphName
        )
        host.present(pane, animated: false)
    }

    static func presentCovenantNeeded(on host: UIViewController) {
        presentVelvet(
            on: host,
            spokenTitle: "House rules still open",
            spokenBody: "Tick the box for the User Agreement and Privacy Policy before this night desk can let you through.",
            settleTitle: "I'll tick them",
            glyphName: "checkmark.shield.fill"
        )
    }
}
