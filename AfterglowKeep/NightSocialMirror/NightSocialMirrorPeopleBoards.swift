import UIKit

enum MirrorPeopleKind {
    case blacklist
    case fans
    case follow
    case friends

    var spokenTitle: String {
        switch self {
        case .blacklist: return NightLang.t(.blacklist)
        case .fans: return NightLang.t(.followers)
        case .follow: return NightLang.t(.following)
        case .friends: return NightLang.t(.friends)
        }
    }
}

final class NightSocialMirrorPeopleBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let kind: MirrorPeopleKind
    private let table = UITableView()
    private var desks: [LoungeCreatorDesk] = []

    init(kind: MirrorPeopleKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = kind.spokenTitle
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(MirrorPersonRow.self, forCellReuseIdentifier: MirrorPersonRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows), name: .deskDrawerDidChange, object: nil)
        reloadRows()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func reloadRows() {
        switch kind {
        case .blacklist:
            desks = NightSocialSessionDrawer.shared.blockedDeskKeys().compactMap { NightSocialLoungeCatalog.creator(deskKey: $0) }
        case .fans:
            desks = NightSocialSessionDrawer.shared.fanDeskKeys().compactMap { NightSocialLoungeCatalog.creator(deskKey: $0) }
        case .follow:
            desks = NightSocialSessionDrawer.shared.followedDeskKeys().compactMap { NightSocialLoungeCatalog.creator(deskKey: $0) }
                .filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
        case .friends:
            desks = NightSocialSessionDrawer.shared.acceptedFriendKeys().compactMap { NightSocialLoungeCatalog.creator(deskKey: $0) }
                .filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
        }
        table.reloadData()
        view.viewWithTag(88)?.removeFromSuperview()
        guard desks.isEmpty else { return }
        let spoken: String
        switch kind {
        case .blacklist:
            spoken = "No blocked desks.\nBlock someone and they sit here until you lift it."
        case .fans:
            spoken = "No followers yet.\nPeople who follow you appear here."
        case .follow:
            spoken = "You are not following anyone yet."
        case .friends:
            spoken = "No friends yet.\nA friend ask waits for the other desk to agree."
        }
        let empty = NightSocialEmptyPane(spoken: spoken)
        empty.tag = 88
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: table.centerYAnchor, constant: -24),
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { desks.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 76 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MirrorPersonRow.reuseId, for: indexPath) as! MirrorPersonRow
        let desk = desks[indexPath.row]
        cell.paint(desk, kind: kind)
        cell.onTrash = { [weak self] in
            NightSocialSessionDrawer.shared.unblockDesk(desk.deskKey)
            self?.reloadRows()
        }
        cell.onChat = { [weak self] in
            self?.navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: desk.deskKey), animated: true)
        }
        cell.onFollowTap = { [weak self] in
            NightSocialSessionDrawer.shared.toggleFollow(desk.deskKey)
            self?.reloadRows()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if kind == .blacklist { return }
        navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: desks[indexPath.row].deskKey), animated: true)
    }
}

final class MirrorPersonRow: UITableViewCell {
    static let reuseId = "MirrorPersonRow"
    var onTrash: (() -> Void)?
    var onChat: (() -> Void)?
    var onFollowTap: (() -> Void)?
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let trash = UIButton(type: .custom)
    private let chat = UIButton(type: .custom)
    private let follow = UIButton(type: .custom)
    private var followWidth: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = AfterHoursPalette.loungeCard
        contentView.layer.cornerRadius = 16
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 20
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        trash.setImage(NightSocialImageCabinet.named("TrashIcon", fallback: "TrashIcon"), for: .normal)
        trash.addTarget(self, action: #selector(tapTrash), for: .touchUpInside)
        chat.setImage(NightSocialImageCabinet.named("ChatBubble", fallback: "ChatBubble"), for: .normal)
        chat.addTarget(self, action: #selector(tapChat), for: .touchUpInside)
        follow.titleLabel?.font = AfterHoursType.foyerCaption(12)
        follow.layer.cornerRadius = 14
        follow.addTarget(self, action: #selector(tapUnfollow), for: .touchUpInside)
        [trash, chat, follow].forEach {
            $0.imageView?.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.addSubview(portrait)
        contentView.addSubview(namePlate)
        contentView.addSubview(trash)
        contentView.addSubview(chat)
        contentView.addSubview(follow)
        followWidth = follow.widthAnchor.constraint(equalToConstant: 76)
        NSLayoutConstraint.activate([
            followWidth,
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 40),
            portrait.heightAnchor.constraint(equalToConstant: 40),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            namePlate.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            namePlate.trailingAnchor.constraint(lessThanOrEqualTo: follow.leadingAnchor, constant: -8),
            trash.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trash.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trash.widthAnchor.constraint(equalToConstant: 32),
            trash.heightAnchor.constraint(equalToConstant: 32),
            chat.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            chat.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chat.widthAnchor.constraint(equalToConstant: 32),
            chat.heightAnchor.constraint(equalToConstant: 32),
            follow.trailingAnchor.constraint(equalTo: chat.leadingAnchor, constant: -8),
            follow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            follow.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    required init?(coder: NSCoder) { nil }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 16, dy: 5)
    }
    func paint(_ desk: LoungeCreatorDesk, kind: MirrorPeopleKind) {
        portrait.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 80, height: 80))
        namePlate.text = desk.spokenName
        trash.isHidden = kind != .blacklist
        chat.isHidden = kind == .blacklist
        let following = NightSocialSessionDrawer.shared.isFollowing(desk.deskKey)
        switch kind {
        case .follow:
            follow.isHidden = false
            styleFollow(title: NightLang.t(.unfollow), filled: false)
        case .fans:
            follow.isHidden = false
            if following {
                styleFollow(title: NightLang.t(.followed), filled: false)
            } else {
                styleFollow(title: NightLang.t(.plusFollow), filled: true)
            }
        default:
            follow.isHidden = true
        }
        followWidth.constant = follow.isHidden ? 0 : 76
    }

    private func styleFollow(title: String, filled: Bool) {
        follow.setTitle("  \(title)  ", for: .normal)
        follow.setImage(nil, for: .normal)
        follow.backgroundColor = filled ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.14)
        follow.setTitleColor(filled ? .white : AfterHoursPalette.loungePink, for: .normal)
    }

    @objc private func tapTrash() { onTrash?() }
    @objc private func tapChat() { onChat?() }
    @objc private func tapUnfollow() { onFollowTap?() }
}
