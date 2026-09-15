import UIKit
import WebKit

enum NightSocialHouseScrollKind {
    case userAgreement
    case privacyCloth

    var spokenTitle: String {
        switch self {
        case .userAgreement: return "User Agreement"
        case .privacyCloth: return "Privacy Policy"
        }
    }

    var pageAddress: URL? {
        switch self {
        case .userAgreement:
            return URL(string: "https://sites.google.com/view/nightchat-terms-of-service/homeme")
        case .privacyCloth:
            return URL(string: "https://sites.google.com/view/nightchat-privacypolicy/homeme")
        }
    }
}

final class NightSocialHouseScrollBoard: NightSocialWashController, WKNavigationDelegate {
    private let scrollKind: NightSocialHouseScrollKind
    private let webPane = WKWebView(frame: .zero, configuration: NightSocialHouseScrollBoard.makeConfiguration())
    private let progressHair = UIView()
    private var progressWidth: NSLayoutConstraint?
    private var progressWatch: NSKeyValueObservation?

    init(scrollKind: NightSocialHouseScrollKind) {
        self.scrollKind = scrollKind
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        washCloth.alpha = 0.35

        webPane.navigationDelegate = self
        webPane.backgroundColor = .clear
        webPane.isOpaque = false
        webPane.scrollView.contentInsetAdjustmentBehavior = .never
        webPane.scrollView.insetsLayoutMarginsFromSafeArea = false
        webPane.allowsBackForwardNavigationGestures = true
        webPane.translatesAutoresizingMaskIntoConstraints = false

        let closeChip = UIButton(type: .system)
        closeChip.setTitle("Close", for: .normal)
        closeChip.setTitleColor(AfterHoursPalette.inkOnSnow, for: .normal)
        closeChip.titleLabel?.font = AfterHoursType.foyerPill(15)
        closeChip.backgroundColor = AfterHoursPalette.snowCard
        closeChip.layer.cornerRadius = 16
        closeChip.translatesAutoresizingMaskIntoConstraints = false
        closeChip.addTarget(self, action: #selector(foldBoard), for: .touchUpInside)

        let titlePlate = UILabel()
        titlePlate.text = scrollKind.spokenTitle
        titlePlate.textColor = AfterHoursPalette.titleSnow
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.translatesAutoresizingMaskIntoConstraints = false

        progressHair.backgroundColor = AfterHoursPalette.snowCard
        progressHair.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titlePlate)
        view.addSubview(closeChip)
        view.addSubview(progressHair)
        view.addSubview(webPane)

        let hairWidth = progressHair.widthAnchor.constraint(equalToConstant: 0)
        progressWidth = hairWidth
        NSLayoutConstraint.activate([
            closeChip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            closeChip.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            closeChip.heightAnchor.constraint(equalToConstant: 32),
            closeChip.widthAnchor.constraint(equalToConstant: 76),

            titlePlate.centerYAnchor.constraint(equalTo: closeChip.centerYAnchor),
            titlePlate.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressHair.topAnchor.constraint(equalTo: closeChip.bottomAnchor, constant: 12),
            progressHair.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressHair.heightAnchor.constraint(equalToConstant: 2),
            hairWidth,

            webPane.topAnchor.constraint(equalTo: progressHair.bottomAnchor),
            webPane.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webPane.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webPane.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        progressWatch = webPane.observe(\.estimatedProgress, options: [.new]) { [weak self] pane, _ in
            self?.writeProgress(pane.estimatedProgress)
        }

        if let address = scrollKind.pageAddress {
            webPane.load(URLRequest(url: address))
        }
    }

    deinit {
        progressWatch?.invalidate()
    }

    @objc private func foldBoard() {
        dismiss(animated: true)
    }

    private func writeProgress(_ value: Double) {
        let width = view.bounds.width * CGFloat(max(0, min(value, 1)))
        progressWidth?.constant = width
        UIView.animate(withDuration: 0.18) {
            self.view.layoutIfNeeded()
            self.progressHair.alpha = value >= 1 ? 0 : 1
        }
    }

    private static func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        return configuration
    }
}
