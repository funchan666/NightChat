import UIKit

final class NightSocialCreatorDeskBoard: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let deskKey: String
    private let cover = UIImageView()
    private let followPill = NightSocialLoungeChrome.pinkPill(title: "+ Follow")
    private let chatPill = UIButton(type: .custom)
    private var clips: [LoungeClipReel] = []
    private var collection: UICollectionView!

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
        guard let desk = NightSocialLoungeCatalog.creator(deskKey: deskKey) else { return }
        clips = NightSocialLoungeCatalog.clips(for: deskKey)

        cover.image = NightSocialStandIn.plate(seed: desk.spokenName + "-cover", size: CGSize(width: 400, height: 640))
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let more = NightSocialLoungeChrome.iconControl(catalog: "LoungeMoreDisc", fallback: "Frame@2x(24)")
        more.addTarget(self, action: #selector(openSafety), for: .touchUpInside)

        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false

        let portrait = UIImageView(image: NightSocialStandIn.plate(seed: desk.spokenName, size: CGSize(width: 160, height: 160)))
        portrait.layer.cornerRadius = 28
        portrait.clipsToBounds = true
        portrait.translatesAutoresizingMaskIntoConstraints = false

        let namePlate = UILabel()
        namePlate.text = desk.spokenName
        namePlate.font = AfterHoursType.foyerHeadline(20)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        let cityPlate = UILabel()
        cityPlate.text = desk.cityLabel
        cityPlate.font = AfterHoursType.foyerCaption(12)
        cityPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        cityPlate.translatesAutoresizingMaskIntoConstraints = false
        let handlePlate = UILabel()
        handlePlate.text = desk.handleTag
        handlePlate.font = AfterHoursType.foyerCaption(12)
        handlePlate.textColor = UIColor.white.withAlphaComponent(0.7)
        handlePlate.translatesAutoresizingMaskIntoConstraints = false
        let vibePlate = UILabel()
        vibePlate.text = desk.vibeLine
        vibePlate.font = AfterHoursType.foyerBody(13)
        vibePlate.textColor = UIColor.white.withAlphaComponent(0.85)
        vibePlate.numberOfLines = 0
        vibePlate.translatesAutoresizingMaskIntoConstraints = false
        let tags = UILabel()
        tags.text = desk.vibeTags.map { "#\($0)" }.joined(separator: "  ")
        tags.font = AfterHoursType.foyerCaption(11)
        tags.textColor = AfterHoursPalette.loungePink
        tags.translatesAutoresizingMaskIntoConstraints = false
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)

        followPill.addTarget(self, action: #selector(flipFollow), for: .touchUpInside)
        chatPill.setImage(NightSocialImageCabinet.named("LoungeChatPill", fallback: "Group_560"), for: .normal)
        chatPill.imageView?.contentMode = .scaleAspectFit
        chatPill.addTarget(self, action: #selector(openWhisper), for: .touchUpInside)
        chatPill.translatesAutoresizingMaskIntoConstraints = false

        let videoHead = UILabel()
        videoHead.text = "video"
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
        collection.register(LoungeClipTile.self, forCellWithReuseIdentifier: LoungeClipTile.reuseId)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.contentInsetAdjustmentBehavior = .never

        view.addSubview(cover)
        view.addSubview(back)
        view.addSubview(more)
        view.addSubview(card)
        card.addSubview(portrait)
        card.addSubview(namePlate)
        card.addSubview(cityPlate)
        card.addSubview(handlePlate)
        card.addSubview(level)
        card.addSubview(vibePlate)
        card.addSubview(tags)
        card.addSubview(followPill)
        card.addSubview(chatPill)
        view.addSubview(videoHead)
        view.addSubview(collection)

        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: view.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: -88),
            portrait.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            portrait.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            portrait.widthAnchor.constraint(equalToConstant: 56),
            portrait.heightAnchor.constraint(equalToConstant: 56),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor),
            cityPlate.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 6),
            cityPlate.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            handlePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            handlePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 2),
            level.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            level.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vibePlate.leadingAnchor.constraint(equalTo: portrait.leadingAnchor),
            vibePlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            vibePlate.topAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 10),
            tags.leadingAnchor.constraint(equalTo: vibePlate.leadingAnchor),
            tags.topAnchor.constraint(equalTo: vibePlate.bottomAnchor, constant: 6),
            followPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            followPill.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 12),
            followPill.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            followPill.widthAnchor.constraint(equalToConstant: 140),
            chatPill.leadingAnchor.constraint(equalTo: followPill.trailingAnchor, constant: 10),
            chatPill.centerYAnchor.constraint(equalTo: followPill.centerYAnchor),
            chatPill.widthAnchor.constraint(equalToConstant: 120),
            chatPill.heightAnchor.constraint(equalToConstant: 36),
            videoHead.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoHead.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 16),
            collection.topAnchor.constraint(equalTo: videoHead.bottomAnchor, constant: 8),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        paintFollow()
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func flipFollow() {
        NightSocialSessionDrawer.shared.toggleFollow(deskKey)
        paintFollow()
    }

    private func paintFollow() {
        let on = NightSocialSessionDrawer.shared.isFollowing(deskKey)
        followPill.setTitle(on ? "Followed" : "+ Follow", for: .normal)
        followPill.backgroundColor = on ? UIColor.white.withAlphaComponent(0.22) : AfterHoursPalette.loungePink
    }

    @objc private func openWhisper() {
        guard let desk = NightSocialLoungeCatalog.creator(deskKey: deskKey) else { return }
        navigationController?.pushViewController(NightSocialWhisperTrail(deskKey: desk.deskKey, spokenName: desk.spokenName), animated: true)
    }

    @objc private func openSafety() {
        present(NightSocialSafetySheet(deskKey: deskKey), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { max(clips.count, 2) }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoungeClipTile.reuseId, for: indexPath) as! LoungeClipTile
        if indexPath.item < clips.count {
            cell.paint(clips[indexPath.item], musicMode: false)
        } else if let desk = NightSocialLoungeCatalog.creator(deskKey: deskKey) {
            let fallback = LoungeClipReel(clipKey: "\(deskKey).standin.\(indexPath.item)", authorDeskKey: deskKey, authorSpokenName: desk.spokenName, caption: desk.clipCaptions[indexPath.item % max(desk.clipCaptions.count, 1)], placeLabel: desk.cityLabel, timePhrase: "", likeCount: desk.likeCount, commentCount: 12, shareCount: 4, meridian: desk.meridian, musicTitle: desk.musicTitle)
            cell.paint(fallback, musicMode: false)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let col = (collectionView.bounds.width - 42) / 2
        return CGSize(width: col, height: col * 1.3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < clips.count {
            navigationController?.pushViewController(NightSocialClipTheater(clipKey: clips[indexPath.item].clipKey), animated: true)
        }
    }
}

final class NightSocialSafetySheet: UIViewController {
    private let deskKey: String
    init(deskKey: String) {
        self.deskKey = deskKey
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        let card = UIView()
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false
        let block = UIButton(type: .custom)
        block.setImage(NightSocialImageCabinet.named("LoungeBlockTile", fallback: "Group_136"), for: .normal)
        block.imageView?.contentMode = .scaleAspectFit
        block.addTarget(self, action: #selector(blockDesk), for: .touchUpInside)
        let report = UIButton(type: .custom)
        report.setImage(NightSocialImageCabinet.named("LoungeReportTile", fallback: "Group_135"), for: .normal)
        report.imageView?.contentMode = .scaleAspectFit
        report.addTarget(self, action: #selector(reportDesk), for: .touchUpInside)
        block.translatesAutoresizingMaskIntoConstraints = false
        report.translatesAutoresizingMaskIntoConstraints = false
        let row = UIStackView(arrangedSubviews: [block, report])
        row.axis = .horizontal
        row.spacing = 18
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 260),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            row.heightAnchor.constraint(equalToConstant: 92),
        ])
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fold)))
    }
    @objc private func fold() { dismiss(animated: true) }
    @objc private func blockDesk() {
        NightSocialSessionDrawer.shared.blockDesk(deskKey)
        dismiss(animated: true) { [weak self] in
            self?.presentingFold()
        }
    }
    @objc private func reportDesk() {
        dismiss(animated: true)
    }
    private func presentingFold() {
        (presentingViewController as? UINavigationController)?.popViewController(animated: true)
    }
}
