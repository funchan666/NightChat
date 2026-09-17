import UIKit

final class NightSocialLookupBoard: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private let field = UITextField()
    private let table = UITableView()
    private var hits: [LoungeCreatorDesk] = NightSocialLoungeCatalog.creators

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)

        field.placeholder = "Search songs, users"
        field.attributedPlaceholder = NSAttributedString(string: "Search songs, users", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)])
        field.textColor = .white
        field.font = AfterHoursType.foyerBody(14)
        field.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 36))
        field.leftViewMode = .always
        field.delegate = self
        field.addTarget(self, action: #selector(rewriteHits), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.register(LookupDeskRow.self, forCellReuseIdentifier: LookupDeskRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(back)
        view.addSubview(field)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            field.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            field.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            field.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        rewriteHits()
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func rewriteHits() {
        let query = NightSocialFoyerGuard.trimmed(field.text).lowercased()
        hits = NightSocialLoungeCatalog.creators.filter { desk in
            guard !NightSocialSessionDrawer.shared.shouldHideDesk(desk.deskKey) else { return false }
            if query.isEmpty { return true }
            return desk.spokenName.lowercased().contains(query)
                || desk.cityLabel.lowercased().contains(query)
                || desk.handleTag.lowercased().contains(query)
                || desk.musicTitle.lowercased().contains(query)
        }
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { hits.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LookupDeskRow.reuseId, for: indexPath) as! LookupDeskRow
        cell.paint(hits[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: hits[indexPath.row].deskKey), animated: true)
    }
}

final class LookupDeskRow: UITableViewCell {
    static let reuseId = "LookupDeskRow"
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let metaPlate = UILabel()
    private let liveMark = UIImageView()
    private let levelHost = UIView()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 24
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(16)
        namePlate.textColor = .white
        namePlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        metaPlate.font = AfterHoursType.foyerCaption(12)
        metaPlate.textColor = UIColor.white.withAlphaComponent(0.58)
        metaPlate.lineBreakMode = .byTruncatingTail
        metaPlate.translatesAutoresizingMaskIntoConstraints = false
        liveMark.image = NightSocialImageCabinet.named("LiveBadge", fallback: "LiveBadge")
        liveMark.contentMode = .scaleAspectFit
        liveMark.setContentCompressionResistancePriority(.required, for: .horizontal)
        liveMark.translatesAutoresizingMaskIntoConstraints = false
        levelHost.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = UIColor.white.withAlphaComponent(0.35)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(portrait)
        contentView.addSubview(namePlate)
        contentView.addSubview(metaPlate)
        contentView.addSubview(liveMark)
        contentView.addSubview(levelHost)
        contentView.addSubview(chevron)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 48),
            portrait.heightAnchor.constraint(equalToConstant: 48),
            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            levelHost.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            levelHost.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            levelHost.widthAnchor.constraint(equalToConstant: 52),
            levelHost.heightAnchor.constraint(equalToConstant: 18),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor, constant: 4),
            liveMark.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 8),
            liveMark.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            liveMark.widthAnchor.constraint(equalToConstant: 40),
            liveMark.heightAnchor.constraint(equalToConstant: 16),
            liveMark.trailingAnchor.constraint(lessThanOrEqualTo: levelHost.leadingAnchor, constant: -8),
            metaPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            metaPlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 5),
            metaPlate.trailingAnchor.constraint(equalTo: levelHost.leadingAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ desk: LoungeCreatorDesk) {
        portrait.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 144, height: 144))
        namePlate.text = desk.spokenName
        metaPlate.text = "\(desk.handleTag)  ·  \(desk.cityLabel)"
        liveMark.isHidden = !desk.isLive
        levelHost.subviews.forEach { $0.removeFromSuperview() }
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)
        levelHost.addSubview(level)
        NSLayoutConstraint.activate([
            level.topAnchor.constraint(equalTo: levelHost.topAnchor),
            level.leadingAnchor.constraint(equalTo: levelHost.leadingAnchor),
            level.trailingAnchor.constraint(equalTo: levelHost.trailingAnchor),
            level.bottomAnchor.constraint(equalTo: levelHost.bottomAnchor),
        ])
    }
}
