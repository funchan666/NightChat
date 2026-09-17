import UIKit

final class NightSocialWaveVoiceStage: UIViewController, UITableViewDataSource {
    private let chamberKey: String
    private var chamber: WaveVoiceChamber
    private var occupied: [String]
    private var mySeat: Int?
    private var chatLines: [LoungeDiscussLine] = []
    private let table = UITableView()
    private let field = UITextField()
    private var seatMarks: [UIButton] = []
    private var seatHalos: [Int: UIView] = [:]
    private var seatPics: [Int: UIImageView] = [:]
    private let danmaku = LiveDanmakuLane()
    private let giftRibbon = LiveGiftRibbon()
    private let giftBurst = UIImageView()
    private var chatter: Timer?
    private var speakTimer: Timer?
    private var speakingIndex: Int?

    init(chamberKey: String) {
        self.chamberKey = chamberKey
        let found = NightSocialWaveCatalog.chamber(chamberKey) ?? NightSocialWaveCatalog.chambers[0]
        self.chamber = found
        self.occupied = found.seatDeskKeys
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        drawStarCloth()

        let exit = NightSocialLoungeChrome.iconControl(catalog: "ExitIcon", fallback: "ExitIcon", edge: 34)
        exit.addTarget(self, action: #selector(askToLeave), for: .touchUpInside)
        let hostName = NightSocialWaveCatalog.hostName(chamber)
        let hostChip = UIButton(type: .custom)
        hostChip.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        hostChip.layer.cornerRadius = 18
        hostChip.addTarget(self, action: #selector(openHost), for: .touchUpInside)
        hostChip.translatesAutoresizingMaskIntoConstraints = false
        let hostPic = UIImageView(image: NightSocialMediaAssets.portrait(for: chamber.hostDeskKey, size: CGSize(width: 72, height: 72)))
        hostPic.contentMode = .scaleAspectFill
        hostPic.layer.cornerRadius = 14
        hostPic.clipsToBounds = true
        hostPic.translatesAutoresizingMaskIntoConstraints = false
        let hostPlate = UILabel()
        hostPlate.text = hostName
        hostPlate.font = AfterHoursType.foyerPill(13)
        hostPlate.textColor = .white
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        let plus = UIButton(type: .system)
        plus.setTitle("+", for: .normal)
        plus.setTitleColor(.white, for: .normal)
        plus.backgroundColor = AfterHoursPalette.loungePink
        plus.layer.cornerRadius = 10
        plus.addTarget(self, action: #selector(followHost), for: .touchUpInside)
        plus.translatesAutoresizingMaskIntoConstraints = false
        let crowd = makeCountChip(
            symbol: "person.2.fill",
            value: "\(chamber.listenerCount)",
            tint: .white
        )
        crowd.addTarget(self, action: #selector(openCrowd), for: .touchUpInside)
        let more = NightSocialLoungeChrome.iconControl(catalog: "MoreDots", fallback: "MoreDots", edge: 32)
        more.addTarget(self, action: #selector(openMore), for: .touchUpInside)
        let crown = NightSocialLoungeChrome.iconControl(catalog: "PartyCrown", fallback: "PartyCrown", edge: 32)
        crown.addTarget(self, action: #selector(openRank), for: .touchUpInside)
        let heat = makeCountChip(
            symbol: "flame.fill",
            value: "\(chamber.heatScore)",
            tint: UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        )
        heat.addTarget(self, action: #selector(openRank), for: .touchUpInside)

        let title = UILabel()
        title.text = chamber.chamberTitle
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let mood = UILabel()
        mood.text = "\(hostName) · \(chamber.moodLine)"
        mood.font = AfterHoursType.foyerCaption(13)
        mood.textColor = UIColor.white.withAlphaComponent(0.75)
        mood.translatesAutoresizingMaskIntoConstraints = false

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 16
        grid.translatesAutoresizingMaskIntoConstraints = false
        for row in 0..<2 {
            let line = UIStackView()
            line.axis = .horizontal
            line.distribution = .fillEqually
            line.spacing = 12
            for col in 0..<4 {
                line.addArrangedSubview(makeSeat(index: row * 4 + col))
            }
            grid.addArrangedSubview(line)
        }
        let openLine = UIStackView()
        openLine.axis = .horizontal
        openLine.distribution = .fillEqually
        openLine.spacing = 12
        openLine.translatesAutoresizingMaskIntoConstraints = false
        for index in 8..<12 {
            openLine.addArrangedSubview(makeOpenMic(index: index))
        }

        danmaku.clipsToBounds = true
        danmaku.isUserInteractionEnabled = false
        danmaku.translatesAutoresizingMaskIntoConstraints = false
        giftBurst.contentMode = .scaleAspectFit
        giftBurst.alpha = 0
        giftBurst.translatesAutoresizingMaskIntoConstraints = false

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 28
        table.register(LiveChatLineCell.self, forCellReuseIdentifier: LiveChatLineCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false

        let dock = UIView()
        dock.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        dock.layer.cornerRadius = 22
        dock.translatesAutoresizingMaskIntoConstraints = false
        let mic = NightSocialLoungeChrome.iconControl(catalog: "MicIcon", fallback: "MicIcon", edge: 28)
        field.placeholder = "Say something..."
        field.attributedPlaceholder = NSAttributedString(
            string: "Say something...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        field.textColor = .white
        field.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = UIButton(type: .system)
        send.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        send.tintColor = .white
        send.addTarget(self, action: #selector(sendChat), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false
        let gift = NightSocialLoungeChrome.iconControl(catalog: "GiftBox", fallback: "GiftBox", edge: 34)
        gift.addTarget(self, action: #selector(openGift), for: .touchUpInside)

        view.addSubview(exit)
        view.addSubview(hostChip)
        hostChip.addSubview(hostPic)
        hostChip.addSubview(hostPlate)
        hostChip.addSubview(plus)
        view.addSubview(crowd)
        view.addSubview(more)
        view.addSubview(crown)
        view.addSubview(heat)
        view.addSubview(title)
        view.addSubview(mood)
        view.addSubview(grid)
        view.addSubview(openLine)
        view.addSubview(danmaku)
        view.addSubview(giftBurst)
        view.addSubview(giftRibbon)
        view.addSubview(table)
        view.addSubview(dock)
        dock.addSubview(mic)
        dock.addSubview(field)
        dock.addSubview(send)
        dock.addSubview(gift)

        NSLayoutConstraint.activate([
            exit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            exit.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            hostChip.leadingAnchor.constraint(equalTo: exit.trailingAnchor, constant: 8),
            hostChip.centerYAnchor.constraint(equalTo: exit.centerYAnchor),
            hostChip.heightAnchor.constraint(equalToConstant: 36),
            hostPic.leadingAnchor.constraint(equalTo: hostChip.leadingAnchor, constant: 4),
            hostPic.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            hostPic.widthAnchor.constraint(equalToConstant: 28),
            hostPic.heightAnchor.constraint(equalToConstant: 28),
            hostPlate.leadingAnchor.constraint(equalTo: hostPic.trailingAnchor, constant: 6),
            hostPlate.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            plus.leadingAnchor.constraint(equalTo: hostPlate.trailingAnchor, constant: 6),
            plus.trailingAnchor.constraint(equalTo: hostChip.trailingAnchor, constant: -6),
            plus.centerYAnchor.constraint(equalTo: hostChip.centerYAnchor),
            plus.widthAnchor.constraint(equalToConstant: 20),
            plus.heightAnchor.constraint(equalToConstant: 20),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: exit.centerYAnchor),
            crowd.trailingAnchor.constraint(equalTo: more.leadingAnchor, constant: -8),
            crowd.centerYAnchor.constraint(equalTo: exit.centerYAnchor),
            crowd.heightAnchor.constraint(equalToConstant: 32),
            crown.topAnchor.constraint(equalTo: more.bottomAnchor, constant: 8),
            crown.trailingAnchor.constraint(equalTo: more.trailingAnchor),
            heat.trailingAnchor.constraint(equalTo: crown.leadingAnchor, constant: -6),
            heat.centerYAnchor.constraint(equalTo: crown.centerYAnchor),
            heat.heightAnchor.constraint(equalToConstant: 28),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: hostChip.bottomAnchor, constant: 14),
            mood.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            mood.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            grid.topAnchor.constraint(equalTo: mood.bottomAnchor, constant: 18),
            openLine.leadingAnchor.constraint(equalTo: grid.leadingAnchor),
            openLine.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            openLine.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 18),
            danmaku.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmaku.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmaku.topAnchor.constraint(equalTo: openLine.bottomAnchor, constant: 8),
            danmaku.heightAnchor.constraint(equalToConstant: 72),
            giftBurst.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            giftBurst.centerYAnchor.constraint(equalTo: grid.centerYAnchor),
            giftBurst.widthAnchor.constraint(equalToConstant: 88),
            giftBurst.heightAnchor.constraint(equalToConstant: 88),
            giftRibbon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            giftRibbon.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            giftRibbon.topAnchor.constraint(equalTo: danmaku.bottomAnchor, constant: 4),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            table.topAnchor.constraint(equalTo: giftRibbon.bottomAnchor, constant: 8),
            table.bottomAnchor.constraint(equalTo: dock.topAnchor, constant: -10),
            dock.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            dock.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            dock.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18),
            dock.heightAnchor.constraint(equalToConstant: 52),
            mic.leadingAnchor.constraint(equalTo: dock.leadingAnchor, constant: 10),
            mic.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            field.leadingAnchor.constraint(equalTo: mic.trailingAnchor, constant: 8),
            field.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            field.heightAnchor.constraint(equalToConstant: 36),
            gift.trailingAnchor.constraint(equalTo: dock.trailingAnchor, constant: -10),
            gift.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: gift.leadingAnchor, constant: -6),
            send.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        if let seated = NightSocialSessionDrawer.shared.seatedChamberSeat(), seated.0 == chamberKey {
            mySeat = seated.1
        }
        NotificationCenter.default.addObserver(self, selector: #selector(catchGift(_:)), name: .liveGiftOffered, object: nil)
        seedOpeningChat()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        startAtmosphere()
        startSpeakCycle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            chatter?.invalidate()
            speakTimer?.invalidate()
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    deinit {
        chatter?.invalidate()
        speakTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    private func makeCountChip(symbol: String, value: String, tint: UIColor) -> UIButton {
        let chip = UIButton(type: .custom)
        chip.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        chip.layer.cornerRadius = 16
        chip.translatesAutoresizingMaskIntoConstraints = false
        let mark = UIImageView(image: UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)))
        mark.tintColor = tint
        mark.contentMode = .scaleAspectFit
        mark.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = value
        plate.font = AfterHoursType.foyerCaption(12)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(mark)
        chip.addSubview(plate)
        NSLayoutConstraint.activate([
            mark.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 10),
            mark.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 14),
            mark.heightAnchor.constraint(equalToConstant: 12),
            plate.leadingAnchor.constraint(equalTo: mark.trailingAnchor, constant: 4),
            plate.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            plate.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -10),
        ])
        return chip
    }

    private func drawStarCloth() {
        let cloth = UIView()
        cloth.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cloth)
        NSLayoutConstraint.activate([
            cloth.topAnchor.constraint(equalTo: view.topAnchor),
            cloth.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cloth.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cloth.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.12, green: 0.03, blue: 0.16, alpha: 1).cgColor,
            UIColor(red: 0.42, green: 0.12, blue: 0.32, alpha: 1).cgColor,
        ]
        gradient.frame = UIScreen.main.bounds
        cloth.layer.addSublayer(gradient)
        for _ in 0..<40 {
            let star = UIView()
            star.backgroundColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.15...0.7))
            star.layer.cornerRadius = 1
            let x = CGFloat.random(in: 0...(UIScreen.main.bounds.width - 2))
            let y = CGFloat.random(in: 0...(UIScreen.main.bounds.height - 2))
            star.frame = CGRect(x: x, y: y, width: 2, height: 2)
            cloth.addSubview(star)
        }
    }

    private func makeSeat(index: Int) -> UIView {
        let wrap = UIView()
        wrap.clipsToBounds = false
        let halo = UIView()
        halo.backgroundColor = .clear
        halo.layer.borderWidth = 2
        halo.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        halo.layer.cornerRadius = 34
        halo.alpha = 0
        halo.isHidden = true
        halo.isUserInteractionEnabled = false
        halo.translatesAutoresizingMaskIntoConstraints = false
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(tapSeat(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let pic = UIImageView()
        pic.tag = 800 + index
        pic.contentMode = .scaleAspectFill
        pic.layer.cornerRadius = 28
        pic.clipsToBounds = true
        pic.translatesAutoresizingMaskIntoConstraints = false
        let name = UILabel()
        name.tag = 900 + index
        name.font = AfterHoursType.foyerCaption(11)
        name.textColor = .white
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        let heat = UILabel()
        heat.tag = 1000 + index
        heat.font = AfterHoursType.foyerCaption(10)
        heat.textColor = UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        heat.textAlignment = .center
        heat.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(halo)
        wrap.addSubview(button)
        wrap.addSubview(pic)
        wrap.addSubview(name)
        wrap.addSubview(heat)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            button.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            halo.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            halo.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            halo.widthAnchor.constraint(equalToConstant: 68),
            halo.heightAnchor.constraint(equalToConstant: 68),
            pic.topAnchor.constraint(equalTo: button.topAnchor),
            pic.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            pic.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            pic.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            name.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            name.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            heat.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 1),
            heat.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            wrap.heightAnchor.constraint(equalToConstant: 100),
        ])
        seatMarks.append(button)
        seatHalos[index] = halo
        seatPics[index] = pic
        paintSeat(index: index, pic: pic, name: name, heat: heat)
        return wrap
    }

    private func makeOpenMic(index: Int) -> UIView {
        let wrap = UIView()
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(tapSeat(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        let mic = UIImageView(image: NightSocialImageCabinet.named("MicIcon", fallback: "MicIcon"))
        mic.contentMode = .scaleAspectFit
        mic.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = "\(index + 1)\nopen"
        plate.numberOfLines = 2
        plate.textAlignment = .center
        plate.font = AfterHoursType.foyerCaption(11)
        plate.textColor = UIColor.white.withAlphaComponent(0.8)
        plate.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(button)
        wrap.addSubview(mic)
        wrap.addSubview(plate)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: wrap.topAnchor),
            button.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            mic.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            mic.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            mic.widthAnchor.constraint(equalToConstant: 22),
            mic.heightAnchor.constraint(equalToConstant: 22),
            plate.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            plate.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            wrap.heightAnchor.constraint(equalToConstant: 88),
        ])
        return wrap
    }

    private func paintSeat(index: Int, pic: UIImageView, name: UILabel, heat: UILabel) {
        if index < occupied.count {
            let key = occupied[index]
            let desk = NightSocialLoungeCatalog.creator(deskKey: key)
            let spoken = desk?.spokenName ?? key
            pic.image = NightSocialMediaAssets.portrait(for: key, size: CGSize(width: 112, height: 112))
            name.text = spoken.split(separator: " ").first.map(String.init)
            heat.text = "\(8 + (index * 5) % 19)"
            pic.isHidden = false
        } else {
            pic.isHidden = true
            name.text = ""
            heat.text = ""
            setSpeaking(index: index, on: false)
        }
    }

    private func refreshSeats() {
        for index in 0..<8 {
            guard let pic = seatPics[index],
                  let name = view.viewWithTag(900 + index) as? UILabel,
                  let heat = view.viewWithTag(1000 + index) as? UILabel else { continue }
            paintSeat(index: index, pic: pic, name: name, heat: heat)
        }
    }

    private func startSpeakCycle() {
        speakTimer?.invalidate()
        advanceSpeaker()
        speakTimer = Timer.scheduledTimer(withTimeInterval: 2.6, repeats: true) { [weak self] _ in
            self?.advanceSpeaker()
        }
    }

    private func advanceSpeaker() {
        let filled = Array(0..<min(8, occupied.count))
        guard !filled.isEmpty else { return }
        if let current = speakingIndex { setSpeaking(index: current, on: false) }
        var next = filled.randomElement() ?? 0
        if filled.count > 1, next == speakingIndex {
            next = filled.first { $0 != speakingIndex } ?? next
        }
        speakingIndex = next
        setSpeaking(index: next, on: true)
    }

    private func setSpeaking(index: Int, on: Bool) {
        guard let halo = seatHalos[index] else { return }
        halo.layer.removeAllAnimations()
        seatPics[index]?.layer.borderWidth = on ? 2 : 0
        seatPics[index]?.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        if on {
            halo.isHidden = false
            halo.alpha = 0.95
            halo.transform = .identity
            UIView.animate(withDuration: 0.85, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                halo.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                halo.alpha = 0.18
            }
        } else {
            halo.transform = .identity
            halo.alpha = 0
            halo.isHidden = true
        }
    }

    @objc private func tapSeat(_ sender: UIButton) {
        let index = sender.tag
        let me = NightSocialSessionDrawer.shared.restoredSession()?.deskHolderId ?? "me.desk"
        if index >= occupied.count {
            if let current = mySeat, current < occupied.count {
                occupied.remove(at: current)
            }
            occupied.append(me)
            mySeat = occupied.count - 1
            NightSocialSessionDrawer.shared.rememberSeatedChamber(chamberKey, seatIndex: mySeat ?? 0)
            refreshSeats()
            FoyerNotice.present(on: self, spokenTitle: "Seat taken", spokenBody: "You are on an open mic. Keep the sitting kind.")
            return
        }
        let key = occupied[index]
        if let desk = NightSocialLoungeCatalog.creator(deskKey: key) {
            navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: desk.deskKey), animated: true)
        }
    }

    @objc private func askToLeave() {
        present(NightSocialVoiceLeavePrompt { [weak self] in
            NightSocialSessionDrawer.shared.clearSeatedChamber()
            self?.navigationController?.popViewController(animated: true)
        }, animated: true)
    }

    @objc private func followHost() {
        NightSocialSessionDrawer.shared.toggleFollow(chamber.hostDeskKey)
    }
    @objc private func openHost() {
        navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: chamber.hostDeskKey), animated: true)
    }
    @objc private func openCrowd() {
        present(
            NightSocialBoothCrowdSheet(
                hostDeskKey: chamber.hostDeskKey,
                watcherCount: max(chamber.listenerCount, occupied.count)
            ),
            animated: true
        )
    }
    @objc private func openRank() {
        present(NightSocialWaveRankSheet(chamber: chamber), animated: true)
    }
    @objc private func openGift() {
        present(NightSocialTributeTray(boothKey: chamber.chamberKey), animated: true)
    }
    @objc private func openMore() {
        present(NightSocialVoiceMoreSheet(chamber: chamber, host: self), animated: true)
    }

    @objc private func sendChat() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        pushLine(speaker: me, body: body, deskKey: "")
        field.text = ""
    }

    private func seedOpeningChat() {
        let others = NightSocialLoungeCatalog.visibleCreators().filter { $0.deskKey != chamber.hostDeskKey }
        guard !others.isEmpty else { return }
        let opening = [
            "Who's on the mic first?",
            "This sitting already feels warm.",
            "Pass the mic if the talk lands.",
        ]
        for (index, phrase) in opening.enumerated() {
            let speaker = others[index % others.count]
            chatLines.append(LoungeDiscussLine(speakerDeskKey: speaker.deskKey, speakerName: speaker.spokenName, spokenBody: phrase))
        }
        table.reloadData()
    }

    private func startAtmosphere() {
        chatter?.invalidate()
        chatter = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            self?.spillAtmosphere()
        }
        if let first = chatLines.first {
            danmaku.fire("\(first.speakerName): \(first.spokenBody)")
        }
    }

    private func spillAtmosphere() {
        let others = NightSocialLoungeCatalog.visibleCreators().filter { $0.deskKey != chamber.hostDeskKey }
        guard let speaker = others.randomElement() else { return }
        let phrases = [
            "Keep the mic kind.",
            "That line landed.",
            "Who's taking the next seat?",
            "This room is easy tonight.",
            "Say it again, slower.",
            "Gift a wand if you're still here.",
            "The night desk is listening.",
            "Stay on this sitting.",
        ]
        let phrase = phrases.randomElement() ?? "Hello."
        pushLine(speaker: speaker.spokenName, body: phrase, deskKey: speaker.deskKey)
        if Int.random(in: 0...4) == 0, let gift = NightSocialLoungeCatalog.gifts.randomElement() {
            paintGift(
                speaker: speaker.spokenName,
                deskKey: speaker.deskKey,
                title: gift.spokenTitle,
                quantity: 1,
                glyphName: gift.glyphCatalog
            )
        }
    }

    private func pushLine(speaker: String, body: String, deskKey: String) {
        chatLines.append(LoungeDiscussLine(speakerDeskKey: deskKey, speakerName: speaker, spokenBody: body))
        if chatLines.count > 36 { chatLines.removeFirst(chatLines.count - 36) }
        table.reloadData()
        let last = IndexPath(row: chatLines.count - 1, section: 0)
        if chatLines.count > 0 {
            table.scrollToRow(at: last, at: .bottom, animated: true)
        }
        danmaku.fire("\(speaker): \(body)")
    }

    @objc private func catchGift(_ note: Notification) {
        let title = note.userInfo?["title"] as? String ?? "Gift"
        let quantity = note.userInfo?["quantity"] as? Int ?? 1
        let glyph = note.userInfo?["glyph"] as? String ?? ""
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        paintGift(speaker: me, deskKey: "", title: title, quantity: quantity, glyphName: glyph)
        pushLine(speaker: me, body: "sent \(title)×\(quantity)", deskKey: "")
    }

    private func paintGift(speaker: String, deskKey: String, title: String, quantity: Int, glyphName: String) {
        let portrait = deskKey.isEmpty
            ? NightSocialMediaAssets.localPortrait(size: CGSize(width: 64, height: 64))
            : NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 64, height: 64))
        giftRibbon.reveal(
            speaker: speaker,
            giftTitle: title,
            quantity: quantity,
            portrait: portrait,
            glyphImage: UIImage(named: glyphName)
        )
        danmaku.fire("\(speaker) sent \(title)×\(quantity)")
        giftBurst.image = UIImage(named: glyphName)
        giftBurst.alpha = 0
        giftBurst.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.8) {
            self.giftBurst.alpha = 1
            self.giftBurst.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 0.55, options: [.curveEaseIn]) {
                self.giftBurst.alpha = 0
                self.giftBurst.transform = CGAffineTransform(translationX: 0, y: -36).scaledBy(x: 0.7, y: 0.7)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { chatLines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveChatLineCell.reuseId, for: indexPath) as! LiveChatLineCell
        cell.paint(chatLines[indexPath.row])
        return cell
    }
}

final class NightSocialVoiceLeavePrompt: UIViewController {
    private let onLeave: () -> Void
    init(onLeave: @escaping () -> Void) {
        self.onLeave = onLeave
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.46)
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "Leave this room?"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.text = "You'll drop the mic and go back to Party."
        body.font = AfterHoursType.foyerBody(14)
        body.textColor = UIColor.white.withAlphaComponent(0.72)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.translatesAutoresizingMaskIntoConstraints = false
        let stay = NightSocialLoungeChrome.ghostPill(title: "Stay")
        stay.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let leave = NightSocialLoungeChrome.pinkPill(title: "Leave")
        leave.addTarget(self, action: #selector(confirmLeave), for: .touchUpInside)
        view.addSubview(card)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(stay)
        card.addSubview(leave)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 300),
            card.heightAnchor.constraint(equalToConstant: 210),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            stay.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stay.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
            stay.widthAnchor.constraint(equalToConstant: 118),
            leave.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            leave.centerYAnchor.constraint(equalTo: stay.centerYAnchor),
            leave.widthAnchor.constraint(equalToConstant: 118),
        ])
    }

    @objc private func fold() { dismiss(animated: true) }
    @objc private func confirmLeave() {
        let leave = onLeave
        dismiss(animated: true) { leave() }
    }
}

final class NightSocialVoiceMoreSheet: UIViewController {
    private let chamber: WaveVoiceChamber
    private weak var host: UIViewController?

    init(chamber: WaveVoiceChamber, host: UIViewController) {
        self.chamber = chamber
        self.host = host
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [
            .custom(identifier: .init("voiceMore")) { _ in 280 }
        ]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 26
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "More"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let kicker = UILabel()
        kicker.text = "Room tools for this sitting"
        kicker.font = AfterHoursType.foyerCaption(13)
        kicker.textColor = UIColor.white.withAlphaComponent(0.62)
        kicker.translatesAutoresizingMaskIntoConstraints = false
        let goal = makeRow(title: "Room goal", symbol: "flag.fill", tint: AfterHoursPalette.foyerGlowPink)
        goal.addTarget(self, action: #selector(openGoal), for: .touchUpInside)
        let report = makeRow(title: "Report or Block", symbol: "exclamationmark.bubble.fill", tint: AfterHoursPalette.loungePink)
        report.addTarget(self, action: #selector(openSafety), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [goal, report])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)
        view.addSubview(title)
        view.addSubview(kicker)
        view.addSubview(stack)
        view.addSubview(cancel)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            kicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 16),
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16),
        ])
    }

    private func makeRow(title: String, symbol: String, tint: UIColor) -> UIButton {
        let row = UIButton(type: .custom)
        row.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        row.layer.cornerRadius = 16
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true
        let mark = UIImageView(image: UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)))
        mark.tintColor = tint
        mark.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = title
        plate.font = AfterHoursType.foyerPill(15)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(mark)
        row.addSubview(plate)
        NSLayoutConstraint.activate([
            mark.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            mark.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 22),
            plate.leadingAnchor.constraint(equalTo: mark.trailingAnchor, constant: 12),
            plate.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    @objc private func fold() { dismiss(animated: true) }
    @objc private func openGoal() {
        dismiss(animated: true) { [weak self] in
            guard let self, let host = self.host else { return }
            host.present(NightSocialWaveGoalSheet(chamber: self.chamber), animated: true)
        }
    }
    @objc private func openSafety() {
        dismiss(animated: true) { [weak self] in
            guard let self, let host = self.host else { return }
            NightSocialSafetyFlow.presentChooser(from: host, target: .desk(self.chamber.hostDeskKey))
        }
    }
}
