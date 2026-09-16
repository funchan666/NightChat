import UIKit

final class NightSocialWaveRankSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let chamber: WaveVoiceChamber
    private let rows: [LoungeCreatorDesk]
    init(chamber: WaveVoiceChamber) {
        self.chamber = chamber
        self.rows = chamber.seatDeskKeys.compactMap { NightSocialLoungeCatalog.creator(deskKey: $0) }
            .filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Voice Room Rank"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "wrank")
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            table.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wrank", for: indexPath)
        let desk = rows[indexPath.row]
        cell.backgroundColor = AfterHoursPalette.loungeInk.withAlphaComponent(0.4)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "\(indexPath.row + 1)  \(desk.spokenName)    \(840 - indexPath.row * 200)"
        cell.imageView?.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 48, height: 48))
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialDeskGate.revealDesk(from: self, deskKey: rows[indexPath.row].deskKey)
    }
}

final class NightSocialWaveGoalSheet: UIViewController {
    private let chamber: WaveVoiceChamber
    init(chamber: WaveVoiceChamber) {
        self.chamber = chamber
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Room Goal"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "Help \(NightSocialWaveCatalog.hostName(chamber)) climb today's room board."
        body.font = AfterHoursType.foyerBody(13)
        body.textColor = UIColor.white.withAlphaComponent(0.75)
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let heat = metric("\(chamber.heatScore)", "Heat")
        let gifts = metric("+0", "Gifts")
        let balance = metric("\(NightSocialSessionDrawer.shared.diamondPurse)", "Balance")
        let row = UIStackView(arrangedSubviews: [heat, gifts, balance])
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        let recharge = NightSocialLoungeChrome.pinkPill(title: "Open night purse")
        recharge.addTarget(self, action: #selector(rechargePurse), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(body)
        view.addSubview(row)
        view.addSubview(recharge)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            row.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            row.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 16),
            row.heightAnchor.constraint(equalToConstant: 72),
            recharge.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            recharge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            recharge.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 18),
        ])
    }
    private func metric(_ value: String, _ label: String) -> UIView {
        let wrap = UIView()
        wrap.backgroundColor = AfterHoursPalette.loungeInk.withAlphaComponent(0.5)
        wrap.layer.cornerRadius = 14
        let a = UILabel()
        a.text = value
        a.font = AfterHoursType.foyerHeadline(20)
        a.textColor = .white
        a.textAlignment = .center
        a.translatesAutoresizingMaskIntoConstraints = false
        let b = UILabel()
        b.text = label
        b.font = AfterHoursType.foyerCaption(12)
        b.textColor = UIColor.white.withAlphaComponent(0.7)
        b.textAlignment = .center
        b.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(a)
        wrap.addSubview(b)
        NSLayoutConstraint.activate([
            a.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            a.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 12),
            b.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            b.topAnchor.constraint(equalTo: a.bottomAnchor, constant: 4),
        ])
        return wrap
    }
    @objc private func rechargePurse() {
        NightSocialLampStore.revealRecharge(from: self)
    }
}

final class NightSocialWaveHostPicksSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private weak var nav: UINavigationController?
    private let table = UITableView()
    private let rows: [WaveVoiceChamber] = {
        let hot = NightSocialWaveCatalog.chambers.filter {
            $0.isLive && NightSocialLoungeCatalog.creator(deskKey: $0.hostDeskKey)?.isHot == true
                && !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey)
        }
        if !hot.isEmpty { return hot }
        return NightSocialWaveCatalog.chambers.filter { $0.isLive && !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey) }
    }()

    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.large()]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 24
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Featured Hosts"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "\(rows.count) online hosts picked for voice rooms"
        kicker.font = AfterHoursType.foyerCaption(12)
        kicker.textColor = UIColor.white.withAlphaComponent(0.55)
        kicker.translatesAutoresizingMaskIntoConstraints = false
        let metrics = WaveSheetMetricsRow(items: [
            ("\(rows.count)", "Live"),
            ("235.2k", "Followers"),
            ("\(Set(rows.compactMap { NightSocialLoungeCatalog.creator(deskKey: $0.hostDeskKey)?.cityLabel }).count)", "Regions"),
        ])
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 108
        table.register(WaveHostPickRow.self, forCellReuseIdentifier: WaveHostPickRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        let join = NightSocialLoungeChrome.pinkPill(title: "Join \(firstHostFirstName())'s room")
        join.heightAnchor.constraint(equalToConstant: 48).isActive = true
        join.addTarget(self, action: #selector(joinFirst), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(kicker)
        view.addSubview(metrics)
        view.addSubview(table)
        view.addSubview(join)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            kicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            metrics.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metrics.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            metrics.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 14),
            metrics.heightAnchor.constraint(equalToConstant: 64),
            table.topAnchor.constraint(equalTo: metrics.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: join.topAnchor, constant: -12),
            join.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            join.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            join.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }
    private func firstHostFirstName() -> String {
        let name = NightSocialWaveCatalog.hostName(rows.first ?? NightSocialWaveCatalog.chambers[0])
        return name.split(separator: " ").first.map(String.init) ?? name
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaveHostPickRow.reuseId, for: indexPath) as! WaveHostPickRow
        cell.paint(rows[indexPath.row])
        cell.onFollow = { [weak tableView] in tableView?.reloadRows(at: [indexPath], with: .none) }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        join(rows[indexPath.row])
    }
    @objc private func joinFirst() {
        guard let first = rows.first else { return }
        join(first)
    }
    private func join(_ chamber: WaveVoiceChamber) {
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveVoiceStage(chamberKey: chamber.chamberKey), animated: true)
        }
    }
}

final class NightSocialWaveOpenRoomsSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private weak var nav: UINavigationController?
    private let allRows = NightSocialWaveCatalog.chambers.filter { $0.isLive && !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey) }
    private var filter = 0
    private let table = UITableView()
    private var chipRow: UIStackView?
    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.large()]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 24
    }
    required init?(coder: NSCoder) { nil }
    private var rows: [WaveVoiceChamber] {
        switch filter {
        case 1: return allRows.filter { $0.heatScore >= 2000 }
        case 2: return allRows.filter { $0.vibeTags.contains("Voice") }
        case 3: return allRows.filter { $0.vibeTags.contains("Music") }
        default: return allRows
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Open Rooms"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "\(allRows.count) rooms ready to join"
        kicker.font = AfterHoursType.foyerCaption(12)
        kicker.textColor = UIColor.white.withAlphaComponent(0.55)
        kicker.translatesAutoresizingMaskIntoConstraints = false
        let listeners = allRows.reduce(0) { $0 + $1.listenerCount }
        let heat = allRows.reduce(0) { $0 + $1.heatScore }
        let metrics = WaveSheetMetricsRow(items: [
            ("\(allRows.count)", "Open"),
            ("\(listeners)", "Listeners"),
            (heat >= 1000 ? String(format: "%.1fk", Double(heat) / 1000) : "\(heat)", "Heat"),
        ])
        let chips = UIStackView()
        chips.axis = .horizontal
        chips.spacing = 8
        chips.translatesAutoresizingMaskIntoConstraints = false
        chipRow = chips
        for (index, title) in ["Recommended", "Hot", "Voice", "Music"].enumerated() {
            let chip = UIButton(type: .custom)
            chip.setTitle("  \(title)  ", for: .normal)
            chip.titleLabel?.font = AfterHoursType.foyerCaption(12)
            chip.layer.cornerRadius = 14
            chip.tag = index
            chip.addTarget(self, action: #selector(pickFilter(_:)), for: .touchUpInside)
            chip.heightAnchor.constraint(equalToConstant: 28).isActive = true
            chips.addArrangedSubview(chip)
        }
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 118
        table.register(WaveOpenRoomRow.self, forCellReuseIdentifier: WaveOpenRoomRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        let join = NightSocialLoungeChrome.pinkPill(title: "Join \(firstHostFirstName())'s room")
        join.heightAnchor.constraint(equalToConstant: 48).isActive = true
        join.addTarget(self, action: #selector(joinFirst), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(kicker)
        view.addSubview(metrics)
        view.addSubview(chips)
        view.addSubview(table)
        view.addSubview(join)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            kicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            metrics.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metrics.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            metrics.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 14),
            metrics.heightAnchor.constraint(equalToConstant: 64),
            chips.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chips.topAnchor.constraint(equalTo: metrics.bottomAnchor, constant: 12),
            table.topAnchor.constraint(equalTo: chips.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: join.topAnchor, constant: -12),
            join.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            join.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            join.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
        paintChips()
    }
    private func firstHostFirstName() -> String {
        let name = NightSocialWaveCatalog.hostName(allRows.first ?? NightSocialWaveCatalog.chambers[0])
        return name.split(separator: " ").first.map(String.init) ?? name
    }
    @objc private func pickFilter(_ sender: UIButton) {
        filter = sender.tag
        paintChips()
        table.reloadData()
    }
    private func paintChips() {
        chipRow?.arrangedSubviews.enumerated().forEach { index, view in
            guard let chip = view as? UIButton else { return }
            let on = index == filter
            chip.backgroundColor = on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.10)
            chip.setTitleColor(on ? .white : UIColor.white.withAlphaComponent(0.7), for: .normal)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaveOpenRoomRow.reuseId, for: indexPath) as! WaveOpenRoomRow
        cell.paint(rows[indexPath.row])
        cell.onJoin = { [weak self] in
            guard let self else { return }
            self.join(self.rows[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        join(rows[indexPath.row])
    }
    @objc private func joinFirst() {
        guard let first = rows.first ?? allRows.first else { return }
        join(first)
    }
    private func join(_ chamber: WaveVoiceChamber) {
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveVoiceStage(chamberKey: chamber.chamberKey), animated: true)
        }
    }
}

final class WaveSheetMetricsRow: UIStackView {
    init(items: [(String, String)]) {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 8
        distribution = .fillEqually
        translatesAutoresizingMaskIntoConstraints = false
        for (value, label) in items {
            let wrap = UIView()
            wrap.backgroundColor = AfterHoursPalette.loungeInk.withAlphaComponent(0.45)
            wrap.layer.cornerRadius = 14
            let a = UILabel()
            a.text = value
            a.font = AfterHoursType.foyerHeadline(20)
            a.textColor = .white
            a.textAlignment = .center
            a.translatesAutoresizingMaskIntoConstraints = false
            let b = UILabel()
            b.text = label
            b.font = AfterHoursType.foyerCaption(11)
            b.textColor = UIColor.white.withAlphaComponent(0.55)
            b.textAlignment = .center
            b.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(a)
            wrap.addSubview(b)
            NSLayoutConstraint.activate([
                a.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                a.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 10),
                b.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                b.topAnchor.constraint(equalTo: a.bottomAnchor, constant: 2),
            ])
            addArrangedSubview(wrap)
        }
    }
    required init(coder: NSCoder) { fatalError("init(coder:)") }
}

final class WaveHostPickRow: UITableViewCell {
    static let reuseId = "WaveHostPickRow"
    var onFollow: (() -> Void)?
    private var deskKey = ""
    private let card = UIView()
    private let portrait = UIImageView()
    private let hot = UIImageView()
    private let titlePlate = UILabel()
    private let hostPlate = UILabel()
    private let follow = UIButton(type: .custom)
    private let listenMark = UIImageView()
    private let listenPlate = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AfterHoursPalette.loungeInk.withAlphaComponent(0.35)
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        portrait.layer.cornerRadius = 28
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 2
        portrait.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false
        hot.image = NightSocialImageCabinet.named("LoungeHotBadge", fallback: "Group_734")
        hot.contentMode = .scaleAspectFit
        hot.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        follow.titleLabel?.font = AfterHoursType.foyerCaption(12)
        follow.layer.cornerRadius = 14
        follow.addTarget(self, action: #selector(flipFollow), for: .touchUpInside)
        follow.translatesAutoresizingMaskIntoConstraints = false
        listenMark.image = UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        listenMark.tintColor = UIColor.white.withAlphaComponent(0.55)
        listenMark.translatesAutoresizingMaskIntoConstraints = false
        listenPlate.font = AfterHoursType.foyerCaption(12)
        listenPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        listenPlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(portrait)
        card.addSubview(hot)
        card.addSubview(titlePlate)
        card.addSubview(hostPlate)
        card.addSubview(follow)
        card.addSubview(listenMark)
        card.addSubview(listenPlate)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 56),
            portrait.heightAnchor.constraint(equalToConstant: 56),
            hot.leadingAnchor.constraint(equalTo: portrait.leadingAnchor, constant: -4),
            hot.topAnchor.constraint(equalTo: portrait.topAnchor, constant: -6),
            hot.widthAnchor.constraint(equalToConstant: 40),
            hot.heightAnchor.constraint(equalToConstant: 16),
            titlePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            hostPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hostPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 3),
            follow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            follow.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            follow.widthAnchor.constraint(equalToConstant: 78),
            follow.heightAnchor.constraint(equalToConstant: 28),
            listenPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            listenPlate.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            listenMark.trailingAnchor.constraint(equalTo: listenPlate.leadingAnchor, constant: -4),
            listenMark.centerYAnchor.constraint(equalTo: listenPlate.centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { nil }

    func paint(_ chamber: WaveVoiceChamber) {
        deskKey = chamber.hostDeskKey
        let host = NightSocialWaveCatalog.hostName(chamber)
        let first = host.split(separator: " ").first.map(String.init) ?? host
        portrait.image = NightSocialMediaAssets.portrait(for: chamber.hostDeskKey, size: CGSize(width: 112, height: 112))
        titlePlate.text = chamber.chamberTitle
        let line = NSMutableAttributedString(string: first, attributes: [
            .foregroundColor: AfterHoursPalette.loungePink,
            .font: AfterHoursType.foyerCaption(12),
        ])
        line.append(NSAttributedString(string: "  ·  \(chamber.moodLine)", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: AfterHoursType.foyerCaption(12),
        ]))
        hostPlate.attributedText = line
        listenPlate.text = "\(chamber.listenerCount)"
        let on = NightSocialSessionDrawer.shared.isFollowing(chamber.hostDeskKey)
        follow.setTitle(on ? "Following" : "Follow", for: .normal)
        follow.backgroundColor = on ? UIColor.white.withAlphaComponent(0.12) : AfterHoursPalette.loungePink
        follow.setTitleColor(.white, for: .normal)
    }

    @objc private func flipFollow() {
        NightSocialSessionDrawer.shared.toggleFollow(deskKey)
        onFollow?()
    }
}

final class WaveOpenRoomRow: UITableViewCell {
    static let reuseId = "WaveOpenRoomRow"
    var onJoin: (() -> Void)?
    private let card = UIView()
    private let portrait = UIImageView()
    private let titlePlate = UILabel()
    private let hostPlate = UILabel()
    private let heatPlate = UILabel()
    private let listenPlate = UILabel()
    private let tagRow = UIStackView()
    private let join = UIButton(type: .custom)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AfterHoursPalette.loungeInk.withAlphaComponent(0.35)
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        portrait.layer.cornerRadius = 28
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 2
        portrait.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        heatPlate.font = AfterHoursType.foyerCaption(12)
        heatPlate.textColor = UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        heatPlate.translatesAutoresizingMaskIntoConstraints = false
        listenPlate.font = AfterHoursType.foyerCaption(11)
        listenPlate.textColor = UIColor.white.withAlphaComponent(0.55)
        listenPlate.translatesAutoresizingMaskIntoConstraints = false
        tagRow.axis = .horizontal
        tagRow.spacing = 6
        tagRow.translatesAutoresizingMaskIntoConstraints = false
        join.setTitle("Join", for: .normal)
        join.setTitleColor(.white, for: .normal)
        join.titleLabel?.font = AfterHoursType.foyerCaption(12)
        join.backgroundColor = AfterHoursPalette.loungePink
        join.layer.cornerRadius = 14
        join.addTarget(self, action: #selector(tapJoin), for: .touchUpInside)
        join.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(portrait)
        card.addSubview(titlePlate)
        card.addSubview(hostPlate)
        card.addSubview(heatPlate)
        card.addSubview(listenPlate)
        card.addSubview(tagRow)
        card.addSubview(join)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 56),
            portrait.heightAnchor.constraint(equalToConstant: 56),
            titlePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            hostPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hostPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 2),
            heatPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            heatPlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            listenPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            listenPlate.topAnchor.constraint(equalTo: heatPlate.bottomAnchor, constant: 2),
            tagRow.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            tagRow.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            join.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            join.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            join.widthAnchor.constraint(equalToConstant: 56),
            join.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    required init?(coder: NSCoder) { nil }

    func paint(_ chamber: WaveVoiceChamber) {
        let host = NightSocialWaveCatalog.hostName(chamber)
        let first = host.split(separator: " ").first.map(String.init) ?? host
        portrait.image = NightSocialMediaAssets.portrait(for: chamber.hostDeskKey, size: CGSize(width: 112, height: 112))
        titlePlate.text = chamber.chamberTitle
        let line = NSMutableAttributedString(string: first, attributes: [
            .foregroundColor: AfterHoursPalette.loungePink,
            .font: AfterHoursType.foyerCaption(12),
        ])
        line.append(NSAttributedString(string: "  ·  \(chamber.moodLine)", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: AfterHoursType.foyerCaption(12),
        ]))
        hostPlate.attributedText = line
        heatPlate.text = "🔥 \(chamber.heatScore >= 1000 ? String(format: "%.1fk", Double(chamber.heatScore) / 1000) : "\(chamber.heatScore)")"
        listenPlate.text = "\(chamber.listenerCount) Listening"
        tagRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in chamber.vibeTags.prefix(2) {
            let plate = UILabel()
            plate.text = "  \(tag)  "
            plate.font = AfterHoursType.foyerCaption(10)
            plate.textColor = .white
            plate.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.78)
            plate.layer.cornerRadius = 8
            plate.clipsToBounds = true
            tagRow.addArrangedSubview(plate)
        }
        let live = UILabel()
        live.text = "  Live now  "
        live.font = AfterHoursType.foyerCaption(10)
        live.textColor = .white
        live.backgroundColor = AfterHoursPalette.levelMint.withAlphaComponent(0.85)
        live.layer.cornerRadius = 8
        live.clipsToBounds = true
        tagRow.addArrangedSubview(live)
    }

    @objc private func tapJoin() { onJoin?() }
}

final class NightSocialWaveCreateSheet: UIViewController {
    private weak var nav: UINavigationController?
    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [
            .custom(identifier: .init("create")) { _ in 216 }
        ]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 24
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Create"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let live = makeCreateCard(
            image: NightSocialImageCabinet.named("WaveGoLivePill", fallback: "Group_909"),
            action: #selector(goLive)
        )
        let post = makeCreateCard(
            image: NightSocialImageCabinet.named("WavePostPill", fallback: "Group_910"),
            action: #selector(postVideo)
        )
        view.addSubview(title)
        view.addSubview(live)
        view.addSubview(post)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            live.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            live.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            live.heightAnchor.constraint(equalToConstant: 88),
            live.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -6),
            post.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 6),
            post.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            post.centerYAnchor.constraint(equalTo: live.centerYAnchor),
            post.heightAnchor.constraint(equalToConstant: 88),
        ])
    }

    private func makeCreateCard(image: UIImage?, action: Selector) -> UIButton {
        let card = UIButton(type: .custom)
        card.setImage(image, for: .normal)
        card.imageView?.contentMode = .scaleAspectFill
        card.imageView?.clipsToBounds = true
        card.clipsToBounds = true
        card.layer.cornerRadius = 22
        card.adjustsImageWhenHighlighted = false
        card.addTarget(self, action: action, for: .touchUpInside)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    @objc private func goLive() {
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveGoLiveBoard(), animated: true)
        }
    }
    @objc private func postVideo() {
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWavePostBoard(), animated: true)
        }
    }
}

final class NightSocialWaveLookupBoard: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private let field = UITextField()
    private let table = UITableView()
    private var hits: [WaveVoiceChamber] = NightSocialWaveCatalog.chambers.filter { $0.isLive }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        field.placeholder = "Search rooms, hosts"
        field.attributedPlaceholder = NSAttributedString(string: "Search rooms, hosts", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)])
        field.textColor = .white
        field.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 36))
        field.leftViewMode = .always
        field.addTarget(self, action: #selector(rewriteHits), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(WaveChamberRow.self, forCellReuseIdentifier: WaveChamberRow.reuseId)
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
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func rewriteHits() {
        let query = NightSocialFoyerGuard.trimmed(field.text).lowercased()
        hits = NightSocialWaveCatalog.chambers.filter { chamber in
            guard chamber.isLive else { return false }
            guard !NightSocialSessionDrawer.shared.shouldHideDesk(chamber.hostDeskKey) else { return false }
            if query.isEmpty { return true }
            return chamber.chamberTitle.lowercased().contains(query)
                || NightSocialWaveCatalog.hostName(chamber).lowercased().contains(query)
                || chamber.tongue.rawValue.lowercased().contains(query)
        }
        table.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { hits.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 108 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaveChamberRow.reuseId, for: indexPath) as! WaveChamberRow
        cell.paint(hits[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialSessionDrawer.shared.rememberVisitedChamber(hits[indexPath.row].chamberKey)
        navigationController?.pushViewController(NightSocialWaveVoiceStage(chamberKey: hits[indexPath.row].chamberKey), animated: true)
    }
}
