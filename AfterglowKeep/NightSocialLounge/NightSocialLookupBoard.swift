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
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        let searchWell = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        let glass = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)))
        glass.tintColor = UIColor.white.withAlphaComponent(0.45)
        glass.frame = CGRect(x: 12, y: 10, width: 16, height: 16)
        searchWell.addSubview(glass)
        field.leftView = searchWell
        field.leftViewMode = .always
        field.delegate = self
        field.addTarget(self, action: #selector(rewriteHits), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.keyboardDismissMode = .onDrag
        table.contentInsetAdjustmentBehavior = .never
        table.rowHeight = 80
        table.estimatedRowHeight = 80
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
        table.backgroundView = hits.isEmpty
            ? NightSocialEmptyPane.tableBackdrop(spoken: "No desks match this search.")
            : nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    private let levelPlate = UILabel()
    private let chevron = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        portrait.contentMode = .scaleAspectFill
        portrait.clipsToBounds = true
        portrait.layer.cornerRadius = 24
        portrait.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        portrait.translatesAutoresizingMaskIntoConstraints = false

        namePlate.font = AfterHoursType.foyerPill(16)
        namePlate.textColor = .white
        namePlate.numberOfLines = 1
        namePlate.lineBreakMode = .byTruncatingTail
        namePlate.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        namePlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        metaPlate.font = AfterHoursType.foyerCaption(12)
        metaPlate.textColor = UIColor.white.withAlphaComponent(0.55)
        metaPlate.numberOfLines = 1
        metaPlate.lineBreakMode = .byTruncatingTail
        metaPlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        liveMark.image = NightSocialImageCabinet.named("LiveBadge", fallback: "LiveBadge")
        liveMark.contentMode = .scaleAspectFit
        liveMark.setContentHuggingPriority(.required, for: .horizontal)
        liveMark.setContentCompressionResistancePriority(.required, for: .horizontal)
        liveMark.translatesAutoresizingMaskIntoConstraints = false

        let levelCloth = UIImageView(image: NightSocialImageCabinet.named("LevelBadge", fallback: "LevelBadge"))
        levelCloth.contentMode = .scaleToFill
        levelCloth.translatesAutoresizingMaskIntoConstraints = false
        levelPlate.textColor = AfterHoursPalette.inkOnSnow
        levelPlate.font = AfterHoursType.foyerCaption(10)
        levelPlate.textAlignment = .center
        levelPlate.translatesAutoresizingMaskIntoConstraints = false
        levelHost.translatesAutoresizingMaskIntoConstraints = false
        levelHost.addSubview(levelCloth)
        levelHost.addSubview(levelPlate)

        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.32)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

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
        textCol.spacing = 4
        textCol.clipsToBounds = true
        textCol.translatesAutoresizingMaskIntoConstraints = false
        textCol.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentView.addSubview(portrait)
        contentView.addSubview(textCol)
        contentView.addSubview(levelHost)
        contentView.addSubview(chevron)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            portrait.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 48),
            portrait.heightAnchor.constraint(equalToConstant: 48),
            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 8),
            chevron.heightAnchor.constraint(equalToConstant: 14),
            levelHost.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
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
            textCol.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            textCol.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textCol.trailingAnchor.constraint(equalTo: levelHost.leadingAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ desk: LoungeCreatorDesk) {
        portrait.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 144, height: 144))
        namePlate.text = desk.spokenName
        metaPlate.text = "\(desk.handleTag)  ·  \(desk.cityLabel)"
        liveMark.isHidden = !desk.isLive
        levelPlate.text = "Lv.\(desk.levelMark)"
    }
}
