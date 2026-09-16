import UIKit

final class NightSocialCovenantBar: UIView, UITextViewDelegate {
    var houseAccepted: Bool { markControl.isSelected }

    var onAcceptedChange: ((Bool) -> Void)?
    var onOpenHouseScroll: ((NightSocialHouseScrollKind) -> Void)?

    private let markControl = UIButton(type: .custom)
    private let spokenView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        markControl.translatesAutoresizingMaskIntoConstraints = false
        markControl.layer.cornerRadius = 11
        markControl.layer.borderWidth = 1.5
        markControl.layer.borderColor = UIColor.white.withAlphaComponent(0.92).cgColor
        markControl.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        markControl.addTarget(self, action: #selector(flipMark), for: .touchUpInside)
        paintMark()

        spokenView.backgroundColor = .clear
        spokenView.isEditable = false
        spokenView.isScrollEnabled = false
        spokenView.isSelectable = true
        spokenView.textContainerInset = .zero
        spokenView.textContainer.lineFragmentPadding = 0
        spokenView.delegate = self
        spokenView.linkTextAttributes = [
            .foregroundColor: AfterHoursPalette.titleSnow,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: AfterHoursType.foyerBody(12, weight: .semibold),
        ]
        spokenView.attributedText = Self.makeSpokenCloth()
        spokenView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(markControl)
        addSubview(spokenView)
        NSLayoutConstraint.activate([
            markControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            markControl.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            markControl.widthAnchor.constraint(equalToConstant: 22),
            markControl.heightAnchor.constraint(equalToConstant: 22),

            spokenView.leadingAnchor.constraint(equalTo: markControl.trailingAnchor, constant: 10),
            spokenView.trailingAnchor.constraint(equalTo: trailingAnchor),
            spokenView.topAnchor.constraint(equalTo: topAnchor),
            spokenView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func applyAccepted(_ flag: Bool) {
        markControl.isSelected = flag
        paintMark()
    }

    @objc private func flipMark() {
        markControl.isSelected.toggle()
        paintMark()
        onAcceptedChange?(markControl.isSelected)
    }

    private func paintMark() {
        if markControl.isSelected {
            markControl.backgroundColor = AfterHoursPalette.snowCard
            markControl.setImage(
                UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)),
                for: .normal
            )
            markControl.tintColor = AfterHoursPalette.magentaPeak
            markControl.layer.borderColor = AfterHoursPalette.snowCard.cgColor
        } else {
            markControl.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            markControl.setImage(nil, for: .normal)
            markControl.layer.borderColor = UIColor.white.withAlphaComponent(0.92).cgColor
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "nightchat" && URL.host == "agreement" {
            onOpenHouseScroll?(.userAgreement)
            return false
        }
        if URL.scheme == "nightchat" && URL.host == "privacy" {
            onOpenHouseScroll?(.privacyCloth)
            return false
        }
        return false
    }

    private static func makeSpokenCloth() -> NSAttributedString {
        let cloth = NSMutableAttributedString(
            string: "I have read and agree to the ",
            attributes: [
                .foregroundColor: AfterHoursPalette.footerSnow,
                .font: AfterHoursType.foyerBody(12),
            ]
        )
        cloth.append(NSAttributedString(
            string: "User Agreement",
            attributes: [
                .link: URL(string: "nightchat://agreement") as Any,
                .foregroundColor: AfterHoursPalette.titleSnow,
                .font: AfterHoursType.foyerBody(12, weight: .semibold),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        ))
        cloth.append(NSAttributedString(
            string: " and ",
            attributes: [
                .foregroundColor: AfterHoursPalette.footerSnow,
                .font: AfterHoursType.foyerBody(12),
            ]
        ))
        cloth.append(NSAttributedString(
            string: "Privacy Policy",
            attributes: [
                .link: URL(string: "nightchat://privacy") as Any,
                .foregroundColor: AfterHoursPalette.titleSnow,
                .font: AfterHoursType.foyerBody(12, weight: .semibold),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        ))
        cloth.append(NSAttributedString(
            string: ".",
            attributes: [
                .foregroundColor: AfterHoursPalette.footerSnow,
                .font: AfterHoursType.foyerBody(12),
            ]
        ))
        return cloth
    }
}

extension NightSocialWashController {
    func bindHouseCovenant(_ bar: NightSocialCovenantBar) {
        bar.applyAccepted(NightSocialSessionDrawer.shared.houseCovenantAccepted)
        bar.onAcceptedChange = { NightSocialSessionDrawer.shared.rememberHouseCovenant($0) }
        bar.onOpenHouseScroll = { [weak self] kind in
            self?.present(NightSocialHouseScrollBoard(scrollKind: kind), animated: true)
        }
    }

    func requireHouseCovenant(_ bar: NightSocialCovenantBar) -> Bool {
        if bar.houseAccepted { return true }
        FoyerNotice.presentCovenantNeeded(on: self)
        return false
    }
}
