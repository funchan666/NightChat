import UIKit

extension Notification.Name {
    static let liveGiftOffered = Notification.Name("lampdesk.afterglow.liveGift.offered")
}

final class LiveDanmakuLane: UIView {
    func fire(_ text: String) {
        guard bounds.width > 1 else { return }
        let plate = UILabel()
        plate.text = text
        plate.font = AfterHoursType.foyerCaption(13)
        plate.textColor = .white
        plate.layer.shadowColor = UIColor.black.cgColor
        plate.layer.shadowOpacity = 0.85
        plate.layer.shadowRadius = 3
        plate.layer.shadowOffset = CGSize(width: 0, height: 1)
        plate.sizeToFit()
        let lane = CGFloat(Int.random(in: 0..<3))
        plate.frame.origin = CGPoint(x: bounds.width + 12, y: 4 + lane * 34)
        addSubview(plate)
        UIView.animate(
            withDuration: Double.random(in: 5.8...7.6),
            delay: 0,
            options: [.curveLinear, .allowUserInteraction]
        ) {
            plate.frame.origin.x = -plate.bounds.width - 16
        } completion: { _ in
            plate.removeFromSuperview()
        }
    }
}

final class LiveGiftRibbon: UIView {
    private let pic = UIImageView()
    private let plate = UILabel()
    private let glyph = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.42)
        layer.cornerRadius = 20
        clipsToBounds = true
        alpha = 0
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.layer.cornerRadius = 16
        pic.translatesAutoresizingMaskIntoConstraints = false
        plate.font = AfterHoursType.foyerCaption(12)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pic)
        addSubview(plate)
        addSubview(glyph)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            pic.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            pic.centerYAnchor.constraint(equalTo: centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 32),
            pic.heightAnchor.constraint(equalToConstant: 32),
            glyph.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            glyph.centerYAnchor.constraint(equalTo: centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 28),
            glyph.heightAnchor.constraint(equalToConstant: 28),
            plate.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 8),
            plate.trailingAnchor.constraint(equalTo: glyph.leadingAnchor, constant: -8),
            plate.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func reveal(speaker: String, giftTitle: String, quantity: Int, portrait: UIImage?, glyphImage: UIImage?) {
        pic.image = portrait
        plate.text = "\(speaker) sent \(giftTitle)×\(quantity)"
        glyph.image = glyphImage
        layer.removeAllAnimations()
        alpha = 0
        transform = CGAffineTransform(translationX: -70, y: 0)
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.transform = .identity
        }
        UIView.animate(withDuration: 0.28, delay: 2.3, options: [.curveEaseIn]) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: -40, y: 0)
        }
    }
}

final class LiveChatLineCell: UITableViewCell {
    static let reuseId = "LiveChatLineCell"
    private let pill = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        pill.font = AfterHoursType.foyerCaption(12)
        pill.textColor = .white
        pill.numberOfLines = 0
        pill.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        pill.layer.cornerRadius = 10
        pill.clipsToBounds = true
        pill.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            pill.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            pill.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ line: LoungeDiscussLine) {
        pill.text = "  \(line.speakerName): \(line.spokenBody)  "
    }
}

final class LiveRankRow: UITableViewCell {
    static let reuseId = "LiveRankRow"
    private let rankDisc = UILabel()
    private let pic = UIImageView()
    private let namePlate = UILabel()
    private let scorePlate = UILabel()
    private let card = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        rankDisc.font = AfterHoursType.foyerPill(13)
        rankDisc.textAlignment = .center
        rankDisc.layer.cornerRadius = 12
        rankDisc.clipsToBounds = true
        rankDisc.translatesAutoresizingMaskIntoConstraints = false
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.layer.cornerRadius = 20
        pic.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        scorePlate.font = AfterHoursType.foyerCaption(12)
        scorePlate.textColor = UIColor.white.withAlphaComponent(0.72)
        scorePlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(rankDisc)
        card.addSubview(pic)
        card.addSubview(namePlate)
        card.addSubview(scorePlate)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            rankDisc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            rankDisc.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            rankDisc.widthAnchor.constraint(equalToConstant: 24),
            rankDisc.heightAnchor.constraint(equalToConstant: 24),
            pic.leadingAnchor.constraint(equalTo: rankDisc.trailingAnchor, constant: 10),
            pic.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 40),
            pic.heightAnchor.constraint(equalToConstant: 40),
            namePlate.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            namePlate.trailingAnchor.constraint(equalTo: scorePlate.leadingAnchor, constant: -8),
            namePlate.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            scorePlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            scorePlate.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(rank: Int, desk: LoungeCreatorDesk) {
        rankDisc.text = "\(rank)"
        pic.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 80, height: 80))
        namePlate.text = desk.spokenName
        scorePlate.text = "◆ \(desk.activityScore)"
        switch rank {
        case 1:
            rankDisc.backgroundColor = UIColor(red: 1.00, green: 0.82, blue: 0.28, alpha: 1)
            rankDisc.textColor = AfterHoursPalette.inkOnSnow
        case 2:
            rankDisc.backgroundColor = UIColor(red: 0.78, green: 0.82, blue: 0.90, alpha: 1)
            rankDisc.textColor = AfterHoursPalette.inkOnSnow
        case 3:
            rankDisc.backgroundColor = UIColor(red: 0.90, green: 0.58, blue: 0.32, alpha: 1)
            rankDisc.textColor = .white
        default:
            rankDisc.backgroundColor = UIColor.white.withAlphaComponent(0.16)
            rankDisc.textColor = .white
        }
    }
}

final class NightSocialLiveBoothStage: UIViewController, UITableViewDataSource {
    private let boothKey: String
    private var videoSurface: NightSocialVideoSurface?
    private var chatLines: [LoungeDiscussLine] = []
    private let table = UITableView()
    private let field = UITextField()
    private let danmaku = LiveDanmakuLane()
    private let giftRibbon = LiveGiftRibbon()
    private let giftBurst = UIImageView()
    private var chatter: Timer?

    init(boothKey: String) {
        self.boothKey = boothKey
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoSurface?.start()
        startAtmosphere()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoSurface?.stop()
        chatter?.invalidate()
        chatter = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }

        let cover = NightSocialVideoSurface(ownerKey: booth.hostDeskKey)
        videoSurface = cover
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false

        let hostChip = UIButton(type: .custom)
        hostChip.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        hostChip.layer.cornerRadius = 20
        hostChip.addTarget(self, action: #selector(openHost), for: .touchUpInside)
        hostChip.translatesAutoresizingMaskIntoConstraints = false
        let hostPic = UIImageView(image: NightSocialMediaAssets.portrait(for: booth.hostDeskKey, size: CGSize(width: 80, height: 80)))
        hostPic.contentMode = .scaleAspectFill
        hostPic.layer.cornerRadius = 16
        hostPic.clipsToBounds = true
        hostPic.translatesAutoresizingMaskIntoConstraints = false
        let hostName = UILabel()
        hostName.text = booth.hostSpokenName
        hostName.font = AfterHoursType.foyerPill(13)
        hostName.textColor = .white
        hostName.translatesAutoresizingMaskIntoConstraints = false
        let plus = UIButton(type: .system)
        plus.setTitle("+", for: .normal)
        plus.setTitleColor(.white, for: .normal)
        plus.backgroundColor = AfterHoursPalette.loungePink
        plus.layer.cornerRadius = 10
        plus.addTarget(self, action: #selector(followHost), for: .touchUpInside)
        plus.translatesAutoresizingMaskIntoConstraints = false

        let watchPlate = UILabel()
        watchPlate.text = "♡ \(booth.watcherCount)"
        watchPlate.textColor = .white
        watchPlate.font = AfterHoursType.foyerCaption(12)
        watchPlate.translatesAutoresizingMaskIntoConstraints = false
        let more = NightSocialLoungeChrome.iconControl(catalog: "LoungeMoreMark", fallback: "Frame@2x(8)", edge: 32)
        more.addTarget(self, action: #selector(openFacts), for: .touchUpInside)
        let close = NightSocialLoungeChrome.iconControl(catalog: "LoungeCloseMark", fallback: "Frame@2x(76)", edge: 32)
        close.addTarget(self, action: #selector(fold), for: .touchUpInside)

        let stats = UIButton(type: .system)
        stats.setTitle("  \(formatCount(booth.watcherCount * 7))    \(formatCount(booth.giftCount))    NO.10  >  ", for: .normal)
        stats.setTitleColor(.white, for: .normal)
        stats.titleLabel?.font = AfterHoursType.foyerCaption(11)
        stats.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        stats.layer.cornerRadius = 12
        stats.addTarget(self, action: #selector(openLadder), for: .touchUpInside)
        stats.translatesAutoresizingMaskIntoConstraints = false

        danmaku.clipsToBounds = true
        danmaku.isUserInteractionEnabled = false
        danmaku.translatesAutoresizingMaskIntoConstraints = false
        giftBurst.contentMode = .scaleAspectFit
        giftBurst.alpha = 0
        giftBurst.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 28
        table.register(LiveChatLineCell.self, forCellReuseIdentifier: LiveChatLineCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false

        field.placeholder = "Tell me your opinion..."
        field.attributedPlaceholder = NSAttributedString(string: "Tell me your opinion...", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.55)])
        field.textColor = .white
        field.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = UIButton(type: .system)
        send.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        send.tintColor = .white
        send.addTarget(self, action: #selector(sendChat), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false
        let gift = NightSocialLoungeChrome.iconControl(catalog: "LoungeGiftBox", fallback: "Group_782@2x(1)", edge: 36)
        gift.addTarget(self, action: #selector(openTribute), for: .touchUpInside)
        let crown = NightSocialLoungeChrome.iconControl(catalog: "LoungeCrownMark", fallback: "Group_781", edge: 34)
        crown.addTarget(self, action: #selector(openLadder), for: .touchUpInside)

        view.addSubview(cover)
        view.addSubview(danmaku)
        view.addSubview(giftBurst)
        view.addSubview(hostChip)
        hostChip.addSubview(hostPic)
        hostChip.addSubview(hostName)
        hostChip.addSubview(plus)
        view.addSubview(watchPlate)
        view.addSubview(more)
        view.addSubview(close)
        view.addSubview(stats)
        view.addSubview(table)
        view.addSubview(giftRibbon)
        view.addSubview(field)
        view.addSubview(send)
        view.addSubview(gift)
        view.addSubview(crown)

        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: view.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostChip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            hostChip.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            hostChip.heightAnchor.constraint(equalToConstant: 40),
            hostPic.leadingAnchor.constraint(equalTo: hostChip.leadingAnchor, constant: 4),
            hostPic.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            hostPic.widthAnchor.constraint(equalToConstant: 32),
            hostPic.heightAnchor.constraint(equalToConstant: 32),
            hostName.leadingAnchor.constraint(equalTo: hostPic.trailingAnchor, constant: 6),
            hostName.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            plus.leadingAnchor.constraint(equalTo: hostName.trailingAnchor, constant: 8),
            plus.trailingAnchor.constraint(equalTo: hostChip.trailingAnchor, constant: -6),
            plus.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            plus.widthAnchor.constraint(equalToConstant: 20),
            plus.heightAnchor.constraint(equalToConstant: 20),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            close.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            more.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -8),
            more.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            watchPlate.trailingAnchor.constraint(equalTo: more.leadingAnchor, constant: -8),
            watchPlate.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            stats.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stats.topAnchor.constraint(equalTo: hostChip.bottomAnchor, constant: 8),
            stats.heightAnchor.constraint(equalToConstant: 24),
            danmaku.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmaku.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmaku.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 18),
            danmaku.heightAnchor.constraint(equalToConstant: 110),
            giftBurst.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            giftBurst.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            giftBurst.widthAnchor.constraint(equalToConstant: 88),
            giftBurst.heightAnchor.constraint(equalToConstant: 88),
            giftRibbon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            giftRibbon.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -90),
            giftRibbon.bottomAnchor.constraint(equalTo: table.topAnchor, constant: -8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            table.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -10),
            table.heightAnchor.constraint(equalToConstant: 140),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            field.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            field.heightAnchor.constraint(equalToConstant: 36),
            crown.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            crown.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            gift.trailingAnchor.constraint(equalTo: crown.leadingAnchor, constant: -8),
            gift.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: gift.leadingAnchor, constant: -8),
            send.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(catchGift(_:)), name: .liveGiftOffered, object: nil)
        seedOpeningChat()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func formatCount(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000) }
        return "\(n)"
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func followHost() {
        if let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) {
            NightSocialSessionDrawer.shared.toggleFollow(booth.hostDeskKey)
        }
    }
    @objc private func openHost() {
        present(NightSocialHostCardSheet(boothKey: boothKey, nav: navigationController), animated: true)
    }
    @objc private func openFacts() {
        present(NightSocialLiveMoreSheet(boothKey: boothKey, host: self), animated: true)
    }
    @objc private func openLadder() {
        present(NightSocialBoothLadderSheet(boothKey: boothKey), animated: true)
    }
    @objc private func openTribute() {
        present(NightSocialTributeTray(boothKey: boothKey), animated: true)
    }
    @objc private func sendChat() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        pushLine(speaker: me, body: body, deskKey: "")
        field.text = ""
    }

    private func seedOpeningChat() {
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }
        let others = NightSocialLoungeCatalog.visibleCreators().filter { $0.deskKey != booth.hostDeskKey }
        guard !others.isEmpty else { return }
        let opening = [
            "The lighting on this sitting is unreal.",
            "Just walked in. Stay a minute.",
            "Send a wand if the talk lands.",
        ]
        for (index, phrase) in opening.enumerated() {
            let speaker = others[index % others.count]
            chatLines.append(LoungeDiscussLine(speakerDeskKey: speaker.deskKey, speakerName: speaker.spokenName, spokenBody: phrase))
        }
        table.reloadData()
    }

    private func startAtmosphere() {
        chatter?.invalidate()
        chatter = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: true) { [weak self] _ in
            self?.spillAtmosphere()
        }
        if let first = chatLines.first {
            danmaku.fire("\(first.speakerName): \(first.spokenBody)")
        }
    }

    private func spillAtmosphere() {
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }
        let others = NightSocialLoungeCatalog.visibleCreators().filter { $0.deskKey != booth.hostDeskKey }
        guard let speaker = others.randomElement() else { return }
        let phrases = [
            "This room is warm tonight.",
            "The talk landed.",
            "Stay, don't fold yet.",
            "That shot is cinematic.",
            "Hi from the back row.",
            "Gift a heart if you're still here.",
            "The night desk is kind.",
            "Keep the lamp low.",
        ]
        let phrase = phrases.randomElement() ?? "Hello."
        pushLine(speaker: speaker.spokenName, body: phrase, deskKey: speaker.deskKey)
        if Int.random(in: 0...4) == 0, let gift = NightSocialLoungeCatalog.gifts.randomElement() {
            paintGift(
                speaker: speaker.spokenName,
                deskKey: speaker.deskKey,
                title: gift.spokenTitle,
                quantity: 1,
                glyphName: gift.glyphCatalog
            )
        }
    }

    private func pushLine(speaker: String, body: String, deskKey: String) {
        chatLines.append(LoungeDiscussLine(speakerDeskKey: deskKey, speakerName: speaker, spokenBody: body))
        if chatLines.count > 36 { chatLines.removeFirst(chatLines.count - 36) }
        table.reloadData()
        let last = IndexPath(row: chatLines.count - 1, section: 0)
        table.scrollToRow(at: last, at: .bottom, animated: true)
        danmaku.fire("\(speaker): \(body)")
    }

    @objc private func catchGift(_ note: Notification) {
        let title = note.userInfo?["title"] as? String ?? "Gift"
        let quantity = note.userInfo?["quantity"] as? Int ?? 1
        let glyph = note.userInfo?["glyph"] as? String ?? ""
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        paintGift(speaker: me, deskKey: "", title: title, quantity: quantity, glyphName: glyph)
        pushLine(speaker: me, body: "sent \(title)×\(quantity)", deskKey: "")
    }

    private func paintGift(speaker: String, deskKey: String, title: String, quantity: Int, glyphName: String) {
        let portrait = deskKey.isEmpty
            ? NightSocialMediaAssets.localPortrait(size: CGSize(width: 64, height: 64))
            : NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 64, height: 64))
        giftRibbon.reveal(
            speaker: speaker,
            giftTitle: title,
            quantity: quantity,
            portrait: portrait,
            glyphImage: UIImage(named: glyphName)
        )
        giftBurst.image = UIImage(named: glyphName)
        giftBurst.alpha = 0
        giftBurst.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.8) {
            self.giftBurst.alpha = 1
            self.giftBurst.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 0.55, options: [.curveEaseIn]) {
                self.giftBurst.alpha = 0
                self.giftBurst.transform = CGAffineTransform(translationX: 0, y: -36).scaledBy(x: 0.7, y: 0.7)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { chatLines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveChatLineCell.reuseId, for: indexPath) as! LiveChatLineCell
        cell.paint(chatLines[indexPath.row])
        return cell
    }
}

final class NightSocialLiveMoreSheet: UIViewController {
    private let boothKey: String
    private weak var host: UIViewController?

    init(boothKey: String, host: UIViewController) {
        self.boothKey = boothKey
        self.host = host
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [
            .custom(identifier: .init("liveMore")) { _ in 392 }
        ]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 26
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard

        let title = UILabel()
        title.text = "More"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "Room tools for this sitting"
        kicker.font = AfterHoursType.foyerCaption(13)
        kicker.textColor = UIColor.white.withAlphaComponent(0.62)
        kicker.translatesAutoresizingMaskIntoConstraints = false

        let details = makeRow(title: "Live Room Details", symbol: "info.circle.fill", tint: AfterHoursPalette.foyerGlowPink)
        details.addTarget(self, action: #selector(openDetails), for: .touchUpInside)
        let ranking = makeRow(title: "Room Ranking", symbol: "trophy.fill", tint: UIColor(red: 1.00, green: 0.82, blue: 0.28, alpha: 1))
        ranking.addTarget(self, action: #selector(openRanking), for: .touchUpInside)
        let audience = makeRow(title: "Audience", symbol: "person.3.fill", tint: AfterHoursPalette.levelMint)
        audience.addTarget(self, action: #selector(openAudience), for: .touchUpInside)
        let report = makeRow(title: "Report or Block", symbol: "exclamationmark.bubble.fill", tint: AfterHoursPalette.loungePink)
        report.addTarget(self, action: #selector(openSafety), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [details, ranking, audience, report])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)

        view.addSubview(title)
        view.addSubview(kicker)
        view.addSubview(stack)
        view.addSubview(cancel)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            kicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 16),
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 14),
            cancel.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func makeRow(title: String, symbol: String, tint: UIColor) -> UIControl {
        let row = UIControl()
        row.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        row.layer.cornerRadius = 16
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let disc = UIView()
        disc.backgroundColor = tint.withAlphaComponent(0.22)
        disc.layer.cornerRadius = 16
        disc.isUserInteractionEnabled = false
        disc.translatesAutoresizingMaskIntoConstraints = false
        let glyph = UIImageView(image: UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        glyph.tintColor = tint
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = title
        plate.font = AfterHoursType.foyerPill(15)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        let chev = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)))
        chev.tintColor = UIColor.white.withAlphaComponent(0.35)
        chev.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(disc)
        disc.addSubview(glyph)
        row.addSubview(plate)
        row.addSubview(chev)
        NSLayoutConstraint.activate([
            disc.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            disc.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 32),
            disc.heightAnchor.constraint(equalToConstant: 32),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            plate.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 12),
            plate.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chev.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            chev.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    @objc private func fold() { dismiss(animated: true) }

    @objc private func openDetails() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.host?.present(NightSocialBoothFactsSheet(boothKey: self.boothKey), animated: true)
        }
    }

    @objc private func openRanking() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.host?.present(NightSocialBoothLadderSheet(boothKey: self.boothKey), animated: true)
        }
    }

    @objc private func openAudience() {
        dismiss(animated: true) { [weak self] in
            self?.host?.present(NightSocialBoothCrowdSheet(), animated: true)
        }
    }

    @objc private func openSafety() {
        dismiss(animated: true) { [weak self] in
            guard let self, let host = self.host,
                  let booth = NightSocialLoungeCatalog.booth(boothKey: self.boothKey) else { return }
            NightSocialSafetyFlow.presentChooser(from: host, target: .desk(booth.hostDeskKey))
        }
    }
}

final class NightSocialBoothFactsSheet: UIViewController {
    private let boothKey: String
    init(boothKey: String) {
        self.boothKey = boothKey
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }
        let title = UILabel()
        title.text = "Live Room Details"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.numberOfLines = 0
        body.textColor = UIColor.white.withAlphaComponent(0.9)
        body.font = AfterHoursType.foyerBody(14)
        body.text = "\(booth.boothTitle)\n\(booth.moodLine)\n\(booth.hostSpokenName)\n\(booth.vibeTags.joined(separator: "  "))\n\n\(booth.watcherCount) Viewers\n\(booth.durationPhrase) Duration\n\(booth.giftCount) Gifts\n\(booth.likeCount) Likes\n\(booth.activityScorePhrase)\n\(booth.regionLabel) Region"
        body.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        view.addSubview(body)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
        ])
    }
}

extension LoungeLiveBooth {
    var activityScorePhrase: String { "\(watcherCount + giftCount / 10) Score" }
}

final class NightSocialBoothCrowdSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let rows: [LoungeCreatorDesk]
    init() {
        self.rows = NightSocialLoungeCatalog.visibleCreators()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium(), .large()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "audience"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "crowd")
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            table.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crowd", for: indexPath)
        let desk = rows[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(desk.spokenName)  \(desk.cityLabel)\n\(desk.handleTag)  \(desk.vibeLine)"
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 48, height: 48))
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialDeskGate.revealDesk(from: self, deskKey: rows[indexPath.row].deskKey)
    }
}

final class NightSocialBoothLadderSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let boothKey: String
    private let rows: [LoungeCreatorDesk]
    init(boothKey: String) {
        self.boothKey = boothKey
        self.rows = NightSocialLoungeCatalog.visibleCreators().sorted { $0.activityScore > $1.activityScore }
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [
            .custom(identifier: .init("rank")) { _ in 520 },
            .large(),
        ]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 24
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Room Ranking"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "Top gifters in this sitting"
        kicker.font = AfterHoursType.foyerCaption(13)
        kicker.textColor = UIColor.white.withAlphaComponent(0.65)
        kicker.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.rowHeight = 72
        table.register(LiveRankRow.self, forCellReuseIdentifier: LiveRankRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        view.addSubview(kicker)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            kicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            table.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { min(rows.count, 8) }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveRankRow.reuseId, for: indexPath) as! LiveRankRow
        cell.paint(rank: indexPath.row + 1, desk: rows[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialDeskGate.revealDesk(from: self, deskKey: rows[indexPath.row].deskKey)
    }
}

final class NightSocialHostCardSheet: UIViewController {
    private let boothKey: String
    private weak var nav: UINavigationController?
    init(boothKey: String, nav: UINavigationController?) {
        self.boothKey = boothKey
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey),
              let desk = NightSocialLoungeCatalog.creator(deskKey: booth.hostDeskKey) else { return }
        let pic = UIImageView(image: NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 140, height: 140)))
        pic.contentMode = .scaleAspectFill
        pic.layer.cornerRadius = 32
        pic.clipsToBounds = true
        pic.isUserInteractionEnabled = true
        pic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        pic.translatesAutoresizingMaskIntoConstraints = false
        let name = UILabel()
        name.text = desk.spokenName
        name.font = AfterHoursType.foyerHeadline(22)
        name.textColor = .white
        name.isUserInteractionEnabled = true
        name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        name.translatesAutoresizingMaskIntoConstraints = false
        let meta = UILabel()
        meta.text = "\(desk.cityLabel)   \(desk.handleTag)"
        meta.font = AfterHoursType.foyerCaption(12)
        meta.textColor = UIColor.white.withAlphaComponent(0.7)
        meta.translatesAutoresizingMaskIntoConstraints = false
        let stats = UILabel()
        stats.text = "\(desk.followerCount) Followers    \(desk.friendCount) Friends    \(desk.watchingCount) Watching"
        stats.font = AfterHoursType.foyerCaption(12)
        stats.textColor = .white
        stats.translatesAutoresizingMaskIntoConstraints = false
        let vibe = UILabel()
        vibe.text = desk.vibeLine
        vibe.numberOfLines = 0
        vibe.font = AfterHoursType.foyerBody(13)
        vibe.textColor = UIColor.white.withAlphaComponent(0.85)
        vibe.translatesAutoresizingMaskIntoConstraints = false
        let follow = NightSocialLoungeChrome.pinkPill(title: NightSocialSessionDrawer.shared.isFollowing(desk.deskKey) ? "Followed" : "+ Follow")
        follow.addTarget(self, action: #selector(flipFollow), for: .touchUpInside)
        let message = NightSocialLoungeChrome.ghostPill(title: "Private Message")
        message.addTarget(self, action: #selector(openWhisper), for: .touchUpInside)
        view.addSubview(pic)
        view.addSubview(name)
        view.addSubview(meta)
        view.addSubview(stats)
        view.addSubview(vibe)
        view.addSubview(follow)
        view.addSubview(message)
        NSLayoutConstraint.activate([
            pic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            pic.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            pic.widthAnchor.constraint(equalToConstant: 64),
            pic.heightAnchor.constraint(equalToConstant: 64),
            name.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 12),
            name.topAnchor.constraint(equalTo: pic.topAnchor),
            meta.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            meta.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
            stats.leadingAnchor.constraint(equalTo: pic.leadingAnchor),
            stats.topAnchor.constraint(equalTo: pic.bottomAnchor, constant: 14),
            vibe.leadingAnchor.constraint(equalTo: pic.leadingAnchor),
            vibe.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            vibe.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 8),
            follow.leadingAnchor.constraint(equalTo: pic.leadingAnchor),
            follow.topAnchor.constraint(equalTo: vibe.bottomAnchor, constant: 16),
            follow.widthAnchor.constraint(equalToConstant: 140),
            message.leadingAnchor.constraint(equalTo: follow.trailingAnchor, constant: 10),
            message.centerYAnchor.constraint(equalTo: follow.centerYAnchor),
            message.widthAnchor.constraint(equalToConstant: 160),
        ])
    }
    @objc private func flipFollow() {
        if let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) {
            NightSocialSessionDrawer.shared.toggleFollow(booth.hostDeskKey)
        }
    }
    @objc private func openWhisper() {
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }
        dismiss(animated: true) { [weak self] in
            self?.nav?.pushViewController(NightSocialChimeThreadBoard(deskKey: booth.hostDeskKey), animated: true)
        }
    }
    @objc private func openDesk() {
        guard let booth = NightSocialLoungeCatalog.booth(boothKey: boothKey) else { return }
        NightSocialDeskGate.revealDesk(from: self, deskKey: booth.hostDeskKey)
    }
}
