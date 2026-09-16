import PhotosUI
import UIKit

final class NightSocialMirrorCheckInBoard: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let banner = UIImageView(image: NightSocialImageCabinet.named("MirrorCheckBanner", fallback: "Group_921"))
        banner.contentMode = .scaleAspectFill
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        let marked = NightSocialSessionDrawer.shared.checkInDays()
        for row in 0..<2 {
            let line = UIStackView()
            line.axis = .horizontal
            line.spacing = 10
            line.distribution = .fillEqually
            for col in 0..<4 {
                let day = row * 4 + col + 1
                let cell = UIButton(type: .custom)
                cell.backgroundColor = AfterHoursPalette.loungeCard
                cell.layer.cornerRadius = 16
                cell.tag = day
                cell.addTarget(self, action: #selector(pickDay(_:)), for: .touchUpInside)
                let coin = UIImageView(image: NightSocialImageCabinet.named("MirrorCoinDay", fallback: "Frame@2x(42)"))
                coin.contentMode = .scaleAspectFit
                coin.translatesAutoresizingMaskIntoConstraints = false
                let plate = UILabel()
                plate.text = "Day \(day)\n\(day * 10)"
                plate.numberOfLines = 2
                plate.textAlignment = .center
                plate.font = AfterHoursType.foyerCaption(11)
                plate.textColor = marked.contains(day) ? AfterHoursPalette.loungePink : .white
                plate.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(coin)
                cell.addSubview(plate)
                NSLayoutConstraint.activate([
                    cell.heightAnchor.constraint(equalToConstant: 88),
                    coin.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                    coin.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                    coin.widthAnchor.constraint(equalToConstant: 28),
                    coin.heightAnchor.constraint(equalToConstant: 28),
                    plate.topAnchor.constraint(equalTo: coin.bottomAnchor, constant: 4),
                    plate.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                ])
                line.addArrangedSubview(cell)
            }
            grid.addArrangedSubview(line)
        }
        let preview = NightSocialLoungeChrome.pinkPill(title: "Review preview")
        preview.addTarget(self, action: #selector(previewTap), for: .touchUpInside)
        view.addSubview(banner)
        view.addSubview(back)
        view.addSubview(grid)
        view.addSubview(preview)
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.topAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.heightAnchor.constraint(equalToConstant: 220),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            grid.topAnchor.constraint(equalTo: banner.bottomAnchor, constant: 16),
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            preview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            preview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func pickDay(_ sender: UIButton) {
        NightSocialSessionDrawer.shared.markCheckInPreview(sender.tag)
        FoyerNotice.present(on: self, spokenTitle: "Review preview", spokenBody: "No reward is granted in this preview sitting.")
    }
    @objc private func previewTap() {
        FoyerNotice.present(on: self, spokenTitle: "Review preview", spokenBody: "Check-in rewards are not granted in this preview.")
    }
}

final class NightSocialMirrorBackpackBoard: UIViewController {
    private let titles = ["Stickers", "Frames", "Badges"]
    private var lane = 0
    private let grid = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Backpack"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let tabs = UIStackView()
        tabs.axis = .horizontal
        tabs.spacing = 16
        tabs.translatesAutoresizingMaskIntoConstraints = false
        for (index, title) in titles.enumerated() {
            let mark = UIButton(type: .system)
            mark.setTitle(title, for: .normal)
            mark.tag = index
            mark.addTarget(self, action: #selector(pickLane(_:)), for: .touchUpInside)
            tabs.addArrangedSubview(mark)
        }
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(tabs)
        view.addSubview(grid)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            tabs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabs.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 16),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            grid.topAnchor.constraint(equalTo: tabs.bottomAnchor, constant: 16),
        ])
        paintLane()
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func pickLane(_ sender: UIButton) {
        lane = sender.tag
        paintLane()
    }

    private func paintLane() {
        if let tabs = view.subviews.compactMap({ $0 as? UIStackView }).first(where: { $0.axis == .horizontal }) {
            tabs.arrangedSubviews.enumerated().forEach { index, view in
                (view as? UIButton)?.setTitleColor(index == lane ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.55), for: .normal)
            }
        }
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if lane != 0 {
            let empty = UILabel()
            empty.text = lane == 1 ? "No frames in this desk yet." : "No badges in this desk yet."
            empty.textColor = UIColor.white.withAlphaComponent(0.6)
            empty.font = AfterHoursType.foyerBody(14)
            grid.addArrangedSubview(empty)
            return
        }
        let items: [(String, String, String)] = [
            ("GiftWand", "Light stick", "x1"),
            ("GiftFist", "fist", "x25"),
            ("GiftHeart", "Compassion", "x16"),
            ("GiftCake", "cake", "x36"),
            ("GiftBalloons", "Hot air balloon", "x46"),
            ("GiftWhistle", "Whistle", "x36"),
            ("GiftLaugh", "expression", "x46"),
            ("MirrorCoinMark", "integral", "x456"),
        ]
        for row in 0..<4 {
            let line = UIStackView()
            line.axis = .horizontal
            line.spacing = 10
            line.distribution = .fillEqually
            for col in 0..<2 {
                let item = items[row * 2 + col]
                let card = UIView()
                card.backgroundColor = AfterHoursPalette.loungeCard
                card.layer.cornerRadius = 16
                let glyph = UIImageView(image: UIImage(named: item.0))
                glyph.contentMode = .scaleAspectFit
                glyph.translatesAutoresizingMaskIntoConstraints = false
                let plate = UILabel()
                plate.text = "\(item.1)\n\(item.2)"
                plate.numberOfLines = 2
                plate.textAlignment = .center
                plate.font = AfterHoursType.foyerCaption(12)
                plate.textColor = .white
                plate.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(glyph)
                card.addSubview(plate)
                NSLayoutConstraint.activate([
                    card.heightAnchor.constraint(equalToConstant: 120),
                    glyph.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                    glyph.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                    glyph.widthAnchor.constraint(equalToConstant: 48),
                    glyph.heightAnchor.constraint(equalToConstant: 48),
                    plate.topAnchor.constraint(equalTo: glyph.bottomAnchor, constant: 8),
                    plate.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                ])
                line.addArrangedSubview(card)
            }
            grid.addArrangedSubview(line)
        }
    }
}

final class NightSocialMirrorLevelBoard: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "My Level"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let wash = UIImageView(image: NightSocialImageCabinet.named("MirrorLevelWash", fallback: "Group_922"))
        wash.contentMode = .scaleAspectFill
        wash.clipsToBounds = true
        wash.layer.cornerRadius = 22
        wash.translatesAutoresizingMaskIntoConstraints = false
        let alias = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "Night guest"
        let pic = UIImageView(image: NightSocialSessionDrawer.shared.loadPortrait() ?? NightSocialMediaAssets.localPortrait(size: CGSize(width: 120, height: 120)))
        pic.layer.cornerRadius = 28
        pic.clipsToBounds = true
        pic.translatesAutoresizingMaskIntoConstraints = false
        let name = UILabel()
        name.text = alias
        name.font = AfterHoursType.foyerPill(16)
        name.textColor = .white
        name.translatesAutoresizingMaskIntoConstraints = false
        let lv = UILabel()
        lv.text = "Lv.8"
        lv.font = AfterHoursType.foyerHeadline(22)
        lv.textColor = .white
        lv.translatesAutoresizingMaskIntoConstraints = false
        let bar = UIView()
        bar.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        bar.layer.cornerRadius = 4
        bar.translatesAutoresizingMaskIntoConstraints = false
        let fill = UIView()
        fill.backgroundColor = .white
        fill.layer.cornerRadius = 4
        fill.translatesAutoresizingMaskIntoConstraints = false
        let exp = UILabel()
        exp.text = "120/500 EXP   Review mode level preview"
        exp.font = AfterHoursType.foyerCaption(11)
        exp.textColor = UIColor.white.withAlphaComponent(0.8)
        exp.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(wash)
        wash.addSubview(pic)
        wash.addSubview(name)
        wash.addSubview(lv)
        wash.addSubview(bar)
        bar.addSubview(fill)
        wash.addSubview(exp)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            wash.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wash.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            wash.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 20),
            wash.heightAnchor.constraint(equalToConstant: 140),
            pic.leadingAnchor.constraint(equalTo: wash.leadingAnchor, constant: 14),
            pic.centerYAnchor.constraint(equalTo: wash.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 56),
            pic.heightAnchor.constraint(equalToConstant: 56),
            name.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            name.topAnchor.constraint(equalTo: pic.topAnchor),
            lv.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            lv.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
            bar.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: wash.trailingAnchor, constant: -16),
            bar.topAnchor.constraint(equalTo: lv.bottomAnchor, constant: 10),
            bar.heightAnchor.constraint(equalToConstant: 8),
            fill.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            fill.topAnchor.constraint(equalTo: bar.topAnchor),
            fill.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: bar.widthAnchor, multiplier: 0.24),
            exp.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            exp.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 6),
        ])
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
}

final class NightSocialMirrorFeedbackBoard: UIViewController, PHPickerViewControllerDelegate {
    private var kind = "Bug"
    private let note = FoyerLonelySnowNote(whisper: "Describe the issue or idea...")
    private let slot = UIImageView()
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Feedback"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let type = UILabel()
        type.text = "Type"
        type.font = AfterHoursType.foyerPill(14)
        type.textColor = .white
        type.translatesAutoresizingMaskIntoConstraints = false
        let chips = UIStackView()
        chips.axis = .horizontal
        chips.spacing = 8
        chips.translatesAutoresizingMaskIntoConstraints = false
        for (index, title) in ["Bug", "Suggestion", "Payment", "Other"].enumerated() {
            let chip = UIButton(type: .system)
            chip.setTitle("  \(title)  ", for: .normal)
            chip.tag = index
            chip.layer.cornerRadius = 14
            chip.backgroundColor = index == 0 ? AfterHoursPalette.loungePink : AfterHoursPalette.loungeCard
            chip.setTitleColor(.white, for: .normal)
            chip.addTarget(self, action: #selector(pickKind(_:)), for: .touchUpInside)
            chips.addArrangedSubview(chip)
        }
        let desc = UILabel()
        desc.text = "Description"
        desc.font = AfterHoursType.foyerPill(14)
        desc.textColor = .white
        desc.translatesAutoresizingMaskIntoConstraints = false
        let upload = UILabel()
        upload.text = "Upload photo"
        upload.font = AfterHoursType.foyerPill(14)
        upload.textColor = .white
        upload.translatesAutoresizingMaskIntoConstraints = false
        slot.backgroundColor = AfterHoursPalette.loungeCard
        slot.layer.cornerRadius = 16
        slot.clipsToBounds = true
        slot.contentMode = .scaleAspectFill
        slot.isUserInteractionEnabled = true
        slot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
        slot.translatesAutoresizingMaskIntoConstraints = false
        let plus = UILabel()
        plus.text = "+"
        plus.font = AfterHoursType.foyerHeadline(32)
        plus.textColor = .white
        plus.tag = 77
        plus.translatesAutoresizingMaskIntoConstraints = false
        let submit = NightSocialLoungeChrome.pinkPill(title: "Submit")
        submit.addTarget(self, action: #selector(submitTap), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(type)
        view.addSubview(chips)
        view.addSubview(desc)
        view.addSubview(note)
        view.addSubview(upload)
        view.addSubview(slot)
        slot.addSubview(plus)
        view.addSubview(submit)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            type.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            type.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 16),
            chips.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            chips.topAnchor.constraint(equalTo: type.bottomAnchor, constant: 8),
            desc.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            desc.topAnchor.constraint(equalTo: chips.bottomAnchor, constant: 16),
            note.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            note.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            note.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 8),
            upload.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            upload.topAnchor.constraint(equalTo: note.bottomAnchor, constant: 16),
            slot.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            slot.topAnchor.constraint(equalTo: upload.bottomAnchor, constant: 8),
            slot.widthAnchor.constraint(equalToConstant: 110),
            slot.heightAnchor.constraint(equalToConstant: 110),
            plus.centerXAnchor.constraint(equalTo: slot.centerXAnchor),
            plus.centerYAnchor.constraint(equalTo: slot.centerYAnchor),
            submit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submit.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func pickKind(_ sender: UIButton) {
        kind = ["Bug", "Suggestion", "Payment", "Other"][sender.tag]
        if let chips = view.subviews.compactMap({ $0 as? UIStackView }).first {
            chips.arrangedSubviews.enumerated().forEach { index, view in
                (view as? UIButton)?.backgroundColor = index == sender.tag ? AfterHoursPalette.loungePink : AfterHoursPalette.loungeCard
            }
        }
    }
    @objc private func pickPhoto() {
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
                self?.slot.image = image
                self?.slot.viewWithTag(77)?.isHidden = true
            }
        }
    }
    @objc private func submitTap() {
        if NightSocialFoyerGuard.trimmed(note.spokenText).isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Description still empty", spokenBody: "Write the issue or idea before it can leave this desk.")
            return
        }
        FoyerNotice.present(on: self, spokenTitle: "Feedback sent", spokenBody: "The house received your \(kind.lowercased()) note.")
    }
}

final class NightSocialMirrorInviteBoard: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Invitation code"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let gift = UIImageView(image: NightSocialImageCabinet.named("MirrorInviteGift", fallback: "image_647"))
        gift.contentMode = .scaleAspectFit
        gift.translatesAutoresizingMaskIntoConstraints = false
        let line = UILabel()
        line.text = "Invite friends, both get 500"
        line.font = AfterHoursType.foyerBody(14)
        line.textColor = .white
        line.textAlignment = .center
        line.translatesAutoresizingMaskIntoConstraints = false
        let code = NightSocialSessionDrawer.shared.inviteCode()
        let codePill = UIButton(type: .custom)
        codePill.backgroundColor = AfterHoursPalette.loungePink
        codePill.layer.cornerRadius = 18
        codePill.setTitle("  \(code)  ", for: .normal)
        codePill.setTitleColor(.white, for: .normal)
        codePill.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        codePill.translatesAutoresizingMaskIntoConstraints = false
        let share = NightSocialLoungeChrome.pinkPill(title: "Share invite link")
        share.addTarget(self, action: #selector(shareCode), for: .touchUpInside)
        let how = UILabel()
        how.text = "How it works\nShare your code with friends\nThey sign up and enter your code\nYou both receive 500 instantly"
        how.numberOfLines = 0
        how.font = AfterHoursType.foyerBody(14)
        how.textColor = UIColor.white.withAlphaComponent(0.85)
        how.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(gift)
        view.addSubview(line)
        view.addSubview(codePill)
        view.addSubview(share)
        view.addSubview(how)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            gift.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gift.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 24),
            gift.widthAnchor.constraint(equalToConstant: 96),
            gift.heightAnchor.constraint(equalToConstant: 96),
            line.topAnchor.constraint(equalTo: gift.bottomAnchor, constant: 12),
            line.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codePill.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 16),
            codePill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codePill.heightAnchor.constraint(equalToConstant: 40),
            share.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            share.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            share.topAnchor.constraint(equalTo: codePill.bottomAnchor, constant: 16),
            how.leadingAnchor.constraint(equalTo: share.leadingAnchor),
            how.trailingAnchor.constraint(equalTo: share.trailingAnchor),
            how.topAnchor.constraint(equalTo: share.bottomAnchor, constant: 24),
        ])
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func copyCode() {
        UIPasteboard.general.string = NightSocialSessionDrawer.shared.inviteCode()
        FoyerNotice.present(on: self, spokenTitle: "Copied", spokenBody: "The invite code is on the pasteboard.")
    }
    @objc private func shareCode() {
        let code = NightSocialSessionDrawer.shared.inviteCode()
        present(UIActivityViewController(activityItems: ["Join NightChat with \(code)"], applicationActivities: nil), animated: true)
    }
}

final class NightSocialMirrorSupportBoard: UIViewController, UITableViewDataSource {
    private var lines: [ChimeLine] = [
        ChimeLine(speakerIsMe: false, hushBody: "Hi! I'm your dedicated support Ella. Feel free to ask about accounts, recharge and live streaming.", spokenAt: Date().timeIntervalSince1970 - 60)
    ]
    private let table = UITableView()
    private let field = UITextField()
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let stored = NightSocialSessionDrawer.shared.chimeLines(for: NightSocialChimeCatalog.supportDeskKey)
        if !stored.isEmpty { lines = stored }
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Customer Support"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let bunny = UIImageView(image: NightSocialImageCabinet.named("MirrorBunny", fallback: "Group_923"))
        bunny.contentMode = .scaleAspectFit
        bunny.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.register(ChimeBubbleCell.self, forCellReuseIdentifier: ChimeBubbleCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Tell me your opinion..."
        field.textColor = AfterHoursPalette.inkOnSnow
        field.backgroundColor = .white
        field.layer.cornerRadius = 22
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        let send = NightSocialLoungeChrome.pinkPill(title: "SEND")
        send.addTarget(self, action: #selector(sendLine), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(bunny)
        view.addSubview(table)
        view.addSubview(field)
        view.addSubview(send)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            bunny.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bunny.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 8),
            bunny.widthAnchor.constraint(equalToConstant: 120),
            bunny.heightAnchor.constraint(equalToConstant: 120),
            table.topAnchor.constraint(equalTo: bunny.bottomAnchor, constant: 8),
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
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { lines.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChimeBubbleCell.reuseId, for: indexPath) as! ChimeBubbleCell
        cell.paint(lines[indexPath.row])
        return cell
    }
    @objc private func sendLine() {
        let body = NightSocialFoyerGuard.trimmed(field.text)
        guard !body.isEmpty else { return }
        let line = ChimeLine(speakerIsMe: true, hushBody: body, spokenAt: Date().timeIntervalSince1970)
        NightSocialSessionDrawer.shared.appendChimeLine(line, deskKey: NightSocialChimeCatalog.supportDeskKey)
        lines.append(line)
        field.text = ""
        table.reloadData()
    }
}

final class NightSocialMirrorRechargeBoard: UIViewController {
    private let pursePlate = UILabel()
    private let busy = UIActivityIndicatorView(style: .large)
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Night purse"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false

        let scroller = UIScrollView()
        scroller.alwaysBounceVertical = true
        scroller.translatesAutoresizingMaskIntoConstraints = false

        let banner = UIView()
        banner.backgroundColor = AfterHoursPalette.loungePink
        banner.layer.cornerRadius = 18
        banner.translatesAutoresizingMaskIntoConstraints = false
        pursePlate.font = AfterHoursType.foyerHeadline(32)
        pursePlate.textColor = .white
        pursePlate.translatesAutoresizingMaskIntoConstraints = false
        let coinLine = UILabel()
        coinLine.text = "Night coins on this desk"
        coinLine.font = AfterHoursType.foyerPill(14)
        coinLine.textColor = .white
        coinLine.translatesAutoresizingMaskIntoConstraints = false
        let hint = UILabel()
        hint.text = "Balance updates the moment Apple finishes the sitting."
        hint.font = AfterHoursType.foyerCaption(12)
        hint.textColor = UIColor.white.withAlphaComponent(0.85)
        hint.translatesAutoresizingMaskIntoConstraints = false
        let gem = UIImageView(image: NightSocialImageCabinet.named("MirrorDiamondPack", fallback: "image_650"))
        gem.contentMode = .scaleAspectFit
        gem.translatesAutoresizingMaskIntoConstraints = false

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        let packs = NightSocialLampPack.allCases
        for row in 0..<3 {
            let line = UIStackView()
            line.axis = .horizontal
            line.spacing = 10
            line.distribution = .fillEqually
            for col in 0..<3 {
                let pack = packs[row * 3 + col]
                let card = UIControl()
                card.backgroundColor = UIColor(red: 1, green: 0.86, blue: 0.92, alpha: 1)
                card.layer.cornerRadius = 16
                card.tag = row * 3 + col
                card.addTarget(self, action: #selector(buyPack(_:)), for: .touchUpInside)
                let coins = UILabel()
                coins.text = "\(pack.coins)"
                coins.font = AfterHoursType.foyerHeadline(18)
                coins.textColor = AfterHoursPalette.loungePink
                coins.textAlignment = .center
                coins.translatesAutoresizingMaskIntoConstraints = false
                let price = UILabel()
                price.text = pack.listedPrice
                price.font = AfterHoursType.foyerCaption(12)
                price.textColor = AfterHoursPalette.inkOnSnow
                price.textAlignment = .center
                price.translatesAutoresizingMaskIntoConstraints = false
                let name = UILabel()
                name.text = pack.spokenTitle
                name.font = AfterHoursType.foyerCaption(11)
                name.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.7)
                name.textAlignment = .center
                name.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(name)
                card.addSubview(coins)
                card.addSubview(price)
                NSLayoutConstraint.activate([
                    card.heightAnchor.constraint(equalToConstant: 88),
                    name.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
                    name.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                    coins.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                    coins.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: 2),
                    price.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
                    price.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                ])
                line.addArrangedSubview(card)
            }
            grid.addArrangedSubview(line)
        }

        let guideHead = UILabel()
        guideHead.text = "Where coins go"
        guideHead.font = AfterHoursType.foyerPill(16)
        guideHead.textColor = .white
        guideHead.translatesAutoresizingMaskIntoConstraints = false
        let guide = UIStackView()
        guide.axis = .vertical
        guide.spacing = 8
        guide.translatesAutoresizingMaskIntoConstraints = false
        for item in NightSocialLampStore.spendGuide {
            let row = UILabel()
            row.text = "\(item.0)  ·  \(item.1)"
            row.font = AfterHoursType.foyerCaption(13)
            row.textColor = UIColor.white.withAlphaComponent(0.78)
            row.numberOfLines = 0
            guide.addArrangedSubview(row)
        }

        busy.hidesWhenStopped = true
        busy.color = .white
        busy.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(scroller)
        scroller.addSubview(banner)
        banner.addSubview(coinLine)
        banner.addSubview(pursePlate)
        banner.addSubview(hint)
        banner.addSubview(gem)
        scroller.addSubview(grid)
        scroller.addSubview(guideHead)
        scroller.addSubview(guide)
        view.addSubview(busy)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            scroller.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 8),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            banner.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 8),
            banner.heightAnchor.constraint(equalToConstant: 118),
            coinLine.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            coinLine.topAnchor.constraint(equalTo: banner.topAnchor, constant: 14),
            pursePlate.leadingAnchor.constraint(equalTo: coinLine.leadingAnchor),
            pursePlate.topAnchor.constraint(equalTo: coinLine.bottomAnchor, constant: 4),
            hint.leadingAnchor.constraint(equalTo: coinLine.leadingAnchor),
            hint.trailingAnchor.constraint(equalTo: gem.leadingAnchor, constant: -8),
            hint.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12),
            gem.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16),
            gem.centerYAnchor.constraint(equalTo: banner.centerYAnchor),
            gem.widthAnchor.constraint(equalToConstant: 56),
            gem.heightAnchor.constraint(equalToConstant: 56),
            grid.leadingAnchor.constraint(equalTo: banner.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: banner.trailingAnchor),
            grid.topAnchor.constraint(equalTo: banner.bottomAnchor, constant: 16),
            guideHead.leadingAnchor.constraint(equalTo: banner.leadingAnchor),
            guideHead.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 22),
            guide.leadingAnchor.constraint(equalTo: banner.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: banner.trailingAnchor),
            guide.topAnchor.constraint(equalTo: guideHead.bottomAnchor, constant: 8),
            guide.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -28),
            busy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            busy.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(paintPurse), name: .deskDrawerDidChange, object: nil)
        paintPurse()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func paintPurse() {
        pursePlate.text = "\(NightSocialSessionDrawer.shared.diamondPurse)"
    }

    @objc private func buyPack(_ sender: UIControl) {
        let packs = NightSocialLampPack.allCases
        guard sender.tag < packs.count else { return }
        let pack = packs[sender.tag]
        busy.startAnimating()
        view.isUserInteractionEnabled = false
        Task { @MainActor in
            do {
                try await NightSocialLampStore.buy(pack)
                paintPurse()
                FoyerNotice.present(
                    on: self,
                    spokenTitle: "\(pack.spokenTitle) landed",
                    spokenBody: "\(pack.coins) night coins are on this desk now."
                )
            } catch NightSocialLampStoreIssue.cancelled {
                breakBusy()
                return
            } catch {
                FoyerNotice.present(
                    on: self,
                    spokenTitle: "The lamp held back",
                    spokenBody: error.localizedDescription
                )
            }
            breakBusy()
        }
    }

    private func breakBusy() {
        busy.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

final class NightSocialMirrorEditBoard: UIViewController, PHPickerViewControllerDelegate {
    private let nameField = FoyerLonelySnowField(whisper: "Please enter the name...")
    private let cover = UIImageView()
    private var pickingCover = true
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Edit Profile"
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
        cover.image = NightSocialMediaAssets.localCover(size: CGSize(width: 420, height: 520))
        let hint = UILabel()
        hint.text = "Change the background image"
        hint.font = AfterHoursType.foyerBody(14)
        hint.textColor = UIColor.white.withAlphaComponent(0.7)
        hint.translatesAutoresizingMaskIntoConstraints = false
        nameField.text = NightSocialSessionDrawer.shared.restoredSession()?.nightAlias
        let slot = UIButton(type: .custom)
        slot.backgroundColor = AfterHoursPalette.loungeCard
        slot.layer.cornerRadius = 16
        slot.setImage(NightSocialMediaAssets.localPortrait(size: CGSize(width: 120, height: 120)), for: .normal)
        slot.imageView?.contentMode = .scaleAspectFill
        slot.clipsToBounds = true
        slot.accessibilityLabel = "Change profile photo"
        slot.titleLabel?.font = AfterHoursType.foyerHeadline(28)
        slot.addTarget(self, action: #selector(pickPortrait), for: .touchUpInside)
        slot.translatesAutoresizingMaskIntoConstraints = false
        let save = NightSocialLoungeChrome.pinkPill(title: "Save")
        save.addTarget(self, action: #selector(saveTap), for: .touchUpInside)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(cover)
        cover.addSubview(hint)
        view.addSubview(nameField)
        view.addSubview(slot)
        view.addSubview(save)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cover.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 16),
            cover.heightAnchor.constraint(equalToConstant: 160),
            hint.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            hint.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
            nameField.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            nameField.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 16),
            slot.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            slot.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            slot.widthAnchor.constraint(equalToConstant: 88),
            slot.heightAnchor.constraint(equalToConstant: 88),
            save.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            save.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            save.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
        ])
    }
    @objc private func fold() { navigationController?.popViewController(animated: true) }
    @objc private func pickCover() { pickingCover = true; openPicker() }
    @objc private func pickPortrait() { pickingCover = false; openPicker() }
    private func openPicker() {
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
            guard let image = object as? UIImage, let self else { return }
            DispatchQueue.main.async {
                if self.pickingCover {
                    self.cover.image = image
                    NightSocialSessionDrawer.shared.writeCover(image)
                } else {
                    NightSocialSessionDrawer.shared.finishDeskCard(
                        nightAlias: NightSocialSessionDrawer.shared.restoredSession()?.nightAlias ?? "Night guest",
                        nightSignature: NightSocialSessionDrawer.shared.restoredSession()?.nightSignature ?? "",
                        portrait: image
                    )
                }
            }
        }
    }
    @objc private func saveTap() {
        let name = NightSocialFoyerGuard.trimmed(nameField.text)
        if name.isEmpty {
            FoyerNotice.present(on: self, spokenTitle: "Name still empty", spokenBody: "Write a name for this night desk before saving.")
            return
        }
        NightSocialSessionDrawer.shared.finishDeskCard(
            nightAlias: name,
            nightSignature: NightSocialSessionDrawer.shared.restoredSession()?.nightSignature ?? "",
            portrait: NightSocialSessionDrawer.shared.loadPortrait()
        )
        navigationController?.popViewController(animated: true)
    }
}
