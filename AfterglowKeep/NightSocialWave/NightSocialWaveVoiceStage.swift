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
        drawStarCloth()

        let exit = NightSocialLoungeChrome.iconControl(catalog: "WaveExitMark", fallback: "Group_648", edge: 34)
        exit.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let hostName = NightSocialWaveCatalog.hostName(chamber)
        let hostChip = UIButton(type: .custom)
        hostChip.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        hostChip.layer.cornerRadius = 18
        hostChip.addTarget(self, action: #selector(openHost), for: .touchUpInside)
        hostChip.translatesAutoresizingMaskIntoConstraints = false
        let hostPic = UIImageView(image: NightSocialStandIn.plate(seed: hostName, size: CGSize(width: 72, height: 72)))
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
        let crowd = UIButton(type: .system)
        crowd.setTitle(" \(chamber.listenerCount) ", for: .normal)
        crowd.setTitleColor(.white, for: .normal)
        crowd.addTarget(self, action: #selector(openCrowd), for: .touchUpInside)
        crowd.translatesAutoresizingMaskIntoConstraints = false
        let more = NightSocialLoungeChrome.iconControl(catalog: "WaveMoreDots", fallback: "Frame@2x(17)", edge: 32)
        more.addTarget(self, action: #selector(openMore), for: .touchUpInside)
        let crown = NightSocialLoungeChrome.iconControl(catalog: "WaveCrownGlyph", fallback: "Frame@2x(14)", edge: 32)
        crown.addTarget(self, action: #selector(openRank), for: .touchUpInside)
        let heat = UILabel()
        heat.text = " \(chamber.heatScore) "
        heat.textColor = UIColor(red: 1, green: 0.62, blue: 0.22, alpha: 1)
        heat.font = AfterHoursType.foyerCaption(12)
        heat.translatesAutoresizingMaskIntoConstraints = false

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
                let index = row * 4 + col
                line.addArrangedSubview(makeSeat(index: index))
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

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "wavechat")
        table.translatesAutoresizingMaskIntoConstraints = false

        let mic = NightSocialLoungeChrome.iconControl(catalog: "WaveMicMark", fallback: "Group_904", edge: 28)
        field.placeholder = "Tell me your opinion..."
        field.attributedPlaceholder = NSAttributedString(string: "Tell me your opinion...", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        field.textColor = .white
        field.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = UIButton(type: .system)
        send.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        send.tintColor = .white
        send.addTarget(self, action: #selector(sendChat), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false
        let gift = NightSocialLoungeChrome.iconControl(catalog: "LoungeGiftBox", fallback: "Group_782@2x(1)", edge: 34)
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
        view.addSubview(table)
        view.addSubview(mic)
        view.addSubview(field)
        view.addSubview(send)
        view.addSubview(gift)

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
            crown.topAnchor.constraint(equalTo: more.bottomAnchor, constant: 8),
            crown.trailingAnchor.constraint(equalTo: more.trailingAnchor),
            heat.trailingAnchor.constraint(equalTo: crown.leadingAnchor, constant: -4),
            heat.centerYAnchor.constraint(equalTo: crown.centerYAnchor),
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
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            table.topAnchor.constraint(equalTo: openLine.bottomAnchor, constant: 12),
            table.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -8),
            mic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            mic.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            field.leadingAnchor.constraint(equalTo: mic.trailingAnchor, constant: 8),
            field.centerYAnchor.constraint(equalTo: mic.centerYAnchor),
            field.heightAnchor.constraint(equalToConstant: 36),
            gift.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            gift.centerYAnchor.constraint(equalTo: mic.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: gift.leadingAnchor, constant: -8),
            send.centerYAnchor.constraint(equalTo: mic.centerYAnchor),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        if let seated = NightSocialSessionDrawer.shared.seatedChamberSeat(), seated.0 == chamberKey {
            mySeat = seated.1
        }
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
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(tapSeat(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let pic = UIImageView()
        pic.tag = 800 + index
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
        wrap.addSubview(button)
        wrap.addSubview(pic)
        wrap.addSubview(name)
        wrap.addSubview(heat)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: wrap.topAnchor),
            button.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            pic.topAnchor.constraint(equalTo: button.topAnchor),
            pic.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            pic.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            pic.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            name.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            name.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            heat.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 1),
            heat.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            wrap.heightAnchor.constraint(equalToConstant: 92),
        ])
        seatMarks.append(button)
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
        button.translatesAutoresizingMaskIntoConstraints = false
        let mic = UIImageView(image: NightSocialImageCabinet.named("WaveMicMark", fallback: "Group_904"))
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
            pic.image = NightSocialStandIn.plate(seed: spoken, size: CGSize(width: 112, height: 112))
            name.text = spoken.split(separator: " ").first.map(String.init)
            heat.text = "\(40 + index * 7)"
            pic.isHidden = false
        } else {
            pic.isHidden = true
            name.text = ""
            heat.text = ""
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
            FoyerNotice.present(on: self, spokenTitle: "Seat taken", spokenBody: "You are on an open mic. Keep the sitting kind.")
            view.setNeedsLayout()
            return
        }
        let key = occupied[index]
        if let desk = NightSocialLoungeCatalog.creator(deskKey: key) {
            navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: desk.deskKey), animated: true)
        }
    }

    @objc private func fold() {
        NightSocialSessionDrawer.shared.clearSeatedChamber()
        navigationController?.popViewController(animated: true)
    }
    @objc private func followHost() {
        NightSocialSessionDrawer.shared.toggleFollow(chamber.hostDeskKey)
    }
    @objc private func openHost() {
        navigationController?.pushViewController(NightSocialCreatorDeskBoard(deskKey: chamber.hostDeskKey), animated: true)
    }
    @objc private func openCrowd() {
        present(NightSocialBoothCrowdSheet(), animated: true)
    }
    @objc private func openRank() {
        present(NightSocialWaveRankSheet(chamber: chamber), animated: true)
    }
    @objc private func openGift() {
        present(NightSocialTributeTray(boothKey: chamber.chamberKey), animated: true)
    }
    @objc private func openMore() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Room goal", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.present(NightSocialWaveGoalSheet(chamber: self.chamber), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Report or Block", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            NightSocialSafetyFlow.presentChooser(from: self, target: .desk(self.chamber.hostDeskKey))
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    @objc private func sendChat() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        chatLines.append(LoungeDiscussLine(speakerName: me, spokenBody: body))
        field.text = ""
        table.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { chatLines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wavechat", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = AfterHoursType.foyerCaption(12)
        cell.textLabel?.numberOfLines = 0
        let line = chatLines[indexPath.row]
        cell.textLabel?.text = "\(line.speakerName): \(line.spokenBody)"
        cell.selectionStyle = .none
        return cell
    }
}
