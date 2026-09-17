import UIKit

final class NightSocialDeskMirrorController: UIViewController {
    private let scroller = UIScrollView()
    private let cover = UIImageView()
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let handlePlate = UILabel()
    private let vibePlate = UILabel()
    private let landPlate = UILabel()
    private let pursePlate = UILabel()
    private let followCount = UILabel()
    private let fanCount = UILabel()
    private let friendCount = UILabel()

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

        let word = UIImageView(image: NightSocialImageCabinet.named("ProfileTitle", fallback: "ProfileTitle"))
        word.contentMode = .scaleAspectFit
        word.translatesAutoresizingMaskIntoConstraints = false
        let globe = magentaChip(symbol: "globe")
        globe.addTarget(self, action: #selector(openLanguage), for: .touchUpInside)
        let gear = magentaChip(symbol: "gearshape.fill")
        gear.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        portrait.contentMode = .scaleAspectFill
        portrait.layer.cornerRadius = 38
        portrait.clipsToBounds = true
        portrait.layer.borderWidth = 3
        portrait.layer.borderColor = UIColor.white.cgColor
        portrait.isUserInteractionEnabled = true
        portrait.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEdit)))
        portrait.translatesAutoresizingMaskIntoConstraints = false
        let lens = UIButton(type: .custom)
        lens.backgroundColor = .white
        lens.layer.cornerRadius = 16
        lens.layer.shadowColor = UIColor.black.cgColor
        lens.layer.shadowOpacity = 0.2
        lens.layer.shadowRadius = 6
        lens.layer.shadowOffset = CGSize(width: 0, height: 2)
        lens.setImage(
            UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)),
            for: .normal
        )
        lens.tintColor = AfterHoursPalette.loungePink
        lens.addTarget(self, action: #selector(openEdit), for: .touchUpInside)
        lens.translatesAutoresizingMaskIntoConstraints = false

        namePlate.font = AfterHoursType.foyerHeadline(20)
        namePlate.textColor = .white
        namePlate.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        let level = NightSocialLoungeChrome.mintLevelPlate(8)
        handlePlate.font = AfterHoursType.foyerCaption(12)
        handlePlate.textColor = UIColor.white.withAlphaComponent(0.7)
        handlePlate.translatesAutoresizingMaskIntoConstraints = false

        pursePlate.font = AfterHoursType.foyerCaption(11)
        pursePlate.textColor = .white
        pursePlate.translatesAutoresizingMaskIntoConstraints = false
        let diamond = UIImageView(image: NightSocialImageCabinet.named("DiamondIcon", fallback: "DiamondIcon"))
        diamond.contentMode = .scaleAspectFit
        diamond.translatesAutoresizingMaskIntoConstraints = false
        landPlate.font = AfterHoursType.foyerCaption(11)
        landPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        landPlate.translatesAutoresizingMaskIntoConstraints = false
        let pin = UIImageView(image: UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)))
        pin.tintColor = AfterHoursPalette.loungePink
        pin.translatesAutoresizingMaskIntoConstraints = false

        let vibeMark = UIImageView(image: NightSocialImageCabinet.named("FeedbackIcon", fallback: "FeedbackIcon"))
        vibeMark.contentMode = .scaleAspectFit
        vibeMark.translatesAutoresizingMaskIntoConstraints = false
        vibePlate.font = AfterHoursType.foyerBody(13)
        vibePlate.textColor = UIColor.white.withAlphaComponent(0.9)
        vibePlate.numberOfLines = 2
        vibePlate.translatesAutoresizingMaskIntoConstraints = false

        let tagRow = UIStackView(arrangedSubviews: [tagChip("#ChillSocial"), tagChip("#LiveTogether")])
        tagRow.axis = .horizontal
        tagRow.spacing = 8
        tagRow.translatesAutoresizingMaskIntoConstraints = false

        let stats = UIButton(type: .custom)
        stats.backgroundColor = AfterHoursPalette.loungePink
        stats.layer.cornerRadius = 20
        stats.addTarget(self, action: #selector(openFollowList), for: .touchUpInside)
        stats.translatesAutoresizingMaskIntoConstraints = false
        let followCol = statColumn(count: followCount, caption: NightLang.t(.following))
        let fanCol = statColumn(count: fanCount, caption: NightLang.t(.followers))
        let friendCol = statColumn(count: friendCount, caption: NightLang.t(.friends))
        let fanTap = UIButton(type: .custom)
        fanTap.addTarget(self, action: #selector(openFans), for: .touchUpInside)
        fanTap.translatesAutoresizingMaskIntoConstraints = false
        let friendTap = UIButton(type: .custom)
        friendTap.addTarget(self, action: #selector(openFriends), for: .touchUpInside)
        friendTap.translatesAutoresizingMaskIntoConstraints = false

        let wallet = perkCard(
            image: NightSocialImageCabinet.named("WalletCard", fallback: "WalletCard"),
            go: NightSocialImageCabinet.named("GoButton", fallback: "GoButton"),
            goSize: CGSize(width: 60, height: 22),
            action: #selector(openWallet)
        )
        let check = perkCard(
            image: NightSocialImageCabinet.named("CheckInCard", fallback: "CheckInCard"),
            go: NightSocialImageCabinet.named("GoCheckInButton", fallback: "GoCheckInButton"),
            goSize: CGSize(width: 40, height: 18),
            action: #selector(openCheckIn)
        )
        let levelCard = perkCard(
            image: NightSocialImageCabinet.named("LevelCard", fallback: "LevelCard"),
            go: NightSocialImageCabinet.named("GoLevelButton", fallback: "GoLevelButton"),
            goSize: CGSize(width: 40, height: 18),
            action: #selector(openLevel)
        )

        let blacklist = menuRow("person.fill", NightLang.t(.blacklist), #selector(openBlacklist))
        let support = menuRow("headphones", NightLang.t(.customerSupport), #selector(openSupport))
        let invite = menuRow("envelope.fill", NightLang.t(.inviteCode), #selector(openInvite))
        let feedback = menuRow("info.circle.fill", NightLang.t(.feedback), #selector(openFeedback))
        let bag = menuRow("bag.fill", NightLang.t(.backpack), #selector(openBag))
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
        scroller.addSubview(level)
        scroller.addSubview(handlePlate)
        scroller.addSubview(diamond)
        scroller.addSubview(pursePlate)
        scroller.addSubview(pin)
        scroller.addSubview(landPlate)
        scroller.addSubview(vibeMark)
        scroller.addSubview(vibePlate)
        scroller.addSubview(tagRow)
        scroller.addSubview(stats)
        stats.addSubview(followCol)
        stats.addSubview(fanCol)
        stats.addSubview(friendCol)
        stats.addSubview(fanTap)
        stats.addSubview(friendTap)
        scroller.addSubview(wallet)
        scroller.addSubview(check)
        scroller.addSubview(levelCard)
        scroller.addSubview(menus)

        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cover.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 210),
            word.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            word.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 54),
            word.heightAnchor.constraint(equalToConstant: 28),
            word.widthAnchor.constraint(equalToConstant: 90),
            gear.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gear.centerYAnchor.constraint(equalTo: word.centerYAnchor),
            globe.trailingAnchor.constraint(equalTo: gear.leadingAnchor, constant: -8),
            globe.centerYAnchor.constraint(equalTo: word.centerYAnchor),
            portrait.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portrait.centerYAnchor.constraint(equalTo: cover.bottomAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 76),
            portrait.heightAnchor.constraint(equalToConstant: 76),
            lens.centerXAnchor.constraint(equalTo: portrait.trailingAnchor, constant: -4),
            lens.centerYAnchor.constraint(equalTo: portrait.bottomAnchor, constant: -4),
            lens.widthAnchor.constraint(equalToConstant: 32),
            lens.heightAnchor.constraint(equalToConstant: 32),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            namePlate.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 6),
            level.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 8),
            level.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            handlePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            handlePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
            landPlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            landPlate.centerYAnchor.constraint(equalTo: handlePlate.centerYAnchor),
            pin.trailingAnchor.constraint(equalTo: landPlate.leadingAnchor, constant: -4),
            pin.centerYAnchor.constraint(equalTo: landPlate.centerYAnchor),
            pin.widthAnchor.constraint(equalToConstant: 12),
            pin.heightAnchor.constraint(equalToConstant: 12),
            pursePlate.trailingAnchor.constraint(equalTo: landPlate.trailingAnchor),
            pursePlate.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            diamond.trailingAnchor.constraint(equalTo: pursePlate.leadingAnchor, constant: -4),
            diamond.centerYAnchor.constraint(equalTo: pursePlate.centerYAnchor),
            diamond.widthAnchor.constraint(equalToConstant: 14),
            diamond.heightAnchor.constraint(equalToConstant: 14),
            level.trailingAnchor.constraint(lessThanOrEqualTo: diamond.leadingAnchor, constant: -8),
            vibeMark.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vibeMark.topAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 16),
            vibeMark.widthAnchor.constraint(equalToConstant: 16),
            vibeMark.heightAnchor.constraint(equalToConstant: 16),
            vibePlate.leadingAnchor.constraint(equalTo: vibeMark.trailingAnchor, constant: 8),
            vibePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vibePlate.topAnchor.constraint(equalTo: vibeMark.topAnchor, constant: -2),
            tagRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tagRow.topAnchor.constraint(equalTo: vibePlate.bottomAnchor, constant: 10),
            stats.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stats.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stats.topAnchor.constraint(equalTo: tagRow.bottomAnchor, constant: 14),
            stats.heightAnchor.constraint(equalToConstant: 72),
            followCol.leadingAnchor.constraint(equalTo: stats.leadingAnchor),
            followCol.topAnchor.constraint(equalTo: stats.topAnchor),
            followCol.bottomAnchor.constraint(equalTo: stats.bottomAnchor),
            followCol.widthAnchor.constraint(equalTo: stats.widthAnchor, multiplier: 1 / 3),
            fanCol.centerXAnchor.constraint(equalTo: stats.centerXAnchor),
            fanCol.topAnchor.constraint(equalTo: stats.topAnchor),
            fanCol.bottomAnchor.constraint(equalTo: stats.bottomAnchor),
            fanCol.widthAnchor.constraint(equalTo: followCol.widthAnchor),
            friendCol.trailingAnchor.constraint(equalTo: stats.trailingAnchor),
            friendCol.topAnchor.constraint(equalTo: stats.topAnchor),
            friendCol.bottomAnchor.constraint(equalTo: stats.bottomAnchor),
            friendCol.widthAnchor.constraint(equalTo: followCol.widthAnchor),
            fanTap.centerXAnchor.constraint(equalTo: fanCol.centerXAnchor),
            fanTap.centerYAnchor.constraint(equalTo: fanCol.centerYAnchor),
            fanTap.widthAnchor.constraint(equalTo: fanCol.widthAnchor),
            fanTap.heightAnchor.constraint(equalTo: stats.heightAnchor),
            friendTap.centerXAnchor.constraint(equalTo: friendCol.centerXAnchor),
            friendTap.centerYAnchor.constraint(equalTo: friendCol.centerYAnchor),
            friendTap.widthAnchor.constraint(equalTo: friendCol.widthAnchor),
            friendTap.heightAnchor.constraint(equalTo: stats.heightAnchor),
            wallet.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wallet.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 12),
            wallet.widthAnchor.constraint(equalToConstant: 187),
            wallet.heightAnchor.constraint(equalToConstant: 180),
            check.leadingAnchor.constraint(equalTo: wallet.trailingAnchor, constant: 8),
            check.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            check.topAnchor.constraint(equalTo: wallet.topAnchor),
            check.heightAnchor.constraint(equalToConstant: 85.67),
            levelCard.leadingAnchor.constraint(equalTo: check.leadingAnchor),
            levelCard.trailingAnchor.constraint(equalTo: check.trailingAnchor),
            levelCard.topAnchor.constraint(equalTo: check.bottomAnchor, constant: 8.66),
            levelCard.bottomAnchor.constraint(equalTo: wallet.bottomAnchor),
            menus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menus.topAnchor.constraint(equalTo: wallet.bottomAnchor, constant: 14),
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

    private func magentaChip(symbol: String) -> UIButton {
        let chip = UIButton(type: .custom)
        chip.backgroundColor = AfterHoursPalette.loungePink
        chip.layer.cornerRadius = 18
        chip.setImage(
            UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)),
            for: .normal
        )
        chip.tintColor = .white
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.widthAnchor.constraint(equalToConstant: 36).isActive = true
        chip.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return chip
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

    private func statColumn(count: UILabel, caption: String) -> UIView {
        let wrap = UIView()
        wrap.isUserInteractionEnabled = false
        wrap.translatesAutoresizingMaskIntoConstraints = false
        count.font = AfterHoursType.foyerPill(20)
        count.textColor = .white
        count.textAlignment = .center
        count.translatesAutoresizingMaskIntoConstraints = false
        let cap = UILabel()
        cap.text = caption
        cap.font = AfterHoursType.foyerCaption(11)
        cap.textColor = UIColor.white.withAlphaComponent(0.88)
        cap.textAlignment = .center
        cap.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(count)
        wrap.addSubview(cap)
        NSLayoutConstraint.activate([
            count.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            count.centerYAnchor.constraint(equalTo: wrap.centerYAnchor, constant: -8),
            cap.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            cap.topAnchor.constraint(equalTo: count.bottomAnchor, constant: 2),
        ])
        return wrap
    }

    private func perkCard(image: UIImage?, go: UIImage?, goSize: CGSize, action: Selector) -> UIButton {
        let card = UIButton(type: .custom)
        card.adjustsImageWhenHighlighted = false
        card.clipsToBounds = true
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false
        let art = UIImageView(image: image)
        art.contentMode = .scaleAspectFill
        art.clipsToBounds = true
        art.isUserInteractionEnabled = false
        art.translatesAutoresizingMaskIntoConstraints = false
        let goMark = UIImageView(image: go)
        goMark.contentMode = .scaleAspectFit
        goMark.isUserInteractionEnabled = false
        goMark.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(art)
        card.addSubview(goMark)
        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: card.topAnchor),
            art.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            art.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            art.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            goMark.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            goMark.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            goMark.widthAnchor.constraint(equalToConstant: goSize.width),
            goMark.heightAnchor.constraint(equalToConstant: goSize.height),
        ])
        card.addTarget(self, action: action, for: .touchUpInside)
        return card
    }

    private func menuRow(_ symbol: String, _ title: String, _ sel: Selector) -> UIButton {
        let row = UIButton(type: .custom)
        row.backgroundColor = AfterHoursPalette.loungeCard
        row.layer.cornerRadius = 22
        row.heightAnchor.constraint(equalToConstant: 54).isActive = true
        let disc = UIView()
        disc.backgroundColor = AfterHoursPalette.loungePink
        disc.layer.cornerRadius = 16
        disc.isUserInteractionEnabled = false
        disc.translatesAutoresizingMaskIntoConstraints = false
        let glyph = UIImageView(
            image: UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        )
        glyph.tintColor = .white
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = title
        plate.font = AfterHoursType.foyerBody(15, weight: .semibold)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        let chevDisc = UIView()
        chevDisc.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        chevDisc.layer.cornerRadius = 12
        chevDisc.isUserInteractionEnabled = false
        chevDisc.translatesAutoresizingMaskIntoConstraints = false
        let chev = UIImageView(
            image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        )
        chev.tintColor = .white
        chev.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(disc)
        disc.addSubview(glyph)
        row.addSubview(plate)
        row.addSubview(chevDisc)
        chevDisc.addSubview(chev)
        NSLayoutConstraint.activate([
            disc.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
            disc.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 32),
            disc.heightAnchor.constraint(equalToConstant: 32),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 16),
            glyph.heightAnchor.constraint(equalToConstant: 16),
            plate.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 12),
            plate.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevDisc.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
            chevDisc.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevDisc.widthAnchor.constraint(equalToConstant: 24),
            chevDisc.heightAnchor.constraint(equalToConstant: 24),
            chev.centerXAnchor.constraint(equalTo: chevDisc.centerXAnchor),
            chev.centerYAnchor.constraint(equalTo: chevDisc.centerYAnchor),
        ])
        row.addTarget(self, action: sel, for: .touchUpInside)
        return row
    }

    @objc private func paintDesk() {
        let session = NightSocialSessionDrawer.shared.restoredSession()
        let alias = session?.nightAlias.isEmpty == false ? session!.nightAlias : "Night guest"
        namePlate.text = alias
        handlePlate.text = "@\(String((session?.deskHolderId ?? "nightchat").prefix(10)))"
        vibePlate.text = session?.nightSignature.isEmpty == false
            ? session!.nightSignature
            : "Live bright, connect with wonderful people."
        followCount.text = "\(NightSocialSessionDrawer.shared.followedDeskKeys().count)"
        fanCount.text = "\(NightSocialSessionDrawer.shared.fanDeskKeys().count)"
        friendCount.text = "\(NightSocialSessionDrawer.shared.acceptedFriendKeys().count)"
        pursePlate.text = "\(NightSocialSessionDrawer.shared.diamondPurse)"
        landPlate.text = NightSocialLampAtlas.land(code: NightSocialSessionDrawer.shared.homeCountryCode).spokenTitle
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
