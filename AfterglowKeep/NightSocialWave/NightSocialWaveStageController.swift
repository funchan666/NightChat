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
        let lookup = NightSocialLoungeChrome.iconControl(catalog: "SearchIcon", fallback: "SearchIcon", edge: 34)
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
            bannerA.paint(image: NightSocialImageCabinet.named("PartyBannerHosts", fallback: "PartyBannerHosts"), seats: liveHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("PartyBannerOpen", fallback: "PartyBannerOpen"), seats: Array(liveHosts.dropFirst(1)))
            headPlate.text = "Live voice rooms"
        case .follow:
            bannerA.paint(image: NightSocialImageCabinet.named("PartyBannerFollow", fallback: "PartyBannerFollow"), seats: followHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("PartyBannerSoon", fallback: "PartyBannerSoon"), seats: followHosts)
            headPlate.text = "Followed rooms"
        case .recent:
            bannerA.paint(image: NightSocialImageCabinet.named("PartyBannerRecent", fallback: "PartyBannerRecent"), seats: recentHosts)
            bannerB.paint(image: NightSocialImageCabinet.named("PartyBannerActive", fallback: "PartyBannerActive"), seats: recentHosts)
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
            ? NightSocialEmptyPane.tableBackdrop(
                spoken: partyLane == .follow
                    ? "No followed rooms yet."
                    : partyLane == .recent
                        ? "No recent rooms yet."
                        : "No live rooms right now.",
                lift: -36
            )
            : nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 128 }
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
            present(NightSocialWaveRoomListSheet(kind: .followingLive, nav: navigationController), animated: true)
        case .recent:
            present(NightSocialWaveRoomListSheet(kind: .returnRooms, nav: navigationController), animated: true)
        }
    }

    @objc private func tapBannerB() {
        switch partyLane {
        case .party:
            present(NightSocialWaveOpenRoomsSheet(nav: navigationController), animated: true)
        case .follow:
            present(NightSocialWaveRoomListSheet(kind: .startingSoon, nav: navigationController), animated: true)
        case .recent:
            present(NightSocialWaveRoomListSheet(kind: .activeAgain, nav: navigationController), animated: true)
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
    private let listenMark = UIImageView()
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
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 32
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 2
        portrait.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        heatMark.image = NightSocialImageCabinet.named("HeatIcon", fallback: "HeatIcon")
        heatMark.contentMode = .scaleAspectFit
        heatMark.translatesAutoresizingMaskIntoConstraints = false
        heatPlate.font = AfterHoursType.foyerCaption(12)
        heatPlate.textColor = UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        heatPlate.translatesAutoresizingMaskIntoConstraints = false
        listenMark.image = UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        listenMark.tintColor = UIColor.white.withAlphaComponent(0.55)
        listenMark.translatesAutoresizingMaskIntoConstraints = false
        listenPlate.font = AfterHoursType.foyerCaption(12)
        listenPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        listenPlate.translatesAutoresizingMaskIntoConstraints = false
        tagRow.axis = .horizontal
        tagRow.spacing = 6
        tagRow.translatesAutoresizingMaskIntoConstraints = false
        for mark in [stackA, stackB, stackC] {
            mark.contentMode = .scaleAspectFill
            mark.layer.cornerRadius = 10
            mark.clipsToBounds = true
            mark.layer.borderWidth = 1.4
            mark.layer.borderColor = UIColor.white.cgColor
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
        card.addSubview(listenMark)
        card.addSubview(listenPlate)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            portrait.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 64),
            portrait.heightAnchor.constraint(equalToConstant: 64),
            titlePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            titlePlate.trailingAnchor.constraint(lessThanOrEqualTo: heatMark.leadingAnchor, constant: -8),
            titlePlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            hostPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hostPlate.trailingAnchor.constraint(lessThanOrEqualTo: heatPlate.leadingAnchor, constant: -8),
            hostPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 3),
            heatPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            heatPlate.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            heatMark.trailingAnchor.constraint(equalTo: heatPlate.leadingAnchor, constant: -4),
            heatMark.centerYAnchor.constraint(equalTo: heatPlate.centerYAnchor),
            heatMark.widthAnchor.constraint(equalToConstant: 13),
            heatMark.heightAnchor.constraint(equalToConstant: 15),
            tagRow.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            tagRow.topAnchor.constraint(equalTo: hostPlate.bottomAnchor, constant: 6),
            stackA.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            stackA.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            stackA.widthAnchor.constraint(equalToConstant: 20),
            stackA.heightAnchor.constraint(equalToConstant: 20),
            stackB.leadingAnchor.constraint(equalTo: stackA.leadingAnchor, constant: 14),
            stackB.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            stackB.widthAnchor.constraint(equalToConstant: 20),
            stackB.heightAnchor.constraint(equalToConstant: 20),
            stackC.leadingAnchor.constraint(equalTo: stackB.leadingAnchor, constant: 14),
            stackC.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            stackC.widthAnchor.constraint(equalToConstant: 20),
            stackC.heightAnchor.constraint(equalToConstant: 20),
            listenPlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            listenPlate.centerYAnchor.constraint(equalTo: stackA.centerYAnchor),
            listenMark.trailingAnchor.constraint(equalTo: listenPlate.leadingAnchor, constant: -4),
            listenMark.centerYAnchor.constraint(equalTo: listenPlate.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ chamber: WaveVoiceChamber) {
        let host = NightSocialWaveCatalog.hostName(chamber)
        let first = host.split(separator: " ").first.map(String.init) ?? host
        portrait.image = NightSocialMediaAssets.portrait(for: chamber.hostDeskKey, size: CGSize(width: 128, height: 128))
        titlePlate.text = chamber.chamberTitle
        let line = NSMutableAttributedString(
            string: first,
            attributes: [
                .foregroundColor: AfterHoursPalette.loungePink,
                .font: AfterHoursType.foyerCaption(12),
            ]
        )
        line.append(NSAttributedString(
            string: "  ·  \(chamber.moodLine)",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.55),
                .font: AfterHoursType.foyerCaption(12),
            ]
        ))
        hostPlate.attributedText = line
        heatPlate.text = "\(chamber.heatScore)"
        listenPlate.text = "\(chamber.listenerCount)"
        tagRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in chamber.vibeTags.prefix(2) {
            let plate = UILabel()
            plate.text = "  \(tag)  "
            plate.font = AfterHoursType.foyerCaption(10)
            plate.textColor = .white
            plate.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.78)
            plate.layer.cornerRadius = 9
            plate.clipsToBounds = true
            tagRow.addArrangedSubview(plate)
        }
        let seats = chamber.seatDeskKeys
        stackA.image = seats.indices.contains(0) ? NightSocialMediaAssets.portrait(for: seats[0], size: CGSize(width: 40, height: 40)) : nil
        stackB.image = seats.indices.contains(1) ? NightSocialMediaAssets.portrait(for: seats[1], size: CGSize(width: 40, height: 40)) : nil
        stackC.image = seats.indices.contains(2) ? NightSocialMediaAssets.portrait(for: seats[2], size: CGSize(width: 40, height: 40)) : nil
        stackA.isHidden = seats.isEmpty
        stackB.isHidden = seats.count < 2
        stackC.isHidden = seats.count < 3
    }
}
