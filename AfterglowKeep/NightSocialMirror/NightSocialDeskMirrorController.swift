import UIKit

final class NightSocialDeskMirrorController: UIViewController {
    private let scroller = UIScrollView()
    private let cover = UIImageView()
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let handlePlate = UILabel()
    private let vibePlate = UILabel()
    private let followPlate = UILabel()
    private let fanPlate = UILabel()
    private let friendPlate = UILabel()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)

        scroller.alwaysBounceVertical = true
        scroller.contentInsetAdjustmentBehavior = .never
        scroller.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        scroller.translatesAutoresizingMaskIntoConstraints = false

        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false

        let word = UIImageView(image: NightSocialImageCabinet.named("MirrorProfileMark", fallback: "Sing_Clip"))
        word.contentMode = .scaleAspectFit
        word.translatesAutoresizingMaskIntoConstraints = false
        let globe = NightSocialLoungeChrome.iconControl(catalog: "MirrorGlobeMark", fallback: "Frame@2x(64)", edge: 32)
        globe.addTarget(self, action: #selector(openLanguage), for: .touchUpInside)
        let gear = UIButton(type: .system)
        gear.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        gear.tintColor = .white
        gear.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        gear.translatesAutoresizingMaskIntoConstraints = false

        portrait.layer.cornerRadius = 36
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 3
        portrait.layer.borderColor = UIColor.white.cgColor
        portrait.isUserInteractionEnabled = true
        portrait.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEdit)))
        portrait.translatesAutoresizingMaskIntoConstraints = false
        let lens = UIImageView(image: NightSocialImageCabinet.named("PortraitLensBadge", fallback: "Frame_1"))
        lens.contentMode = .scaleAspectFit
        lens.translatesAutoresizingMaskIntoConstraints = false

        namePlate.font = AfterHoursType.foyerHeadline(22)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        handlePlate.font = AfterHoursType.foyerCaption(12)
        handlePlate.textColor = UIColor.white.withAlphaComponent(0.7)
        handlePlate.translatesAutoresizingMaskIntoConstraints = false
        vibePlate.font = AfterHoursType.foyerBody(13)
        vibePlate.textColor = UIColor.white.withAlphaComponent(0.9)
        vibePlate.numberOfLines = 0
        vibePlate.translatesAutoresizingMaskIntoConstraints = false
        let tags = UILabel()
        tags.text = "#ChillSocial   #LiveTogether"
        tags.font = AfterHoursType.foyerCaption(12)
        tags.textColor = AfterHoursPalette.loungePink
        tags.translatesAutoresizingMaskIntoConstraints = false

        let stats = UIButton(type: .custom)
        stats.backgroundColor = AfterHoursPalette.loungePink
        stats.layer.cornerRadius = 16
        stats.addTarget(self, action: #selector(openFollowList), for: .touchUpInside)
        stats.translatesAutoresizingMaskIntoConstraints = false
        followPlate.font = AfterHoursType.foyerPill(16)
        followPlate.textColor = .white
        followPlate.textAlignment = .center
        followPlate.numberOfLines = 2
        fanPlate.font = AfterHoursType.foyerPill(16)
        fanPlate.textColor = .white
        fanPlate.textAlignment = .center
        fanPlate.numberOfLines = 2
        friendPlate.font = AfterHoursType.foyerPill(16)
        friendPlate.textColor = .white
        friendPlate.textAlignment = .center
        friendPlate.numberOfLines = 2
        followPlate.translatesAutoresizingMaskIntoConstraints = false
        fanPlate.translatesAutoresizingMaskIntoConstraints = false
        friendPlate.translatesAutoresizingMaskIntoConstraints = false
        let fanTap = UIButton(type: .custom)
        fanTap.addTarget(self, action: #selector(openFans), for: .touchUpInside)
        fanTap.translatesAutoresizingMaskIntoConstraints = false
        let friendTap = UIButton(type: .custom)
        friendTap.addTarget(self, action: #selector(openFriends), for: .touchUpInside)
        friendTap.translatesAutoresizingMaskIntoConstraints = false

        let wallet = UIButton(type: .custom)
        wallet.setImage(NightSocialImageCabinet.named("MirrorWalletCard", fallback: "Group_915"), for: .normal)
        wallet.imageView?.contentMode = .scaleAspectFit
        wallet.addTarget(self, action: #selector(openWallet), for: .touchUpInside)
        let check = UIButton(type: .custom)
        check.setImage(NightSocialImageCabinet.named("MirrorCheckCard", fallback: "Group_917"), for: .normal)
        check.imageView?.contentMode = .scaleAspectFit
        check.addTarget(self, action: #selector(openCheckIn), for: .touchUpInside)
        let level = UIButton(type: .custom)
        level.setImage(NightSocialImageCabinet.named("MirrorLevelCard", fallback: "Group_919"), for: .normal)
        level.imageView?.contentMode = .scaleAspectFit
        level.addTarget(self, action: #selector(openLevel), for: .touchUpInside)
        wallet.translatesAutoresizingMaskIntoConstraints = false
        check.translatesAutoresizingMaskIntoConstraints = false
        level.translatesAutoresizingMaskIntoConstraints = false

        let blacklist = menuRow("MirrorPersonMark", "Frame@2x(37)", "Blacklist", #selector(openBlacklist))
        let support = menuRow("MirrorSupportMark", "huaban-6136992362_1", "Customer Support", #selector(openSupport))
        let invite = menuRow("MirrorInviteMark", "Frame@2x(13)", "Invite Code", #selector(openInvite))
        let feedback = menuRow("MirrorFeedbackMark", "Frame@2x(66)", "Feedback", #selector(openFeedback))
        let bag = menuRow("MirrorBagMark", "Frame@2x(67)", "My backpack", #selector(openBag))
        let menus = UIStackView(arrangedSubviews: [blacklist, support, invite, feedback, bag])
        menus.axis = .vertical
        menus.spacing = 10
        menus.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scroller)
        scroller.addSubview(cover)
        scroller.addSubview(word)
        scroller.addSubview(globe)
        scroller.addSubview(gear)
        scroller.addSubview(portrait)
        scroller.addSubview(lens)
        scroller.addSubview(namePlate)
        scroller.addSubview(handlePlate)
        scroller.addSubview(vibePlate)
        scroller.addSubview(tags)
        scroller.addSubview(stats)
        stats.addSubview(followPlate)
        stats.addSubview(fanPlate)
        stats.addSubview(friendPlate)
        stats.addSubview(fanTap)
        stats.addSubview(friendTap)
        scroller.addSubview(wallet)
        scroller.addSubview(check)
        scroller.addSubview(level)
        scroller.addSubview(menus)

        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cover.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 260),
            word.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            word.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 54),
            word.heightAnchor.constraint(equalToConstant: 28),
            word.widthAnchor.constraint(equalToConstant: 90),
            gear.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gear.centerYAnchor.constraint(equalTo: word.centerYAnchor),
            gear.widthAnchor.constraint(equalToConstant: 28),
            gear.heightAnchor.constraint(equalToConstant: 28),
            globe.trailingAnchor.constraint(equalTo: gear.leadingAnchor, constant: -10),
            globe.centerYAnchor.constraint(equalTo: word.centerYAnchor),
            portrait.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portrait.centerYAnchor.constraint(equalTo: cover.bottomAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 72),
            portrait.heightAnchor.constraint(equalToConstant: 72),
            lens.trailingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 4),
            lens.bottomAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 4),
            lens.widthAnchor.constraint(equalToConstant: 22),
            lens.heightAnchor.constraint(equalToConstant: 22),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            namePlate.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 8),
            handlePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            handlePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
            vibePlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vibePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vibePlate.topAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 14),
            tags.leadingAnchor.constraint(equalTo: vibePlate.leadingAnchor),
            tags.topAnchor.constraint(equalTo: vibePlate.bottomAnchor, constant: 8),
            stats.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stats.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stats.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 14),
            stats.heightAnchor.constraint(equalToConstant: 64),
            followPlate.leadingAnchor.constraint(equalTo: stats.leadingAnchor),
            followPlate.centerYAnchor.constraint(equalTo: stats.centerYAnchor),
            followPlate.widthAnchor.constraint(equalTo: stats.widthAnchor, multiplier: 1 / 3),
            fanPlate.centerXAnchor.constraint(equalTo: stats.centerXAnchor),
            fanPlate.centerYAnchor.constraint(equalTo: stats.centerYAnchor),
            fanPlate.widthAnchor.constraint(equalTo: followPlate.widthAnchor),
            friendPlate.trailingAnchor.constraint(equalTo: stats.trailingAnchor),
            friendPlate.centerYAnchor.constraint(equalTo: stats.centerYAnchor),
            friendPlate.widthAnchor.constraint(equalTo: followPlate.widthAnchor),
            fanTap.centerXAnchor.constraint(equalTo: fanPlate.centerXAnchor),
            fanTap.centerYAnchor.constraint(equalTo: fanPlate.centerYAnchor),
            fanTap.widthAnchor.constraint(equalTo: fanPlate.widthAnchor),
            fanTap.heightAnchor.constraint(equalTo: stats.heightAnchor),
            friendTap.centerXAnchor.constraint(equalTo: friendPlate.centerXAnchor),
            friendTap.centerYAnchor.constraint(equalTo: friendPlate.centerYAnchor),
            friendTap.widthAnchor.constraint(equalTo: friendPlate.widthAnchor),
            friendTap.heightAnchor.constraint(equalTo: stats.heightAnchor),
            wallet.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wallet.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 14),
            wallet.widthAnchor.constraint(equalToConstant: 168),
            wallet.heightAnchor.constraint(equalToConstant: 92),
            check.leadingAnchor.constraint(equalTo: wallet.trailingAnchor, constant: 10),
            check.topAnchor.constraint(equalTo: wallet.topAnchor),
            check.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            check.heightAnchor.constraint(equalToConstant: 42),
            level.leadingAnchor.constraint(equalTo: check.leadingAnchor),
            level.trailingAnchor.constraint(equalTo: check.trailingAnchor),
            level.topAnchor.constraint(equalTo: check.bottomAnchor, constant: 8),
            level.heightAnchor.constraint(equalToConstant: 42),
            menus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menus.topAnchor.constraint(equalTo: wallet.bottomAnchor, constant: 16),
            menus.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -16),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(paintDesk), name: .deskDrawerDidChange, object: nil)
        paintDesk()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        paintDesk()
    }

    private func menuRow(_ catalog: String, _ fallback: String, _ title: String, _ sel: Selector) -> UIButton {
        let row = UIButton(type: .custom)
        row.backgroundColor = AfterHoursPalette.loungeCard
        row.layer.cornerRadius = 16
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true
        let icon = UIImageView(image: NightSocialImageCabinet.named(catalog, fallback: fallback))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = title
        plate.font = AfterHoursType.foyerBody(15, weight: .semibold)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        let chev = UIImageView(image: UIImage(systemName: "chevron.right"))
        chev.tintColor = UIColor.white.withAlphaComponent(0.45)
        chev.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(icon)
        row.addSubview(plate)
        row.addSubview(chev)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            plate.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            plate.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chev.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            chev.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        row.addTarget(self, action: sel, for: .touchUpInside)
        return row
    }

    @objc private func paintDesk() {
        let session = NightSocialSessionDrawer.shared.restoredSession()
        let alias = session?.nightAlias.isEmpty == false ? session!.nightAlias : "Night guest"
        namePlate.text = alias
        handlePlate.text = "@\(String((session?.deskHolderId ?? "nightchat").prefix(10)))   Night desk"
        vibePlate.text = session?.nightSignature.isEmpty == false
            ? session!.nightSignature
            : "Live bright, connect with wonderful people."
        followPlate.text = "\(NightSocialSessionDrawer.shared.followedDeskKeys().count)\nFollowing"
        fanPlate.text = "\(NightSocialSessionDrawer.shared.fanDeskKeys().count)\nFollowers"
        friendPlate.text = "\(NightSocialSessionDrawer.shared.acceptedFriendKeys().count)\nFriends"
        portrait.image = NightSocialSessionDrawer.shared.loadPortrait()
            ?? NightSocialMediaAssets.localPortrait(size: CGSize(width: 160, height: 160))
        cover.image = NightSocialSessionDrawer.shared.loadCover()
            ?? NightSocialMediaAssets.localCover(size: CGSize(width: 420, height: 520))
    }

    @objc private func openLanguage() {
        navigationController?.pushViewController(NightSocialMirrorLanguageBoard(), animated: true)
    }
    @objc private func openSettings() {
        navigationController?.pushViewController(NightSocialMirrorSettingsBoard(), animated: true)
    }
    @objc private func openEdit() {
        navigationController?.pushViewController(NightSocialMirrorEditBoard(), animated: true)
    }
    @objc private func openFollowList() {
        navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .follow), animated: true)
    }
    @objc private func openFans() {
        navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .fans), animated: true)
    }
    @objc private func openFriends() {
        navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .friends), animated: true)
    }
    @objc private func openBlacklist() {
        navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .blacklist), animated: true)
    }
    @objc private func openSupport() {
        navigationController?.pushViewController(NightSocialMirrorSupportBoard(), animated: true)
    }
    @objc private func openInvite() {
        navigationController?.pushViewController(NightSocialMirrorInviteBoard(), animated: true)
    }
    @objc private func openFeedback() {
        navigationController?.pushViewController(NightSocialMirrorFeedbackBoard(), animated: true)
    }
    @objc private func openBag() {
        navigationController?.pushViewController(NightSocialMirrorBackpackBoard(), animated: true)
    }
    @objc private func openWallet() {
        navigationController?.pushViewController(NightSocialMirrorRechargeBoard(), animated: true)
    }
    @objc private func openCheckIn() {
        navigationController?.pushViewController(NightSocialMirrorCheckInBoard(), animated: true)
    }
    @objc private func openLevel() {
        navigationController?.pushViewController(NightSocialMirrorLevelBoard(), animated: true)
    }
}
