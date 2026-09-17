import UIKit

final class NightSocialCrownBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Span: Int { case daily, weekly, monthly }
    private var span: Span = .daily
    private let table = UITableView()
    private var rows: [LoungeCreatorDesk] = []
    private let spanRow = UIStackView()
    private let podium = UIView()
    private var podiumSeats: [CrownPodiumSeat] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false

        let wash = UIImageView(image: NightSocialImageCabinet.named("RankBackground", fallback: "RankBackground"))
        wash.contentMode = .scaleAspectFill
        wash.clipsToBounds = true
        wash.translatesAutoresizingMaskIntoConstraints = false

        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let title = UILabel()
        title.text = "Activity"
        title.font = AfterHoursType.foyerHeadline(22)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false

        spanRow.axis = .horizontal
        spanRow.spacing = 8
        spanRow.translatesAutoresizingMaskIntoConstraints = false
        for item in [("Daily", 0), ("Weekly", 1), ("Monthly", 2)] {
            let chip = UIButton(type: .custom)
            chip.setTitle("  \(item.0)  ", for: .normal)
            chip.titleLabel?.font = AfterHoursType.foyerCaption(13)
            chip.tag = item.1
            chip.layer.cornerRadius = 16
            chip.addTarget(self, action: #selector(pickSpan(_:)), for: .touchUpInside)
            chip.translatesAutoresizingMaskIntoConstraints = false
            chip.heightAnchor.constraint(equalToConstant: 32).isActive = true
            spanRow.addArrangedSubview(chip)
        }

        podium.translatesAutoresizingMaskIntoConstraints = false
        let second = CrownPodiumSeat(rank: 2)
        let first = CrownPodiumSeat(rank: 1)
        let third = CrownPodiumSeat(rank: 3)
        podiumSeats = [first, second, third]
        podium.addSubview(second)
        podium.addSubview(third)
        podium.addSubview(first)

        table.backgroundColor = .white
        table.layer.cornerRadius = 28
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.rowHeight = 76
        table.register(CrownListRow.self, forCellReuseIdentifier: CrownListRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)

        view.addSubview(wash)
        view.addSubview(back)
        view.addSubview(title)
        view.addSubview(spanRow)
        view.addSubview(podium)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            wash.topAnchor.constraint(equalTo: view.topAnchor),
            wash.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wash.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wash.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            title.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            title.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            spanRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            spanRow.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            podium.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            podium.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            podium.topAnchor.constraint(equalTo: spanRow.bottomAnchor, constant: 8),
            podium.heightAnchor.constraint(equalToConstant: 236),
            first.centerXAnchor.constraint(equalTo: podium.centerXAnchor),
            first.topAnchor.constraint(equalTo: podium.topAnchor),
            first.widthAnchor.constraint(equalToConstant: 128),
            second.leadingAnchor.constraint(equalTo: podium.leadingAnchor),
            second.trailingAnchor.constraint(equalTo: first.leadingAnchor),
            second.bottomAnchor.constraint(equalTo: podium.bottomAnchor, constant: -6),
            third.leadingAnchor.constraint(equalTo: first.trailingAnchor),
            third.trailingAnchor.constraint(equalTo: podium.trailingAnchor),
            third.bottomAnchor.constraint(equalTo: podium.bottomAnchor, constant: -6),
            table.topAnchor.constraint(equalTo: podium.bottomAnchor, constant: 4),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        reloadRanks()
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickSpan(_ sender: UIButton) {
        span = Span(rawValue: sender.tag) ?? .daily
        reloadRanks()
    }

    private func factor() -> Int {
        span == .daily ? 1 : (span == .weekly ? 4 : 12)
    }

    private func reloadRanks() {
        let mul = factor()
        rows = NightSocialLoungeCatalog.visibleCreators().sorted { $0.activityScore * mul > $1.activityScore * mul }
        for (index, chip) in spanRow.arrangedSubviews.enumerated() {
            guard let button = chip as? UIButton else { continue }
            let on = index == span.rawValue
            button.backgroundColor = on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.38)
            button.setTitleColor(on ? .white : UIColor.white.withAlphaComponent(0.92), for: .normal)
        }
        let seats = [1, 2, 3]
        for rank in seats where rank - 1 < rows.count {
            let desk = rows[rank - 1]
            let seat = podiumSeats.first { $0.rank == rank }
            seat?.paint(desk: desk, score: desk.activityScore * mul)
            seat?.onPick = { [weak self] in
                guard let self else { return }
                NightSocialDeskGate.revealDesk(from: self, deskKey: desk.deskKey)
            }
        }
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(0, rows.count - 3)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CrownListRow.reuseId, for: indexPath) as! CrownListRow
        let desk = rows[indexPath.row + 3]
        cell.paint(rank: indexPath.row + 4, desk: desk, score: desk.activityScore * factor())
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NightSocialDeskGate.revealDesk(from: self, deskKey: rows[indexPath.row + 3].deskKey)
    }
}

final class CrownPodiumSeat: UIControl {
    let rank: Int
    var onPick: (() -> Void)?
    private let pic = UIImageView()
    private let frameMark = UIImageView()
    private let namePlate = UILabel()
    private let scorePlate = UILabel()
    private let spark = UIImageView()
    private let levelHost = UIView()

    init(rank: Int) {
        self.rank = rank
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(tap), for: .touchUpInside)

        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.isUserInteractionEnabled = false
        pic.translatesAutoresizingMaskIntoConstraints = false
        frameMark.contentMode = .scaleAspectFit
        frameMark.isUserInteractionEnabled = false
        frameMark.image = Self.frameImage(rank)
        frameMark.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(rank == 1 ? 14 : 12)
        namePlate.textColor = AfterHoursPalette.inkOnSnow
        namePlate.textAlignment = .center
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        scorePlate.font = AfterHoursType.foyerPill(rank == 1 ? 15 : 13)
        scorePlate.textColor = UIColor(red: 0.95, green: 0.62, blue: 0.08, alpha: 1)
        scorePlate.textAlignment = .center
        scorePlate.translatesAutoresizingMaskIntoConstraints = false
        spark.image = NightSocialImageCabinet.named("Sparkle", fallback: "Sparkle")
        spark.contentMode = .scaleAspectFit
        spark.translatesAutoresizingMaskIntoConstraints = false
        levelHost.translatesAutoresizingMaskIntoConstraints = false

        addSubview(pic)
        addSubview(frameMark)
        addSubview(namePlate)
        addSubview(levelHost)
        addSubview(spark)
        addSubview(scorePlate)

        let frameEdge: CGFloat = rank == 1 ? 118 : 96
        let faceEdge: CGFloat = rank == 1 ? 62 : 50
        NSLayoutConstraint.activate([
            frameMark.topAnchor.constraint(equalTo: topAnchor),
            frameMark.centerXAnchor.constraint(equalTo: centerXAnchor),
            frameMark.widthAnchor.constraint(equalToConstant: frameEdge),
            frameMark.heightAnchor.constraint(equalToConstant: frameEdge),
            pic.centerXAnchor.constraint(equalTo: frameMark.centerXAnchor),
            pic.centerYAnchor.constraint(equalTo: frameMark.centerYAnchor, constant: -7),
            pic.widthAnchor.constraint(equalToConstant: faceEdge),
            pic.heightAnchor.constraint(equalToConstant: faceEdge),
            namePlate.topAnchor.constraint(equalTo: frameMark.bottomAnchor, constant: -6),
            namePlate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            namePlate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            levelHost.centerXAnchor.constraint(equalTo: centerXAnchor),
            levelHost.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
            levelHost.widthAnchor.constraint(equalToConstant: 52),
            levelHost.heightAnchor.constraint(equalToConstant: 18),
            spark.trailingAnchor.constraint(equalTo: scorePlate.leadingAnchor, constant: -3),
            spark.centerYAnchor.constraint(equalTo: scorePlate.centerYAnchor),
            spark.widthAnchor.constraint(equalToConstant: 12),
            spark.heightAnchor.constraint(equalToConstant: 12),
            scorePlate.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 7),
            scorePlate.topAnchor.constraint(equalTo: levelHost.bottomAnchor, constant: 6),
            scorePlate.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        pic.layer.cornerRadius = faceEdge / 2
    }

    required init?(coder: NSCoder) { nil }

    func paint(desk: LoungeCreatorDesk, score: Int) {
        pic.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 120, height: 120))
        namePlate.text = desk.spokenName
        scorePlate.text = Self.scorePhrase(score)
        levelHost.subviews.forEach { $0.removeFromSuperview() }
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)
        levelHost.addSubview(level)
        NSLayoutConstraint.activate([
            level.topAnchor.constraint(equalTo: levelHost.topAnchor),
            level.leadingAnchor.constraint(equalTo: levelHost.leadingAnchor),
            level.trailingAnchor.constraint(equalTo: levelHost.trailingAnchor),
            level.bottomAnchor.constraint(equalTo: levelHost.bottomAnchor),
        ])
    }

    @objc private func tap() { onPick?() }

    private static func frameImage(_ rank: Int) -> UIImage? {
        switch rank {
        case 1: return NightSocialImageCabinet.named("RankFrameGold", fallback: "RankFrameGold")
        case 2: return NightSocialImageCabinet.named("RankFrameSilver", fallback: "RankFrameSilver")
        default: return NightSocialImageCabinet.named("RankFrameBronze", fallback: "RankFrameBronze")
        }
    }

    private static func scorePhrase(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.2fK", Double(n) / 1000.0) }
        return "\(n)"
    }
}

final class CrownListRow: UITableViewCell {
    static let reuseId = "CrownListRow"
    private let rankDisc = UILabel()
    private let pic = UIImageView()
    private let namePlate = UILabel()
    private let scorePlate = UILabel()
    private let spark = UIImageView()
    private var levelWrap: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        rankDisc.font = AfterHoursType.foyerPill(13)
        rankDisc.textAlignment = .center
        rankDisc.textColor = AfterHoursPalette.inkOnSnow
        rankDisc.backgroundColor = UIColor(red: 1.00, green: 0.82, blue: 0.28, alpha: 1)
        rankDisc.layer.cornerRadius = 14
        rankDisc.clipsToBounds = true
        rankDisc.translatesAutoresizingMaskIntoConstraints = false
        pic.contentMode = .scaleAspectFill
        pic.clipsToBounds = true
        pic.layer.cornerRadius = 22
        pic.layer.borderWidth = 2
        pic.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        pic.translatesAutoresizingMaskIntoConstraints = false
        namePlate.font = AfterHoursType.foyerPill(15)
        namePlate.textColor = AfterHoursPalette.inkOnSnow
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        scorePlate.font = AfterHoursType.foyerPill(14)
        scorePlate.textColor = UIColor(red: 0.95, green: 0.62, blue: 0.08, alpha: 1)
        scorePlate.translatesAutoresizingMaskIntoConstraints = false
        spark.image = NightSocialImageCabinet.named("Sparkle", fallback: "Sparkle")
        spark.contentMode = .scaleAspectFit
        spark.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rankDisc)
        contentView.addSubview(pic)
        contentView.addSubview(namePlate)
        contentView.addSubview(spark)
        contentView.addSubview(scorePlate)
        NSLayoutConstraint.activate([
            rankDisc.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankDisc.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankDisc.widthAnchor.constraint(equalToConstant: 28),
            rankDisc.heightAnchor.constraint(equalToConstant: 28),
            pic.leadingAnchor.constraint(equalTo: rankDisc.trailingAnchor, constant: 12),
            pic.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pic.widthAnchor.constraint(equalToConstant: 44),
            pic.heightAnchor.constraint(equalToConstant: 44),
            namePlate.leadingAnchor.constraint(equalTo: pic.trailingAnchor, constant: 10),
            namePlate.topAnchor.constraint(equalTo: pic.topAnchor, constant: 2),
            spark.trailingAnchor.constraint(equalTo: scorePlate.leadingAnchor, constant: -4),
            spark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spark.widthAnchor.constraint(equalToConstant: 12),
            spark.heightAnchor.constraint(equalToConstant: 12),
            scorePlate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            scorePlate.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(rank: Int, desk: LoungeCreatorDesk, score: Int) {
        rankDisc.text = "\(rank)"
        pic.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 88, height: 88))
        namePlate.text = desk.spokenName
        scorePlate.text = score >= 1000 ? String(format: "%.2fK", Double(score) / 1000.0) : "\(score)"
        levelWrap?.removeFromSuperview()
        let level = NightSocialLoungeChrome.mintLevelPlate(desk.levelMark)
        levelWrap = level
        contentView.addSubview(level)
        NSLayoutConstraint.activate([
            level.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            level.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 4),
        ])
    }
}
