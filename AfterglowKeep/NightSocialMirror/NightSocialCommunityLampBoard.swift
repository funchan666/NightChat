import UIKit

final class NightSocialCommunityLampBoard: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let head = UILabel()
        head.text = "Community Rules"
        head.font = AfterHoursType.foyerHeadline(20)
        head.textColor = .white
        head.translatesAutoresizingMaskIntoConstraints = false
        let scroller = UIScrollView()
        scroller.alwaysBounceVertical = true
        scroller.contentInsetAdjustmentBehavior = .never
        scroller.translatesAutoresizingMaskIntoConstraints = false
        let mascot = UIImageView(image: NightSocialImageCabinet.named("EmptyMascot", fallback: "EmptyMascot"))
        mascot.contentMode = .scaleAspectFit
        mascot.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = AfterHoursPalette.loungeCard
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false
        let body = UILabel()
        body.numberOfLines = 0
        body.textColor = UIColor.white.withAlphaComponent(0.92)
        body.font = AfterHoursType.foyerBody(14)
        body.text = Self.spokenRules
        body.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(mascot)
        scroller.addSubview(card)
        card.addSubview(body)
        view.addSubview(back)
        view.addSubview(head)
        view.addSubview(scroller)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            head.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 8),
            head.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            scroller.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 8),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mascot.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 8),
            mascot.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mascot.widthAnchor.constraint(equalToConstant: 140),
            mascot.heightAnchor.constraint(equalToConstant: 140),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: mascot.bottomAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -28),
            body.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
    }

    @objc private func fold() { navigationController?.popViewController(animated: true) }

    private static let spokenRules = """
    NightChat is a late-sitting house. Keep every desk, clip, voice room, and chat kind.

    1. No anonymous chats
    Direct messages and video calls are allowed only after both desks follow each other. Follows are one-way until the other desk follows you back. Friend asks wait for a real yes. The house never auto-follows or auto-accepts.

    2. Real people, real age
    You must be 17 or older. Do not impersonate someone else. Do not invent a desk to harass, scam, or hide from house rules.

    3. No sexual content involving minors
    Any sexual, nude, or exploitative material involving anyone 17 or under is banned and reported. NightChat will hide it and may remove the desk.

    4. No hate, threats, or bullying
    Harassment, slurs, stalking, doxxing, and violent threats have no seat at this lamp. Report them. The sitting disappears from your night.

    5. No spam, scams, or illegal trade
    Do not sell banned goods, run phishing, or flood rooms with ads. Gift and diamond sittings are in-app only.

    6. Clips wait for review
    Posts do not appear in the lounge the moment you send them. The house holds every clip until a reviewer passes it. Pending clips stay off public lists.

    7. Voice rooms stay decent
    Live mics are public sittings. No sexual services, no hate, no dumping personal data of others. Hosts share the duty to keep the room kind.

    8. Report and block
    Use Report to pick a reason. Use Block to hide a desk, including their clips, rooms, and chats. Both save on this device and refresh lists at once. You can lift a block from Blacklist.

    9. Your desk, your keys
    Keep your mailbox and secret private. Logging out parks the sitting. Deleting the account erases this night desk from the device.

    10. House may act
    NightChat may hide content, end a sitting, or close a desk that breaks these rules or Apple App Store Guideline 1.2 (User-Generated Content).

    If you see harm, tap Report. If you need a quieter night, tap Block. Keep the lamp warm for people who came to sit, not to wound.
    """
}
