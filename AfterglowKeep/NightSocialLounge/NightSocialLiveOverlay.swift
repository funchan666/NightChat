import UIKit

extension Notification.Name {
    static let liveGiftOffered = Notification.Name("lampdesk.afterglow.liveGift.offered")
}

final class LiveDanmakuLane: UIView {
    func fire(_ text: String) {
        guard bounds.width > 1 else { return }
        let plate = UILabel()
        plate.text = text
        plate.font = AfterHoursType.foyerCaption(13)
        plate.textColor = .white
        plate.layer.shadowColor = UIColor.black.cgColor
        plate.layer.shadowOpacity = 0.85
        plate.layer.shadowRadius = 3
        plate.layer.shadowOffset = CGSize(width: 0, height: 1)
        plate.sizeToFit()
        let lane = CGFloat(Int.random(in: 0..<3))
        plate.frame.origin = CGPoint(x: bounds.width + 12, y: 4 + lane * 34)
        addSubview(plate)
        UIView.animate(
            withDuration: Double.random(in: 5.8...7.6),
            delay: 0,
            options: [.curveLinear, .allowUserInteraction]
        ) {
            plate.frame.origin.x = -plate.bounds.width - 16
        } completion: { _ in
            plate.removeFromSuperview()
        }
    }
}

final class LiveGiftRibbon: UIView {
    private let pic = UIImageView()
    private let plate = UILabel()
    private let glyph = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.42)
        layer.cornerRadius = 20
        clipsToBounds = true
        alpha = 0
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.layer.cornerRadius = 16
        pic.translatesAutoresizingMaskIntoConstraints = false
        plate.font = AfterHoursType.foyerCaption(12)
        plate.textColor = .white
        plate.translatesAutoresizingMaskIntoConstraints = false
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pic)
        addSubview(plate)
        addSubview(glyph)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            pic.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            pic.centerYAnchor.constraint(equalTo: centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 32),
            pic.heightAnchor.constraint(equalToConstant: 32),
            glyph.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            glyph.centerYAnchor.constraint(equalTo: centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 28),
            glyph.heightAnchor.constraint(equalToConstant: 28),
            plate.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 8),
            plate.trailingAnchor.constraint(equalTo: glyph.leadingAnchor, constant: -8),
            plate.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func reveal(speaker: String, giftTitle: String, quantity: Int, portrait: UIImage?, glyphImage: UIImage?) {
        pic.image = portrait
        plate.text = "\(speaker) sent \(giftTitle)×\(quantity)"
        glyph.image = glyphImage
        layer.removeAllAnimations()
        alpha = 0
        transform = CGAffineTransform(translationX: -70, y: 0)
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.transform = .identity
        }
        UIView.animate(withDuration: 0.28, delay: 2.3, options: [.curveEaseIn]) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: -40, y: 0)
        }
    }
}

final class LiveChatLineCell: UITableViewCell {
    static let reuseId = "LiveChatLineCell"
    private let pill = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        pill.font = AfterHoursType.foyerCaption(12)
        pill.textColor = .white
        pill.numberOfLines = 0
        pill.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        pill.layer.cornerRadius = 10
        pill.clipsToBounds = true
        pill.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            pill.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            pill.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ line: LoungeDiscussLine) {
        pill.text = "  \(line.speakerName): \(line.spokenBody)  "
    }
}

final class LiveRankRow: UITableViewCell {
    static let reuseId = "LiveRankRow"
    private let rankDisc = UILabel()
    private let pic = UIImageView()
    private let namePlate = UILabel()
    private let scorePlate = UILabel()
    private let card = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        rankDisc.font = AfterHoursType.foyerPill(13)
        rankDisc.textAlignment = .center
        rankDisc.layer.cornerRadius = 12
        rankDisc.clipsToBounds = true
        rankDisc.translatesAutoresizingMaskIntoConstraints = false
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.layer.cornerRadius = 20
        pic.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        scorePlate.font = AfterHoursType.foyerCaption(12)
        scorePlate.textColor = UIColor.white.withAlphaComponent(0.72)
        scorePlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.addSubview(rankDisc)
        card.addSubview(pic)
        card.addSubview(namePlate)
        card.addSubview(scorePlate)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            rankDisc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            rankDisc.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            rankDisc.widthAnchor.constraint(equalToConstant: 24),
            rankDisc.heightAnchor.constraint(equalToConstant: 24),
            pic.leadingAnchor.constraint(equalTo: rankDisc.trailingAnchor, constant: 10),
            pic.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 40),
            pic.heightAnchor.constraint(equalToConstant: 40),
            namePlate.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            namePlate.trailingAnchor.constraint(equalTo: scorePlate.leadingAnchor, constant: -8),
            namePlate.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            scorePlate.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            scorePlate.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(rank: Int, desk: LoungeCreatorDesk) {
        rankDisc.text = "\(rank)"
        pic.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 80, height: 80))
        namePlate.text = desk.spokenName
        scorePlate.text = "◆ \(desk.activityScore)"
        switch rank {
        case 1:
            rankDisc.backgroundColor = UIColor(red: 1.00, green: 0.82, blue: 0.28, alpha: 1)
            rankDisc.textColor = AfterHoursPalette.inkOnSnow
        case 2:
            rankDisc.backgroundColor = UIColor(red: 0.78, green: 0.82, blue: 0.90, alpha: 1)
            rankDisc.textColor = AfterHoursPalette.inkOnSnow
        case 3:
            rankDisc.backgroundColor = UIColor(red: 0.90, green: 0.58, blue: 0.32, alpha: 1)
            rankDisc.textColor = .white
        default:
            rankDisc.backgroundColor = UIColor.white.withAlphaComponent(0.16)
            rankDisc.textColor = .white
        }
    }
}
