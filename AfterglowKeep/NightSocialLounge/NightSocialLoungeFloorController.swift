import UIKit

final class LoungeSectionHead: UICollectionReusableView {
    static let reuseId = "LoungeSectionHead"
    let plate = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        plate.font = AfterHoursType.foyerPill(16)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plate)
        NSLayoutConstraint.activate([
            plate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            plate.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

final class NightSocialLoungeFloorController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var browseLane: LoungeBrowseLane = .all
    private var meridianLane: LoungeMeridianLane = .global
    private let browseRow = UIStackView()
    private let meridianRow = UIScrollView()
    private let meridianStack = UIStackView()
    private var collection: UICollectionView!
    private var creatorItems: [LoungeCreatorDesk] = []
    private var boothItems: [LoungeLiveBooth] = []
    private var clipItems: [LoungeClipReel] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        edgesForExtendedLayout = .all
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)

        browseRow.axis = .horizontal
        browseRow.spacing = 16
        browseRow.alignment = .center
        browseRow.translatesAutoresizingMaskIntoConstraints = false
        for lane in LoungeBrowseLane.allCases {
            let mark = UIButton(type: .system)
            mark.tag = lane.rawValue
            mark.setTitle(lane.spokenTitle, for: .normal)
            mark.addTarget(self, action: #selector(pickBrowse(_:)), for: .touchUpInside)
            browseRow.addArrangedSubview(mark)
        }

        let lookup = NightSocialLoungeChrome.iconControl(catalog: "SearchIcon", fallback: "SearchIcon", edge: 34)
        lookup.addTarget(self, action: #selector(openLookup), for: .touchUpInside)
        let crown = NightSocialLoungeChrome.iconControl(catalog: "CrownIcon", fallback: "CrownIcon", edge: 34)
        crown.addTarget(self, action: #selector(openCrown), for: .touchUpInside)

        meridianRow.showsHorizontalScrollIndicator = false
        meridianRow.translatesAutoresizingMaskIntoConstraints = false
        meridianStack.axis = .horizontal
        meridianStack.spacing = 8
        meridianStack.translatesAutoresizingMaskIntoConstraints = false
        meridianRow.addSubview(meridianStack)
        for lane in LoungeMeridianLane.allCases {
            let chip = UIButton(type: .system)
            chip.setTitle("  \(lane.spokenTitle)  ", for: .normal)
            chip.titleLabel?.font = AfterHoursType.foyerCaption(12)
            chip.layer.cornerRadius = 14
            chip.tag = LoungeMeridianLane.allCases.firstIndex(of: lane) ?? 0
            chip.addTarget(self, action: #selector(pickMeridian(_:)), for: .touchUpInside)
            meridianStack.addArrangedSubview(chip)
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 110, right: 16)
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.contentInsetAdjustmentBehavior = .never
        collection.insetsLayoutMarginsFromSafeArea = false
        collection.register(LoungeCreatorTile.self, forCellWithReuseIdentifier: LoungeCreatorTile.reuseId)
        collection.register(LoungeBoothTile.self, forCellWithReuseIdentifier: LoungeBoothTile.reuseId)
        collection.register(LoungeClipTile.self, forCellWithReuseIdentifier: LoungeClipTile.reuseId)
        collection.register(LoungeMusicTile.self, forCellWithReuseIdentifier: LoungeMusicTile.reuseId)
        collection.register(LoungeSectionHead.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LoungeSectionHead.reuseId)
        collection.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(browseRow)
        view.addSubview(lookup)
        view.addSubview(crown)
        view.addSubview(meridianRow)
        view.addSubview(collection)
        NSLayoutConstraint.activate([
            browseRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            browseRow.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            lookup.centerYAnchor.constraint(equalTo: browseRow.centerYAnchor),
            crown.centerYAnchor.constraint(equalTo: browseRow.centerYAnchor),
            crown.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lookup.trailingAnchor.constraint(equalTo: crown.leadingAnchor, constant: -8),
            meridianRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            meridianRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            meridianRow.topAnchor.constraint(equalTo: browseRow.bottomAnchor, constant: 12),
            meridianRow.heightAnchor.constraint(equalToConstant: 32),
            meridianStack.leadingAnchor.constraint(equalTo: meridianRow.contentLayoutGuide.leadingAnchor, constant: 16),
            meridianStack.trailingAnchor.constraint(equalTo: meridianRow.contentLayoutGuide.trailingAnchor, constant: -16),
            meridianStack.topAnchor.constraint(equalTo: meridianRow.contentLayoutGuide.topAnchor),
            meridianStack.bottomAnchor.constraint(equalTo: meridianRow.contentLayoutGuide.bottomAnchor),
            meridianStack.heightAnchor.constraint(equalTo: meridianRow.frameLayoutGuide.heightAnchor),
            collection.topAnchor.constraint(equalTo: meridianRow.bottomAnchor, constant: 8),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(reloadLane), name: .deskDrawerDidChange, object: nil)
        paintBrowse()
        paintMeridian()
        reloadLane()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadLane()
    }

    @objc private func pickBrowse(_ sender: UIButton) {
        browseLane = LoungeBrowseLane(rawValue: sender.tag) ?? .all
        paintBrowse()
        reloadLane()
    }

    @objc private func pickMeridian(_ sender: UIButton) {
        let all = LoungeMeridianLane.allCases
        guard sender.tag < all.count else { return }
        meridianLane = all[sender.tag]
        paintMeridian()
        reloadLane()
    }

    private func paintBrowse() {
        for view in browseRow.arrangedSubviews {
            guard let mark = view as? UIButton else { continue }
            let on = mark.tag == browseLane.rawValue
            mark.setTitleColor(on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.55), for: .normal)
            mark.titleLabel?.font = on ? AfterHoursType.foyerPill(18) : AfterHoursType.foyerBody(16, weight: .medium)
        }
    }

    private func paintMeridian() {
        let all = LoungeMeridianLane.allCases
        for (index, view) in meridianStack.arrangedSubviews.enumerated() {
            guard let chip = view as? UIButton, index < all.count else { continue }
            let on = all[index] == meridianLane
            chip.backgroundColor = on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.10)
            chip.setTitleColor(.white, for: .normal)
            chip.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }
    }

    @objc private func reloadLane() {
        let followed = NightSocialSessionDrawer.shared.followedDeskKeys()
        func meridianOk(_ itemMeridian: LoungeMeridianLane) -> Bool {
            meridianLane == .global || itemMeridian == meridianLane
        }
        creatorItems = NightSocialLoungeCatalog.visibleCreators().filter { desk in
            meridianOk(desk.meridian) && (browseLane != .follow || followed.contains(desk.deskKey))
        }
        boothItems = NightSocialLoungeCatalog.visibleBooths().filter { booth in
            meridianOk(booth.meridian)
        }
        clipItems = NightSocialLoungeCatalog.visibleClips().filter { clip in
            meridianOk(clip.meridian)
        }
        collection.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch browseLane {
        case .all, .follow: return creatorItems.count
        case .live: return boothItems.count
        case .fresh, .music: return clipItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let head = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoungeSectionHead.reuseId, for: indexPath) as! LoungeSectionHead
        head.plate.text = browseLane.sectionTitle
        return head
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch browseLane {
        case .all, .follow:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeCreatorTile.reuseId, for: indexPath) as! LoungeCreatorTile
            cell.paint(creatorItems[indexPath.item])
            return cell
        case .live:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeBoothTile.reuseId, for: indexPath) as! LoungeBoothTile
            cell.paint(boothItems[indexPath.item])
            return cell
        case .fresh:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeClipTile.reuseId, for: indexPath) as! LoungeClipTile
            cell.paint(clipItems[indexPath.item], musicMode: false)
            return cell
        case .music:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeMusicTile.reuseId, for: indexPath) as! LoungeMusicTile
            cell.paint(clipItems[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        switch browseLane {
        case .all, .follow:
            let col = (width - 10) / 2
            return CGSize(width: col, height: col * 1.28)
        case .live:
            return CGSize(width: width, height: 118)
        case .fresh:
            let col = (width - 10) / 2
            return CGSize(width: col, height: col * 1.35)
        case .music:
            return CGSize(width: width, height: 76)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch browseLane {
        case .all, .follow:
            let desk = creatorItems[indexPath.item]
            if desk.isLive, let booth = NightSocialLoungeCatalog.booth(hostedBy: desk.deskKey) {
                navigationController?.pushViewController(NightSocialLiveBoothStage(boothKey: booth.boothKey), animated: true)
            } else {
                navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: desk.deskKey), animated: true)
            }
        case .live:
            let booth = boothItems[indexPath.item]
            navigationController?.pushViewController(NightSocialLiveBoothStage(boothKey: booth.boothKey), animated: true)
        case .fresh, .music:
            let clip = clipItems[indexPath.item]
            navigationController?.pushViewController(
                browseLane == .music
                    ? NightSocialMusicStage(clipKey: clip.clipKey)
                    : NightSocialClipTheater(clipKey: clip.clipKey),
                animated: true
            )
        }
    }

    @objc private func openLookup() {
        navigationController?.pushViewController(NightSocialLookupBoard(), animated: true)
    }

    @objc private func openCrown() {
        navigationController?.pushViewController(NightSocialCrownBoard(), animated: true)
    }
}
