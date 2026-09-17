import UIKit

enum NightSocialLoungeChrome {
    static func backControl() -> UIButton {
        let control = UIButton(type: .custom)
        control.setImage(NightSocialImageCabinet.named("BackIcon", fallback: "BackIcon"), for: .normal)
        control.imageView?.contentMode = .scaleAspectFit
        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(equalToConstant: 36).isActive = true
        control.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return control
    }

    static func iconControl(catalog: String, fallback: String, edge: CGFloat = 36) -> UIButton {
        let control = UIButton(type: .custom)
        control.setImage(NightSocialImageCabinet.named(catalog, fallback: fallback), for: .normal)
        control.imageView?.contentMode = .scaleAspectFit
        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(equalToConstant: edge).isActive = true
        control.heightAnchor.constraint(equalToConstant: edge).isActive = true
        return control
    }

    static func mintLevelPlate(_ level: Int) -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let cloth = UIImageView(image: NightSocialImageCabinet.named("LevelBadge", fallback: "LevelBadge"))
        cloth.contentMode = .scaleToFill
        cloth.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = "Lv.\(level)"
        plate.textColor = AfterHoursPalette.inkOnSnow
        plate.font = AfterHoursType.foyerCaption(10)
        plate.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(cloth)
        wrap.addSubview(plate)
        NSLayoutConstraint.activate([
            wrap.widthAnchor.constraint(equalToConstant: 52),
            wrap.heightAnchor.constraint(equalToConstant: 18),
            cloth.topAnchor.constraint(equalTo: wrap.topAnchor),
            cloth.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            cloth.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            cloth.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            plate.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            plate.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
        ])
        return wrap
    }

    static func pinkPill(title: String) -> UIButton {
        let pill = UIButton(type: .custom)
        pill.setTitle(title, for: .normal)
        pill.setTitleColor(.white, for: .normal)
        pill.titleLabel?.font = AfterHoursType.foyerPill(14)
        pill.backgroundColor = AfterHoursPalette.loungePink
        pill.layer.cornerRadius = 18
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return pill
    }

    static func emptyPane(spoken: String) -> UIView {
        NightSocialEmptyPane(spoken: spoken)
    }

    static func ghostPill(title: String) -> UIButton {
        let pill = UIButton(type: .custom)
        pill.setTitle(title, for: .normal)
        pill.setTitleColor(.white, for: .normal)
        pill.titleLabel?.font = AfterHoursType.foyerPill(14)
        pill.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        pill.layer.cornerRadius = 18
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return pill
    }
}

final class NightSocialDiamondAmount: UIStackView {
    private let gem = UIImageView(image: NightSocialImageCabinet.named("DiamondIcon"))
    private let plate = UILabel()

    init(font: UIFont, gemSize: CGFloat = 12, color: UIColor = .white) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        spacing = 3
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        gem.contentMode = .scaleAspectFit
        gem.translatesAutoresizingMaskIntoConstraints = false
        gem.widthAnchor.constraint(equalToConstant: gemSize).isActive = true
        gem.heightAnchor.constraint(equalToConstant: gemSize).isActive = true
        plate.font = font
        plate.textColor = color
        addArrangedSubview(gem)
        addArrangedSubview(plate)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func paint(_ amount: Int) {
        plate.text = "\(amount)"
    }
}

final class NightSocialEmptyPane: UIView {
    init(spoken: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        let mascot = UIImageView(image: NightSocialImageCabinet.named("EmptyMascot", fallback: "EmptyMascot"))
        mascot.contentMode = .scaleAspectFit
        mascot.translatesAutoresizingMaskIntoConstraints = false
        let plate = UILabel()
        plate.text = spoken
        plate.font = AfterHoursType.foyerBody(14)
        plate.textColor = UIColor.white.withAlphaComponent(0.62)
        plate.textAlignment = .center
        plate.numberOfLines = 0
        plate.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mascot)
        addSubview(plate)
        NSLayoutConstraint.activate([
            mascot.topAnchor.constraint(equalTo: topAnchor),
            mascot.centerXAnchor.constraint(equalTo: centerXAnchor),
            mascot.widthAnchor.constraint(equalToConstant: 140),
            mascot.heightAnchor.constraint(equalToConstant: 130),
            plate.topAnchor.constraint(equalTo: mascot.bottomAnchor, constant: 12),
            plate.leadingAnchor.constraint(equalTo: leadingAnchor),
            plate.trailingAnchor.constraint(equalTo: trailingAnchor),
            plate.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(equalToConstant: 280),
        ])
    }

    required init?(coder: NSCoder) { nil }
}
