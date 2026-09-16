import UIKit

final class NightSocialWaveStageController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var partyLane: WavePartyLane = .party
    private var tongueLane: WaveTongueLane = .all
    private let partyRow = UIStackView()
    private let tongueRow = UIStackView()
    private let bannerA = WaveBannerTile()
    private let bannerB = WaveBannerTile()
    private let headPlate = UILabel()
    private let countPlate = UILabel()
    private let table = UITableView()
    private var rows: [WaveVoiceChamber] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)

        partyRow.axis = .horizontal
        partyRow.spacing = 18
        partyRow.translatesAutoresizingMaskIntoConstraints = false
        for lane in WavePartyLane.allCases {
            let mark = UIButton(type: .system)
            mark.tag = lane.rawValue
            mark.setTitle(lane.spokenTitle, for: .normal)
            mark.addTarget(self, action: #selector(pickParty(_:)), for: .touchUpInside)
            partyRow.addArrangedSubview(mark)
        }
        let lookup = NightSocialLoungeChrome.iconControl(catalog: "LoungeLookupMark", fallback: "Group_646", edge: 34)
        lookup.addTarget(self, action: #selector(openLookup), for: .touchUpInside)
        let plus = UIButton(type: .system)
        plus.setTitle("+", for: .normal)
        plus.setTitleColor(.white, for: .normal)
        plus.titleLabel?.font = AfterHoursType.foyerHeadline(28)
        plus.addTarget(self, action: #selector(openCreate), for: .touchUpInside)
        plus.translatesAutoresizingMaskIntoConstraints = false

        tongueRow.axis = .horizontal
        tongueRow.spacing = 8
        tongueRow.translatesAutoresizingMaskIntoConstraints = false
        for (index, lane) in WaveTongueLane.allCases.enumerated() {
            let chip = UIButton(type: .system)
            chip.setTitle("  \(lane.rawValue)  ", for: .normal)
            chip.titleLabel?.font = AfterHoursType.foyerCaption(12)
            chip.layer.cornerRadius = 14
            chip.tag = index
            chip.addTarget(self, action: #selector(pickTongue(_:)), for: .touchUpInside)
            tongueRow.addArrangedSubview(chip)
        }

        bannerA.addTarget(self, action: #selector(tapBannerA), for: .touchUpInside)
        bannerB.addTarget(self, action: #selector(tapBannerB), for: .touchUpInside)

        headPlate.font = AfterHoursType.foyerPill(18)
        headPlate.textColor = .white
        headPlate.translatesAutoresizingMaskIntoConstraints = false
        countPlate.font = AfterHoursType.foyerCaption(12)
        countPlate.textColor = UIColor.white.withAlphaComponent(0.65)
        countPlate.translatesAutoresizingMaskIntoConstraints = false

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        table.register(WaveChamberRow.self, forCellReuseIdentifier: WaveChamberRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(partyRow)
        view.addSubview(lookup)
        view.addSubview(plus)
        view.addSubview(tongueRow)
        view.addSubview(bannerA)
        view.addSubview(bannerB)
        view.addSubview(headPlate)
        view.addSubview(countPlate)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            partyRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            partyRow.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            plus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            plus.centerYAnchor.constraint(equalTo: partyRow.centerYAnchor),
            lookup.trailingAnchor.constraint(equalTo: plus.leadingAnchor, constant: -8),
            lookup.centerYAnchor.constraint(equalTo: partyRow.centerYAnchor),
            tongueRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tongueRow.topAnchor.constraint(equalTo: partyRow.bottomAnchor, constant: 12),
            bannerA.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerA.topAnchor.constraint(equalTo: tongueRow.bottomAnchor, constant: 14),
            bannerA.widthAnchor.constraint(equalToConstant: 173),
            bannerA.heightAnchor.constraint(equalToConstant: 100),
            bannerB.leadingAnchor.constraint(equalTo: bannerA.trailingAnchor, constant: 10),
            bannerB.topAnchor.constraint(equalTo: bannerA.topAnchor),
            bannerB.widthAnchor.constraint(equalToConstant: 173),
            bannerB.heightAnchor.constraint(equalToConstant: 100),
            headPlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headPlate.topAnchor.constraint(equalTo: bannerA.bottomAnchor, constant: 16),
            countPlate.leadingAnchor.constraint(equalTo: headPlate.leadingAnchor),
            countPlate.topAnchor.constraint(equalTo: headPlate.bottomAnchor, constant: 2),
            table.topAnchor.constraint(equalTo: countPlate.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows), name: .deskDrawerDidChange, object: nil)
        paintParty()
        paintTongue()
        paintBanners()
        reloadRows()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadRows()
    }

    @objc private func pickParty(_ sender: UIButton) {
        partyLane = WavePartyLane(rawValue: sender.tag) ?? .party
        paintParty()
        paintBanners()
        reloadRows()
    }

    @objc private func pickTongue(_ sender: UIButton) {
        let all = WaveTongueLane.allCases
        guard sender.tag < all.count else { return }
        tongueLane = all[sender.tag]
        paintTongue()
        reloadRows()
    }

    private func paintParty() {
        for view in partyRow.arrangedSubviews {
            guard let mark = view as? UIButton else { continue }
            let on = mark.tag == partyLane.rawValue
            mark.setTitleColor(on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.55), for: .normal)
            mark.titleLabel?.font = on ? AfterHoursType.foyerPill(20) : AfterHoursType.foyerBody(16, weight: .medium)
        }
    }

    private func paintTongue() {
        let all = WaveTongueLane.allCases
        for (index, view) in tongueRow.arrangedSubviews.enumerated() {
            guard let chip = view as? UIButton, index < all.count else { continue }
            let on = all[index] == tongueLane
            chip.backgroundColor = on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.10)
            chip.setTitleColor(.white, for: .normal)
            chip.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }
    }

    private func paintBanners() {
        let liveHosts = NightSocialWaveCatalog.chambers.filter { $0.isLive }.map(\.hostDeskKey)
        let followed = NightSocialSessionDrawer.shared.followedDeskKeys()
        let followHosts = liveHosts.filter { followed.contains($0) }
        let recentHosts = NightSocialSessionDrawer.shared.recentChamberKeys().compactMap { key in
            NightSocialWaveCatalog.chamber(key)?.hostDeskKey
        }
        switch partyLane {
        case .party:
            bannerA.paint(image: NightSocialImageCabinet.named("WaveBannerHosts", fallback: "Group_898"), seats: liveHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("WaveBannerOpen", fallback: "Group_899"), seats: Array(liveHosts.dropFirst(1)))
            headPlate.text = "Live voice rooms"
        case .follow:
            bannerA.paint(image: NightSocialImageCabinet.named("WaveBannerFollow", fallback: "Group_902"), seats: followHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("WaveBannerSoon", fallback: "Group_903"), seats: followHosts)
            headPlate.text = "Followed rooms"
        case .recent:
            bannerA.paint(image: NightSocialImageCabinet.named("WaveBannerReturn", fallback: "Group_900"), seats: recentHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("WaveBannerActive", fallback: "Group_901"), seats: recentHosts)
            headPlate.text = "Recently joined"
        }
    }

    @objc private func reloadRows() {
        let followed = NightSocialSessionDrawer.shared.followedDeskKeys()
        let recent = NightSocialSessionDrawer.shared.recentChamberKeys()
        var pool = NightSocialWaveCatalog.chambers.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey) }
        if tongueLane != .all {
            pool = pool.filter { $0.tongue == tongueLane }
        }
        switch partyLane {
        case .party:
            rows = pool.filter { $0.isLive }
        case .follow:
            rows = pool.filter { $0.isLive && followed.contains($0.hostDeskKey) }
        case .recent:
            rows = recent.compactMap { key in pool.first { $0.chamberKey == key } }
        }
        let extra = NightSocialSessionDrawer.shared.hostedChamberRecords().compactMap { rec -> WaveVoiceChamber? in
            guard let key = rec["key"], let title = rec["title"], let host = rec["host"] else { return nil }
            return WaveVoiceChamber(chamberKey: key, chamberTitle: title, moodLine: rec["mood"] ?? "My room", hostDeskKey: host, heatScore: 120, listenerCount: 1, tongue: .english, vibeTags: (rec["tags"] ?? "Voice").split(separator: ",").map(String.init), isLive: true, isUpcoming: false, seatDeskKeys: [host])
        }
        if partyLane == .party { rows.insert(contentsOf: extra, at: 0) }
        countPlate.text = partyLane == .recent
            ? "\(rows.count) rooms you visited recently"
            : partyLane == .follow
                ? "\(rows.count) rooms from creators you follow"
                : "\(rows.count) active rooms"
        paintBanners()
        table.reloadData()
        table.backgroundView = rows.isEmpty
            ? NightSocialEmptyPane(spoken: partyLane == .follow
                ? "No followed rooms yet."
                : partyLane == .recent
                    ? "No recent rooms yet."
                    : "No live rooms right now.")
            : nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 108 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaveChamberRow.reuseId, for: indexPath) as! WaveChamberRow
        cell.paint(rows[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        enterChamber(rows[indexPath.row])
    }

    private func enterChamber(_ chamber: WaveVoiceChamber) {
        if chamber.isUpcoming {
            FoyerNotice.present(on: self, spokenTitle: "Starting soon", spokenBody: "This voice desk is not open yet. Keep the chair, come back when the lamp is lit.")
            return
        }
        NightSocialSessionDrawer.shared.rememberVisitedChamber(chamber.chamberKey)
        navigationController?.pushViewController(NightSocialWaveVoiceStage(chamberKey: chamber.chamberKey), animated: true)
    }

    @objc private func openLookup() {
        navigationController?.pushViewController(NightSocialWaveLookupBoard(), animated: true)
    }

    @objc private func openCreate() {
        present(NightSocialWaveCreateSheet(nav: navigationController), animated: true)
    }

    @objc private func tapBannerA() {
        switch partyLane {
        case .party:
            present(NightSocialWaveHostPicksSheet(nav: navigationController), animated: true)
        case .follow:
            partyLane = .follow
            reloadRows()
        case .recent:
            if let key = NightSocialSessionDrawer.shared.recentChamberKeys().first, let chamber = NightSocialWaveCatalog.chamber(key) {
                enterChamber(chamber)
            }
        }
    }

    @objc private func tapBannerB() {
        switch partyLane {
        case .party:
            present(NightSocialWaveOpenRoomsSheet(nav: navigationController), animated: true)
        case .follow:
            let soon = NightSocialWaveCatalog.chambers.filter { $0.isUpcoming }
            if let first = soon.first {
                enterChamber(first)
            }
        case .recent:
            let liveRecent = rows.filter { $0.isLive }
            if let first = liveRecent.first { enterChamber(first) }
        }
    }
}

final class WaveBannerTile: UIControl {
    private let cloth = UIImageView()
    private let stackA = UIImageView()
    private let stackB = UIImageView()
    private let stackC = UIImageView()
    private let arrow = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 18
        cloth.contentMode = .scaleAspectFill
        cloth.clipsToBounds = true
        cloth.isUserInteractionEnabled = false
        cloth.translatesAutoresizingMaskIntoConstraints = false
        arrow.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .bold))
        arrow.tintColor = AfterHoursPalette.inkOnSnow
        arrow.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        arrow.layer.cornerRadius = 11
        arrow.contentMode = .center
        arrow.clipsToBounds = true
        arrow.isUserInteractionEnabled = false
        arrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cloth)
        addSubview(stackC)
        addSubview(stackB)
        addSubview(stackA)
        addSubview(arrow)
        for mark in [stackA, stackB, stackC] {
            mark.contentMode = .scaleAspectFill
            mark.clipsToBounds = true
            mark.layer.cornerRadius = 11
            mark.layer.borderWidth = 1.5
            mark.layer.borderColor = UIColor.white.cgColor
            mark.isUserInteractionEnabled = false
            mark.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            cloth.topAnchor.constraint(equalTo: topAnchor),
            cloth.leadingAnchor.constraint(equalTo: leadingAnchor),
            cloth.trailingAnchor.constraint(equalTo: trailingAnchor),
            cloth.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackA.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackA.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackA.widthAnchor.constraint(equalToConstant: 22),
            stackA.heightAnchor.constraint(equalToConstant: 22),
            stackB.leadingAnchor.constraint(equalTo: stackA.leadingAnchor, constant: 14),
            stackB.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            stackB.widthAnchor.constraint(equalToConstant: 22),
            stackB.heightAnchor.constraint(equalToConstant: 22),
            stackC.leadingAnchor.constraint(equalTo: stackB.leadingAnchor, constant: 14),
            stackC.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            stackC.widthAnchor.constraint(equalToConstant: 22),
            stackC.heightAnchor.constraint(equalToConstant: 22),
            arrow.leadingAnchor.constraint(equalTo: stackC.trailingAnchor, constant: 8),
            arrow.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 22),
            arrow.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(image: UIImage?, seats: [String]) {
        cloth.image = image
        let keys = Array(seats.prefix(3))
        stackA.image = keys.indices.contains(0) ? NightSocialMediaAssets.portrait(for: keys[0], size: CGSize(width: 44, height: 44)) : nil
        stackB.image = keys.indices.contains(1) ? NightSocialMediaAssets.portrait(for: keys[1], size: CGSize(width: 44, height: 44)) : nil
        stackC.image = keys.indices.contains(2) ? NightSocialMediaAssets.portrait(for: keys[2], size: CGSize(width: 44, height: 44)) : nil
        stackA.isHidden = keys.isEmpty
        stackB.isHidden = keys.count < 2
        stackC.isHidden = keys.count < 3
        arrow.isHidden = keys.isEmpty
    }
}

final class WaveChamberRow: UITableViewCell {
    static let reuseId = "WaveChamberRow"
    private let card = UIView()
    private let portrait = UIImageView()
    private let titlePlate = UILabel()
    private let hostPlate = UILabel()
    private let heatMark = UIImageView()
    private let heatPlate = UILabel()
    private let listenPlate = UILabel()
    private let tagRow = UIStackView()
    private let stackA = UIImageView()
    private let stackB = UIImageView()
    private let stackC = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        portrait.layer.cornerRadius = 28
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        hostPlate.font = AfterHoursType.foyerCaption(12)
        hostPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        heatMark.image = NightSocialImageCabinet.named("WaveHeatMark", fallback: "Frame@2x(7)")
        heatMark.contentMode = .scaleAspectFit
        heatMark.translatesAutoresizingMaskIntoConstraints = false
        heatPlate.font = AfterHoursType.foyerCaption(12)
        heatPlate.textColor = UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        heatPlate.translatesAutoresizingMaskIntoConstraints = false
        listenPlate.font = AfterHoursType.foyerCaption(11)
        listenPlate.textColor = UIColor.white.withAlphaComponent(0.75)
        listenPlate.translatesAutoresizingMaskIntoConstraints = false
        tagRow.axis = .horizontal
        tagRow.spacing = 6
        tagRow.translatesAutoresizingMaskIntoConstraints = false
        for mark in [stackA, stackB, stackC] {
            mark.layer.cornerRadius = 10
            mark.clipsToBounds = true
            mark.layer.borderWidth = 1
            mark.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            mark.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.addSubview(card)
        card.addSubview(portrait)
        card.addSubview(titlePlate)
        card.addSubview(hostPlate)
        card.addSubview(heatMark)
        card.addSubview(heatPlate)
        card.addSubview(tagRow)
        card.addSubview(stackA)
        card.addSubview(stackB)
        card.addSubview(stackC)
        card.addSubview(listenPlate)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 56),
            portrait.heightAnchor.constraint(equalToConstant: 56),
            titlePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            hostPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hostPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 2),
            heatPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            heatPlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            heatMark.trailingAnchor.constraint(equalTo: heatPlate.leadingAnchor, constant: -4),
            heatMark.centerYAnchor.constraint(equalTo: heatPlate.centerYAnchor),
            heatMark.widthAnchor.constraint(equalToConstant: 14),
            heatMark.heightAnchor.constraint(equalToConstant: 16),
            tagRow.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            tagRow.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            listenPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            listenPlate.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            stackC.trailingAnchor.constraint(equalTo: listenPlate.leadingAnchor, constant: -6),
            stackC.centerYAnchor.constraint(equalTo: listenPlate.centerYAnchor),
            stackC.widthAnchor.constraint(equalToConstant: 20),
            stackC.heightAnchor.constraint(equalToConstant: 20),
            stackB.trailingAnchor.constraint(equalTo: stackC.leadingAnchor, constant: 6),
            stackB.centerYAnchor.constraint(equalTo: stackC.centerYAnchor),
            stackB.widthAnchor.constraint(equalToConstant: 20),
            stackB.heightAnchor.constraint(equalToConstant: 20),
            stackA.trailingAnchor.constraint(equalTo: stackB.leadingAnchor, constant: 6),
            stackA.centerYAnchor.constraint(equalTo: stackC.centerYAnchor),
            stackA.widthAnchor.constraint(equalToConstant: 20),
            stackA.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ chamber: WaveVoiceChamber) {
        let host = NightSocialWaveCatalog.hostName(chamber)
        portrait.image = NightSocialMediaAssets.portrait(for: chamber.hostDeskKey, size: CGSize(width: 120, height: 120))
        titlePlate.text = chamber.chamberTitle
        hostPlate.text = "\(host)  \(chamber.moodLine)"
        heatPlate.text = "\(chamber.heatScore)"
        listenPlate.text = "\(chamber.listenerCount)"
        tagRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in chamber.vibeTags.prefix(2) {
            let plate = UILabel()
            plate.text = "  \(tag)  "
            plate.font = AfterHoursType.foyerCaption(10)
            plate.textColor = AfterHoursPalette.loungePink
            plate.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.15)
            plate.layer.cornerRadius = 8
            plate.clipsToBounds = true
            tagRow.addArrangedSubview(plate)
        }
        let seats = chamber.seatDeskKeys
        stackA.image = seats.indices.contains(0) ? NightSocialMediaAssets.portrait(for: seats[0], size: CGSize(width: 40, height: 40)) : nil
        stackB.image = seats.indices.contains(1) ? NightSocialMediaAssets.portrait(for: seats[1], size: CGSize(width: 40, height: 40)) : nil
        stackC.image = seats.indices.contains(2) ? NightSocialMediaAssets.portrait(for: seats[2], size: CGSize(width: 40, height: 40)) : nil
    }
}
