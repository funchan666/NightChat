import UIKit

final class NightSocialStageGlyph: UIControl {
    private let mark = UIImageView()
    private let idlePicture: UIImage?
    private let litPicture: UIImage?

    var glowing: Bool = false {
        didSet { mark.image = glowing ? litPicture : idlePicture }
    }

    init(idlePicture: UIImage?, litPicture: UIImage?) {
        self.idlePicture = idlePicture
        self.litPicture = litPicture
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        mark.image = idlePicture
        mark.contentMode = .scaleAspectFit
        mark.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mark)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 30),
            heightAnchor.constraint(equalToConstant: 30),
            mark.centerXAnchor.constraint(equalTo: centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 30),
            mark.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

final class NightSocialStageDock: UIView {
    var onPickLane: ((Int) -> Void)?

    private let glyphs: [NightSocialStageGlyph]

    override init(frame: CGRect) {
        let house = NightSocialStageGlyph(
            idlePicture: NightSocialImageCabinet.dockHouse(lit: false),
            litPicture: NightSocialImageCabinet.dockHouse(lit: true)
        )
        let wave = NightSocialStageGlyph(
            idlePicture: NightSocialImageCabinet.dockWave(lit: false),
            litPicture: NightSocialImageCabinet.dockWave(lit: true)
        )
        let chime = NightSocialStageGlyph(
            idlePicture: NightSocialImageCabinet.dockChime(lit: false),
            litPicture: NightSocialImageCabinet.dockChime(lit: true)
        )
        let smile = NightSocialStageGlyph(
            idlePicture: NightSocialImageCabinet.dockSmile(lit: false),
            litPicture: NightSocialImageCabinet.dockSmile(lit: true)
        )
        glyphs = [house, wave, chime, smile]
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AfterHoursPalette.stageDockPlum
        layer.cornerRadius = 30
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .fill
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 83),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for (index, glyph) in glyphs.enumerated() {
            glyph.isUserInteractionEnabled = false
            let well = UIControl()
            well.tag = index
            well.translatesAutoresizingMaskIntoConstraints = false
            well.addTarget(self, action: #selector(pickGlyph(_:)), for: .touchUpInside)
            well.addSubview(glyph)
            NSLayoutConstraint.activate([
                glyph.centerXAnchor.constraint(equalTo: well.centerXAnchor),
                glyph.topAnchor.constraint(equalTo: well.topAnchor, constant: 16),
            ])
            row.addArrangedSubview(well)
        }
        lightLane(0)
    }

    required init?(coder: NSCoder) { nil }

    func lightLane(_ index: Int) {
        for (offset, glyph) in glyphs.enumerated() {
            glyph.glowing = offset == index
        }
    }

    @objc private func pickGlyph(_ sender: UIControl) {
        lightLane(sender.tag)
        onPickLane?(sender.tag)
    }
}
