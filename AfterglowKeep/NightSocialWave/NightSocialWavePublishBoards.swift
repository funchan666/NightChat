import PhotosUI
import UIKit

final class NightSocialWaveGoLiveBoard: UIViewController, PHPickerViewControllerDelegate {
    private enum LiveKind { case voice, video }
    private var kind: LiveKind = .video
    private let titleField = FoyerLonelySnowField(whisper: "What's your room about?")
    private let cover = UIImageView()
    private var coverImage: UIImage?
    private var pickedTags: Set<String> = []
    private let tagTitles = ["Chat", "Music", "Game Talk", "Life Vibe", "Relax Time", "Story Sharing"]
    private let voiceCard = UIButton(type: .custom)
    private let videoCard = UIButton(type: .custom)
    private let start = NightSocialLoungeChrome.pinkPill(title: "Start")

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        navigationController?.setNavigationBarHidden(true, animated: false)
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Go Live"
        head.font = AfterHoursType.foyerHeadline(22)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false

        let scroller = UIScrollView()
        scroller.alwaysBounceVertical = true
        scroller.keyboardDismissMode = .onDrag
        scroller.translatesAutoresizingMaskIntoConstraints = false

        styleModeCard(voiceCard, symbol: "mic.fill", title: "Voice Room", subtitle: "Talk on mics with a sitting")
        voiceCard.addTarget(self, action: #selector(pickVoice), for: .touchUpInside)
        styleModeCard(videoCard, symbol: "video.fill", title: "Video Live", subtitle: "Go on camera")
        videoCard.addTarget(self, action: #selector(pickVideo), for: .touchUpInside)
        let modes = UIStackView(arrangedSubviews: [voiceCard, videoCard])
        modes.axis = .horizontal
        modes.spacing = 10
        modes.distribution = .fillEqually
        modes.translatesAutoresizingMaskIntoConstraints = false

        cover.backgroundColor = AfterHoursPalette.loungeCard
        cover.layer.cornerRadius = 20
        cover.clipsToBounds = true
        cover.contentMode = .scaleAspectFill
        cover.isUserInteractionEnabled = true
        cover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickCover)))
        cover.translatesAutoresizingMaskIntoConstraints = false
        let cam = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)))
        cam.tintColor = .white
        cam.translatesAutoresizingMaskIntoConstraints = false
        let coverHint = UILabel()
        coverHint.text = "Add a cover"
        coverHint.textColor = UIColor.white.withAlphaComponent(0.78)
        coverHint.font = AfterHoursType.foyerBody(14)
        coverHint.translatesAutoresizingMaskIntoConstraints = false
        coverHint.tag = 44
        let hintStack = UIStackView(arrangedSubviews: [cam, coverHint])
        hintStack.axis = .vertical
        hintStack.alignment = .center
        hintStack.spacing = 8
        hintStack.translatesAutoresizingMaskIntoConstraints = false
        hintStack.tag = 44
        hintStack.isUserInteractionEnabled = false

        let titleMark = UILabel()
        titleMark.text = "Title"
        titleMark.font = AfterHoursType.foyerPill(14)
        titleMark.textColor = .white
        let labelMark = UILabel()
        labelMark.text = "Label"
        labelMark.font = AfterHoursType.foyerPill(14)
        labelMark.textColor = .white

        let tagWrap = UIStackView()
        tagWrap.axis = .vertical
        tagWrap.spacing = 8
        tagWrap.translatesAutoresizingMaskIntoConstraints = false
        for chunk in stride(from: 0, to: tagTitles.count, by: 3) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually
            row.translatesAutoresizingMaskIntoConstraints = false
            for index in chunk..<min(chunk + 3, tagTitles.count) {
                let chip = UIButton(type: .custom)
                chip.setTitle(tagTitles[index], for: .normal)
                chip.tag = index
                chip.layer.cornerRadius = 16
                chip.titleLabel?.font = AfterHoursType.foyerCaption(12)
                chip.backgroundColor = UIColor.white.withAlphaComponent(0.10)
                chip.setTitleColor(.white, for: .normal)
                chip.addTarget(self, action: #selector(flipTag(_:)), for: .touchUpInside)
                chip.heightAnchor.constraint(equalToConstant: 32).isActive = true
                row.addArrangedSubview(chip)
            }
            tagWrap.addArrangedSubview(row)
        }

        start.addTarget(self, action: #selector(startLive), for: .touchUpInside)
        paintMode()

        let stack = UIStackView(arrangedSubviews: [modes, cover, titleMark, titleField, labelMark, tagWrap])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(18, after: modes)
        stack.setCustomSpacing(18, after: cover)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(scroller)
        scroller.addSubview(stack)
        cover.addSubview(hintStack)
        view.addSubview(start)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            scroller.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: start.topAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            modes.heightAnchor.constraint(equalToConstant: 108),
            cover.heightAnchor.constraint(equalToConstant: 168),
            hintStack.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            hintStack.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
            start.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            start.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            start.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }

    private func styleModeCard(_ card: UIButton, symbol: String, title: String, subtitle: String) {
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        let mark = UIImageView(image: UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)))
        mark.tintColor = AfterHoursPalette.loungePink
        mark.translatesAutoresizingMaskIntoConstraints = false
        let name = UILabel()
        name.text = title
        name.font = AfterHoursType.foyerPill(15)
        name.textColor = .white
        name.translatesAutoresizingMaskIntoConstraints = false
        let hint = UILabel()
        hint.text = subtitle
        hint.font = AfterHoursType.foyerCaption(11)
        hint.textColor = UIColor.white.withAlphaComponent(0.62)
        hint.numberOfLines = 2
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(mark)
        card.addSubview(name)
        card.addSubview(hint)
        NSLayoutConstraint.activate([
            mark.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            mark.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            name.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            name.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: 8),
            hint.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            hint.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            hint.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
        ])
    }

    private func paintMode() {
        let voiceOn = kind == .voice
        voiceCard.backgroundColor = voiceOn ? AfterHoursPalette.loungePink.withAlphaComponent(0.28) : AfterHoursPalette.loungeCard
        videoCard.backgroundColor = voiceOn ? AfterHoursPalette.loungeCard : AfterHoursPalette.loungePink.withAlphaComponent(0.28)
        voiceCard.layer.borderWidth = voiceOn ? 1.5 : 0
        videoCard.layer.borderWidth = voiceOn ? 0 : 1.5
        voiceCard.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        videoCard.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        let cost = NightSocialLampSpend.hostVoice.cost
        start.setTitle(voiceOn ? "Start Voice Room · \(cost)" : "Start Video Live · \(cost)", for: .normal)
    }

    @objc private func pickVoice() { kind = .voice; paintMode() }
    @objc private func pickVideo() { kind = .video; paintMode() }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func flipTag(_ sender: UIButton) {
        let title = tagTitles[sender.tag]
        if pickedTags.contains(title) { pickedTags.remove(title) } else { pickedTags.insert(title) }
        sender.backgroundColor = pickedTags.contains(title) ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.10)
    }

    @objc private func pickCover() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.coverImage = image
                self?.cover.image = image
                self?.cover.viewWithTag(44)?.isHidden = true
            }
        }
    }

    @objc private func startLive() {
        let title = NightSocialFoyerGuard.trimmed(titleField.text)
        if title.isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Title still empty", spokenBody: "Write a title before you go live.")
            return
        }
        if pickedTags.isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Pick a label", spokenBody: "Choose at least one label so people can find you.")
            return
        }
        let tags = Array(pickedTags)
        let spend: NightSocialLampSpend = kind == .voice ? .hostVoice : .hostLive
        NightSocialLampStore.spend(spend, from: self) { [weak self] in
            guard let self else { return }
            if self.kind == .voice {
                self.openHostedSitting(title: title, tags: tags)
            } else {
                self.openHostedLive(title: title, tags: tags)
            }
        }
    }

    private func openHostedSitting(title: String, tags: [String]) {
        let host = NightSocialSessionDrawer.shared.restoredSession()?.deskHolderId ?? "me.desk"
        let key = "wave.hosted.\(UUID().uuidString)"
        NightSocialSessionDrawer.shared.rememberHostedChamber([
            "key": key,
            "title": title,
            "mood": "Hosted sitting",
            "host": host,
            "tags": tags.joined(separator: ","),
        ])
        NightSocialSessionDrawer.shared.rememberVisitedChamber(key)
        navigationController?.pushViewController(NightSocialWaveVoiceStage(chamberKey: key), animated: true)
    }

    private func openHostedLive(title: String, tags: [String]) {
        let host = NightSocialSessionDrawer.shared.restoredSession()?.deskHolderId ?? "me.desk"
        let key = "live.hosted.\(UUID().uuidString)"
        NightSocialSessionDrawer.shared.rememberHostedLive([
            "key": key,
            "title": title,
            "mood": "Live now",
            "host": host,
            "tags": tags.joined(separator: ","),
        ])
        navigationController?.pushViewController(NightSocialLiveBoothStage(boothKey: key), animated: true)
    }
}

final class NightSocialWavePostBoard: UIViewController, PHPickerViewControllerDelegate {
    private let note = FoyerLonelySnowNote(whisper: "Please input your thoughts..")
    private let slot = UIImageView()
    private var clipImage: UIImage?
    private let costPlate = UILabel()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Post"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        slot.backgroundColor = AfterHoursPalette.loungeCard
        slot.layer.cornerRadius = 16
        slot.clipsToBounds = true
        slot.contentMode = .scaleAspectFill
        slot.isUserInteractionEnabled = true
        slot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickClip)))
        slot.translatesAutoresizingMaskIntoConstraints = false
        let plus = UILabel()
        plus.text = "+"
        plus.font = AfterHoursType.foyerHeadline(36)
        plus.textColor = .white
        plus.textAlignment = .center
        plus.tag = 45
        plus.translatesAutoresizingMaskIntoConstraints = false
        costPlate.text = "Spend 68 night coins to post this clip. Chat stays free."
        costPlate.font = AfterHoursType.foyerCaption(12)
        costPlate.textColor = UIColor.white.withAlphaComponent(0.75)
        costPlate.translatesAutoresizingMaskIntoConstraints = false
        let post = NightSocialLoungeChrome.pinkPill(title: "Post")
        post.addTarget(self, action: #selector(publish), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(note)
        view.addSubview(slot)
        slot.addSubview(plus)
        view.addSubview(costPlate)
        view.addSubview(post)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            note.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            note.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            note.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 16),
            slot.leadingAnchor.constraint(equalTo: note.leadingAnchor),
            slot.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 16),
            slot.widthAnchor.constraint(equalToConstant: 120),
            slot.heightAnchor.constraint(equalToConstant: 120),
            plus.centerXAnchor.constraint(equalTo: slot.centerXAnchor),
            plus.centerYAnchor.constraint(equalTo: slot.centerYAnchor),
            costPlate.leadingAnchor.constraint(equalTo: note.leadingAnchor),
            costPlate.bottomAnchor.constraint(equalTo: post.topAnchor, constant: -10),
            post.leadingAnchor.constraint(equalTo: note.leadingAnchor),
            post.trailingAnchor.constraint(equalTo: note.trailingAnchor),
            post.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func pickClip() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .any(of: [.images, .videos])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.clipImage = image
                    self?.slot.image = image
                    self?.slot.viewWithTag(45)?.isHidden = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.clipImage = NightSocialMediaAssets.portrait(for: "posted-clip", size: CGSize(width: 240, height: 240))
                self.slot.image = self.clipImage
                self.slot.viewWithTag(45)?.isHidden = true
            }
        }
    }

    @objc private func publish() {
        let body = NightSocialFoyerGuard.trimmed(note.spokenText)
        if body.isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Thoughts still empty", spokenBody: "Write a line before this clip can leave the desk.")
            return
        }
        if clipImage == nil {
            FoyerNotice.present(on: self, spokenTitle: "Clip still empty", spokenBody: "Add a photo or video placeholder before you post.")
            return
        }
        NightSocialLampStore.spend(.postClip, from: self) { [weak self] in
            guard let self else { return }
            NightSocialSessionDrawer.shared.rememberPendingClip(caption: body)
            NightSocialLampNotices.presentReviewHold(from: self) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
