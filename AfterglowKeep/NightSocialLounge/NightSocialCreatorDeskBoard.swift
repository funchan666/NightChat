import UIKit

final class NightSocialCreatorDeskBoard: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let deskKey: String
    private let scroller = UIScrollView()
    private let followPill = UIButton(type: .custom)
    private let chatPill = UIButton(type: .custom)
    private let followedMark = UILabel()
    private let emptyPane = NightSocialEmptyPane(spoken: NightLang.t(.noPostsYet))
    private var moments: [DeskMoment] = []
    private var collection: UICollectionView!
    private var collectionHeight: NSLayoutConstraint!

    init(deskKey: String) {
        self.deskKey = deskKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        guard let desk = NightSocialLoungeCatalog.creator(deskKey: deskKey) else { return }
        reloadClips()

        scroller.alwaysBounceVertical = true
        scroller.contentInsetAdjustmentBehavior = .never
        scroller.translatesAutoresizingMaskIntoConstraints = false

        let cover = UIImageView(image: NightSocialMediaAssets.cover(for: desk.deskKey, size: CGSize(width: 430, height: 760)))
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let more = NightSocialLoungeChrome.iconControl(catalog: "MoreCircle", fallback: "MoreCircle")
        more.addTarget(self, action: #selector(openSafety), for: .touchUpInside)

        followedMark.text = NightLang.t(.followed)
        followedMark.font = AfterHoursType.foyerPill(13)
        followedMark.textColor = AfterHoursPalette.inkOnSnow
        followedMark.textAlignment = .center
        followedMark.backgroundColor = UIColor.white.withAlphaComponent(0.94)
        followedMark.layer.cornerRadius = 16
        followedMark.clipsToBounds = true
        followedMark.translatesAutoresizingMaskIntoConstraints = false

        let portrait = UIImageView(image: NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 160, height: 160)))
        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 38
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 3
        portrait.layer.borderColor = UIColor.white.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false

        let namePlate = UILabel()
        namePlate.text = desk.spokenName
        namePlate.font = AfterHoursType.foyerHeadline(22)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        let cityPlate = UILabel()
        cityPlate.text = desk.cityLabel
        cityPlate.font = AfterHoursType.foyerCaption(13)
        cityPlate.textColor = UIColor.white.withAlphaComponent(0.62)
        cityPlate.translatesAutoresizingMaskIntoConstraints = false
        let handlePlate = UILabel()
        handlePlate.text = desk.handleTag
        handlePlate.font = AfterHoursType.foyerCaption(12)
        handlePlate.textColor = UIColor.white.withAlphaComponent(0.62)
        handlePlate.translatesAutoresizingMaskIntoConstraints = false
        let coins = NightSocialDiamondAmount(font: AfterHoursType.foyerCaption(12), gemSize: 12)
        coins.paint(desk.likeCount)
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)

        let vibePlate = UILabel()
        vibePlate.text = desk.vibeLine
        vibePlate.font = AfterHoursType.foyerBody(13)
        vibePlate.textColor = UIColor.white.withAlphaComponent(0.86)
        vibePlate.numberOfLines = 0
        vibePlate.translatesAutoresizingMaskIntoConstraints = false

        var tagViews: [UIView] = desk.vibeTags.prefix(2).map { tagChip("#\($0)") }
        if desk.isLive {
            tagViews.append(liveChip())
        }
        let tagRow = UIStackView(arrangedSubviews: tagViews)
        tagRow.axis = .horizontal
        tagRow.spacing = 8
        tagRow.translatesAutoresizingMaskIntoConstraints = false

        styleActionPill(followPill, title: NightLang.t(.follow), symbol: "plus")
        followPill.addTarget(self, action: #selector(flipFollow), for: .touchUpInside)
        styleActionPill(chatPill, title: NightLang.t(.chatting), symbol: "ellipsis.bubble.fill")
        chatPill.addTarget(self, action: #selector(openWhisper), for: .touchUpInside)
        let actions = UIStackView(arrangedSubviews: [followPill, chatPill])
        actions.axis = .horizontal
        actions.spacing = 12
        actions.distribution = .fillEqually
        actions.translatesAutoresizingMaskIntoConstraints = false

        let videoHead = UILabel()
        videoHead.text = NightLang.t(.video)
        videoHead.font = AfterHoursType.foyerPill(16)
        videoHead.textColor = .white
        videoHead.translatesAutoresizingMaskIntoConstraints = false

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.register(LoungeMomentTile.self, forCellWithReuseIdentifier: LoungeMomentTile.reuseId)
        collection.register(LoungeClipTile.self, forCellWithReuseIdentifier: LoungeClipTile.reuseId)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collectionHeight = collection.heightAnchor.constraint(equalToConstant: 220)

        view.addSubview(scroller)
        scroller.addSubview(cover)
        scroller.addSubview(followedMark)
        scroller.addSubview(portrait)
        scroller.addSubview(namePlate)
        scroller.addSubview(cityPlate)
        scroller.addSubview(handlePlate)
        scroller.addSubview(coins)
        scroller.addSubview(level)
        scroller.addSubview(vibePlate)
        scroller.addSubview(tagRow)
        scroller.addSubview(actions)
        scroller.addSubview(videoHead)
        scroller.addSubview(collection)
        scroller.addSubview(emptyPane)
        view.addSubview(back)
        view.addSubview(more)

        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cover.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 360),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            followedMark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            followedMark.bottomAnchor.constraint(equalTo: cover.bottomAnchor, constant: -18),
            followedMark.widthAnchor.constraint(equalToConstant: 108),
            followedMark.heightAnchor.constraint(equalToConstant: 32),
            portrait.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portrait.centerYAnchor.constraint(equalTo: cover.bottomAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 76),
            portrait.heightAnchor.constraint(equalToConstant: 76),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            namePlate.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 10),
            cityPlate.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 6),
            cityPlate.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            cityPlate.trailingAnchor.constraint(lessThanOrEqualTo: coins.leadingAnchor, constant: -8),
            coins.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            coins.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            handlePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            handlePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 3),
            level.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            level.centerYAnchor.constraint(equalTo: handlePlate.centerYAnchor),
            vibePlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vibePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vibePlate.topAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 14),
            tagRow.leadingAnchor.constraint(equalTo: vibePlate.leadingAnchor),
            tagRow.topAnchor.constraint(equalTo: vibePlate.bottomAnchor, constant: 10),
            actions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actions.topAnchor.constraint(equalTo: tagRow.bottomAnchor, constant: 16),
            actions.heightAnchor.constraint(equalToConstant: 44),
            videoHead.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoHead.topAnchor.constraint(equalTo: actions.bottomAnchor, constant: 22),
            collection.topAnchor.constraint(equalTo: videoHead.bottomAnchor, constant: 10),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionHeight,
            collection.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -24),
            emptyPane.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPane.topAnchor.constraint(equalTo: videoHead.bottomAnchor, constant: 28),
            emptyPane.bottomAnchor.constraint(lessThanOrEqualTo: scroller.contentLayoutGuide.bottomAnchor, constant: -24),
        ])
        paintFollow()
        paintPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDesk), name: .deskDrawerDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight()
    }

    private func reloadClips() {
        moments = NightSocialLoungeCatalog.moments(for: deskKey)
    }

    private func paintPosts() {
        let empty = moments.isEmpty
        emptyPane.isHidden = !empty
        collection.isHidden = empty
        collection.reloadData()
        updateCollectionHeight()
    }

    private func updateCollectionHeight() {
        guard !moments.isEmpty else {
            if collectionHeight.constant != 220 { collectionHeight.constant = 220 }
            return
        }
        let width = max(120, (view.bounds.width - 42) / 2)
        let height = width * 1.32
        let rows = ceil(CGFloat(moments.count) / 2)
        let next = rows * height + max(0, rows - 1) * 10
        if abs(collectionHeight.constant - next) > 0.5 {
            collectionHeight.constant = next
        }
    }

    private func styleActionPill(_ pill: UIButton, title: String, symbol: String) {
        pill.backgroundColor = AfterHoursPalette.loungePink
        pill.layer.cornerRadius = 22
        pill.setTitle(" \(title)", for: .normal)
        pill.setTitleColor(.white, for: .normal)
        pill.titleLabel?.font = AfterHoursType.foyerPill(15)
        pill.setImage(
            UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)),
            for: .normal
        )
        pill.tintColor = .white
        pill.translatesAutoresizingMaskIntoConstraints = false
    }

    private func tagChip(_ spoken: String) -> UIView {
        let wrap = UIView()
        wrap.layer.cornerRadius = 11
        wrap.layer.borderWidth = 1
        wrap.layer.borderColor = AfterHoursPalette.loungePink.withAlphaComponent(0.75).cgColor
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = spoken
        plate.font = AfterHoursType.foyerCaption(11)
        plate.textColor = AfterHoursPalette.loungePink
        plate.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(plate)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 22),
            plate.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 10),
            plate.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -10),
            plate.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
        ])
        return wrap
    }

    private func liveChip() -> UIView {
        let wrap = UIView()
        wrap.backgroundColor = AfterHoursPalette.loungePink
        wrap.layer.cornerRadius = 11
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = NightLang.t(.liveNow)
        plate.font = AfterHoursType.foyerCaption(11)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(plate)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 22),
            plate.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 10),
            plate.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -10),
            plate.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
        ])
        return wrap
    }

    @objc private func reloadDesk() {
        if NightSocialSessionDrawer.shared.shouldHideDesk(deskKey) {
            navigationController?.popViewController(animated: true)
            return
        }
        reloadClips()
        paintFollow()
        paintPosts()
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func flipFollow() {
        NightSocialSessionDrawer.shared.toggleFollow(deskKey)
        paintFollow()
    }

    private func paintFollow() {
        let on = NightSocialSessionDrawer.shared.isFollowing(deskKey)
        followedMark.isHidden = !on
        followPill.setTitle(on ? " \(NightLang.t(.followed))" : " \(NightLang.t(.follow))", for: .normal)
        followPill.setImage(
            UIImage(
                systemName: on ? "checkmark" : "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            ),
            for: .normal
        )
        followPill.backgroundColor = on ? UIColor.white.withAlphaComponent(0.18) : AfterHoursPalette.loungePink
    }

    @objc private func openWhisper() {
        navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: deskKey), animated: true)
    }

    @objc private func openSafety() {
        NightSocialSafetyFlow.presentChooser(from: self, target: .desk(deskKey))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { moments.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let moment = moments[indexPath.item]
        if let clipKey = moment.clipKey, let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeClipTile.reuseId, for: indexPath) as! LoungeClipTile
            cell.paint(clip, musicMode: false)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeMomentTile.reuseId, for: indexPath) as! LoungeMomentTile
        cell.paint(moment)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let col = (collectionView.bounds.width - 42) / 2
        return CGSize(width: col, height: col * 1.32)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let moment = moments[indexPath.item]
        if let clipKey = moment.clipKey {
            navigationController?.pushViewController(NightSocialClipTheater(clipKey: clipKey), animated: true)
        } else {
            navigationController?.pushViewController(NightSocialMomentBoard(moment: moment), animated: true)
        }
    }
}

final class NightSocialMomentBoard: UIViewController {
    private let moment: DeskMoment
    init(moment: DeskMoment) {
        self.moment = moment
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        navigationController?.setNavigationBarHidden(true, animated: false)
        let still = UIImageView(
            image: moment.useCover
                ? NightSocialMediaAssets.cover(for: moment.deskKey, size: CGSize(width: 430, height: 760))
                : NightSocialMediaAssets.portrait(for: moment.deskKey, size: CGSize(width: 430, height: 760))
        )
        still.contentMode = .scaleAspectFill
        still.clipsToBounds = true
        still.translatesAutoresizingMaskIntoConstraints = false
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let caption = UILabel()
        caption.text = moment.caption
        caption.font = AfterHoursType.foyerBody(16)
        caption.textColor = .white
        caption.numberOfLines = 0
        caption.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(still)
        view.addSubview(back)
        view.addSubview(caption)
        NSLayoutConstraint.activate([
            still.topAnchor.constraint(equalTo: view.topAnchor),
            still.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            still.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            still.bottomAnchor.constraint(equalTo: caption.topAnchor, constant: -16),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            caption.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
}
