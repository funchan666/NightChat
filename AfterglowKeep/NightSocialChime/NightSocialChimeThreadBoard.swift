import UIKit

final class NightSocialChimeThreadBoard: UIViewController, UITableViewDataSource {
    private let deskKey: String
    private var lines: [ChimeLine] = []
    private let table = UITableView()
    private let field = UITextField()
    private let dock = UIView()
    private let dockWash = CAGradientLayer()

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
        NightSocialSessionDrawer.shared.markChimeRead(deskKey)
        let desk = NightSocialChimeCatalog.desk(for: deskKey)
        openHouseSeedIfNeeded()

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let name = UILabel()
        name.text = desk?.spokenName ?? "Chat"
        name.font = AfterHoursType.foyerHeadline(20)
        name.textColor = .white
        name.isUserInteractionEnabled = true
        name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        name.translatesAutoresizingMaskIntoConstraints = false
        let more = NightSocialLoungeChrome.iconControl(catalog: "MoreCircle", fallback: "MoreCircle", edge: 34)
        more.addTarget(self, action: #selector(openMore), for: .touchUpInside)
        more.accessibilityLabel = "Report this chat"

        let isSupport = deskKey == NightSocialChimeCatalog.supportDeskKey
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isHidden = isSupport
        let pic = UIImageView(image: NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 96, height: 96)))
        pic.contentMode = .scaleAspectFill
        pic.layer.cornerRadius = 26
        pic.clipsToBounds = true
        pic.isUserInteractionEnabled = true
        pic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        pic.translatesAutoresizingMaskIntoConstraints = false
        let cardName = UILabel()
        cardName.text = desk?.spokenName
        cardName.font = AfterHoursType.foyerPill(16)
        cardName.textColor = .white
        cardName.isUserInteractionEnabled = true
        cardName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        cardName.translatesAutoresizingMaskIntoConstraints = false
        let stats = UILabel()
        let fans = desk?.followerCount ?? "0"
        let follow = desk?.friendCount ?? "0"
        let statsText = NSMutableAttributedString(
            string: "\(NightLang.t(.fans)) ",
            attributes: [.font: AfterHoursType.foyerCaption(11), .foregroundColor: UIColor.white.withAlphaComponent(0.62)]
        )
        statsText.append(NSAttributedString(string: fans, attributes: [.font: AfterHoursType.foyerPill(12), .foregroundColor: UIColor.white]))
        statsText.append(NSAttributedString(string: "    \(NightLang.t(.followStat)) ", attributes: [.font: AfterHoursType.foyerCaption(11), .foregroundColor: UIColor.white.withAlphaComponent(0.62)]))
        statsText.append(NSAttributedString(string: follow, attributes: [.font: AfterHoursType.foyerPill(12), .foregroundColor: UIColor.white]))
        stats.attributedText = statsText
        stats.translatesAutoresizingMaskIntoConstraints = false
        let video = UIButton(type: .custom)
        video.setImage(NightSocialImageCabinet.named("VideoCallIcon", fallback: "VideoCallIcon"), for: .normal)
        video.imageView?.contentMode = .scaleAspectFit
        video.addTarget(self, action: #selector(openCall), for: .touchUpInside)
        video.translatesAutoresizingMaskIntoConstraints = false
        video.isHidden = isSupport

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 56
        table.register(ChimeBubbleCell.self, forCellReuseIdentifier: ChimeBubbleCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        dock.layer.cornerRadius = 26
        dock.clipsToBounds = true
        dock.translatesAutoresizingMaskIntoConstraints = false
        dockWash.colors = [
            AfterHoursPalette.loungePink.cgColor,
            UIColor(red: 1, green: 0.62, blue: 0.78, alpha: 1).cgColor,
        ]
        dockWash.startPoint = CGPoint(x: 0, y: 0.5)
        dockWash.endPoint = CGPoint(x: 1, y: 0.5)
        dock.layer.insertSublayer(dockWash, at: 0)
        field.attributedPlaceholder = NSAttributedString(
            string: NightLang.t(.tellOpinion),
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.72), .font: AfterHoursType.foyerBody(14)]
        )
        field.textColor = .white
        field.font = AfterHoursType.foyerBody(14)
        field.backgroundColor = .clear
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = UIButton(type: .custom)
        send.setTitle(NightLang.t(.send), for: .normal)
        send.setTitleColor(.white, for: .normal)
        send.titleLabel?.font = AfterHoursType.foyerPill(13)
        send.backgroundColor = AfterHoursPalette.inkOnSnow
        send.layer.cornerRadius = 18
        send.addTarget(self, action: #selector(sendLine), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(back)
        view.addSubview(name)
        view.addSubview(more)
        view.addSubview(card)
        card.addSubview(pic)
        card.addSubview(cardName)
        card.addSubview(stats)
        card.addSubview(video)
        view.addSubview(table)
        view.addSubview(dock)
        dock.addSubview(field)
        dock.addSubview(send)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            name.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            name.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 14),
            card.heightAnchor.constraint(equalToConstant: isSupport ? 0 : 78),
            pic.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            pic.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 52),
            pic.heightAnchor.constraint(equalToConstant: 52),
            cardName.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            cardName.topAnchor.constraint(equalTo: pic.topAnchor, constant: 6),
            cardName.trailingAnchor.constraint(lessThanOrEqualTo: video.leadingAnchor, constant: -8),
            stats.leadingAnchor.constraint(equalTo: cardName.leadingAnchor),
            stats.topAnchor.constraint(equalTo: cardName.bottomAnchor, constant: 4),
            video.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            video.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            video.widthAnchor.constraint(equalToConstant: 40),
            video.heightAnchor.constraint(equalToConstant: 40),
            table.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: dock.topAnchor, constant: -12),
            dock.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dock.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dock.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            dock.heightAnchor.constraint(equalToConstant: 52),
            field.leadingAnchor.constraint(equalTo: dock.leadingAnchor),
            field.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            field.heightAnchor.constraint(equalToConstant: 44),
            send.trailingAnchor.constraint(equalTo: dock.trailingAnchor, constant: -6),
            send.centerYAnchor.constraint(equalTo: dock.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 72),
            send.heightAnchor.constraint(equalToConstant: 36),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        reloadLines()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dockWash.frame = dock.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func openHouseSeedIfNeeded() {
        guard deskKey == NightSocialChimeCatalog.supportDeskKey else { return }
        if NightSocialSessionDrawer.shared.chimeThreadExists(deskKey) { return }
        NightSocialChimeCatalog.supportSeed.forEach { NightSocialSessionDrawer.shared.appendChimeLine($0, deskKey: deskKey) }
    }

    private func reloadLines() {
        lines = NightSocialSessionDrawer.shared.chimeLines(for: deskKey)
        table.reloadData()
        if !lines.isEmpty {
            table.scrollToRow(at: IndexPath(row: lines.count - 1, section: 0), at: .bottom, animated: false)
        }
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func openMore() {
        NightSocialSafetyFlow.presentReportKinds(from: self, target: .chat(deskKey))
    }
    @objc private func openDesk() {
        NightSocialDeskGate.revealDesk(from: self, deskKey: deskKey)
    }

    @objc private func openCall() {
        guard NightSocialDeskGate.guardExchange(on: self, deskKey: deskKey) else { return }
        let name = NightSocialChimeCatalog.desk(for: deskKey)?.spokenName ?? "Night guest"
        navigationController?.pushViewController(NightSocialChimeCallStage(spokenName: name, deskKey: deskKey), animated: true)
    }
    @objc private func sendLine() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        guard NightSocialDeskGate.guardExchange(on: self, deskKey: deskKey) else { return }
        NightSocialSessionDrawer.shared.appendChimeLine(
            ChimeLine(speakerIsMe: true, hushBody: body, spokenAt: Date().timeIntervalSince1970),
            deskKey: deskKey
        )
        field.text = ""
        reloadLines()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { lines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeBubbleCell.reuseId, for: indexPath) as! ChimeBubbleCell
        cell.paint(lines[indexPath.row])
        return cell
    }
}

final class ChimeBubbleCell: UITableViewCell {
    static let reuseId = "ChimeBubbleCell"
    private let bubble = UIView()
    private let plate = UILabel()
    private var leading: NSLayoutConstraint?
    private var trailing: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        selectionStyle = .none
        bubble.layer.cornerRadius = 18
        bubble.clipsToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false
        plate.numberOfLines = 0
        plate.font = AfterHoursType.foyerBody(14)
        plate.lineBreakMode = .byWordWrapping
        plate.clipsToBounds = false
        plate.setContentCompressionResistancePriority(.required, for: .vertical)
        plate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubble)
        bubble.addSubview(plate)
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.78),
            plate.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 18),
            plate.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -18),
            plate.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 14),
            plate.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -14),
        ])
    }
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxWidth = contentView.bounds.width * 0.78 - 36
        if maxWidth > 0, abs(plate.preferredMaxLayoutWidth - maxWidth) > 0.5 {
            plate.preferredMaxLayoutWidth = maxWidth
        }
    }

    func paint(_ line: ChimeLine) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.lineBreakMode = .byWordWrapping
        leading?.isActive = false
        trailing?.isActive = false
        if line.speakerIsMe {
            bubble.backgroundColor = AfterHoursPalette.loungePink
            trailing = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            trailing?.isActive = true
            plate.attributedText = NSAttributedString(
                string: line.hushBody,
                attributes: [
                    .font: AfterHoursType.foyerBody(14),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: style,
                ]
            )
        } else {
            bubble.backgroundColor = AfterHoursPalette.loungePink
            leading = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            leading?.isActive = true
            plate.attributedText = NSAttributedString(
                string: line.hushBody,
                attributes: [
                    .font: AfterHoursType.foyerBody(14),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: style,
                ]
            )
        }
    }
}

final class NightSocialChimeComposeBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let table = UITableView()
    private var desks: [LoungeCreatorDesk] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "New message"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(ChimeFollowRow.self, forCellReuseIdentifier: ChimeFollowRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        desks = NightSocialSessionDrawer.shared.followedDeskKeys().compactMap {
            NightSocialLoungeCatalog.creator(deskKey: $0)
        }.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        if desks.isEmpty {
            let empty = NightSocialEmptyPane(spoken: "Follow someone and wait for a follow back.\nChats require mutual follows.")
            view.addSubview(empty)
            NSLayoutConstraint.activate([
                empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                empty.centerYAnchor.constraint(equalTo: table.centerYAnchor, constant: -24),
            ])
        }
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { desks.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 76 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeFollowRow.reuseId, for: indexPath) as! ChimeFollowRow
        let desk = desks[indexPath.row]
        cell.paint(desk)
        cell.onChat = { [weak self] in
            guard let self else { return }
            NightSocialDeskGate.revealChime(from: self, deskKey: desk.deskKey)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NightSocialDeskGate.revealChime(from: self, deskKey: desks[indexPath.row].deskKey)
    }
}

extension NightSocialChimeThreadBoard: NightSocialSafetyContent {
    var isHiddenBySafetyAction: Bool {
        NightSocialSessionDrawer.shared.shouldHideChat(deskKey)
    }
}
