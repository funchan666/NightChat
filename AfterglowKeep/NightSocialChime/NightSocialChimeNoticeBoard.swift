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

    var notices: [ChimeNotice] {
        switch self {
        case .platform: return NightSocialChimeCatalog.platformNotices
        case .likes: return NightSocialChimeCatalog.likeNotices
        }
    }
}

final class NightSocialChimeNoticeBoard: UIViewController, UITableViewDataSource {
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
        table.register(ChimeNoticeRow.self, forCellReuseIdentifier: ChimeNoticeRow.reuseId)
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
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { kind.notices.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 88 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeNoticeRow.reuseId, for: indexPath) as! ChimeNoticeRow
        cell.paint(kind.notices[indexPath.row], likes: kind == .likes)
        return cell
    }
}

final class ChimeNoticeRow: UITableViewCell {
    static let reuseId = "ChimeNoticeRow"
    private let card = UILabel()
    private let clock = UILabel()
    private let dot = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.numberOfLines = 0
        card.font = AfterHoursType.foyerBody(14)
        card.textColor = .white
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        clock.font = AfterHoursType.foyerCaption(11)
        clock.textColor = UIColor.white.withAlphaComponent(0.45)
        clock.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        contentView.addSubview(clock)
        contentView.addSubview(dot)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -36),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            clock.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            clock.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 4),
            clock.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            dot.leadingAnchor.constraint(equalTo: card.trailingAnchor, constant: 8),
            dot.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
        ])
    }
    required init?(coder: NSCoder) { nil }
    func paint(_ notice: ChimeNotice, likes: Bool) {
        card.text = "  \(notice.spokenBody)  "
        clock.text = "\(notice.minutesAgo) min ago"
        dot.backgroundColor = likes ? AfterHoursPalette.levelMint : AfterHoursPalette.loungePink
    }
}
