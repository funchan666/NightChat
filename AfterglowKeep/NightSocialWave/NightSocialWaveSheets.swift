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
        let recharge = NightSocialLoungeChrome.pinkPill(title: "Recharge Diamonds")
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
        let purse = NightSocialSessionDrawer.shared.diamondPurse
        NightSocialSessionDrawer.shared.writeDiamondPurse(purse + 500)
        dismiss(animated: true)
    }
}

final class NightSocialWaveHostPicksSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private weak var nav: UINavigationController?
    private let rows = NightSocialLoungeCatalog.visibleCreators().filter { $0.isHot }
    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.large()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Featured Hosts"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let stats = UILabel()
        stats.text = "\(rows.count) Live    235.2k Followers    4 Regions"
        stats.font = AfterHoursType.foyerCaption(12)
        stats.textColor = UIColor.white.withAlphaComponent(0.7)
        stats.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "hostpick")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tag = 71
        let join = NightSocialLoungeChrome.pinkPill(title: "Join \(rows.first?.spokenName ?? "the") room")
        join.addTarget(self, action: #selector(joinFirst), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(stats)
        view.addSubview(table)
        view.addSubview(join)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            stats.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            stats.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            table.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: join.topAnchor, constant: -12),
            join.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            join.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            join.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostpick", for: indexPath)
        let desk = rows[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "\(desk.spokenName)  \(desk.cityLabel)"
        cell.imageView?.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 48, height: 48))
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialDeskGate.revealDesk(from: self, deskKey: rows[indexPath.row].deskKey)
    }
    @objc private func joinFirst() {
        guard let desk = rows.first,
              let chamber = NightSocialWaveCatalog.chambers.first(where: { $0.hostDeskKey == desk.deskKey && $0.isLive })
                ?? NightSocialWaveCatalog.chambers.first(where: { $0.isLive }) else { return }
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveVoiceStage(chamberKey: chamber.chamberKey), animated: true)
        }
    }
}

final class NightSocialWaveOpenRoomsSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private weak var nav: UINavigationController?
    private let rows = NightSocialWaveCatalog.chambers.filter { $0.isLive && !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey) }
    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.large()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Open Rooms"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let stats = UILabel()
        stats.text = "\(rows.count) Open    \(rows.reduce(0) { $0 + $1.listenerCount }) Listeners    \(rows.reduce(0) { $0 + $1.heatScore }) Heat"
        stats.font = AfterHoursType.foyerCaption(12)
        stats.textColor = UIColor.white.withAlphaComponent(0.75)
        stats.translatesAutoresizingMaskIntoConstraints = false
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(WaveChamberRow.self, forCellReuseIdentifier: WaveChamberRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        let join = NightSocialLoungeChrome.pinkPill(title: "Join \(NightSocialWaveCatalog.hostName(rows.first ?? NightSocialWaveCatalog.chambers[0]))'s room")
        join.addTarget(self, action: #selector(joinFirst), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(stats)
        view.addSubview(table)
        view.addSubview(join)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            stats.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            stats.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            table.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: join.topAnchor, constant: -12),
            join.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            join.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            join.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 108 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaveChamberRow.reuseId, for: indexPath) as! WaveChamberRow
        cell.paint(rows[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chamber = rows[indexPath.row]
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveVoiceStage(chamberKey: chamber.chamberKey), animated: true)
        }
    }
    @objc private func joinFirst() {
        guard let first = rows.first else { return }
        let nav = self.nav
        dismiss(animated: true) {
            nav?.pushViewController(NightSocialWaveVoiceStage(chamberKey: first.chamberKey), animated: true)
        }
    }
}

final class NightSocialWaveCreateSheet: UIViewController {
    private weak var nav: UINavigationController?
    init(nav: UINavigationController?) {
        self.nav = nav
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Create"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let live = UIButton(type: .custom)
        live.setImage(NightSocialImageCabinet.named("WaveGoLivePill", fallback: "Group_909"), for: .normal)
        live.imageView?.contentMode = .scaleAspectFit
        live.addTarget(self, action: #selector(goLive), for: .touchUpInside)
        let post = UIButton(type: .custom)
        post.setImage(NightSocialImageCabinet.named("WavePostPill", fallback: "Group_910"), for: .normal)
        post.imageView?.contentMode = .scaleAspectFit
        post.addTarget(self, action: #selector(postVideo), for: .touchUpInside)
        live.translatesAutoresizingMaskIntoConstraints = false
        post.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        view.addSubview(live)
        view.addSubview(post)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            live.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            live.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 18),
            live.heightAnchor.constraint(equalToConstant: 56),
            live.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            post.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            post.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            post.centerYAnchor.constraint(equalTo: live.centerYAnchor),
            post.heightAnchor.constraint(equalTo: live.heightAnchor),
        ])
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
