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

        messageMark.setTitle("Message", for: .normal)
        followMark.setTitle("Following", for: .normal)
        messageMark.addTarget(self, action: #selector(showMessages), for: .touchUpInside)
        followMark.addTarget(self, action: #selector(showFollow), for: .touchUpInside)
        let compose = UIButton(type: .system)
        compose.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        compose.tintColor = .white
        compose.addTarget(self, action: #selector(openCompose), for: .touchUpInside)
        compose.translatesAutoresizingMaskIntoConstraints = false

        let platform = tileButton("ChimePlatformTile", "Group_912", #selector(openPlatform))
        let likes = tileButton("ChimeLikesTile", "Group_913", #selector(openLikes))
        let support = tileButton("ChimeSupportTile", "Group_914", #selector(openSupport))
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
        chatHead.text = "Chat with friends"
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
                ? "Follows you start sit here.\nNobody is auto-followed."
                : "No chats yet.\nOpen a desk, then send a line after you follow each other."
        )
        empty.tag = 77
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.topAnchor.constraint(equalTo: table.topAnchor, constant: 28),
        ])
    }

    private func rebuildFriends() {
        friendsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let friends = NightSocialSessionDrawer.shared.acceptedFriendKeys().compactMap {
            NightSocialLoungeCatalog.creator(deskKey: $0)
        }.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
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
            let ring = UIImageView(image: NightSocialImageCabinet.named("ChimeLiveRing", fallback: "Group_892"))
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
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let metaPlate = UILabel()
    private let liveMark = UIImageView()
    private let chat = UIButton(type: .custom)
    private var levelWrap: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = AfterHoursPalette.loungeCard
        contentView.layer.cornerRadius = 16
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 22
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        metaPlate.font = AfterHoursType.foyerCaption(11)
        metaPlate.textColor = UIColor.white.withAlphaComponent(0.65)
        metaPlate.translatesAutoresizingMaskIntoConstraints = false
        liveMark.image = NightSocialImageCabinet.named("LoungeLiveBadge", fallback: "Group_668@2x(1)")
        liveMark.contentMode = .scaleAspectFit
        liveMark.translatesAutoresizingMaskIntoConstraints = false
        chat.setImage(NightSocialImageCabinet.named("ChimeBubbleMark", fallback: "Group_819"), for: .normal)
        chat.imageView?.contentMode = .scaleAspectFit
        chat.addTarget(self, action: #selector(tapChat), for: .touchUpInside)
        chat.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(portrait)
        contentView.addSubview(namePlate)
        contentView.addSubview(metaPlate)
        contentView.addSubview(liveMark)
        contentView.addSubview(chat)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 44),
            portrait.heightAnchor.constraint(equalToConstant: 44),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor),
            liveMark.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 6),
            liveMark.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            liveMark.widthAnchor.constraint(equalToConstant: 40),
            liveMark.heightAnchor.constraint(equalToConstant: 16),
            metaPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            metaPlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
            chat.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            chat.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chat.widthAnchor.constraint(equalToConstant: 36),
            chat.heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    required init?(coder: NSCoder) { nil }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 16, dy: 5)
    }
    func paint(_ desk: LoungeCreatorDesk) {
        portrait.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 88, height: 88))
        namePlate.text = "\(desk.spokenName)  \(desk.cityLabel)"
        metaPlate.text = "\(desk.followerCount) followers"
        liveMark.isHidden = !desk.isLive
        levelWrap?.removeFromSuperview()
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)
        levelWrap = level
        contentView.addSubview(level)
        NSLayoutConstraint.activate([
            level.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            level.topAnchor.constraint(equalTo: metaPlate.bottomAnchor, constant: 2),
        ])
    }
    @objc private func tapChat() { onChat?() }
}
