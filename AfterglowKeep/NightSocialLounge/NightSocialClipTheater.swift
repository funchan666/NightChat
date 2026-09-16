import UIKit

final class NightSocialClipTheater: UIViewController {
    private let clipKey: String
    private let asMusic: Bool
    private var liked = false
    private var videoSurface: NightSocialVideoSurface?
    private var playing = false
    private var clock: Timer?
    private let likePlate = UILabel()
    private let commentPlate = UILabel()
    private let sharePlate = UILabel()
    private let playMark = UIImageView()
    private let progress = UIProgressView(progressViewStyle: .default)
    private let elapsedPlate = UILabel()
    private let remainPlate = UILabel()

    init(clipKey: String, asMusic: Bool = false) {
        self.clipKey = clipKey
        self.asMusic = asMusic
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoSurface?.start()
        playing = videoSurface?.isPlaying == true
        paintPlayMark()
        if asMusic { startClock() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoSurface?.stop()
        clock?.invalidate()
        clock = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        guard let clip = NightSocialLoungeCatalog.clip(clipKey: clipKey) else { return }

        let cover: UIView
        if NightSocialMediaAssets.videoURL(for: clip.authorDeskKey) != nil {
            let surface = NightSocialVideoSurface(ownerKey: clip.authorDeskKey)
            videoSurface = surface
            cover = surface
        } else {
            let still = UIImageView(image: NightSocialMediaAssets.clipCover(clip.clipKey, size: CGSize(width: 420, height: 760)))
            still.contentMode = .scaleAspectFill
            still.clipsToBounds = true
            cover = still
        }
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.isUserInteractionEnabled = true
        cover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipPlayback)))

        playMark.image = UIImage(systemName: "play.circle.fill")
        playMark.tintColor = .white
        playMark.translatesAutoresizingMaskIntoConstraints = false
        playMark.isUserInteractionEnabled = false

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

        let portrait = UIImageView(image: NightSocialMediaAssets.portrait(for: clip.authorDeskKey, size: CGSize(width: 80, height: 80)))
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
        meta.text = asMusic ? clip.authorSpokenName : "\(clip.timePhrase)   \(clip.placeLabel)"
        meta.font = AfterHoursType.foyerCaption(11)
        meta.textColor = UIColor.white.withAlphaComponent(0.75)
        meta.translatesAutoresizingMaskIntoConstraints = false
        let caption = UILabel()
        caption.text = asMusic ? clip.musicTitle : clip.caption
        caption.font = asMusic ? AfterHoursType.foyerHeadline(22) : AfterHoursType.foyerBody(13)
        caption.textColor = .white
        caption.numberOfLines = 0
        caption.translatesAutoresizingMaskIntoConstraints = false

        progress.progressTintColor = AfterHoursPalette.loungePink
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.22)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isHidden = !asMusic
        elapsedPlate.font = AfterHoursType.foyerCaption(11)
        elapsedPlate.textColor = UIColor.white.withAlphaComponent(0.8)
        elapsedPlate.text = "0:00"
        elapsedPlate.translatesAutoresizingMaskIntoConstraints = false
        elapsedPlate.isHidden = !asMusic
        remainPlate.font = AfterHoursType.foyerCaption(11)
        remainPlate.textColor = UIColor.white.withAlphaComponent(0.8)
        remainPlate.text = clip.durationPhrase
        remainPlate.textAlignment = .right
        remainPlate.translatesAutoresizingMaskIntoConstraints = false
        remainPlate.isHidden = !asMusic

        let album = UIImageView(image: NightSocialMediaAssets.clipCover(clip.clipKey, size: CGSize(width: 280, height: 280)))
        album.contentMode = .scaleAspectFill
        album.clipsToBounds = true
        album.layer.cornerRadius = 24
        album.translatesAutoresizingMaskIntoConstraints = false
        album.isHidden = !asMusic
        album.isUserInteractionEnabled = false

        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(asMusic ? 0.38 : 0)
        dim.isUserInteractionEnabled = false
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.isHidden = !asMusic

        if asMusic {
            namePlate.text = clip.musicTitle
            namePlate.font = AfterHoursType.foyerHeadline(20)
            meta.text = "\(clip.authorSpokenName)  ·  \(clip.durationPhrase)"
            caption.text = clip.caption
            caption.font = AfterHoursType.foyerCaption(13)
            caption.textColor = UIColor.white.withAlphaComponent(0.78)
        }

        view.addSubview(cover)
        view.addSubview(dim)
        view.addSubview(album)
        view.addSubview(playMark)
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
        view.addSubview(progress)
        view.addSubview(elapsedPlate)
        view.addSubview(remainPlate)

        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: view.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            album.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            album.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -48),
            album.widthAnchor.constraint(equalToConstant: 220),
            album.heightAnchor.constraint(equalToConstant: 220),
            playMark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playMark.centerYAnchor.constraint(equalTo: asMusic ? album.bottomAnchor : view.centerYAnchor, constant: asMusic ? 28 : 0),
            playMark.widthAnchor.constraint(equalToConstant: 64),
            playMark.heightAnchor.constraint(equalToConstant: 64),
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
            progress.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progress.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72),
            progress.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: asMusic ? -92 : -36),
            elapsedPlate.leadingAnchor.constraint(equalTo: progress.leadingAnchor),
            elapsedPlate.bottomAnchor.constraint(equalTo: progress.topAnchor, constant: -6),
            remainPlate.trailingAnchor.constraint(equalTo: progress.trailingAnchor),
            remainPlate.centerYAnchor.constraint(equalTo: elapsedPlate.centerYAnchor),
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72),
            caption.bottomAnchor.constraint(equalTo: asMusic ? elapsedPlate.topAnchor : view.bottomAnchor, constant: asMusic ? -10 : -36),
            portrait.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portrait.bottomAnchor.constraint(equalTo: caption.topAnchor, constant: -8),
            portrait.widthAnchor.constraint(equalToConstant: 36),
            portrait.heightAnchor.constraint(equalToConstant: 36),
            namePlate.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 8),
            namePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72),
            namePlate.topAnchor.constraint(equalTo: portrait.topAnchor),
            meta.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            meta.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 2),
        ])
        likePlate.text = "\(clip.likeCount)"
        commentPlate.text = "\(NightSocialSessionDrawer.shared.discussLines(for: clipKey).count)"
        sharePlate.text = "\(clip.shareCount)"
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCounts), name: .deskDrawerDidChange, object: nil)
        paintPlayMark()
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

    @objc private func flipPlayback() {
        if videoSurface != nil {
            if videoSurface?.isPlaying == true {
                videoSurface?.pausePlayback()
                playing = false
            } else {
                videoSurface?.start()
                playing = true
            }
        } else {
            playing.toggle()
        }
        paintPlayMark()
    }

    private func paintPlayMark() {
        playMark.alpha = playing ? 0 : 1
    }

    private func startClock() {
        clock?.invalidate()
        clock = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self else { return }
            let fallback = Double(NightSocialLoungeCatalog.clip(clipKey: self.clipKey)?.trackSeconds ?? 1)
            let current: Double
            let duration: Double
            if let surface = self.videoSurface, surface.hasVideo {
                let pair = surface.progress()
                current = pair.current
                duration = max(pair.duration, 1)
            } else {
                duration = fallback
                let stepped = Double(self.progress.progress) * duration + (self.playing ? 0.25 : 0)
                current = min(duration, stepped)
            }
            self.progress.progress = Float(min(1, current / duration))
            self.elapsedPlate.text = Self.clockPhrase(current)
            self.remainPlate.text = Self.clockPhrase(max(0, duration - current))
        }
    }

    private static func clockPhrase(_ seconds: Double) -> String {
        let total = max(0, Int(seconds))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

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
        portrait.image = NightSocialMediaAssets.portrait(for: line.speakerDeskKey, size: CGSize(width: 64, height: 64))
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
