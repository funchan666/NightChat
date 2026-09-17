import UIKit

final class NightSocialChimeThreadBoard: UIViewController, UITableViewDataSource {
    private let deskKey: String
    private var lines: [ChimeLine] = []
    private let table = UITableView()
    private let field = UITextField()

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
        let more = NightSocialLoungeChrome.iconControl(catalog: "DeleteIcon", fallback: "DeleteIcon", edge: 32)
        more.addTarget(self, action: #selector(clearThread), for: .touchUpInside)
        let video = NightSocialLoungeChrome.iconControl(catalog: "VideoCallIcon", fallback: "VideoCallIcon", edge: 32)
        video.addTarget(self, action: #selector(openCall), for: .touchUpInside)
        video.isHidden = deskKey == NightSocialChimeCatalog.supportDeskKey

        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.85)
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isHidden = deskKey == NightSocialChimeCatalog.supportDeskKey
        let pic = UIImageView(image: NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 96, height: 96)))
        pic.contentMode = .scaleAspectFill
        pic.layer.cornerRadius = 24
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
        stats.text = "Fans \(desk?.followerCount ?? "0")   Follow \(desk?.friendCount ?? "0")"
        stats.font = AfterHoursType.foyerCaption(11)
        stats.textColor = UIColor.white.withAlphaComponent(0.85)
        stats.translatesAutoresizingMaskIntoConstraints = false
        let gift = NightSocialLoungeChrome.iconControl(catalog: "GiftBox", fallback: "GiftBox", edge: 32)
        gift.addTarget(self, action: #selector(openGift), for: .touchUpInside)

        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.register(ChimeBubbleCell.self, forCellReuseIdentifier: ChimeBubbleCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never

        field.placeholder = "Tell me your opinion..."
        field.attributedPlaceholder = NSAttributedString(string: "Tell me your opinion...", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)])
        field.textColor = AfterHoursPalette.inkOnSnow
        field.backgroundColor = AfterHoursPalette.loungeCard
        field.layer.cornerRadius = 22
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 44))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = NightSocialLoungeChrome.pinkPill(title: "SEND")
        send.addTarget(self, action: #selector(sendLine), for: .touchUpInside)

        view.addSubview(back)
        view.addSubview(name)
        view.addSubview(video)
        view.addSubview(more)
        view.addSubview(card)
        card.addSubview(pic)
        card.addSubview(cardName)
        card.addSubview(stats)
        card.addSubview(gift)
        view.addSubview(table)
        view.addSubview(field)
        view.addSubview(send)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            name.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            name.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            video.trailingAnchor.constraint(equalTo: more.leadingAnchor, constant: -8),
            video.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            card.heightAnchor.constraint(equalToConstant: card.isHidden ? 0 : 78),
            pic.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            pic.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 48),
            pic.heightAnchor.constraint(equalToConstant: 48),
            cardName.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            cardName.topAnchor.constraint(equalTo: pic.topAnchor, constant: 4),
            stats.leadingAnchor.constraint(equalTo: cardName.leadingAnchor),
            stats.topAnchor.constraint(equalTo: cardName.bottomAnchor, constant: 4),
            gift.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            gift.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            table.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -10),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            field.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            field.heightAnchor.constraint(equalToConstant: 44),
            send.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            send.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 84),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        reloadLines()
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
    @objc private func clearThread() {
        NightSocialSessionDrawer.shared.clearChimeLines(deskKey: deskKey)
        reloadLines()
    }
    @objc private func openDesk() {
        NightSocialDeskGate.revealDesk(from: self, deskKey: deskKey)
    }

    @objc private func openCall() {
        guard NightSocialDeskGate.guardExchange(on: self, deskKey: deskKey) else { return }
        let name = NightSocialChimeCatalog.desk(for: deskKey)?.spokenName ?? "Night guest"
        navigationController?.pushViewController(NightSocialChimeCallStage(spokenName: name, deskKey: deskKey), animated: true)
    }
    @objc private func openGift() {
        present(NightSocialTributeTray(boothKey: deskKey), animated: true)
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
    private let bubble = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        bubble.numberOfLines = 0
        bubble.font = AfterHoursType.foyerBody(14)
        bubble.layer.cornerRadius = 16
        bubble.clipsToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubble)
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.72),
        ])
    }
    required init?(coder: NSCoder) { nil }

    private var leading: NSLayoutConstraint?
    private var trailing: NSLayoutConstraint?

    func paint(_ line: ChimeLine) {
        bubble.text = "  \(line.hushBody)  "
        leading?.isActive = false
        trailing?.isActive = false
        if line.speakerIsMe {
            bubble.backgroundColor = .white
            bubble.textColor = AfterHoursPalette.inkOnSnow
            trailing = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            trailing?.isActive = true
        } else {
            bubble.backgroundColor = AfterHoursPalette.loungePink
            bubble.textColor = .white
            leading = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            leading?.isActive = true
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
            let empty = NightSocialEmptyPane(spoken: "Follow someone first.\nNew messages start from desks you follow.")
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
            self?.navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: desk.deskKey), animated: true)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(NightSocialChimeThreadBoard(deskKey: desks[indexPath.row].deskKey), animated: true)
    }
}
