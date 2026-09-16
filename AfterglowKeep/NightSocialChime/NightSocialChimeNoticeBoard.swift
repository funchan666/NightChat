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
        case .platform: return "House notes for this desk"
        case .likes: return "Who warmed your sitting"
        }
    }

    var symbol: String {
        switch self {
        case .platform: return "bell.fill"
        case .likes: return "heart.fill"
        }
    }

    var tint: UIColor {
        switch self {
        case .platform: return AfterHoursPalette.loungePink
        case .likes: return AfterHoursPalette.foyerGlowPink
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
        let disc = UIView()
        disc.backgroundColor = kind.tint.withAlphaComponent(0.2)
        disc.layer.cornerRadius = 16
        disc.translatesAutoresizingMaskIntoConstraints = false
        let glyph = UIImageView(image: UIImage(systemName: kind.symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)))
        glyph.tintColor = kind.tint
        glyph.translatesAutoresizingMaskIntoConstraints = false
        let head = UILabel()
        head.text = kind.spokenTitle
        head.font = AfterHoursType.foyerHeadline(22)
        head.textColor = .white
        let kicker = UILabel()
        kicker.text = kind.kicker
        kicker.font = AfterHoursType.foyerCaption(12)
        kicker.textColor = UIColor.white.withAlphaComponent(0.55)
        let titleBlock = UIStackView(arrangedSubviews: [head, kicker])
        titleBlock.axis = .vertical
        titleBlock.spacing = 1
        titleBlock.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 92
        table.register(ChimeNoticeRow.self, forCellReuseIdentifier: ChimeNoticeRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        view.addSubview(back)
        view.addSubview(disc)
        disc.addSubview(glyph)
        view.addSubview(titleBlock)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            disc.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disc.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 32),
            disc.heightAnchor.constraint(equalToConstant: 32),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            titleBlock.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 10),
            titleBlock.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
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
    private let titlePlate = UILabel()
    private let bodyPlate = UILabel()
    private let clock = UILabel()
    private let thumb = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        disc.layer.cornerRadius = 18
        disc.translatesAutoresizingMaskIntoConstraints = false
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        portrait.contentMode = .scaleAspectFill
        portrait.clipsToBounds = true
        portrait.layer.cornerRadius = 18
        portrait.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(15)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        bodyPlate.font = AfterHoursType.foyerCaption(12)
        bodyPlate.textColor = UIColor.white.withAlphaComponent(0.62)
        bodyPlate.translatesAutoresizingMaskIntoConstraints = false
        clock.font = AfterHoursType.foyerCaption(11)
        clock.textColor = UIColor.white.withAlphaComponent(0.38)
        clock.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 10
        thumb.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(disc)
        disc.addSubview(glyph)
        card.addSubview(portrait)
        card.addSubview(titlePlate)
        card.addSubview(bodyPlate)
        card.addSubview(clock)
        card.addSubview(thumb)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            disc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            disc.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 36),
            disc.heightAnchor.constraint(equalToConstant: 36),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 36),
            portrait.heightAnchor.constraint(equalToConstant: 36),
            titlePlate.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 12),
            titlePlate.trailingAnchor.constraint(lessThanOrEqualTo: thumb.leadingAnchor, constant: -10),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            bodyPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            bodyPlate.trailingAnchor.constraint(equalTo: titlePlate.trailingAnchor),
            bodyPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 2),
            clock.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            clock.topAnchor.constraint(equalTo: bodyPlate.bottomAnchor, constant: 4),
            thumb.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            thumb.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumb.widthAnchor.constraint(equalToConstant: 44),
            thumb.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ notice: ChimeNotice, likes: Bool) {
        titlePlate.text = notice.spokenTitle
        bodyPlate.text = notice.spokenBody
        clock.text = "\(notice.minutesAgo) min ago"
        let tint = likes ? AfterHoursPalette.foyerGlowPink : AfterHoursPalette.loungePink
        disc.backgroundColor = tint.withAlphaComponent(0.18)
        glyph.image = UIImage(systemName: likes ? "heart.fill" : "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        glyph.tintColor = tint
        if let deskKey = notice.speakerDeskKey {
            portrait.image = NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 72, height: 72))
            portrait.isHidden = false
            disc.isHidden = true
        } else {
            portrait.isHidden = true
            disc.isHidden = false
        }
        if let clipKey = notice.clipKey {
            thumb.image = NightSocialMediaAssets.clipCover(clipKey, size: CGSize(width: 88, height: 88))
            thumb.isHidden = false
        } else {
            thumb.isHidden = true
        }
    }
}
