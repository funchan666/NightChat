import UIKit

final class NightSocialChimeBoardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var showingFollow = false
    private let messageMark = UIButton(type: .system)
    private let followMark = UIButton(type: .system)
    private let friendsRow = UIScrollView()
    private let friendsStack = UIStackView()
    private let table = UITableView()
    private var threadKeys: [String] = []
    private var followDesks: [LoungeCreatorDesk] = []
    private var tableToHead: NSLayoutConstraint?
    private var tableToTabs: NSLayoutConstraint?
    private var friendsHeight: NSLayoutConstraint?

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)

        messageMark.setTitle(NightLang.t(.message), for: .normal)
        followMark.setTitle(NightLang.t(.following), for: .normal)
        messageMark.addTarget(self, action: #selector(showMessages), for: .touchUpInside)
        followMark.addTarget(self, action: #selector(showFollow), for: .touchUpInside)
        let compose = UIButton(type: .system)
        compose.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        compose.tintColor = .white
        compose.addTarget(self, action: #selector(openCompose), for: .touchUpInside)
        compose.translatesAutoresizingMaskIntoConstraints = false

        let platform = tileButton("PlatformTile", "PlatformTile", #selector(openPlatform))
        let likes = tileButton("LikesTile", "LikesTile", #selector(openLikes))
        let support = tileButton("SupportAvatar", "SupportAvatar", #selector(openSupport))
        let tiles = UIStackView(arrangedSubviews: [platform, likes, support])
        tiles.axis = .horizontal
        tiles.spacing = 10
        tiles.distribution = .fillEqually
        tiles.translatesAutoresizingMaskIntoConstraints = false
        tiles.tag = 62

        friendsRow.showsHorizontalScrollIndicator = false
        friendsRow.translatesAutoresizingMaskIntoConstraints = false
        friendsStack.axis = .horizontal
        friendsStack.spacing = 14
        friendsStack.translatesAutoresizingMaskIntoConstraints = false
        friendsRow.addSubview(friendsStack)

        let chatHead = UILabel()
        chatHead.text = NightLang.t(.chatWithFriends)
        chatHead.font = AfterHoursType.foyerPill(16)
        chatHead.textColor = .white
        chatHead.translatesAutoresizingMaskIntoConstraints = false
        chatHead.tag = 61

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        table.register(ChimeThreadRow.self, forCellReuseIdentifier: ChimeThreadRow.reuseId)
        table.register(ChimeFollowRow.self, forCellReuseIdentifier: ChimeFollowRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(messageMark)
        view.addSubview(followMark)
        view.addSubview(compose)
        view.addSubview(tiles)
        view.addSubview(friendsRow)
        view.addSubview(chatHead)
        view.addSubview(table)
        messageMark.translatesAutoresizingMaskIntoConstraints = false
        followMark.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageMark.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageMark.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            followMark.leadingAnchor.constraint(equalTo: messageMark.trailingAnchor, constant: 16),
            followMark.centerYAnchor.constraint(equalTo: messageMark.centerYAnchor),
            compose.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            compose.centerYAnchor.constraint(equalTo: messageMark.centerYAnchor),
            tiles.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tiles.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tiles.topAnchor.constraint(equalTo: messageMark.bottomAnchor, constant: 14),
            tiles.heightAnchor.constraint(equalToConstant: 92),
            friendsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendsRow.topAnchor.constraint(equalTo: tiles.bottomAnchor, constant: 14),
            friendsStack.leadingAnchor.constraint(equalTo: friendsRow.contentLayoutGuide.leadingAnchor, constant: 16),
            friendsStack.trailingAnchor.constraint(equalTo: friendsRow.contentLayoutGuide.trailingAnchor, constant: -16),
            friendsStack.topAnchor.constraint(equalTo: friendsRow.contentLayoutGuide.topAnchor),
            friendsStack.bottomAnchor.constraint(equalTo: friendsRow.contentLayoutGuide.bottomAnchor),
            friendsStack.heightAnchor.constraint(equalTo: friendsRow.frameLayoutGuide.heightAnchor),
            chatHead.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chatHead.topAnchor.constraint(equalTo: friendsRow.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        friendsHeight = friendsRow.heightAnchor.constraint(equalToConstant: 86)
        friendsHeight?.isActive = true
        tableToHead = table.topAnchor.constraint(equalTo: chatHead.bottomAnchor, constant: 6)
        tableToTabs = table.topAnchor.constraint(equalTo: followMark.bottomAnchor, constant: 16)
        tableToHead?.isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBoard), name: .deskDrawerDidChange, object: nil)
        paintTabs()
        reloadBoard()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadBoard()
    }

    private func tileButton(_ catalog: String, _ fallback: String, _ sel: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(NightSocialImageCabinet.named(catalog, fallback: fallback), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: sel, for: .touchUpInside)
        return button
    }

    @objc private func showMessages() {
        showingFollow = false
        paintTabs()
        reloadBoard()
    }

    @objc private func showFollow() {
        showingFollow = true
        paintTabs()
        reloadBoard()
    }

    private func paintTabs() {
        messageMark.setTitleColor(showingFollow ? UIColor.white.withAlphaComponent(0.55) : AfterHoursPalette.loungePink, for: .normal)
        followMark.setTitleColor(showingFollow ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.55), for: .normal)
        messageMark.titleLabel?.font = showingFollow ? AfterHoursType.foyerBody(18, weight: .medium) : AfterHoursType.foyerPill(22)
        followMark.titleLabel?.font = showingFollow ? AfterHoursType.foyerPill(22) : AfterHoursType.foyerBody(18, weight: .medium)
        view.viewWithTag(61)?.isHidden = showingFollow
        view.viewWithTag(62)?.isHidden = showingFollow
        friendsRow.isHidden = showingFollow
        tableToHead?.isActive = !showingFollow
        tableToTabs?.isActive = showingFollow
    }

    @objc private func reloadBoard() {
        threadKeys = NightSocialSessionDrawer.shared.chimeThreadKeys()
        followDesks = NightSocialSessionDrawer.shared.followedDeskKeys().compactMap {
            NightSocialLoungeCatalog.creator(deskKey: $0)
        }.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
        rebuildFriends()
        table.reloadData()
        paintEmpty()
    }

    private func paintEmpty() {
        view.viewWithTag(77)?.removeFromSuperview()
        let showingEmpty = showingFollow ? followDesks.isEmpty : threadKeys.isEmpty
        guard showingEmpty else { return }
        let empty = NightSocialEmptyPane(
            spoken: showingFollow
                ? NightLang.t(.noFollowsYet)
                : NightLang.t(.noChatsYet)
        )
        empty.tag = 77
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: table.centerYAnchor, constant: -24),
        ])
    }

    private func rebuildFriends() {
        friendsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let friends = NightSocialSessionDrawer.shared.mutualFollowDeskKeys().compactMap {
            NightSocialLoungeCatalog.creator(deskKey: $0)
        }
        if friends.isEmpty {
            friendsRow.isHidden = showingFollow
            friendsHeight?.constant = showingFollow ? 0 : 0
            return
        }
        friendsRow.isHidden = showingFollow
        friendsHeight?.constant = showingFollow ? 0 : 86
        for desk in friends.prefix(12) {
            let wrap = UIControl()
            wrap.translatesAutoresizingMaskIntoConstraints = false
            wrap.widthAnchor.constraint(equalToConstant: 64).isActive = true
            let pic = UIImageView(image: NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 96, height: 96)))
            pic.contentMode = .scaleAspectFill
            pic.layer.cornerRadius = 24
            pic.clipsToBounds = true
            pic.translatesAutoresizingMaskIntoConstraints = false
            let ring = UIImageView(image: NightSocialImageCabinet.named("LiveAvatarRing", fallback: "LiveAvatarRing"))
            ring.contentMode = .scaleAspectFit
            ring.isHidden = !desk.isLive
            ring.translatesAutoresizingMaskIntoConstraints = false
            let name = UILabel()
            name.text = desk.spokenName.split(separator: " ").first.map(String.init)
            name.font = AfterHoursType.foyerCaption(11)
            name.textColor = .white
            name.textAlignment = .center
            name.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(pic)
            wrap.addSubview(ring)
            wrap.addSubview(name)
            NSLayoutConstraint.activate([
                pic.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                pic.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 4),
                pic.widthAnchor.constraint(equalToConstant: 48),
                pic.heightAnchor.constraint(equalToConstant: 48),
                ring.centerXAnchor.constraint(equalTo: pic.centerXAnchor),
                ring.centerYAnchor.constraint(equalTo: pic.centerYAnchor),
                ring.widthAnchor.constraint(equalToConstant: 58),
                ring.heightAnchor.constraint(equalToConstant: 58),
                name.topAnchor.constraint(equalTo: pic.bottomAnchor, constant: 10),
                name.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            ])
            wrap.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                NightSocialDeskGate.revealDesk(from: self, deskKey: desk.deskKey)
            }, for: .touchUpInside)
            friendsStack.addArrangedSubview(wrap)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showingFollow ? followDesks.count : threadKeys.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { showingFollow ? 88 : 76 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingFollow {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChimeFollowRow.reuseId, for: indexPath) as! ChimeFollowRow
            let desk = followDesks[indexPath.row]
            cell.paint(desk)
            cell.onChat = { [weak self] in self?.openThread(desk.deskKey) }
            cell.onUnfollow = { [weak self] in
                NightSocialSessionDrawer.shared.toggleFollow(desk.deskKey)
                self?.reloadBoard()
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeThreadRow.reuseId, for: indexPath) as! ChimeThreadRow
        let key = threadKeys[indexPath.row]
        cell.paint(deskKey: key)
        cell.onOpenDesk = { [weak self] in
            guard let self else { return }
            NightSocialDeskGate.revealDesk(from: self, deskKey: key)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showingFollow {
            navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: followDesks[indexPath.row].deskKey), animated: true)
        } else {
            openThread(threadKeys[indexPath.row])
        }
    }

    private func openThread(_ deskKey: String) {
        navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: deskKey), animated: true)
    }

    @objc private func openCompose() {
        navigationController?.pushViewController(NightSocialChimeComposeBoard(), animated: true)
    }
    @objc private func openPlatform() {
        NightSocialSessionDrawer.shared.markPlatformRead()
        navigationController?.pushViewController(NightSocialChimeNoticeBoard(kind: .platform), animated: true)
    }
    @objc private func openLikes() {
        NightSocialSessionDrawer.shared.markLikesRead()
        navigationController?.pushViewController(NightSocialChimeNoticeBoard(kind: .likes), animated: true)
    }
    @objc private func openSupport() {
        navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: NightSocialChimeCatalog.supportDeskKey), animated: true)
    }
}

final class ChimeThreadRow: UITableViewCell {
    static let reuseId = "ChimeThreadRow"
    var onOpenDesk: (() -> Void)?
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let linePlate = UILabel()
    private let clockPlate = UILabel()
    private let unreadDot = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = AfterHoursPalette.loungeCard
        contentView.layer.cornerRadius = 16
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 22
        portrait.clipsToBounds = true
        portrait.isUserInteractionEnabled = true
        portrait.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.isUserInteractionEnabled = true
        namePlate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        linePlate.font = AfterHoursType.foyerCaption(12)
        linePlate.textColor = UIColor.white.withAlphaComponent(0.65)
        linePlate.translatesAutoresizingMaskIntoConstraints = false
        clockPlate.font = AfterHoursType.foyerCaption(11)
        clockPlate.textColor = UIColor.white.withAlphaComponent(0.5)
        clockPlate.translatesAutoresizingMaskIntoConstraints = false
        unreadDot.backgroundColor = AfterHoursPalette.loungePink
        unreadDot.layer.cornerRadius = 4
        unreadDot.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(portrait)
        contentView.addSubview(namePlate)
        contentView.addSubview(linePlate)
        contentView.addSubview(clockPlate)
        contentView.addSubview(unreadDot)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 44),
            portrait.heightAnchor.constraint(equalToConstant: 44),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor, constant: 2),
            linePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            linePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
            linePlate.trailingAnchor.constraint(equalTo: clockPlate.leadingAnchor, constant: -8),
            clockPlate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            clockPlate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            unreadDot.trailingAnchor.constraint(equalTo: clockPlate.trailingAnchor),
            unreadDot.topAnchor.constraint(equalTo: clockPlate.bottomAnchor, constant: 10),
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8),
        ])
    }
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 16, dy: 5)
    }

    func paint(deskKey: String) {
        let desk = NightSocialChimeCatalog.desk(for: deskKey)
        portrait.image = NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 88, height: 88))
        namePlate.text = desk?.spokenName ?? "Night guest"
        let stored = NightSocialSessionDrawer.shared.chimeLines(for: deskKey)
        if let last = stored.last {
            linePlate.text = last.hushBody
            let date = Date(timeIntervalSince1970: last.spokenAt)
            let stamp = DateFormatter()
            stamp.dateFormat = "h:mm a"
            clockPlate.text = stamp.string(from: date).lowercased()
        } else {
            linePlate.text = "Keep the sitting open."
            clockPlate.text = ""
        }
        unreadDot.isHidden = NightSocialSessionDrawer.shared.chimeIsRead(deskKey)
    }

    @objc private func openDesk() { onOpenDesk?() }
}

final class ChimeFollowRow: UITableViewCell {
    static let reuseId = "ChimeFollowRow"
    var onChat: (() -> Void)?
    var onUnfollow: (() -> Void)?
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let metaPlate = UILabel()
    private let liveMark = UIImageView()
    private let levelPlate = UILabel()
    private let unfollow = UIButton(type: .custom)
    private let chat = UIButton(type: .custom)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = AfterHoursPalette.loungeCard
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 22
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.numberOfLines = 1
        namePlate.lineBreakMode = .byTruncatingTail
        namePlate.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        namePlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        metaPlate.font = AfterHoursType.foyerCaption(11)
        metaPlate.textColor = UIColor.white.withAlphaComponent(0.65)
        metaPlate.numberOfLines = 1
        metaPlate.lineBreakMode = .byTruncatingTail
        metaPlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        liveMark.image = NightSocialImageCabinet.named("LiveBadge", fallback: "LiveBadge")
        liveMark.contentMode = .scaleAspectFit
        liveMark.setContentHuggingPriority(.required, for: .horizontal)
        liveMark.setContentCompressionResistancePriority(.required, for: .horizontal)
        liveMark.translatesAutoresizingMaskIntoConstraints = false
        let levelHost = UIView()
        levelHost.translatesAutoresizingMaskIntoConstraints = false
        let levelCloth = UIImageView(image: NightSocialImageCabinet.named("LevelBadge", fallback: "LevelBadge"))
        levelCloth.contentMode = .scaleToFill
        levelCloth.translatesAutoresizingMaskIntoConstraints = false
        levelPlate.textColor = AfterHoursPalette.inkOnSnow
        levelPlate.font = AfterHoursType.foyerCaption(10)
        levelPlate.textAlignment = .center
        levelPlate.translatesAutoresizingMaskIntoConstraints = false
        levelHost.addSubview(levelCloth)
        levelHost.addSubview(levelPlate)
        unfollow.setTitle("  \(NightLang.t(.unfollow))  ", for: .normal)
        unfollow.setTitleColor(AfterHoursPalette.loungePink, for: .normal)
        unfollow.titleLabel?.font = AfterHoursType.foyerCaption(12)
        unfollow.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        unfollow.layer.cornerRadius = 14
        unfollow.addTarget(self, action: #selector(tapUnfollow), for: .touchUpInside)
        unfollow.setContentCompressionResistancePriority(.required, for: .horizontal)
        unfollow.translatesAutoresizingMaskIntoConstraints = false
        chat.setImage(NightSocialImageCabinet.named("ChatBubble", fallback: "ChatBubble"), for: .normal)
        chat.imageView?.contentMode = .scaleAspectFit
        chat.addTarget(self, action: #selector(tapChat), for: .touchUpInside)
        chat.translatesAutoresizingMaskIntoConstraints = false
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        let nameRow = UIStackView(arrangedSubviews: [namePlate, liveMark, spacer])
        nameRow.axis = .horizontal
        nameRow.alignment = .center
        nameRow.spacing = 6
        nameRow.clipsToBounds = true
        let textCol = UIStackView(arrangedSubviews: [nameRow, metaPlate])
        textCol.axis = .vertical
        textCol.alignment = .fill
        textCol.spacing = 3
        textCol.clipsToBounds = true
        textCol.translatesAutoresizingMaskIntoConstraints = false
        textCol.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.addSubview(portrait)
        contentView.addSubview(textCol)
        contentView.addSubview(levelHost)
        contentView.addSubview(unfollow)
        contentView.addSubview(chat)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 44),
            portrait.heightAnchor.constraint(equalToConstant: 44),
            chat.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            chat.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chat.widthAnchor.constraint(equalToConstant: 36),
            chat.heightAnchor.constraint(equalToConstant: 36),
            unfollow.trailingAnchor.constraint(equalTo: chat.leadingAnchor, constant: -8),
            unfollow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unfollow.heightAnchor.constraint(equalToConstant: 28),
            unfollow.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            levelHost.trailingAnchor.constraint(equalTo: unfollow.leadingAnchor, constant: -8),
            levelHost.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            levelHost.widthAnchor.constraint(equalToConstant: 52),
            levelHost.heightAnchor.constraint(equalToConstant: 18),
            levelCloth.topAnchor.constraint(equalTo: levelHost.topAnchor),
            levelCloth.leadingAnchor.constraint(equalTo: levelHost.leadingAnchor),
            levelCloth.trailingAnchor.constraint(equalTo: levelHost.trailingAnchor),
            levelCloth.bottomAnchor.constraint(equalTo: levelHost.bottomAnchor),
            levelPlate.centerXAnchor.constraint(equalTo: levelHost.centerXAnchor),
            levelPlate.centerYAnchor.constraint(equalTo: levelHost.centerYAnchor),
            liveMark.widthAnchor.constraint(equalToConstant: 40),
            liveMark.heightAnchor.constraint(equalToConstant: 16),
            textCol.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            textCol.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textCol.trailingAnchor.constraint(equalTo: levelHost.leadingAnchor, constant: -8),
        ])
    }
    required init?(coder: NSCoder) { nil }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 16, dy: 5)
    }
    func paint(_ desk: LoungeCreatorDesk) {
        portrait.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 88, height: 88))
        namePlate.text = desk.spokenName
        metaPlate.text = "\(desk.followerCount) followers"
        liveMark.isHidden = !desk.isLive
        levelPlate.text = "Lv.\(desk.levelMark)"
    }
    @objc private func tapChat() { onChat?() }
    @objc private func tapUnfollow() { onUnfollow?() }
}
