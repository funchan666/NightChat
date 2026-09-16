import UIKit

final class NightSocialTributeTray: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let boothKey: String
    private var picked: LoungeGiftToken?
    private var quantity = 1
    private let pursePlate = UILabel()
    private let qtyPlate = UILabel()
    private var collection: UICollectionView!

    init(boothKey: String) {
        self.boothKey = boothKey
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [
            .custom(identifier: .init("gifts")) { _ in 348 }
        ]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 24
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeCard
        let title = UILabel()
        title.text = "Send a gift"
        title.font = AfterHoursType.foyerHeadline(18)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 12
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(GiftGlyphCell.self, forCellWithReuseIdentifier: GiftGlyphCell.reuseId)

        pursePlate.textColor = .white
        pursePlate.font = AfterHoursType.foyerBody(13, weight: .semibold)
        pursePlate.translatesAutoresizingMaskIntoConstraints = false
        let minus = UIButton(type: .system)
        minus.setTitle("−", for: .normal)
        minus.setTitleColor(.white, for: .normal)
        minus.addTarget(self, action: #selector(dropQty), for: .touchUpInside)
        let plus = UIButton(type: .system)
        plus.setTitle("+", for: .normal)
        plus.setTitleColor(.white, for: .normal)
        plus.addTarget(self, action: #selector(liftQty), for: .touchUpInside)
        qtyPlate.textColor = .white
        qtyPlate.font = AfterHoursType.foyerPill(14)
        qtyPlate.textAlignment = .center
        minus.translatesAutoresizingMaskIntoConstraints = false
        plus.translatesAutoresizingMaskIntoConstraints = false
        qtyPlate.translatesAutoresizingMaskIntoConstraints = false
        let send = UIButton(type: .custom)
        send.setImage(NightSocialImageCabinet.named("LoungeGiftPill", fallback: "Group_782@2x(2)"), for: .normal)
        send.imageView?.contentMode = .scaleAspectFit
        send.addTarget(self, action: #selector(offerGift), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(title)
        view.addSubview(collection)
        view.addSubview(pursePlate)
        view.addSubview(minus)
        view.addSubview(qtyPlate)
        view.addSubview(plus)
        view.addSubview(send)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            collection.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collection.heightAnchor.constraint(equalToConstant: 196),
            pursePlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pursePlate.centerYAnchor.constraint(equalTo: send.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            send.topAnchor.constraint(equalTo: collection.bottomAnchor, constant: 14),
            send.widthAnchor.constraint(equalToConstant: 84),
            send.heightAnchor.constraint(equalToConstant: 36),
            plus.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -10),
            plus.centerYAnchor.constraint(equalTo: send.centerYAnchor),
            qtyPlate.trailingAnchor.constraint(equalTo: plus.leadingAnchor, constant: -6),
            qtyPlate.centerYAnchor.constraint(equalTo: send.centerYAnchor),
            qtyPlate.widthAnchor.constraint(equalToConstant: 36),
            minus.trailingAnchor.constraint(equalTo: qtyPlate.leadingAnchor, constant: -6),
            minus.centerYAnchor.constraint(equalTo: send.centerYAnchor),
        ])
        picked = NightSocialLoungeCatalog.gifts.first
        NotificationCenter.default.addObserver(self, selector: #selector(paintPurse), name: .deskDrawerDidChange, object: nil)
        paintPurse()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func paintPurse() {
        pursePlate.text = "◆ \(NightSocialSessionDrawer.shared.diamondPurse)"
        qtyPlate.text = "\(quantity)"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        NightSocialLoungeCatalog.gifts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiftGlyphCell.reuseId, for: indexPath) as! GiftGlyphCell
        let gift = NightSocialLoungeCatalog.gifts[indexPath.item]
        cell.paint(gift, chosen: gift.giftKey == picked?.giftKey)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 72, height: 88)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        picked = NightSocialLoungeCatalog.gifts[indexPath.item]
        collectionView.reloadData()
    }

    @objc private func dropQty() { quantity = max(1, quantity - 1); paintPurse() }
    @objc private func liftQty() { quantity += 1; paintPurse() }

    @objc private func offerGift() {
        guard let gift = picked else { return }
        let count = quantity
        NightSocialLampStore.spend(.liveGift(gift, quantity: count), from: self) { [weak self] in
            NotificationCenter.default.post(
                name: .liveGiftOffered,
                object: nil,
                userInfo: [
                    "title": gift.spokenTitle,
                    "quantity": count,
                    "glyph": gift.glyphCatalog,
                ]
            )
            self?.dismiss(animated: true)
        }
    }
}

final class GiftGlyphCell: UICollectionViewCell {
    static let reuseId = "GiftGlyphCell"
    private let glyph = UIImageView()
    private let costPlate = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false
        costPlate.font = AfterHoursType.foyerCaption(11)
        costPlate.textColor = .white
        costPlate.textAlignment = .center
        costPlate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(glyph)
        contentView.addSubview(costPlate)
        NSLayoutConstraint.activate([
            glyph.topAnchor.constraint(equalTo: contentView.topAnchor),
            glyph.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 48),
            glyph.heightAnchor.constraint(equalToConstant: 48),
            costPlate.topAnchor.constraint(equalTo: glyph.bottomAnchor, constant: 4),
            costPlate.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    required init?(coder: NSCoder) { nil }
    func paint(_ gift: LoungeGiftToken, chosen: Bool) {
        glyph.image = UIImage(named: gift.glyphCatalog)
        costPlate.text = "◆ \(gift.diamondCost)"
        contentView.alpha = chosen ? 1 : 0.7
        contentView.layer.borderWidth = chosen ? 1.5 : 0
        contentView.layer.borderColor = AfterHoursPalette.loungePink.cgColor
        contentView.layer.cornerRadius = 12
    }
}

final class NightSocialDiamondPrompt: UIViewController {
    private let cost: Int
    private let quantity: Int
    private let giftTitle: String
    private let onPaid: (() -> Void)?
    private let onShort: (() -> Void)?
    init(cost: Int, quantity: Int, giftTitle: String, onPaid: (() -> Void)? = nil, onShort: (() -> Void)? = nil) {
        self.cost = cost
        self.quantity = quantity
        self.giftTitle = giftTitle
        self.onPaid = onPaid
        self.onShort = onShort
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        let cloth = UIImageView(image: NightSocialImageCabinet.named("DiamondPromptCloth", fallback: "image_622"))
        cloth.contentMode = .scaleAspectFill
        cloth.clipsToBounds = true
        cloth.layer.cornerRadius = 24
        cloth.translatesAutoresizingMaskIntoConstraints = false
        let enough = NightSocialSessionDrawer.shared.diamondPurse >= cost
        let body = UILabel()
        body.numberOfLines = 0
        body.textAlignment = .center
        body.font = AfterHoursType.foyerHeadline(18)
        body.textColor = AfterHoursPalette.inkOnSnow
        body.text = enough ? "Spend \(cost) night coins\nfor \(giftTitle)?" : "Not enough night coins\nfor \(giftTitle)."
        body.translatesAutoresizingMaskIntoConstraints = false
        let cancel = NightSocialLoungeChrome.ghostPill(title: "Cancel")
        cancel.setTitleColor(AfterHoursPalette.inkOnSnow, for: .normal)
        cancel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        cancel.addTarget(self, action: #selector(fold), for: .touchUpInside)
        let go = NightSocialLoungeChrome.pinkPill(title: enough ? "Confirm" : "Top-up")
        go.addTarget(self, action: #selector(settle), for: .touchUpInside)
        view.addSubview(cloth)
        view.addSubview(body)
        view.addSubview(cancel)
        view.addSubview(go)
        NSLayoutConstraint.activate([
            cloth.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloth.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            cloth.widthAnchor.constraint(equalToConstant: 300),
            cloth.heightAnchor.constraint(equalToConstant: 280),
            body.centerXAnchor.constraint(equalTo: cloth.centerXAnchor),
            body.centerYAnchor.constraint(equalTo: cloth.centerYAnchor, constant: 24),
            body.widthAnchor.constraint(equalToConstant: 240),
            cancel.leadingAnchor.constraint(equalTo: cloth.leadingAnchor, constant: 24),
            cancel.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            cancel.widthAnchor.constraint(equalToConstant: 110),
            go.trailingAnchor.constraint(equalTo: cloth.trailingAnchor, constant: -24),
            go.bottomAnchor.constraint(equalTo: cloth.bottomAnchor, constant: -22),
            go.widthAnchor.constraint(equalToConstant: 110),
        ])
    }

    @objc private func fold() { dismiss(animated: true) }
    @objc private func settle() {
        let purse = NightSocialSessionDrawer.shared.diamondPurse
        if purse >= cost {
            NightSocialSessionDrawer.shared.writeDiamondPurse(purse - cost)
            let paid = onPaid
            dismiss(animated: true) { paid?() }
        } else {
            let short = onShort
            let host = presentingViewController
            dismiss(animated: true) {
                if let short { short() }
                else if let host { NightSocialLampStore.revealRecharge(from: host) }
            }
        }
    }
}
