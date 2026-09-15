import UIKit

enum NightSocialLoungeChrome {
    static func backControl() -> UIButton {
        let control = UIButton(type: .custom)
        control.setImage(NightSocialImageCabinet.named("LoungeBackMark", fallback: "Frame@2x(41)"), for: .normal)
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
        let cloth = UIImageView(image: NightSocialImageCabinet.named("LoungeLevelCapsule", fallback: "Rectangle_1276"))
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
