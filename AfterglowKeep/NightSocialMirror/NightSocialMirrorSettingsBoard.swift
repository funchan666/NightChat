import UIKit

final class NightSocialMirrorSettingsBoard: UIViewController {
    private let deskCard = NightSocialSettingsDeskCard()
    private let blacklistLane = NightSocialSettingsLane(
        kind: .blacklist,
        title: "Blacklist",
        hint: "Desks you hid from this sitting",
        catalog: "MirrorPersonMark",
        fallback: "Frame@2x(37)"
    )
    private let languageLane = NightSocialSettingsLane(
        kind: .language,
        title: "Language",
        hint: "Spoken labels on this desk",
        catalog: "MirrorGlobeMark",
        fallback: "Frame@2x(64)"
    )

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        navigationController?.setNavigationBarHidden(true, animated: false)

        let atmosphere = NightSocialSettingsAtmosphere()
        let scroller = UIScrollView()
        scroller.alwaysBounceVertical = true
        scroller.showsVerticalScrollIndicator = false
        scroller.contentInsetAdjustmentBehavior = .never
        scroller.backgroundColor = .clear
        scroller.translatesAutoresizingMaskIntoConstraints = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Settings"
        head.font = AfterHoursType.foyerHeadline(22)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "House, desk, and sitting"
        kicker.font = AfterHoursType.foyerCaption(12)
        kicker.textColor = UIColor.white.withAlphaComponent(0.62)
        kicker.translatesAutoresizingMaskIntoConstraints = false

        let community = NightSocialSettingsLane(
            kind: .community,
            title: "Community Rules",
            hint: "How we keep the house kind",
            catalog: "SafetyShieldMark",
            fallback: "Frame@2x(37)"
        )
        let privacy = NightSocialSettingsLane(
            kind: .privacy,
            title: "Privacy agreement",
            hint: "How NightChat holds your data",
            catalog: "MirrorLockMark",
            fallback: "Frame@2x(37)"
        )
        let agreement = NightSocialSettingsLane(
            kind: .agreement,
            title: "User agreement",
            hint: "Terms of this sitting",
            symbol: "doc.text.fill"
        )
        let logout = NightSocialSettingsLane(
            kind: .logout,
            title: "Log Out",
            hint: "Park this desk until next time",
            symbol: "rectangle.portrait.and.arrow.right",
            showsChevron: false,
            tone: .leave
        )
        let deleteDesk = NightSocialSettingsLane(
            kind: .deleteDesk,
            title: "Deletion of account",
            hint: "Erase this night desk",
            catalog: "MirrorTrashMark",
            fallback: "Frame@2x(37)",
            showsChevron: false,
            tone: .erase
        )

        [blacklistLane, community, privacy, agreement, languageLane, logout, deleteDesk].forEach { lane in
            lane.addTarget(self, action: #selector(pickRow(_:)), for: .touchUpInside)
        }

        let spine = UIStackView(arrangedSubviews: [
            deskCard,
            cluster(spoken: "Safety", lanes: [blacklistLane, community]),
            cluster(spoken: "House scrolls", lanes: [privacy, agreement]),
            cluster(spoken: "Preferences", lanes: [languageLane]),
            cluster(spoken: "Account", lanes: [logout, deleteDesk]),
            versionPlate(),
        ])
        spine.axis = .vertical
        spine.spacing = 22
        spine.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(atmosphere)
        view.addSubview(scroller)
        scroller.addSubview(spine)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(kicker)
        NSLayoutConstraint.activate([
            atmosphere.topAnchor.constraint(equalTo: view.topAnchor),
            atmosphere.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            atmosphere.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            atmosphere.heightAnchor.constraint(equalToConstant: 280),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.topAnchor.constraint(equalTo: back.topAnchor, constant: -2),
            kicker.leadingAnchor.constraint(equalTo: head.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 1),
            scroller.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 16),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spine.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            spine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            spine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            spine.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -36),
            spine.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
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

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickRow(_ sender: UIControl) {
        switch NightSocialSettingsLane.Kind(rawValue: sender.tag) {
        case .blacklist:
            navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .blacklist), animated: true)
        case .community:
            navigationController?.pushViewController(NightSocialCommunityLampBoard(), animated: true)
        case .privacy:
            present(NightSocialHouseScrollBoard(scrollKind: .privacyCloth), animated: true)
        case .agreement:
            present(NightSocialHouseScrollBoard(scrollKind: .userAgreement), animated: true)
        case .deleteDesk:
            confirmLeave(delete: true)
        case .logout:
            confirmLeave(delete: false)
        case .language:
            navigationController?.pushViewController(NightSocialMirrorLanguageBoard(), animated: true)
        case .none:
            break
        }
    }

    private func confirmLeave(delete: Bool) {
        present(NightSocialLeaveConfirm(delete: delete, host: self), animated: true)
    }

    func settleLeave(delete: Bool) {
        NightSocialLampNotices.presentSeatExit(from: self, delete: delete) { [weak self] in
            if delete {
                NightSocialSessionDrawer.shared.eraseDesk()
                AfterglowRootCoordinator.revealFoyer(from: self)
            } else {
                NightSocialSessionDrawer.shared.parkDesk()
                AfterglowRootCoordinator.revealReturnDoor(from: self)
            }
        }
    }

    @objc private func paintDesk() {
        let session = NightSocialSessionDrawer.shared.restoredSession()
        let alias = session?.nightAlias.isEmpty == false ? session!.nightAlias : "Night guest"
        let handle = "@\(String((session?.deskHolderId ?? "nightchat").prefix(10)))"
        deskCard.paint(
            alias: alias,
            handle: handle,
            portrait: NightSocialSessionDrawer.shared.loadPortrait()
                ?? NightSocialMediaAssets.localPortrait(size: CGSize(width: 140, height: 140))
        )
        let blocked = NightSocialSessionDrawer.shared.blockedDeskKeys().count
        blacklistLane.setValue(blocked == 0 ? "Empty" : "\(blocked)")
        languageLane.setValue(NightSocialSessionDrawer.shared.spokenTongue)
    }

    private func cluster(spoken: String, lanes: [NightSocialSettingsLane]) -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.attributedText = NSAttributedString(
            string: spoken.uppercased(),
            attributes: [
                .font: AfterHoursType.foyerCaption(11),
                .foregroundColor: UIColor.white.withAlphaComponent(0.42),
                .kern: 1.5,
            ]
        )
        kicker.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        for (index, lane) in lanes.enumerated() {
            stack.addArrangedSubview(lane)
            if index < lanes.count - 1 {
                stack.addArrangedSubview(Self.hairline())
            }
        }
        wrap.addSubview(kicker)
        wrap.addSubview(card)
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            kicker.topAnchor.constraint(equalTo: wrap.topAnchor),
            kicker.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 6),
            card.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -6),
        ])
        return wrap
    }

    private static func hairline() -> UIView {
        let hair = UIView()
        hair.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        hair.translatesAutoresizingMaskIntoConstraints = false
        let wrap = UIView()
        wrap.addSubview(hair)
        NSLayoutConstraint.activate([
            hair.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 64),
            hair.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -16),
            hair.topAnchor.constraint(equalTo: wrap.topAnchor),
            hair.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            wrap.heightAnchor.constraint(equalToConstant: 1),
        ])
        return wrap
    }

    private func versionPlate() -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let mark = UIImageView(image: NightSocialImageCabinet.stageMark)
        mark.contentMode = .scaleAspectFill
        mark.clipsToBounds = true
        mark.layer.cornerRadius = 10
        mark.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        plate.text = "NightChat  \(version)"
        plate.font = AfterHoursType.foyerCaption(12)
        plate.textColor = UIColor.white.withAlphaComponent(0.45)
        plate.textAlignment = .center
        plate.translatesAutoresizingMaskIntoConstraints = false
        let note = UILabel()
        note.text = "After hours, still together"
        note.font = AfterHoursType.foyerCaption(11)
        note.textColor = UIColor.white.withAlphaComponent(0.28)
        note.textAlignment = .center
        note.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(mark)
        wrap.addSubview(plate)
        wrap.addSubview(note)
        NSLayoutConstraint.activate([
            mark.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            mark.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            mark.widthAnchor.constraint(equalToConstant: 20),
            mark.heightAnchor.constraint(equalToConstant: 20),
            plate.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 8),
            plate.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            note.topAnchor.constraint(equalTo: plate.bottomAnchor, constant: 4),
            note.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            note.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
        ])
        return wrap
    }
}

final class NightSocialSettingsAtmosphere: UIView {
    private let cloth = UIImageView()
    private let fade = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        cloth.image = NightSocialImageCabinet.stageWash
        cloth.contentMode = .scaleAspectFill
        cloth.clipsToBounds = true
        cloth.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cloth)
        NSLayoutConstraint.activate([
            cloth.topAnchor.constraint(equalTo: topAnchor),
            cloth.leadingAnchor.constraint(equalTo: leadingAnchor),
            cloth.trailingAnchor.constraint(equalTo: trailingAnchor),
            cloth.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        fade.colors = [
            AfterHoursPalette.loungeInk.withAlphaComponent(0.15).cgColor,
            AfterHoursPalette.loungeInk.withAlphaComponent(0.55).cgColor,
            AfterHoursPalette.loungeInk.cgColor,
        ]
        fade.locations = [0, 0.52, 1]
        fade.startPoint = CGPoint(x: 0.5, y: 0)
        fade.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(fade)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        fade.frame = bounds
    }
}

final class NightSocialSettingsDeskCard: UIView {
    private let wash = CAGradientLayer()
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let handlePlate = UILabel()
    private let chip = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        wash.colors = [
            AfterHoursPalette.foyerGlowPink.withAlphaComponent(0.42).cgColor,
            AfterHoursPalette.loungeCard.cgColor,
        ]
        wash.startPoint = CGPoint(x: 0, y: 0)
        wash.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(wash, at: 0)

        portrait.contentMode = .scaleAspectFill
        portrait.clipsToBounds = true
        portrait.layer.cornerRadius = 30
        portrait.layer.borderWidth = 2
        portrait.layer.borderColor = UIColor.white.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false

        namePlate.font = AfterHoursType.foyerHeadline(18)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        handlePlate.font = AfterHoursType.foyerCaption(12)
        handlePlate.textColor = UIColor.white.withAlphaComponent(0.7)
        handlePlate.translatesAutoresizingMaskIntoConstraints = false

        chip.text = "  Night desk  "
        chip.font = AfterHoursType.foyerCaption(10)
        chip.textColor = .white
        chip.backgroundColor = AfterHoursPalette.loungePink
        chip.layer.cornerRadius = 9
        chip.clipsToBounds = true
        chip.textAlignment = .center
        chip.translatesAutoresizingMaskIntoConstraints = false

        let sparkle = UIImageView(image: NightSocialImageCabinet.named("SparkleMark", fallback: "sparkle"))
        sparkle.contentMode = .scaleAspectFit
        sparkle.translatesAutoresizingMaskIntoConstraints = false

        addSubview(portrait)
        addSubview(namePlate)
        addSubview(handlePlate)
        addSubview(chip)
        addSubview(sparkle)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 96),
            portrait.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            portrait.centerYAnchor.constraint(equalTo: centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 60),
            portrait.heightAnchor.constraint(equalToConstant: 60),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 12),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor, constant: 2),
            namePlate.trailingAnchor.constraint(lessThanOrEqualTo: sparkle.leadingAnchor, constant: -8),
            handlePlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            handlePlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 2),
            chip.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            chip.topAnchor.constraint(equalTo: handlePlate.bottomAnchor, constant: 6),
            chip.heightAnchor.constraint(equalToConstant: 18),
            sparkle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sparkle.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            sparkle.widthAnchor.constraint(equalToConstant: 22),
            sparkle.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        wash.frame = bounds
    }

    func paint(alias: String, handle: String, portrait image: UIImage?) {
        namePlate.text = alias
        handlePlate.text = handle
        portrait.image = image
    }
}

final class NightSocialSettingsLane: UIControl {
    enum Kind: Int {
        case blacklist
        case community
        case privacy
        case agreement
        case deleteDesk
        case logout
        case language
    }

    enum Tone {
        case house
        case leave
        case erase
    }

    private let valuePlate = UILabel()
    private let glow = UIView()

    init(
        kind: Kind,
        title: String,
        hint: String,
        catalog: String? = nil,
        fallback: String? = nil,
        symbol: String? = nil,
        showsChevron: Bool = true,
        tone: Tone = .house
    ) {
        super.init(frame: .zero)
        tag = kind.rawValue
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        heightAnchor.constraint(equalToConstant: 64).isActive = true

        glow.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        glow.alpha = 0
        glow.isUserInteractionEnabled = false
        glow.translatesAutoresizingMaskIntoConstraints = false

        let disc = UIView()
        disc.isUserInteractionEnabled = false
        disc.layer.cornerRadius = 12
        disc.translatesAutoresizingMaskIntoConstraints = false
        switch tone {
        case .house:
            disc.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        case .leave:
            disc.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.22)
        case .erase:
            disc.backgroundColor = UIColor(red: 1.00, green: 0.42, blue: 0.48, alpha: 0.22)
        }

        let glyph = UIImageView()
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        if let catalog {
            glyph.image = NightSocialImageCabinet.named(catalog, fallback: fallback ?? catalog)
        } else if let symbol {
            glyph.image = UIImage(
                systemName: symbol,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            )
            glyph.tintColor = .white
        }

        let titlePlate = UILabel()
        titlePlate.text = title
        titlePlate.font = AfterHoursType.foyerBody(15, weight: .semibold)
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        let hintPlate = UILabel()
        hintPlate.text = hint
        hintPlate.font = AfterHoursType.foyerCaption(11)
        hintPlate.translatesAutoresizingMaskIntoConstraints = false
        switch tone {
        case .house:
            titlePlate.textColor = .white
            hintPlate.textColor = UIColor.white.withAlphaComponent(0.48)
        case .leave:
            titlePlate.textColor = AfterHoursPalette.loungePink
            hintPlate.textColor = UIColor.white.withAlphaComponent(0.48)
        case .erase:
            titlePlate.textColor = UIColor(red: 1.00, green: 0.62, blue: 0.68, alpha: 1)
            hintPlate.textColor = UIColor.white.withAlphaComponent(0.42)
        }

        valuePlate.font = AfterHoursType.foyerCaption(12)
        valuePlate.textColor = UIColor.white.withAlphaComponent(0.55)
        valuePlate.textAlignment = .right
        valuePlate.translatesAutoresizingMaskIntoConstraints = false
        valuePlate.setContentCompressionResistancePriority(.required, for: .horizontal)

        let chev = UIImageView(image: UIImage(systemName: "chevron.right"))
        chev.tintColor = UIColor.white.withAlphaComponent(0.32)
        chev.contentMode = .scaleAspectFit
        chev.isHidden = !showsChevron
        chev.translatesAutoresizingMaskIntoConstraints = false

        addSubview(glow)
        addSubview(disc)
        disc.addSubview(glyph)
        addSubview(titlePlate)
        addSubview(hintPlate)
        addSubview(valuePlate)
        addSubview(chev)
        NSLayoutConstraint.activate([
            glow.topAnchor.constraint(equalTo: topAnchor),
            glow.leadingAnchor.constraint(equalTo: leadingAnchor),
            glow.trailingAnchor.constraint(equalTo: trailingAnchor),
            glow.bottomAnchor.constraint(equalTo: bottomAnchor),
            disc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            disc.centerYAnchor.constraint(equalTo: centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 36),
            disc.heightAnchor.constraint(equalToConstant: 36),
            glyph.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 18),
            glyph.heightAnchor.constraint(equalToConstant: 18),
            titlePlate.leadingAnchor.constraint(equalTo: disc.trailingAnchor, constant: 12),
            titlePlate.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titlePlate.trailingAnchor.constraint(lessThanOrEqualTo: valuePlate.leadingAnchor, constant: -8),
            hintPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hintPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 2),
            hintPlate.trailingAnchor.constraint(lessThanOrEqualTo: valuePlate.leadingAnchor, constant: -8),
            chev.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            chev.centerYAnchor.constraint(equalTo: centerYAnchor),
            chev.widthAnchor.constraint(equalToConstant: 12),
            chev.heightAnchor.constraint(equalToConstant: 16),
            valuePlate.trailingAnchor.constraint(equalTo: showsChevron ? chev.leadingAnchor : trailingAnchor, constant: showsChevron ? -6 : -16),
            valuePlate.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.14, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.glow.alpha = self.isHighlighted ? 1 : 0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.99, y: 0.99) : .identity
            }
        }
    }

    func setValue(_ text: String?) {
        valuePlate.text = text
        valuePlate.isHidden = (text ?? "").isEmpty
        if let text, !text.isEmpty {
            accessibilityValue = text
        }
    }
}

final class NightSocialLeaveConfirm: UIViewController {
    private let delete: Bool
    private weak var host: NightSocialMirrorSettingsBoard?
    init(delete: Bool, host: NightSocialMirrorSettingsBoard) {
        self.delete = delete
        self.host = host
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        let cloth = UIImageView(image: NightSocialImageCabinet.named("DiamondPromptCloth", fallback: "image_622"))
        cloth.contentMode = .scaleAspectFill
        cloth.clipsToBounds = true
        cloth.layer.cornerRadius = 24
        cloth.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = delete ? "Delete this night desk?" : "Leave this night desk?"
        body.font = AfterHoursType.foyerHeadline(18)
        body.textColor = AfterHoursPalette.inkOnSnow
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.setTitleColor(AfterHoursPalette.inkOnSnow, for: .normal)
        cancel.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let go = NightSocialLoungeChrome.pinkPill(title: delete ? "Delete" : "Log Out")
        go.addTarget(self, action: #selector(settle), for: .touchUpInside)
        view.addSubview(cloth)
        view.addSubview(body)
        view.addSubview(cancel)
        view.addSubview(go)
        NSLayoutConstraint.activate([
            cloth.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloth.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cloth.widthAnchor.constraint(equalToConstant: 300),
            cloth.heightAnchor.constraint(equalToConstant: 280),
            body.centerXAnchor.constraint(equalTo: cloth.centerXAnchor),
            body.centerYAnchor.constraint(equalTo: cloth.centerYAnchor, constant: 24),
            body.widthAnchor.constraint(equalToConstant: 240),
            cancel.leadingAnchor.constraint(equalTo: cloth.leadingAnchor, constant: 24),
            cancel.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            cancel.widthAnchor.constraint(equalToConstant: 110),
            go.trailingAnchor.constraint(equalTo: cloth.trailingAnchor, constant: -24),
            go.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            go.widthAnchor.constraint(equalToConstant: 110),
        ])
    }
    @objc private func fold() { dismiss(animated: true) }
    @objc private func settle() {
        let host = self.host
        let delete = self.delete
        dismiss(animated: true) {
            host?.settleLeave(delete: delete)
        }
    }
}

final class NightSocialMirrorLanguageBoard: UIViewController {
    private let tongues = ["English", "Español", "Deutsch", "Bahasa Melayu", "Bahasa Indonesia"]
    private var lanes: [NightSocialLanguageLane] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        navigationController?.setNavigationBarHidden(true, animated: false)

        let atmosphere = NightSocialSettingsAtmosphere()
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Language"
        head.font = AfterHoursType.foyerHeadline(22)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "Choose the tongue for this desk"
        kicker.font = AfterHoursType.foyerCaption(12)
        kicker.textColor = UIColor.white.withAlphaComponent(0.62)
        kicker.translatesAutoresizingMaskIntoConstraints = false

        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        let current = NightSocialSessionDrawer.shared.spokenTongue
        for (index, title) in tongues.enumerated() {
            let lane = NightSocialLanguageLane(tongue: title, chosen: title == current)
            lane.tag = index
            lane.addTarget(self, action: #selector(pickTongue(_:)), for: .touchUpInside)
            lanes.append(lane)
            stack.addArrangedSubview(lane)
            if index < tongues.count - 1 {
                let hair = UIView()
                hair.backgroundColor = UIColor.white.withAlphaComponent(0.08)
                hair.translatesAutoresizingMaskIntoConstraints = false
                let wrap = UIView()
                wrap.addSubview(hair)
                NSLayoutConstraint.activate([
                    hair.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 18),
                    hair.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -18),
                    hair.topAnchor.constraint(equalTo: wrap.topAnchor),
                    hair.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
                    wrap.heightAnchor.constraint(equalToConstant: 1),
                ])
                stack.addArrangedSubview(wrap)
            }
        }
        card.addSubview(stack)

        let note = UILabel()
        note.text = "House copy stays in the tongue you pick for this sitting."
        note.font = AfterHoursType.foyerCaption(12)
        note.textColor = UIColor.white.withAlphaComponent(0.38)
        note.numberOfLines = 0
        note.textAlignment = .center
        note.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(atmosphere)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(kicker)
        view.addSubview(card)
        view.addSubview(note)
        NSLayoutConstraint.activate([
            atmosphere.topAnchor.constraint(equalTo: view.topAnchor),
            atmosphere.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            atmosphere.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            atmosphere.heightAnchor.constraint(equalToConstant: 280),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.topAnchor.constraint(equalTo: back.topAnchor, constant: -2),
            kicker.leadingAnchor.constraint(equalTo: head.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 1),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 22),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -6),
            note.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            note.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            note.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 16),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickTongue(_ sender: UIControl) {
        let title = tongues[sender.tag]
        present(NightSocialLanguageConfirm(tongue: title, host: self), animated: true)
    }

    func applyTongue(_ title: String) {
        NightSocialSessionDrawer.shared.writeSpokenTongue(title)
        lanes.forEach { $0.setChosen($0.tongue == title) }
    }
}

final class NightSocialLanguageLane: UIControl {
    let tongue: String
    private let titlePlate = UILabel()
    private let tick = UIImageView()
    private let glow = UIView()

    init(tongue: String, chosen: Bool) {
        self.tongue = tongue
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = tongue
        heightAnchor.constraint(equalToConstant: 56).isActive = true

        glow.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        glow.alpha = 0
        glow.isUserInteractionEnabled = false
        glow.translatesAutoresizingMaskIntoConstraints = false

        titlePlate.text = tongue
        titlePlate.font = AfterHoursType.foyerBody(15, weight: .semibold)
        titlePlate.translatesAutoresizingMaskIntoConstraints = false

        tick.contentMode = .scaleAspectFit
        tick.translatesAutoresizingMaskIntoConstraints = false
        tick.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        )
        tick.tintColor = AfterHoursPalette.loungePink

        addSubview(glow)
        addSubview(titlePlate)
        addSubview(tick)
        NSLayoutConstraint.activate([
            glow.topAnchor.constraint(equalTo: topAnchor),
            glow.leadingAnchor.constraint(equalTo: leadingAnchor),
            glow.trailingAnchor.constraint(equalTo: trailingAnchor),
            glow.bottomAnchor.constraint(equalTo: bottomAnchor),
            titlePlate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titlePlate.centerYAnchor.constraint(equalTo: centerYAnchor),
            tick.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tick.centerYAnchor.constraint(equalTo: centerYAnchor),
            tick.widthAnchor.constraint(equalToConstant: 22),
            tick.heightAnchor.constraint(equalToConstant: 22),
        ])
        setChosen(chosen)
    }

    required init?(coder: NSCoder) { nil }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.14, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.glow.alpha = self.isHighlighted ? 1 : 0
            }
        }
    }

    func setChosen(_ on: Bool) {
        tick.isHidden = !on
        titlePlate.textColor = on ? AfterHoursPalette.loungePink : .white
        accessibilityTraits = on ? [.button, .selected] : .button
    }
}

final class NightSocialLanguageConfirm: UIViewController {
    private let tongue: String
    private weak var host: NightSocialMirrorLanguageBoard?
    init(tongue: String, host: NightSocialMirrorLanguageBoard) {
        self.tongue = tongue
        self.host = host
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        let cloth = UIImageView(image: NightSocialImageCabinet.named("DiamondPromptCloth", fallback: "image_622"))
        cloth.contentMode = .scaleAspectFill
        cloth.clipsToBounds = true
        cloth.layer.cornerRadius = 24
        cloth.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "Are you sure you want to\nchange the language?"
        body.font = AfterHoursType.foyerHeadline(18)
        body.textColor = AfterHoursPalette.inkOnSnow
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.setTitleColor(AfterHoursPalette.inkOnSnow, for: .normal)
        cancel.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let go = NightSocialLoungeChrome.pinkPill(title: "Confirm")
        go.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        view.addSubview(cloth)
        view.addSubview(body)
        view.addSubview(cancel)
        view.addSubview(go)
        NSLayoutConstraint.activate([
            cloth.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloth.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cloth.widthAnchor.constraint(equalToConstant: 300),
            cloth.heightAnchor.constraint(equalToConstant: 280),
            body.centerXAnchor.constraint(equalTo: cloth.centerXAnchor),
            body.centerYAnchor.constraint(equalTo: cloth.centerYAnchor, constant: 20),
            body.widthAnchor.constraint(equalToConstant: 240),
            cancel.leadingAnchor.constraint(equalTo: cloth.leadingAnchor, constant: 24),
            cancel.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            cancel.widthAnchor.constraint(equalToConstant: 110),
            go.trailingAnchor.constraint(equalTo: cloth.trailingAnchor, constant: -24),
            go.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            go.widthAnchor.constraint(equalToConstant: 110),
        ])
    }
    @objc private func fold() { dismiss(animated: true) }
    @objc private func confirm() {
        host?.applyTongue(tongue)
        dismiss(animated: true)
    }
}
