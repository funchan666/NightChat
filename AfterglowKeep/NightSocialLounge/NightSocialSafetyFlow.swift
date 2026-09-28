import UIKit

enum NightSocialSafetyTarget {
    case desk(String)
    case clip(clipKey: String, authorDeskKey: String)
    case comment(lineKey: String, speakerDeskKey: String)

    var deskKey: String {
        switch self {
        case .desk(let key): return key
        case .clip(_, let author): return author
        case .comment(_, let speaker): return speaker
        }
    }
}

enum NightSocialReportKind: String, CaseIterable {
    case sexualContent = "Sexual content"
    case harassment = "Harassment or bullying"
    case hate = "Hate or discrimination"
    case spam = "Spam or scams"
    case impersonation = "Impersonation"
    case illegal = "Illegal activity"
    case other = "Other"
}

protocol NightSocialSafetyContent: AnyObject {
    var isHiddenBySafetyAction: Bool { get }
    func prepareForSafetyRemoval()
}

extension NightSocialSafetyContent {
    func prepareForSafetyRemoval() {}
}

enum NightSocialSafetyFlow {
    static func presentChooser(from host: UIViewController, target: NightSocialSafetyTarget) {
        let sheet = NightSocialSafetySheet(target: target)
        sheet.sourceController = host
        host.present(sheet, animated: true)
    }

    static func presentReportKinds(from host: UIViewController, target: NightSocialSafetyTarget) {
        let sheet = NightSocialReportKindBoard(target: target)
        sheet.sourceController = host
        host.present(sheet, animated: true)
    }

    static func complete(from sheet: UIViewController, source: UIViewController?,
                         blocked: Bool, save: @escaping () -> Void) {
        // UIKit may promote the presentation to a navigation controller.
        // Keep the actual content controller for the return destination.
        guard let presenter = source ?? sheet.presentingViewController else { return }
        let host = (presenter as? UINavigationController)?.visibleViewController ?? presenter
        sheet.dismiss(animated: true) {
            save()
            let finish = { returnToVisibleContent(from: host) }
            if blocked {
                NightSocialLampNotices.presentBlockSettled(from: host, then: finish)
            } else {
                NightSocialLampNotices.presentReportSettled(from: host, then: finish)
            }
        }
    }

    private static func returnToVisibleContent(from host: UIViewController) {
        let navigation = host.navigationController
            ?? (host.presentingViewController as? UINavigationController)
            ?? host.presentingViewController?.navigationController
        let finish = {
            if let navigation {
                let visible = navigation.viewControllers.filter {
                    guard let content = $0 as? NightSocialSafetyContent,
                          content.isHiddenBySafetyAction else { return true }
                    content.prepareForSafetyRemoval()
                    return false
                }
                if !visible.isEmpty, visible.count != navigation.viewControllers.count {
                    navigation.setViewControllers(visible, animated: true)
                }
            }
            NotificationCenter.default.post(name: .deskDrawerDidChange,
                                            object: NightSocialSessionDrawer.shared)
        }
        if host.navigationController == nil,
           (host as? NightSocialSafetyContent)?.isHiddenBySafetyAction == true,
           host.presentingViewController != nil {
            host.dismiss(animated: true, completion: finish)
        } else {
            finish()
        }
    }
}

final class NightSocialSafetySheet: UIViewController, UIGestureRecognizerDelegate {
    private let target: NightSocialSafetyTarget
    weak var sourceController: UIViewController?
    private var isFinishing = false
    init(target: NightSocialSafetyTarget) {
        self.target = target
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    init(deskKey: String) {
        self.target = .desk(deskKey)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        let card = UIView()
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false
        let block = UIButton(type: .custom)
        block.setImage(NightSocialImageCabinet.named("BlockIcon", fallback: "BlockIcon"), for: .normal)
        block.imageView?.contentMode = .scaleAspectFit
        block.addTarget(self, action: #selector(blockDesk), for: .touchUpInside)
        let report = UIButton(type: .custom)
        report.setImage(NightSocialImageCabinet.named("ReportIcon", fallback: "ReportIcon"), for: .normal)
        report.imageView?.contentMode = .scaleAspectFit
        report.addTarget(self, action: #selector(reportDesk), for: .touchUpInside)
        block.translatesAutoresizingMaskIntoConstraints = false
        report.translatesAutoresizingMaskIntoConstraints = false
        let row = UIStackView(arrangedSubviews: [block, report])
        row.axis = .horizontal
        row.spacing = 18
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 260),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            row.heightAnchor.constraint(equalToConstant: 92),
        ])
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(fold))
        dimTap.delegate = self
        dimTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dimTap)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === view
    }

    @objc private func fold() {
        guard !isFinishing else { return }
        dismiss(animated: true)
    }

    @objc private func blockDesk() {
        guard !isFinishing else { return }
        let key = target.deskKey
        guard !key.isEmpty else {
            dismiss(animated: true)
            return
        }
        isFinishing = true
        view.isUserInteractionEnabled = false
        NightSocialSafetyFlow.complete(from: self, source: sourceController, blocked: true) {
            NightSocialSessionDrawer.shared.blockDesk(key)
        }
    }

    @objc private func reportDesk() {
        guard !isFinishing else { return }
        isFinishing = true
        view.isUserInteractionEnabled = false
        let target = self.target
        let host = sourceController ?? presentingViewController
        dismiss(animated: true) {
            guard let host else { return }
            NightSocialSafetyFlow.presentReportKinds(from: host, target: target)
        }
    }
}

final class NightSocialReportKindBoard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let target: NightSocialSafetyTarget
    private var picked: NightSocialReportKind = .harassment
    private let table = UITableView()
    weak var sourceController: UIViewController?
    private var isFinishing = false

    init(target: NightSocialSafetyTarget) {
        self.target = target
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = "Report"
        title.font = AfterHoursType.foyerHeadline(20)
        title.textColor = AfterHoursPalette.inkOnSnow
        title.translatesAutoresizingMaskIntoConstraints = false
        let hint = UILabel()
        hint.text = "Pick why this sitting should leave your night."
        hint.font = AfterHoursType.foyerCaption(12)
        hint.textColor = AfterHoursPalette.inkOnSnow.withAlphaComponent(0.6)
        hint.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(ReportKindRow.self, forCellReuseIdentifier: ReportKindRow.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.setTitleColor(AfterHoursPalette.inkOnSnow, for: .normal)
        cancel.backgroundColor = UIColor(white: 0.92, alpha: 1)
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let go = NightSocialLoungeChrome.pinkPill(title: "Report")
        go.addTarget(self, action: #selector(submit), for: .touchUpInside)
        card.addSubview(title)
        card.addSubview(hint)
        card.addSubview(table)
        card.addSubview(cancel)
        card.addSubview(go)
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 320),
            card.heightAnchor.constraint(equalToConstant: 520),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            hint.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            hint.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            table.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            table.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            table.bottomAnchor.constraint(equalTo: go.topAnchor, constant: -12),
            cancel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            cancel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            cancel.widthAnchor.constraint(equalToConstant: 130),
            go.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            go.bottomAnchor.constraint(equalTo: cancel.bottomAnchor),
            go.widthAnchor.constraint(equalToConstant: 130),
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NightSocialReportKind.allCases.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 48 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReportKindRow.reuseId, for: indexPath) as! ReportKindRow
        let kind = NightSocialReportKind.allCases[indexPath.row]
        cell.paint(kind.rawValue, on: kind == picked)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        picked = NightSocialReportKind.allCases[indexPath.row]
        tableView.reloadData()
    }

    @objc private func fold() {
        guard !isFinishing else { return }
        dismiss(animated: true)
    }

    @objc private func submit() {
        guard !isFinishing else { return }
        isFinishing = true
        view.isUserInteractionEnabled = false
        let target = self.target
        let kind = picked
        NightSocialSafetyFlow.complete(from: self, source: sourceController, blocked: false) {
            NightSocialSessionDrawer.shared.rememberReport(target, kind: kind)
        }
    }
}

final class ReportKindRow: UITableViewCell {
    static let reuseId = "ReportKindRow"
    private let plate = UILabel()
    private let disc = UIView()
    private let inner = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        plate.font = AfterHoursType.foyerBody(15, weight: .medium)
        plate.textColor = AfterHoursPalette.inkOnSnow
        plate.translatesAutoresizingMaskIntoConstraints = false
        disc.layer.cornerRadius = 9
        disc.layer.borderWidth = 1.5
        disc.translatesAutoresizingMaskIntoConstraints = false
        inner.layer.cornerRadius = 5
        inner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plate)
        contentView.addSubview(disc)
        disc.addSubview(inner)
        NSLayoutConstraint.activate([
            plate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plate.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disc.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 18),
            disc.heightAnchor.constraint(equalToConstant: 18),
            inner.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
            inner.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            inner.widthAnchor.constraint(equalToConstant: 10),
            inner.heightAnchor.constraint(equalToConstant: 10),
        ])
    }
    required init?(coder: NSCoder) { nil }

    func paint(_ title: String, on: Bool) {
        plate.text = title
        disc.layer.borderColor = (on ? AfterHoursPalette.loungePink : UIColor(white: 0.75, alpha: 1)).cgColor
        inner.backgroundColor = on ? AfterHoursPalette.loungePink : .clear
    }
}
