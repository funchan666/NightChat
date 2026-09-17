import StoreKit
import UIKit

enum NightSocialLampPack: CaseIterable {
    case spark
    case ember
    case wick
    case lantern
    case aurora
    case comet
    case halo
    case nova
    case eclipse

    var productId: String {
        switch self {
        case .spark: return "gofstjjhqnnceiwv"
        case .ember: return "kkalmkkftltgufwu"
        case .wick: return "ansrbejfagaqcjxy"
        case .lantern: return "tncvbyzwbnotsnwf"
        case .aurora: return "wjckpbfuyhraqmos"
        case .comet: return "moonumpyvwbzclfn"
        case .halo: return "qhvxrmpldntewksa"
        case .nova: return "dbavnvxjbkfizlzy"
        case .eclipse: return "yhzmgciusfonlhrw"
        }
    }

    var coins: Int {
        switch self {
        case .spark: return 450
        case .ember: return 900
        case .wick: return 2700
        case .lantern: return 5600
        case .aurora: return 8600
        case .comet: return 11800
        case .halo: return 18800
        case .nova: return 31800
        case .eclipse: return 68800
        }
    }

    var listedPrice: String {
        switch self {
        case .spark: return "$0.99"
        case .ember: return "$1.99"
        case .wick: return "$4.99"
        case .lantern: return "$9.99"
        case .aurora: return "$14.99"
        case .comet: return "$19.99"
        case .halo: return "$29.99"
        case .nova: return "$49.99"
        case .eclipse: return "$99.99"
        }
    }

    var spokenTitle: String {
        switch self {
        case .spark: return "Spark"
        case .ember: return "Ember"
        case .wick: return "Wick"
        case .lantern: return "Lantern"
        case .aurora: return "Aurora"
        case .comet: return "Comet"
        case .halo: return "Halo"
        case .nova: return "Nova"
        case .eclipse: return "Eclipse"
        }
    }
}

enum NightSocialLampSpend {
    case liveGift(LoungeGiftToken, quantity: Int)
    case hostVoice
    case hostLive
    case postClip

    var cost: Int {
        switch self {
        case .liveGift(let gift, let quantity): return gift.diamondCost * quantity
        case .hostVoice, .hostLive: return 188
        case .postClip: return 68
        }
    }

    var spokenTitle: String {
        switch self {
        case .liveGift(let gift, let quantity): return "Send \(gift.spokenTitle)×\(quantity)"
        case .hostVoice: return "Open a voice sitting"
        case .hostLive: return "Start a video live"
        case .postClip: return "Post a night clip"
        }
    }
}

enum NightSocialLampStoreIssue: LocalizedError {
    case missingProduct
    case cancelled
    case pending
    case unverified

    var errorDescription: String? {
        switch self {
        case .missingProduct: return "This night pack is not on the lamp yet. Try again after the store listing lands."
        case .cancelled: return "The sitting was left unbought."
        case .pending: return "Apple is still holding this purchase."
        case .unverified: return "Apple could not verify this night pack."
        }
    }
}

enum NightSocialLampStore {
    static let welcomeGrant = 1288

    static let spendGuide: [(String, String)] = [
        ("Live gifts", "99 or 199 coins, by glyph"),
        ("Open a voice sitting", "188 coins"),
        ("Post a night clip", "68 coins"),
        ("Chat, follows, watching", "Always free"),
    ]

    static func startListening() {
        Task.detached {
            for await result in Transaction.updates {
                _ = try? await settle(result)
            }
        }
        Task {
            for await result in Transaction.unfinished {
                _ = try? await settle(result)
            }
        }
    }

    @MainActor
    static func buy(_ pack: NightSocialLampPack) async throws {
        let found = try await Product.products(for: [pack.productId])
        guard let product = found.first else { throw NightSocialLampStoreIssue.missingProduct }
        let outcome = try await product.purchase()
        switch outcome {
        case .success(let verification):
            try await settle(verification)
        case .userCancelled:
            throw NightSocialLampStoreIssue.cancelled
        case .pending:
            throw NightSocialLampStoreIssue.pending
        @unknown default:
            throw NightSocialLampStoreIssue.unverified
        }
    }

    static func spend(_ spend: NightSocialLampSpend, from host: UIViewController, onPaid: @escaping () -> Void) {
        let prompt = NightSocialDiamondPrompt(
            cost: spend.cost,
            quantity: 1,
            giftTitle: spend.spokenTitle,
            onPaid: onPaid,
            onShort: { revealRecharge(from: host) }
        )
        host.present(prompt, animated: true)
    }

    static func revealRecharge(from host: UIViewController) {
        let board = NightSocialMirrorRechargeBoard()
        if let nav = nearestNav(from: host) {
            dismissToNav(host) {
                nav.pushViewController(board, animated: true)
            }
            return
        }
        host.present(UINavigationController(rootViewController: board), animated: true)
    }

    private static func nearestNav(from host: UIViewController) -> UINavigationController? {
        if let nav = host.navigationController { return nav }
        var node: UIViewController? = host
        while let presenter = node?.presentingViewController {
            if let nav = presenter as? UINavigationController { return nav }
            if let nav = presenter.navigationController { return nav }
            node = presenter
        }
        return AfterglowRootCoordinator.frontController()?.navigationController
    }

    private static func dismissToNav(_ host: UIViewController, then: @escaping () -> Void) {
        if host.presentingViewController != nil {
            var root = host
            while let presenter = root.presentingViewController, presenter.navigationController == nil, !(presenter is UINavigationController) {
                if presenter.presentingViewController == nil { break }
                root = presenter
            }
            if let tray = host.presentingViewController, tray.presentingViewController != nil {
                host.dismiss(animated: true) {
                    tray.dismiss(animated: true, completion: then)
                }
            } else {
                host.dismiss(animated: true, completion: then)
            }
        } else {
            then()
        }
    }

    private static func settle(_ result: VerificationResult<Transaction>) async throws {
        switch result {
        case .unverified:
            throw NightSocialLampStoreIssue.unverified
        case .verified(let transaction):
            await MainActor.run {
                NightSocialSessionDrawer.shared.creditLampPack(productId: transaction.productID, transactionId: "\(transaction.id)")
            }
            await transaction.finish()
        }
    }
}

enum NightSocialCoinTill {
    static func spend(_ spend: NightSocialLampSpend, from host: UIViewController, onPaid: @escaping () -> Void) {
        NightSocialLampStore.spend(spend, from: host, onPaid: onPaid)
    }

    static func revealRecharge(from host: UIViewController) {
        NightSocialLampStore.revealRecharge(from: host)
    }
}

final class NightSocialLampWelcomePane: UIViewController {
    private let grant: Int
    private let countPlate = UILabel()
    private let glow = UIView()
    private let mark = UIImageView()
    private var ticker: Timer?
    private var shown = 0

    init(grant: Int) {
        self.grant = grant
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    static func offer(from host: UIViewController) {
        let grant = NightSocialSessionDrawer.shared.grantNightLampWelcomeIfNeeded()
        guard grant > 0 else { return }
        host.present(NightSocialLampWelcomePane(grant: grant), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let wash = UIImageView(image: NightSocialImageCabinet.stageWash)
        wash.contentMode = .scaleAspectFill
        wash.clipsToBounds = true
        wash.translatesAutoresizingMaskIntoConstraints = false

        glow.backgroundColor = AfterHoursPalette.foyerGlowPink.withAlphaComponent(0.28)
        glow.layer.cornerRadius = 110
        glow.translatesAutoresizingMaskIntoConstraints = false

        mark.image = NightSocialImageCabinet.stageMark
        mark.contentMode = .scaleAspectFit
        mark.layer.cornerRadius = 36
        mark.clipsToBounds = true
        mark.translatesAutoresizingMaskIntoConstraints = false

        let coin = UIImageView(image: NightSocialImageCabinet.named("CoinIcon", fallback: "CoinIcon"))
        coin.contentMode = .scaleAspectFit
        coin.translatesAutoresizingMaskIntoConstraints = false

        let kicker = UILabel()
        kicker.text = "A lamp was already burning."
        kicker.font = AfterHoursType.foyerHeadline(24)
        kicker.textColor = .white
        kicker.textAlignment = .center
        kicker.numberOfLines = 0
        kicker.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = "Night coins kept for the first sitting."
        body.font = AfterHoursType.foyerBody(15)
        body.textColor = UIColor.white.withAlphaComponent(0.82)
        body.textAlignment = .center
        body.translatesAutoresizingMaskIntoConstraints = false

        countPlate.text = "0"
        countPlate.font = AfterHoursType.foyerHeadline(42)
        countPlate.textColor = UIColor(red: 1.00, green: 0.84, blue: 0.32, alpha: 1)
        countPlate.textAlignment = .center
        countPlate.translatesAutoresizingMaskIntoConstraints = false

        let take = MidnightPillControl(spokenTitle: "Sit with the lamp")
        take.addTarget(self, action: #selector(fold), for: .touchUpInside)

        view.addSubview(wash)
        view.addSubview(glow)
        view.addSubview(mark)
        view.addSubview(coin)
        view.addSubview(kicker)
        view.addSubview(body)
        view.addSubview(countPlate)
        view.addSubview(take)

        for index in 0..<6 {
            let spark = UIImageView(image: NightSocialImageCabinet.named("Sparkle", fallback: "Sparkle"))
            spark.tag = 200 + index
            spark.alpha = 0
            spark.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(spark, belowSubview: mark)
            let angle = CGFloat(index) / 6 * .pi * 2
            NSLayoutConstraint.activate([
                spark.centerXAnchor.constraint(equalTo: glow.centerXAnchor, constant: cos(angle) * 92),
                spark.centerYAnchor.constraint(equalTo: glow.centerYAnchor, constant: sin(angle) * 92),
                spark.widthAnchor.constraint(equalToConstant: 18),
                spark.heightAnchor.constraint(equalToConstant: 18),
            ])
        }

        NSLayoutConstraint.activate([
            wash.topAnchor.constraint(equalTo: view.topAnchor),
            wash.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wash.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wash.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            glow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glow.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -96),
            glow.widthAnchor.constraint(equalToConstant: 220),
            glow.heightAnchor.constraint(equalToConstant: 220),
            mark.centerXAnchor.constraint(equalTo: glow.centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: glow.centerYAnchor, constant: -10),
            mark.widthAnchor.constraint(equalToConstant: 72),
            mark.heightAnchor.constraint(equalToConstant: 72),
            coin.centerXAnchor.constraint(equalTo: glow.centerXAnchor),
            coin.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 8),
            coin.widthAnchor.constraint(equalToConstant: 36),
            coin.heightAnchor.constraint(equalToConstant: 36),
            kicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            kicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            kicker.topAnchor.constraint(equalTo: glow.bottomAnchor, constant: 28),
            body.leadingAnchor.constraint(equalTo: kicker.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: kicker.trailingAnchor),
            body.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 8),
            countPlate.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countPlate.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 18),
            take.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            take.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            take.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
        ])
        glow.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        glow.alpha = 0
        mark.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.7, delay: 0.05, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.6) {
            self.glow.transform = .identity
            self.glow.alpha = 1
        }
        UIView.animate(withDuration: 0.45, delay: 0.12) {
            self.view.subviews.forEach { sub in
                if sub.tag >= 200 { sub.alpha = 1 }
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0.18) {
            self.mark.alpha = 1
        }
        ticker = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.shown = min(self.grant, self.shown + max(17, self.grant / 48))
            self.countPlate.text = "\(self.shown)"
            if self.shown >= self.grant { timer.invalidate() }
        }
    }

    @objc private func fold() {
        ticker?.invalidate()
        dismiss(animated: true)
    }
}
