import UIKit

final class NightSocialMirrorSettingsBoard: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Settings"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let titles = ["Blacklist", "Community Rules", "Privacy agreement", "User agreement", "Deletion of account", "Log Out", "Language"]
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        for (index, title) in titles.enumerated() {
            let row = UIButton(type: .custom)
            row.backgroundColor = AfterHoursPalette.loungeCard
            row.layer.cornerRadius = 16
            row.setTitle(title, for: .normal)
            row.setTitleColor(.white, for: .normal)
            row.titleLabel?.font = AfterHoursType.foyerBody(15, weight: .semibold)
            row.contentHorizontalAlignment = .left
            row.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            row.heightAnchor.constraint(equalToConstant: 52).isActive = true
            row.tag = index
            row.addTarget(self, action: #selector(pickRow(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 20),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickRow(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            navigationController?.pushViewController(NightSocialMirrorPeopleBoard(kind: .blacklist), animated: true)
        case 1:
            navigationController?.pushViewController(NightSocialCommunityLampBoard(), animated: true)
        case 2:
            present(NightSocialHouseScrollBoard(scrollKind: .privacyCloth), animated: true)
        case 3:
            present(NightSocialHouseScrollBoard(scrollKind: .userAgreement), animated: true)
        case 4:
            confirmLeave(delete: true)
        case 5:
            confirmLeave(delete: false)
        default:
            navigationController?.pushViewController(NightSocialMirrorLanguageBoard(), animated: true)
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

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Language"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        let current = NightSocialSessionDrawer.shared.spokenTongue
        for (index, title) in tongues.enumerated() {
            let row = UIButton(type: .custom)
            row.setTitle(title, for: .normal)
            row.setTitleColor(.white, for: .normal)
            row.titleLabel?.font = AfterHoursType.foyerBody(15, weight: .semibold)
            row.layer.cornerRadius = 16
            row.heightAnchor.constraint(equalToConstant: 52).isActive = true
            row.tag = index
            row.backgroundColor = title == current ? AfterHoursPalette.loungePink : AfterHoursPalette.loungeCard
            row.addTarget(self, action: #selector(pickTongue(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
        }
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 20),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickTongue(_ sender: UIButton) {
        let title = tongues[sender.tag]
        present(NightSocialLanguageConfirm(tongue: title, host: self), animated: true)
    }

    func applyTongue(_ title: String) {
        NightSocialSessionDrawer.shared.writeSpokenTongue(title)
        view.subviews.compactMap { $0 as? UIStackView }.first?.arrangedSubviews.enumerated().forEach { index, row in
            (row as? UIButton)?.backgroundColor = tongues[index] == title ? AfterHoursPalette.loungePink : AfterHoursPalette.loungeCard
        }
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
