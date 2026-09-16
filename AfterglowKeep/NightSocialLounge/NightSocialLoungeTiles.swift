import UIKit

final class LoungeCreatorTile: UICollectionViewCell {
    static let reuseId = "LoungeCreatorTile"
    private let cover = UIImageView()
    private let dim = UIView()
    private let hotMark = UIImageView()
    private let likePlate = UILabel()
    private let namePlate = UILabel()
    private let cityPlate = UILabel()
    private let tagPlate = UILabel()
    private let playMark = UIImageView()
    private var levelWrap: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        cover.contentMode = .scaleAspectFill
        cover.translatesAutoresizingMaskIntoConstraints = false
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        dim.translatesAutoresizingMaskIntoConstraints = false
        hotMark.image = NightSocialImageCabinet.named("LoungeHotBadge", fallback: "Group_734")
        hotMark.contentMode = .scaleAspectFit
        hotMark.translatesAutoresizingMaskIntoConstraints = false
        likePlate.font = AfterHoursType.foyerCaption(10)
        likePlate.textColor = .white
        likePlate.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(13)
        namePlate.textColor = .white
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        cityPlate.font = AfterHoursType.foyerCaption(10)
        cityPlate.textColor = UIColor.white.withAlphaComponent(0.85)
        cityPlate.translatesAutoresizingMaskIntoConstraints = false
        tagPlate.font = AfterHoursType.foyerCaption(10)
        tagPlate.textColor = AfterHoursPalette.loungePink
        tagPlate.translatesAutoresizingMaskIntoConstraints = false
        playMark.image = UIImage(systemName: "play.rectangle.fill")
        playMark.tintColor = .white
        playMark.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cover)
        contentView.addSubview(dim)
        contentView.addSubview(hotMark)
        contentView.addSubview(likePlate)
        contentView.addSubview(namePlate)
        contentView.addSubview(cityPlate)
        contentView.addSubview(tagPlate)
        contentView.addSubview(playMark)
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: contentView.topAnchor),
            cover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dim.topAnchor.constraint(equalTo: contentView.topAnchor),
            dim.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hotMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hotMark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hotMark.heightAnchor.constraint(equalToConstant: 18),
            hotMark.widthAnchor.constraint(equalToConstant: 44),
            likePlate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            likePlate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            playMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            playMark.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            playMark.widthAnchor.constraint(equalToConstant: 18),
            playMark.heightAnchor.constraint(equalToConstant: 14),
            tagPlate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tagPlate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cityPlate.leadingAnchor.constraint(equalTo: tagPlate.leadingAnchor),
            cityPlate.bottomAnchor.constraint(equalTo: tagPlate.topAnchor, constant: -2),
            namePlate.leadingAnchor.constraint(equalTo: tagPlate.leadingAnchor),
            namePlate.bottomAnchor.constraint(equalTo: cityPlate.topAnchor, constant: -2),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ desk: LoungeCreatorDesk) {
        cover.image = NightSocialMediaAssets.cover(for: desk.deskKey, size: CGSize(width: 320, height: 420))
        hotMark.isHidden = !desk.isHot
        likePlate.text = "♡ \(desk.likeCount)"
        namePlate.text = desk.spokenName
        cityPlate.text = desk.cityLabel
        tagPlate.text = desk.vibeTags.first ?? "NightDesk"
        levelWrap?.removeFromSuperview()
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)
        levelWrap = level
        contentView.addSubview(level)
        NSLayoutConstraint.activate([
            level.leadingAnchor.constraint(equalTo: namePlate.trailingAnchor, constant: 6),
            level.centerYAnchor.constraint(equalTo: namePlate.centerYAnchor),
        ])
    }
}

final class LoungeBoothTile: UICollectionViewCell {
    static let reuseId = "LoungeBoothTile"
    private let thumb = UIImageView()
    private let liveMark = UIImageView()
    private let titlePlate = UILabel()
    private let moodPlate = UILabel()
    private let hostPlate = UILabel()
    private let metaPlate = UILabel()
    private let tagA = UILabel()
    private let tagB = UILabel()
    private let watchPlate = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AfterHoursPalette.loungeCard
        contentView.layer.cornerRadius = 18
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 14
        thumb.translatesAutoresizingMaskIntoConstraints = false
        liveMark.image = NightSocialImageCabinet.named("LoungeLiveBadge", fallback: "Group_668@2x(1)")
        liveMark.contentMode = .scaleAspectFit
        liveMark.translatesAutoresizingMaskIntoConstraints = false
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textColor = .white
        titlePlate.translatesAutoresizingMaskIntoConstraints = false
        moodPlate.font = AfterHoursType.foyerCaption(12)
        moodPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        moodPlate.translatesAutoresizingMaskIntoConstraints = false
        hostPlate.font = AfterHoursType.foyerBody(13, weight: .semibold)
        hostPlate.textColor = .white
        hostPlate.translatesAutoresizingMaskIntoConstraints = false
        metaPlate.font = AfterHoursType.foyerCaption(11)
        metaPlate.textColor = UIColor.white.withAlphaComponent(0.7)
        metaPlate.translatesAutoresizingMaskIntoConstraints = false
        tagA.font = AfterHoursType.foyerCaption(10)
        tagA.textColor = AfterHoursPalette.loungePink
        tagA.translatesAutoresizingMaskIntoConstraints = false
        tagB.font = AfterHoursType.foyerCaption(10)
        tagB.textColor = AfterHoursPalette.loungePink
        tagB.translatesAutoresizingMaskIntoConstraints = false
        watchPlate.font = AfterHoursType.foyerCaption(11)
        watchPlate.textColor = .white
        watchPlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumb)
        contentView.addSubview(liveMark)
        contentView.addSubview(titlePlate)
        contentView.addSubview(moodPlate)
        contentView.addSubview(hostPlate)
        contentView.addSubview(metaPlate)
        contentView.addSubview(tagA)
        contentView.addSubview(tagB)
        contentView.addSubview(watchPlate)
        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            thumb.widthAnchor.constraint(equalToConstant: 92),
            liveMark.leadingAnchor.constraint(equalTo: thumb.leadingAnchor, constant: 6),
            liveMark.bottomAnchor.constraint(equalTo: thumb.bottomAnchor, constant: -6),
            liveMark.heightAnchor.constraint(equalToConstant: 18),
            liveMark.widthAnchor.constraint(equalToConstant: 44),
            titlePlate.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            titlePlate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            moodPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            moodPlate.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 2),
            hostPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            hostPlate.topAnchor.constraint(equalTo: moodPlate.bottomAnchor, constant: 8),
            metaPlate.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            metaPlate.topAnchor.constraint(equalTo: hostPlate.bottomAnchor, constant: 2),
            tagA.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            tagA.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            tagB.leadingAnchor.constraint(equalTo: tagA.trailingAnchor, constant: 8),
            tagB.centerYAnchor.constraint(equalTo: tagA.centerYAnchor),
            watchPlate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            watchPlate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ booth: LoungeLiveBooth) {
        thumb.image = NightSocialMediaAssets.cover(for: booth.hostDeskKey, size: CGSize(width: 200, height: 240))
        titlePlate.text = booth.boothTitle
        moodPlate.text = booth.moodLine
        hostPlate.text = booth.hostSpokenName
        metaPlate.text = "\(booth.hostAge) · \(booth.hostCity)"
        tagA.text = booth.vibeTags.first
        tagB.text = booth.vibeTags.dropFirst().first
        watchPlate.text = "♡ \(booth.watcherCount)"
    }
}

final class LoungeClipTile: UICollectionViewCell {
    static let reuseId = "LoungeClipTile"
    private let cover = UIImageView()
    private let playDisc = UIImageView()
    private let captionPlate = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        cover.contentMode = .scaleAspectFill
        cover.translatesAutoresizingMaskIntoConstraints = false
        playDisc.image = UIImage(systemName: "play.circle.fill")
        playDisc.tintColor = .white
        playDisc.translatesAutoresizingMaskIntoConstraints = false
        captionPlate.font = AfterHoursType.foyerCaption(11)
        captionPlate.textColor = .white
        captionPlate.numberOfLines = 3
        captionPlate.backgroundColor = AfterHoursPalette.loungePink.withAlphaComponent(0.92)
        captionPlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cover)
        contentView.addSubview(playDisc)
        contentView.addSubview(captionPlate)
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: contentView.topAnchor),
            cover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playDisc.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playDisc.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -12),
            playDisc.widthAnchor.constraint(equalToConstant: 36),
            playDisc.heightAnchor.constraint(equalToConstant: 36),
            captionPlate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            captionPlate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            captionPlate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ clip: LoungeClipReel, musicMode: Bool) {
        cover.image = NightSocialMediaAssets.clipCover(clip.clipKey, size: CGSize(width: 320, height: 400))
        captionPlate.text = "  " + (musicMode ? clip.musicTitle : clip.caption) + "  "
    }
}
