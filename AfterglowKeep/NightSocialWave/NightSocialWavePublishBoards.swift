import PhotosUI
import UIKit

final class NightSocialWaveGoLiveBoard: UIViewController, PHPickerViewControllerDelegate {
    private let titleField = FoyerLonelySnowField(whisper: "What's your room about?")
    private let cover = UIImageView()
    private var coverImage: UIImage?
    private var pickedTags: Set<String> = []
    private let tagTitles = ["Chat", "Music", "Game Talk", "Life Vibe", "Relax Time", "Story Sharing"]
    private let tagRow = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Go Live"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        cover.backgroundColor = AfterHoursPalette.loungeCard
        cover.layer.cornerRadius = 18
        cover.clipsToBounds = true
        cover.contentMode = .scaleAspectFill
        cover.isUserInteractionEnabled = true
        cover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickCover)))
        cover.translatesAutoresizingMaskIntoConstraints = false
        let coverHint = UILabel()
        coverHint.text = "Add a cover"
        coverHint.textColor = UIColor.white.withAlphaComponent(0.7)
        coverHint.font = AfterHoursType.foyerBody(14)
        coverHint.translatesAutoresizingMaskIntoConstraints = false
        coverHint.tag = 44
        let titleMark = UILabel()
        titleMark.text = "Title"
        titleMark.font = AfterHoursType.foyerPill(14)
        titleMark.textColor = .white
        titleMark.translatesAutoresizingMaskIntoConstraints = false
        let labelMark = UILabel()
        labelMark.text = "Label"
        labelMark.font = AfterHoursType.foyerPill(14)
        labelMark.textColor = .white
        labelMark.translatesAutoresizingMaskIntoConstraints = false
        tagRow.axis = .horizontal
        tagRow.spacing = 8
        tagRow.translatesAutoresizingMaskIntoConstraints = false
        let wrap = UIScrollView()
        wrap.showsHorizontalScrollIndicator = false
        wrap.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(tagRow)
        for (index, title) in tagTitles.enumerated() {
            let chip = UIButton(type: .system)
            chip.setTitle("  \(title)  ", for: .normal)
            chip.tag = index
            chip.layer.cornerRadius = 14
            chip.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            chip.setTitleColor(.white, for: .normal)
            chip.addTarget(self, action: #selector(flipTag(_:)), for: .touchUpInside)
            tagRow.addArrangedSubview(chip)
        }
        let start = NightSocialLoungeChrome.pinkPill(title: "StartLive · 120pts")
        start.addTarget(self, action: #selector(startLive), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(cover)
        cover.addSubview(coverHint)
        view.addSubview(titleMark)
        view.addSubview(titleField)
        view.addSubview(labelMark)
        view.addSubview(wrap)
        view.addSubview(start)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cover.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 16),
            cover.heightAnchor.constraint(equalToConstant: 180),
            coverHint.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            coverHint.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
            titleMark.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            titleMark.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            titleField.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            titleField.topAnchor.constraint(equalTo: titleMark.bottomAnchor, constant: 8),
            labelMark.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            labelMark.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            wrap.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            wrap.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            wrap.topAnchor.constraint(equalTo: labelMark.bottomAnchor, constant: 8),
            wrap.heightAnchor.constraint(equalToConstant: 32),
            tagRow.leadingAnchor.constraint(equalTo: wrap.contentLayoutGuide.leadingAnchor),
            tagRow.trailingAnchor.constraint(equalTo: wrap.contentLayoutGuide.trailingAnchor),
            tagRow.topAnchor.constraint(equalTo: wrap.contentLayoutGuide.topAnchor),
            tagRow.bottomAnchor.constraint(equalTo: wrap.contentLayoutGuide.bottomAnchor),
            start.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            start.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            start.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }

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
            FoyerNotice.present(on: self, spokenTitle: "Title still empty", spokenBody: "Write what this voice desk is about before you go live.")
            return
        }
        if pickedTags.isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Pick a label", spokenBody: "Choose at least one label so people can find the sitting.")
            return
        }
        NightSocialLampStore.spend(.hostVoice, from: self) { [weak self] in
            self?.openHostedSitting(title: title, tags: pickedTags)
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
            NightSocialSessionDrawer.shared.rememberPendingClip(caption: body)
            NightSocialLampNotices.presentReviewHold(from: self) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
