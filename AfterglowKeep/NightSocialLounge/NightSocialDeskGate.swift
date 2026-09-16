import UIKit

enum NightSocialDeskGate {
    static func isHouseDesk(_ deskKey: String) -> Bool {
        deskKey == NightSocialChimeCatalog.supportDeskKey
    }

    static func canExchangeChime(with deskKey: String) -> Bool {
        if isHouseDesk(deskKey) { return true }
        return NightSocialSessionDrawer.shared.isMutualFollow(deskKey)
    }

    static func revealDesk(from host: UIViewController, deskKey: String) {
        guard !isHouseDesk(deskKey) else { return }
        guard NightSocialLoungeCatalog.creator(deskKey: deskKey) != nil else { return }
        let board = NightSocialCreatorDeskBoard(deskKey: deskKey)
        if let nav = host.navigationController {
            nav.pushViewController(board, animated: true)
            return
        }
        let nav = host.presentingViewController as? UINavigationController
            ?? host.presentingViewController?.navigationController
        host.dismiss(animated: true) {
            nav?.pushViewController(board, animated: true)
        }
    }

    static func revealChime(from host: UIViewController, deskKey: String) {
        let board = NightSocialChimeThreadBoard(deskKey: deskKey)
        if let nav = host.navigationController {
            nav.pushViewController(board, animated: true)
            return
        }
        let nav = host.presentingViewController as? UINavigationController
            ?? host.presentingViewController?.navigationController
        host.dismiss(animated: true) {
            nav?.pushViewController(board, animated: true)
        }
    }

    static func guardExchange(on host: UIViewController, deskKey: String) -> Bool {
        if canExchangeChime(with: deskKey) { return true }
        NightSocialLampNotices.presentMutualFollow(from: host)
        return false
    }

    static func bindDeskTap(_ view: UIView, deskKey: String, host: UIViewController) {
        guard !isHouseDesk(deskKey) else { return }
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addTarget(DeskTapRelay.shared, action: #selector(DeskTapRelay.fire(_:)))
        DeskTapRelay.shared.remember(tap, deskKey: deskKey, host: host)
        view.addGestureRecognizer(tap)
    }
}

private final class DeskTapRelay: NSObject {
    static let shared = DeskTapRelay()
    private var box: [ObjectIdentifier: (String, UIViewController)] = [:]

    func remember(_ tap: UITapGestureRecognizer, deskKey: String, host: UIViewController) {
        box[ObjectIdentifier(tap)] = (deskKey, host)
    }

    @objc func fire(_ tap: UITapGestureRecognizer) {
        guard let pair = box[ObjectIdentifier(tap)] else { return }
        NightSocialDeskGate.revealDesk(from: pair.1, deskKey: pair.0)
    }
}
