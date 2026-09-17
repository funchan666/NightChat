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
    private let stage = UIView()
    private let card = UIView()
    private let header = UIView()
    private let headerWash = CAGradientLayer()

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
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(foldPane)))

        stage.translatesAutoresizingMaskIntoConstraints = false
        stage.layer.shadowColor = AfterHoursPalette.magentaPeak.cgColor
        stage.layer.shadowOpacity = 0.55
        stage.layer.shadowRadius = 30
        stage.layer.shadowOffset = CGSize(width: 0, height: 16)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(red: 1, green: 0.97, blue: 0.985, alpha: 1)
        card.layer.cornerRadius = 32
        card.clipsToBounds = true
        card.isOpaque = true

        header.translatesAutoresizingMaskIntoConstraints = false
        header.clipsToBounds = true
        headerWash.colors = [
            AfterHoursPalette.magentaPeak.cgColor,
            AfterHoursPalette.foyerGlowPink.cgColor,
            AfterHoursPalette.loungePink.cgColor,
        ]
        headerWash.startPoint = CGPoint(x: 0, y: 0)
        headerWash.endPoint = CGPoint(x: 1, y: 1)
        header.layer.insertSublayer(headerWash, at: 0)

        let washCloth = UIImageView(image: NightSocialImageCabinet.stageWash)
        washCloth.contentMode = .scaleAspectFill
        washCloth.alpha = 0.35
        washCloth.translatesAutoresizingMaskIntoConstraints = false

        let sparkA = makeSpark(alpha: 0.95, edge: 28)
        let sparkB = makeSpark(alpha: 0.7, edge: 18)
        let sparkC = makeSpark(alpha: 0.55, edge: 14)

        let close = UIButton(type: .custom)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(
            UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)),
            for: .normal
        )
        close.tintColor = .white
        close.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        close.layer.cornerRadius = 14
        close.addTarget(self, action: #selector(foldPane), for: .touchUpInside)

        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = .white
        badge.layer.cornerRadius = 36
        badge.layer.borderWidth = 3
        badge.layer.borderColor = UIColor.white.cgColor

        let mark = UIImageView(image: NightSocialImageCabinet.stageMark)
        mark.contentMode = .scaleAspectFill
        mark.clipsToBounds = true
        mark.layer.cornerRadius = 28
        mark.translatesAutoresizingMaskIntoConstraints = false

        let glyph = UIImageView(
            image: UIImage(
                systemName: glyphName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            )
        )
        glyph.translatesAutoresizingMaskIntoConstraints = false
        glyph.tintColor = .white
        glyph.backgroundColor = AfterHoursPalette.loungePink
        glyph.layer.cornerRadius = 12
        glyph.clipsToBounds = true
        glyph.contentMode = .center

        let headline = UILabel()
        headline.text = spokenTitle
        headline.textColor = AfterHoursPalette.inkOnSnow
        headline.font = AfterHoursType.foyerHeadline(22)
        headline.textAlignment = .center
        headline.numberOfLines = 0
        headline.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = spokenBody
        body.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.68)
        body.font = AfterHoursType.foyerBody(15)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false

        let settle = MidnightPillControl(spokenTitle: settleTitle)
        settle.addTarget(self, action: #selector(foldPane), for: .touchUpInside)

        view.addSubview(blur)
        view.addSubview(dim)
        view.addSubview(stage)
        stage.addSubview(card)
        card.addSubview(header)
        header.addSubview(washCloth)
        header.addSubview(sparkA)
        header.addSubview(sparkB)
        header.addSubview(sparkC)
        header.addSubview(close)
        card.addSubview(headline)
        card.addSubview(body)
        card.addSubview(settle)
        card.addSubview(badge)
        badge.addSubview(mark)
        card.addSubview(glyph)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            stage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            stage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.topAnchor.constraint(equalTo: stage.topAnchor),
            card.leadingAnchor.constraint(equalTo: stage.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: stage.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: stage.bottomAnchor),

            header.topAnchor.constraint(equalTo: card.topAnchor),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 118),
            washCloth.topAnchor.constraint(equalTo: header.topAnchor),
            washCloth.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            washCloth.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            washCloth.bottomAnchor.constraint(equalTo: header.bottomAnchor),

            sparkA.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            sparkA.topAnchor.constraint(equalTo: header.topAnchor, constant: 28),
            sparkB.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -54),
            sparkB.topAnchor.constraint(equalTo: header.topAnchor, constant: 22),
            sparkC.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 78),
            sparkC.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16),

            close.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -14),
            close.topAnchor.constraint(equalTo: header.topAnchor, constant: 14),
            close.widthAnchor.constraint(equalToConstant: 28),
            close.heightAnchor.constraint(equalToConstant: 28),

            badge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: header.bottomAnchor),
            badge.widthAnchor.constraint(equalToConstant: 72),
            badge.heightAnchor.constraint(equalToConstant: 72),
            mark.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 56),
            mark.heightAnchor.constraint(equalToConstant: 56),
            glyph.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 4),
            glyph.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: 2),
            glyph.widthAnchor.constraint(equalToConstant: 24),
            glyph.heightAnchor.constraint(equalToConstant: 24),

            headline.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 18),
            headline.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            headline.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            settle.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 22),
            settle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            settle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            settle.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])

        stage.transform = CGAffineTransform(translationX: 0, y: 24).scaledBy(x: 0.94, y: 0.94)
        stage.alpha = 0
        dim.alpha = 0
        blur.alpha = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerWash.frame = header.bounds
        stage.layer.shadowPath = UIBezierPath(roundedRect: stage.bounds, cornerRadius: 32).cgPath
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(
            withDuration: 0.48,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: [.allowUserInteraction]
        ) {
            self.stage.transform = .identity
            self.stage.alpha = 1
            self.dim.alpha = 1
            self.blur.alpha = 1
        }
    }

    @objc private func foldPane() {
        UIView.animate(withDuration: 0.2, animations: {
            self.stage.transform = CGAffineTransform(translationX: 0, y: 16).scaledBy(x: 0.96, y: 0.96)
            self.stage.alpha = 0
            self.dim.alpha = 0
            self.blur.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }

    private func makeSpark(alpha: CGFloat, edge: CGFloat) -> UIImageView {
        let spark = UIImageView(image: NightSocialImageCabinet.named("Sparkle", fallback: "Sparkle"))
        spark.alpha = alpha
        spark.contentMode = .scaleAspectFit
        spark.translatesAutoresizingMaskIntoConstraints = false
        spark.widthAnchor.constraint(equalToConstant: edge).isActive = true
        spark.heightAnchor.constraint(equalToConstant: edge).isActive = true
        return spark
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
