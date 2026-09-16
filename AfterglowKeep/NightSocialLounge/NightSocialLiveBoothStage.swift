import UIKit

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
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Live Room Details", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.present(NightSocialBoothFactsSheet(boothKey: self.boothKey), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Room Ranking", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.present(NightSocialBoothLadderSheet(boothKey: self.boothKey), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Audience", style: .default, handler: { [weak self] _ in
            self?.present(NightSocialBoothCrowdSheet(), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Report or Block", style: .destructive, handler: { [weak self] _ in
            guard let self, let booth = NightSocialLoungeCatalog.booth(boothKey: self.boothKey) else { return }
            NightSocialSafetyFlow.presentChooser(from: self, target: .desk(booth.hostDeskKey))
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
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
        chatLines.append(LoungeDiscussLine(speakerName: me, spokenBody: body))
        field.text = ""
        table.reloadData()
        table.scrollToRow(at: IndexPath(row: chatLines.count - 1, section: 0), at: .bottom, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { chatLines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = AfterHoursType.foyerCaption(12)
        cell.textLabel?.numberOfLines = 0
        let line = chatLines[indexPath.row]
        cell.textLabel?.text = "\(line.speakerName): \(line.spokenBody)"
        cell.selectionStyle = .none
        return cell
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
        sheetPresentationController?.detents = [.medium(), .large()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Room Ranking"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: "rank")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { min(rows.count, 8) }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rank", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        let desk = rows[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1)  \(desk.spokenName)    \(desk.activityScore)"
        cell.imageView?.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 48, height: 48))
        cell.selectionStyle = .none
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
