import UIKit

final class NightSocialCrownBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Span: Int { case daily, weekly, monthly }
    private var span: Span = .daily
    private let table = UITableView()
    private var rows: [LoungeCreatorDesk] = []
    private let spanRow = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false

        let wash = UIImageView(image: NightSocialImageCabinet.named("CrownBoardWash", fallback: "Rectangle_1291"))
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
            let chip = UIButton(type: .system)
            chip.setTitle("  \(item.0)  ", for: .normal)
            chip.tag = item.1
            chip.layer.cornerRadius = 14
            chip.addTarget(self, action: #selector(pickSpan(_:)), for: .touchUpInside)
            spanRow.addArrangedSubview(chip)
        }

        let podium = UIStackView()
        podium.axis = .horizontal
        podium.distribution = .fillEqually
        podium.alignment = .bottom
        podium.translatesAutoresizingMaskIntoConstraints = false

        table.backgroundColor = UIColor.white.withAlphaComponent(0.96)
        table.layer.cornerRadius = 24
        table.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: "crown")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.contentInsetAdjustmentBehavior = .never

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
            podium.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            podium.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            podium.topAnchor.constraint(equalTo: spanRow.bottomAnchor, constant: 12),
            podium.heightAnchor.constraint(equalToConstant: 140),
            table.topAnchor.constraint(equalTo: podium.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        self.podiumStack = podium
        reloadRanks()
    }

    private var podiumStack: UIStackView?

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    @objc private func pickSpan(_ sender: UIButton) {
        span = Span(rawValue: sender.tag) ?? .daily
        reloadRanks()
    }

    private func reloadRanks() {
        let factor = span == .daily ? 1 : (span == .weekly ? 4 : 12)
        rows = NightSocialLoungeCatalog.visibleCreators().sorted { $0.activityScore * factor > $1.activityScore * factor }
        for (index, chip) in spanRow.arrangedSubviews.enumerated() {
            guard let button = chip as? UIButton else { continue }
            let on = index == span.rawValue
            button.backgroundColor = on ? AfterHoursPalette.loungePink : UIColor.white.withAlphaComponent(0.35)
            button.setTitleColor(on ? .white : AfterHoursPalette.inkOnSnow, for: .normal)
        }
        podiumStack?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let order = [1, 0, 2]
        for index in order where index < rows.count {
            let desk = rows[index]
            let col = UIView()
            let pic = UIImageView(image: NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 100, height: 100)))
            pic.layer.cornerRadius = 28
            pic.clipsToBounds = true
            pic.translatesAutoresizingMaskIntoConstraints = false
            let name = UILabel()
            name.text = desk.spokenName
            name.font = AfterHoursType.foyerCaption(11)
            name.textColor = AfterHoursPalette.inkOnSnow
            name.textAlignment = .center
            name.translatesAutoresizingMaskIntoConstraints = false
            let score = UILabel()
            score.text = "\(desk.activityScore * factor)"
            score.font = AfterHoursType.foyerPill(12)
            score.textColor = AfterHoursPalette.loungePink
            score.textAlignment = .center
            score.translatesAutoresizingMaskIntoConstraints = false
            let tap = UIControl()
            tap.translatesAutoresizingMaskIntoConstraints = false
            tap.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                NightSocialDeskGate.revealDesk(from: self, deskKey: desk.deskKey)
            }, for: .touchUpInside)
            col.addSubview(pic)
            col.addSubview(name)
            col.addSubview(score)
            col.addSubview(tap)
            let size: CGFloat = index == 0 ? 64 : 52
            NSLayoutConstraint.activate([
                pic.centerXAnchor.constraint(equalTo: col.centerXAnchor),
                pic.topAnchor.constraint(equalTo: col.topAnchor, constant: index == 0 ? 0 : 16),
                pic.widthAnchor.constraint(equalToConstant: size),
                pic.heightAnchor.constraint(equalToConstant: size),
                name.topAnchor.constraint(equalTo: pic.bottomAnchor, constant: 6),
                name.centerXAnchor.constraint(equalTo: col.centerXAnchor),
                score.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2),
                score.centerXAnchor.constraint(equalTo: col.centerXAnchor),
                tap.topAnchor.constraint(equalTo: col.topAnchor),
                tap.leadingAnchor.constraint(equalTo: col.leadingAnchor),
                tap.trailingAnchor.constraint(equalTo: col.trailingAnchor),
                tap.bottomAnchor.constraint(equalTo: col.bottomAnchor),
            ])
            podiumStack?.addArrangedSubview(col)
        }
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(0, rows.count - 3)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crown", for: indexPath)
        let desk = rows[indexPath.row + 3]
        cell.backgroundColor = .clear
        cell.textLabel?.text = "\(indexPath.row + 4)   \(desk.spokenName)"
        cell.detailTextLabel?.text = nil
        cell.imageView?.image = NightSocialMediaAssets.portrait(for: desk.deskKey, size: CGSize(width: 48, height: 48))
        cell.accessoryType = .none
        let score = UILabel()
        score.text = "\(desk.activityScore)"
        score.textColor = AfterHoursPalette.loungePink
        score.font = AfterHoursType.foyerPill(13)
        score.sizeToFit()
        cell.accessoryView = score
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let desk = rows[indexPath.row + 3]
        NightSocialDeskGate.revealDesk(from: self, deskKey: desk.deskKey)
    }
}
