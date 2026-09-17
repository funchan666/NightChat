import UIKit

enum ChimeNoticeKind {
    case platform
    case likes

    var spokenTitle: String {
        switch self {
        case .platform: return "Platform"
        case .likes: return "Likes"
        }
    }

    var kicker: String {
        switch self {
        case .platform: return "Notes from NightChat"
        case .likes: return "Who liked your posts"
        }
    }

    var notices: [ChimeNotice] {
        switch self {
        case .platform: return NightSocialChimeCatalog.platformNotices
        case .likes: return NightSocialChimeCatalog.likeNotices
        }
    }
}

final class NightSocialChimeNoticeBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let kind: ChimeNoticeKind
    private let table = UITableView()

    init(kind: ChimeNoticeKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        navigationController?.setNavigationBarHidden(true, animated: false)
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = kind.spokenTitle
        head.font = AfterHoursType.foyerHeadline(22)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = kind.kicker
        kicker.font = AfterHoursType.foyerCaption(13)
        kicker.textColor = UIColor.white.withAlphaComponent(0.55)
        kicker.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 108
        table.register(ChimeNoticeRow.self, forCellReuseIdentifier: ChimeNoticeRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 28, right: 0)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(kicker)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 10),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor, constant: -8),
            kicker.leadingAnchor.constraint(equalTo: head.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 1),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 18),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { kind.notices.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeNoticeRow.reuseId, for: indexPath) as! ChimeNoticeRow
        cell.paint(kind.notices[indexPath.row], likes: kind == .likes)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notice = kind.notices[indexPath.row]
        if let clipKey = notice.clipKey {
            navigationController?.pushViewController(NightSocialClipTheater(clipKey: clipKey), animated: true)
        } else if let deskKey = notice.speakerDeskKey {
            NightSocialDeskGate.revealDesk(from: self, deskKey: deskKey)
        }
    }
}

final class ChimeNoticeRow: UITableViewCell {
    static let reuseId = "ChimeNoticeRow"
    private let card = UIView()
    private let disc = UIView()
    private let glyph = UIImageView()
    private let portrait = UIImageView()
    private let heartBadge = UIImageView()
    private let titlePlate = UILabel()
    private let bodyPlate = UILabel()
    private let clock = UILabel()
    private let thumb = UIImageView()
    private var thumbWidth: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        disc.layer.cornerRadius = 22
        disc.translatesAutoresizingMaskIntoConstraints = false
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        portrait.contentMode = .scaleAspectFill
        portrait.clipsToBounds = true
        portrait.layer.cornerRadius = 22
        portrait.translatesAutoresizingMaskIntoConstraints = false
        heartBadge.image = UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .bold))
        heartBadge.tintColor = .white
        heartBadge.backgroundColor = AfterHoursPalette.loungePink
        heartBadge.layer.cornerRadius = 8
        heartBadge.clipsToBounds = true
        heartBadge.contentMode = .center
        heartBadge.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        bodyPlate.font = AfterHoursType.foyerBody(13)
        bodyPlate.textColor = UIColor.white.withAlphaComponent(0.68)
        bodyPlate.numberOfLines = 2
        bodyPlate.translatesAutoresizingMaskIntoConstraints = false
        clock.font = AfterHoursType.foyerCaption(11)
        clock.textColor = UIColor.white.withAlphaComponent(0.42)
        clock.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 12
        thumb.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(disc)
        disc.addSubview(glyph)
        card.addSubview(portrait)
        card.addSubview(heartBadge)
        card.addSubview(titlePlate)
        card.addSubview(bodyPlate)
        card.addSubview(clock)
        card.addSubview(thumb)
        thumbWidth = thumb.widthAnchor.constraint(equalToConstant: 52)
        NSLayoutConstraint.activate([
            thumbWidth,
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            disc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            disc.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            disc.widthAnchor.constraint(equalToConstant: 44),
            disc.heightAnchor.constraint(equalToConstant: 44),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            portrait.leadingAnchor.constraint(equalTo: disc.leadingAnchor),
            portrait.topAnchor.constraint(equalTo: disc.topAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 44),
            portrait.heightAnchor.constraint(equalToConstant: 44),
            heartBadge.trailingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 3),
            heartBadge.bottomAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 3),
            heartBadge.widthAnchor.constraint(equalToConstant: 16),
            heartBadge.heightAnchor.constraint(equalToConstant: 16),
            titlePlate.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 12),
            titlePlate.trailingAnchor.constraint(lessThanOrEqualTo: thumb.leadingAnchor, constant: -12),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            bodyPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            bodyPlate.trailingAnchor.constraint(equalTo: titlePlate.trailingAnchor),
            bodyPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 3),
            clock.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            clock.topAnchor.constraint(equalTo: bodyPlate.bottomAnchor, constant: 6),
            clock.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            thumb.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            thumb.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumb.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ notice: ChimeNotice, likes: Bool) {
        titlePlate.text = notice.spokenTitle
        bodyPlate.text = notice.spokenBody
        clock.text = Self.clockPhrase(notice.minutesAgo)
        let tints = [
            AfterHoursPalette.loungePink,
            AfterHoursPalette.levelMint,
            UIColor(red: 1, green: 0.78, blue: 0.32, alpha: 1),
        ]
        let tint = tints[min(notice.tintKind, tints.count - 1)]
        disc.backgroundColor = tint.withAlphaComponent(0.18)
        glyph.image = UIImage(systemName: notice.glyph, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        glyph.tintColor = tint
        if likes, let deskKey = notice.speakerDeskKey {
            portrait.image = NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 88, height: 88))
            portrait.isHidden = false
            disc.isHidden = true
            heartBadge.isHidden = false
        } else {
            portrait.isHidden = true
            disc.isHidden = false
            heartBadge.isHidden = true
        }
        if likes, let clipKey = notice.clipKey {
            thumb.image = NightSocialMediaAssets.clipCover(clipKey, size: CGSize(width: 104, height: 104))
            thumb.isHidden = false
            thumbWidth.constant = 52
        } else {
            thumb.isHidden = true
            thumbWidth.constant = 0
        }
    }

    private static func clockPhrase(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        return "\(hours / 24)d ago"
    }
}
