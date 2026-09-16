import UIKit

final class NightSocialClipTheater: UIViewController {
    private let clipKey: String
    private var liked = false
    private let likePlate = UILabel()
    private let commentPlate = UILabel()
    private let sharePlate = UILabel()

    init(clipKey: String) {
        self.clipKey = clipKey
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        guard let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) else { return }

        let cover = UIImageView(image: NightSocialStandIn.plate(seed: clip.clipKey, size: CGSize(width: 420, height: 760)))
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false

        let play = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        play.tintColor = .white
        play.translatesAutoresizingMaskIntoConstraints = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let more = NightSocialLoungeChrome.iconControl(catalog: "LoungeMoreDisc", fallback: "Frame@2x(24)")
        more.addTarget(self, action: #selector(openSafety), for: .touchUpInside)

        likePlate.textColor = .white
        likePlate.font = AfterHoursType.foyerCaption(12)
        likePlate.textAlignment = .center
        commentPlate.textColor = .white
        commentPlate.font = AfterHoursType.foyerCaption(12)
        commentPlate.textAlignment = .center
        sharePlate.textColor = .white
        sharePlate.font = AfterHoursType.foyerCaption(12)
        sharePlate.textAlignment = .center
        likePlate.translatesAutoresizingMaskIntoConstraints = false
        commentPlate.translatesAutoresizingMaskIntoConstraints = false
        sharePlate.translatesAutoresizingMaskIntoConstraints = false

        let heart = UIButton(type: .system)
        heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        heart.tintColor = .white
        heart.addTarget(self, action: #selector(flipLike), for: .touchUpInside)
        let bubble = UIButton(type: .system)
        bubble.setImage(UIImage(systemName: "ellipsis.bubble.fill"), for: .normal)
        bubble.tintColor = .white
        bubble.addTarget(self, action: #selector(openDiscuss), for: .touchUpInside)
        let send = UIButton(type: .system)
        send.setImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        send.tintColor = .white
        heart.translatesAutoresizingMaskIntoConstraints = false
        bubble.translatesAutoresizingMaskIntoConstraints = false
        send.translatesAutoresizingMaskIntoConstraints = false

        let portrait = UIImageView(image: NightSocialStandIn.plate(seed: clip.authorSpokenName, size: CGSize(width: 80, height: 80)))
        portrait.layer.cornerRadius = 18
        portrait.clipsToBounds = true
        portrait.isUserInteractionEnabled = true
        portrait.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAuthor)))
        portrait.translatesAutoresizingMaskIntoConstraints = false
        let namePlate = UILabel()
        namePlate.text = clip.authorSpokenName
        namePlate.font = AfterHoursType.foyerPill(14)
        namePlate.textColor = .white
        namePlate.isUserInteractionEnabled = true
        namePlate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAuthor)))
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        let meta = UILabel()
        meta.text = "\(clip.timePhrase)   \(clip.placeLabel)"
        meta.font = AfterHoursType.foyerCaption(11)
        meta.textColor = UIColor.white.withAlphaComponent(0.75)
        meta.translatesAutoresizingMaskIntoConstraints = false
        let caption = UILabel()
        caption.text = clip.caption
        caption.font = AfterHoursType.foyerBody(13)
        caption.textColor = .white
        caption.numberOfLines = 0
        caption.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cover)
        view.addSubview(play)
        view.addSubview(back)
        view.addSubview(more)
        view.addSubview(heart)
        view.addSubview(likePlate)
        view.addSubview(bubble)
        view.addSubview(commentPlate)
        view.addSubview(send)
        view.addSubview(sharePlate)
        view.addSubview(portrait)
        view.addSubview(namePlate)
        view.addSubview(meta)
        view.addSubview(caption)

        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: view.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            play.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 64),
            play.heightAnchor.constraint(equalToConstant: 64),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            sharePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sharePlate.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            send.centerXAnchor.constraint(equalTo: sharePlate.centerXAnchor),
            send.bottomAnchor.constraint(equalTo: sharePlate.topAnchor, constant: -4),
            commentPlate.centerXAnchor.constraint(equalTo: sharePlate.centerXAnchor),
            commentPlate.bottomAnchor.constraint(equalTo: send.topAnchor, constant: -16),
            bubble.centerXAnchor.constraint(equalTo: sharePlate.centerXAnchor),
            bubble.bottomAnchor.constraint(equalTo: commentPlate.topAnchor, constant: -4),
            likePlate.centerXAnchor.constraint(equalTo: sharePlate.centerXAnchor),
            likePlate.bottomAnchor.constraint(equalTo: bubble.topAnchor, constant: -16),
            heart.centerXAnchor.constraint(equalTo: sharePlate.centerXAnchor),
            heart.bottomAnchor.constraint(equalTo: likePlate.topAnchor, constant: -4),
            portrait.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portrait.bottomAnchor.constraint(equalTo: caption.topAnchor, constant: -8),
            portrait.widthAnchor.constraint(equalToConstant: 36),
            portrait.heightAnchor.constraint(equalToConstant: 36),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 8),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor),
            meta.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            meta.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 2),
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72),
            caption.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36),
        ])
        likePlate.text = "\(clip.likeCount)"
        commentPlate.text = "\(NightSocialSessionDrawer.shared.discussLines(for: clipKey).count)"
        sharePlate.text = "\(clip.shareCount)"
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCounts), name: .deskDrawerDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func refreshCounts() {
        if NightSocialSessionDrawer.shared.shouldHideClip(clipKey, authorDeskKey: NightSocialLoungeCatalog.clip(clipKey: clipKey)?.authorDeskKey ?? "") {
            navigationController?.popViewController(animated: true)
            return
        }
        commentPlate.text = "\(NightSocialSessionDrawer.shared.discussLines(for: clipKey).count)"
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func openAuthor() {
        if let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) {
            NightSocialDeskGate.revealDesk(from: self, deskKey: clip.authorDeskKey)
        }
    }
    @objc private func openSafety() {
        guard let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) else { return }
        NightSocialSafetyFlow.presentChooser(from: self, target: .clip(clipKey: clip.clipKey, authorDeskKey: clip.authorDeskKey))
    }
    @objc private func flipLike() {
        liked.toggle()
        if let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) {
            likePlate.text = "\(clip.likeCount + (liked ? 1 : 0))"
        }
    }
    @objc private func openDiscuss() {
        present(NightSocialDiscussSheet(clipKey: clipKey), animated: true)
    }
}

final class NightSocialDiscussSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let clipKey: String
    private var lines: [LoungeDiscussLine] = []
    private let table = UITableView()
    private let field = UITextField()

    init(clipKey: String) {
        self.clipKey = clipKey
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 0.86, blue: 0.92, alpha: 1)
        let head = UILabel()
        head.text = "DISCUSS"
        head.font = AfterHoursType.foyerPill(16)
        head.textColor = AfterHoursPalette.inkOnSnow
        head.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(DiscussLineRow.self, forCellReuseIdentifier: DiscussLineRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Tell me your opinion..."
        field.backgroundColor = .white
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        let send = NightSocialLoungeChrome.pinkPill(title: "SEND")
        send.addTarget(self, action: #selector(sendLine), for: .touchUpInside)
        view.addSubview(head)
        view.addSubview(table)
        view.addSubview(field)
        view.addSubview(send)
        NSLayoutConstraint.activate([
            head.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            head.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            table.topAnchor.constraint(equalTo: head.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -10),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            field.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            send.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            send.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 84),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLines), name: .deskDrawerDidChange, object: nil)
        reloadLines()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func reloadLines() {
        lines = NightSocialSessionDrawer.shared.discussLines(for: clipKey)
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { lines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscussLineRow.reuseId, for: indexPath) as! DiscussLineRow
        let line = lines[indexPath.row]
        cell.paint(line)
        cell.onReport = { [weak self] in
            guard let self else { return }
            NightSocialSafetyFlow.presentChooser(
                from: self,
                target: .comment(lineKey: line.lineKey, speakerDeskKey: line.speakerDeskKey)
            )
        }
        cell.onOpenDesk = { [weak self] in
            guard let self else { return }
            NightSocialDeskGate.revealDesk(from: self, deskKey: line.speakerDeskKey)
        }
        return cell
    }

    @objc private func sendLine() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        let myKey = NightSocialSessionDrawer.shared.restoredSession()?.deskHolderId ?? "me.desk"
        NightSocialSessionDrawer.shared.appendComment(
            LoungeDiscussLine(speakerDeskKey: myKey, speakerName: me, spokenBody: body),
            clipKey: clipKey
        )
        field.text = ""
        reloadLines()
        if !lines.isEmpty {
            table.scrollToRow(at: IndexPath(row: lines.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
}

final class DiscussLineRow: UITableViewCell {
    static let reuseId = "DiscussLineRow"
    var onReport: (() -> Void)?
    var onOpenDesk: (() -> Void)?
    private let portrait = UIImageView()
    private let namePlate = UILabel()
    private let bodyPlate = UILabel()
    private let flag = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        portrait.layer.cornerRadius = 16
        portrait.clipsToBounds = true
        portrait.isUserInteractionEnabled = true
        portrait.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        portrait.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(13)
        namePlate.textColor = AfterHoursPalette.inkOnSnow
        namePlate.isUserInteractionEnabled = true
        namePlate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        bodyPlate.font = AfterHoursType.foyerBody(13)
        bodyPlate.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.78)
        bodyPlate.numberOfLines = 0
        bodyPlate.translatesAutoresizingMaskIntoConstraints = false
        flag.setImage(UIImage(systemName: "exclamationmark.bubble"), for: .normal)
        flag.tintColor = AfterHoursPalette.loungePink
        flag.addTarget(self, action: #selector(reportLine), for: .touchUpInside)
        flag.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(portrait)
        contentView.addSubview(namePlate)
        contentView.addSubview(bodyPlate)
        contentView.addSubview(flag)
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            portrait.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            portrait.widthAnchor.constraint(equalToConstant: 32),
            portrait.heightAnchor.constraint(equalToConstant: 32),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 8),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor),
            flag.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            flag.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
            bodyPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            bodyPlate.trailingAnchor.constraint(equalTo: flag.leadingAnchor, constant: -8),
            bodyPlate.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 2),
            bodyPlate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    required init?(coder: NSCoder) { nil }

    func paint(_ line: LoungeDiscussLine) {
        portrait.image = NightSocialStandIn.plate(seed: line.speakerName, size: CGSize(width: 64, height: 64))
        namePlate.text = line.speakerName
        bodyPlate.text = line.spokenBody
    }

    @objc private func reportLine() { onReport?() }
    @objc private func openDesk() { onOpenDesk?() }
}

final class NightSocialWhisperTrail: UIViewController, UITableViewDataSource {
    private let deskKey: String
    private let spokenName: String
    private var lines: [LoungeDiscussLine]
    private let table = UITableView()
    private let field = UITextField()

    init(deskKey: String, spokenName: String) {
        self.deskKey = deskKey
        self.spokenName = spokenName
        self.lines = [
            LoungeDiscussLine(speakerName: spokenName, spokenBody: "The lamp is on if you want to sit."),
        ]
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = spokenName
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "whisper")
        table.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Write a hush note"
        field.textColor = AfterHoursPalette.inkOnSnow
        field.backgroundColor = .white
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = NightSocialLoungeChrome.pinkPill(title: "Send")
        send.addTarget(self, action: #selector(sendLine), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(table)
        view.addSubview(field)
        view.addSubview(send)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            table.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -10),
            field.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            field.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            field.heightAnchor.constraint(equalToConstant: 36),
            send.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            send.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 72),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -8),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { lines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "whisper", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 0
        let line = lines[indexPath.row]
        cell.textLabel?.text = "\(line.speakerName)\n\(line.spokenBody)"
        cell.selectionStyle = .none
        return cell
    }
    @objc private func sendLine() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let me = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "You"
        lines.append(LoungeDiscussLine(speakerName: me, spokenBody: body))
        field.text = ""
        table.reloadData()
    }
}
