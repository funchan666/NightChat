import UIKit

class NightSocialWashController: UIViewController {
    let washCloth = UIImageView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        additionalSafeAreaInsets = .zero
        view.insetsLayoutMarginsFromSafeArea = false
        view.backgroundColor = AfterHoursPalette.magentaPeak

        washCloth.image = NightSocialImageCabinet.stageWash
        washCloth.contentMode = .scaleAspectFill
        washCloth.clipsToBounds = true
        washCloth.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(washCloth)
        NSLayoutConstraint.activate([
            washCloth.topAnchor.constraint(equalTo: view.topAnchor),
            washCloth.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            washCloth.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            washCloth.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(foldKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nav = navigationController
        nav?.interactivePopGestureRecognizer?.delegate = nil
        nav?.interactivePopGestureRecognizer?.isEnabled = (nav?.viewControllers.count ?? 0) > 1
    }

    @objc func foldKeyboard() {
        view.endEditing(true)
    }

    @discardableResult
    func attachFoyerBackControl(action: Selector) -> UIButton {
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: action, for: .touchUpInside)
        back.accessibilityLabel = "Back"
        view.addSubview(back)
        view.bringSubviewToFront(back)
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
        ])
        return back
    }

    @objc func foldTowardFoyer() {
        foldKeyboard()
        AfterglowRootCoordinator.foldFoyerBoard(self)
    }

    func makeStageMarkView(edge: CGFloat) -> UIImageView {
        let mark = UIImageView(image: NightSocialImageCabinet.stageMark)
        mark.contentMode = .scaleAspectFit
        mark.clipsToBounds = true
        mark.layer.cornerRadius = 22
        mark.translatesAutoresizingMaskIntoConstraints = false
        mark.widthAnchor.constraint(equalToConstant: edge).isActive = true
        mark.heightAnchor.constraint(equalToConstant: edge).isActive = true
        return mark
    }

    func attachStageMark(edge: CGFloat, topOffset: CGFloat) -> UIImageView {
        let mark = makeStageMarkView(edge: edge)
        view.addSubview(mark)
        NSLayoutConstraint.activate([
            mark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mark.topAnchor.constraint(equalTo: view.topAnchor, constant: topOffset),
        ])
        return mark
    }

    func attachCenteredStageMark(edge: CGFloat) -> UIImageView {
        let mark = makeStageMarkView(edge: edge)
        view.addSubview(mark)
        NSLayoutConstraint.activate([
            mark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mark.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return mark
    }

    func attachHeadline(_ spoken: String) -> UILabel {
        let plate = UILabel()
        plate.text = spoken
        plate.textColor = AfterHoursPalette.titleSnow
        plate.font = AfterHoursType.foyerHeadline(34)
        plate.textAlignment = .center
        plate.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plate)
        return plate
    }
}

enum FoyerStagePillKind {
    case snow
    case frost
    case magenta
    case apple
}

/// Capsule control drawn with its own layers so iOS 26 glass does not wash it out.
class FoyerStagePill: UIControl {
    private let cloth = UIView()
    private let wash = CAGradientLayer()
    private let shine = CAGradientLayer()
    private let titlePlate = UILabel()
    private let glyphView = UIImageView()
    private let row = UIStackView()
    private let kind: FoyerStagePillKind

    init(spokenTitle: String, kind: FoyerStagePillKind, glyphName: String? = nil) {
        self.kind = kind
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 54).isActive = true
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = spokenTitle

        cloth.isUserInteractionEnabled = false
        cloth.translatesAutoresizingMaskIntoConstraints = false
        cloth.clipsToBounds = true
        insertSubview(cloth, at: 0)
        NSLayoutConstraint.activate([
            cloth.topAnchor.constraint(equalTo: topAnchor),
            cloth.leadingAnchor.constraint(equalTo: leadingAnchor),
            cloth.trailingAnchor.constraint(equalTo: trailingAnchor),
            cloth.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        cloth.layer.insertSublayer(wash, at: 0)
        cloth.layer.addSublayer(shine)

        titlePlate.text = spokenTitle
        titlePlate.font = AfterHoursType.foyerPill(16)
        titlePlate.textAlignment = .center

        glyphView.contentMode = .scaleAspectFit
        glyphView.translatesAutoresizingMaskIntoConstraints = false
        glyphView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        glyphView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        if let glyphName {
            glyphView.image = UIImage(
                systemName: glyphName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            )
        } else {
            glyphView.isHidden = true
        }

        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addArrangedSubview(glyphView)
        row.addArrangedSubview(titlePlate)
        addSubview(row)
        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: centerXAnchor),
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
            row.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -18),
        ])
        paintKind()
    }

    required init?(coder: NSCoder) { nil }

    func setTitle(_ title: String?, for state: UIControl.State) {
        titlePlate.text = title
        titlePlate.isHidden = (title ?? "").isEmpty
        if let title, !title.isEmpty { accessibilityLabel = title }
    }

    override var isHighlighted: Bool {
        didSet { press(isHighlighted) }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.55 }
    }

    private func press(_ on: Bool) {
        UIView.animate(withDuration: 0.16, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = on ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.alpha = on ? 0.9 : (self.isEnabled ? 1 : 0.55)
        }
    }

    private func paintKind() {
        wash.startPoint = CGPoint(x: 0, y: 0.5)
        wash.endPoint = CGPoint(x: 1, y: 1)
        shine.startPoint = CGPoint(x: 0.5, y: 0)
        shine.endPoint = CGPoint(x: 0.5, y: 1)
        switch kind {
        case .snow:
            wash.colors = [
                UIColor.white.cgColor,
                UIColor(red: 1.00, green: 0.94, blue: 0.97, alpha: 1).cgColor,
            ]
            titlePlate.textColor = AfterHoursPalette.inkOnSnow
            glyphView.tintColor = AfterHoursPalette.inkOnSnow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.22
            layer.shadowRadius = 14
            layer.shadowOffset = CGSize(width: 0, height: 8)
            shine.colors = [
                UIColor.white.withAlphaComponent(0.7).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ]
        case .frost:
            wash.colors = [
                UIColor.white.withAlphaComponent(0.22).cgColor,
                UIColor.white.withAlphaComponent(0.08).cgColor,
            ]
            cloth.layer.borderWidth = 1.2
            cloth.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
            titlePlate.textColor = .white
            glyphView.tintColor = .white
            layer.shadowOpacity = 0
            shine.colors = [
                UIColor.white.withAlphaComponent(0.28).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ]
        case .magenta:
            wash.colors = [
                AfterHoursPalette.foyerGlowPink.cgColor,
                AfterHoursPalette.magentaPeak.cgColor,
            ]
            titlePlate.textColor = .white
            glyphView.tintColor = .white
            layer.shadowColor = AfterHoursPalette.magentaPeak.cgColor
            layer.shadowOpacity = 0.48
            layer.shadowRadius = 16
            layer.shadowOffset = CGSize(width: 0, height: 8)
            shine.colors = [
                UIColor.white.withAlphaComponent(0.34).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ]
        case .apple:
            wash.colors = [UIColor.black.cgColor, UIColor(white: 0.14, alpha: 1).cgColor]
            titlePlate.textColor = .white
            glyphView.tintColor = .white
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.3
            layer.shadowRadius = 12
            layer.shadowOffset = CGSize(width: 0, height: 6)
            shine.colors = [
                UIColor.white.withAlphaComponent(0.14).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor,
            ]
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.height / 2
        cloth.layer.cornerRadius = radius
        wash.frame = cloth.bounds
        wash.cornerRadius = radius
        shine.frame = CGRect(x: 0, y: 0, width: cloth.bounds.width, height: max(1, cloth.bounds.height * 0.52))
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
    }
}

final class SnowPillControl: FoyerStagePill {
    init(spokenTitle: String) {
        super.init(spokenTitle: spokenTitle, kind: .snow)
    }
    required init?(coder: NSCoder) { nil }
}

final class MidnightPillControl: FoyerStagePill {
    init(spokenTitle: String) {
        super.init(spokenTitle: spokenTitle, kind: .magenta)
    }
    required init?(coder: NSCoder) { nil }
}

final class FoyerInkField: UITextField {
    init(whisper: String, glyphName: String) {
        super.init(frame: .zero)
        placeholder = whisper
        attributedPlaceholder = NSAttributedString(
            string: whisper,
            attributes: [
                .foregroundColor: AfterHoursPalette.mistPlaceholder,
                .font: AfterHoursType.foyerBody(15),
            ]
        )
        font = AfterHoursType.foyerBody(15)
        textColor = AfterHoursPalette.inkOnSnow
        borderStyle = .none
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        tintColor = AfterHoursPalette.magentaPeak
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 56).isActive = true

        let wrap = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 56))
        let glyph = UIImageView(image: UIImage(systemName: glyphName))
        glyph.tintColor = AfterHoursPalette.mistPlaceholder
        glyph.contentMode = .scaleAspectFit
        glyph.frame = CGRect(x: 18, y: 18, width: 18, height: 20)
        wrap.addSubview(glyph)
        leftView = wrap
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        rightViewMode = .always
    }

    required init?(coder: NSCoder) { nil }
}

final class FoyerCredentialCluster: UIView {
    init(rows: [FoyerInkField]) {
        super.init(frame: .zero)
        backgroundColor = AfterHoursPalette.snowCard
        layer.cornerRadius = 24
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for (index, row) in rows.enumerated() {
            stack.addArrangedSubview(row)
            if index < rows.count - 1 {
                let hair = UIView()
                hair.backgroundColor = AfterHoursPalette.hairlineMist
                hair.translatesAutoresizingMaskIntoConstraints = false
                hair.heightAnchor.constraint(equalToConstant: 1).isActive = true
                let hairWrap = UIView()
                hairWrap.addSubview(hair)
                NSLayoutConstraint.activate([
                    hair.leadingAnchor.constraint(equalTo: hairWrap.leadingAnchor, constant: 48),
                    hair.trailingAnchor.constraint(equalTo: hairWrap.trailingAnchor),
                    hair.topAnchor.constraint(equalTo: hairWrap.topAnchor),
                    hair.bottomAnchor.constraint(equalTo: hairWrap.bottomAnchor),
                    hairWrap.heightAnchor.constraint(equalToConstant: 1),
                ])
                stack.addArrangedSubview(hairWrap)
            }
        }
    }

    required init?(coder: NSCoder) { nil }
}

final class FoyerLonelySnowField: UITextField {
    init(whisper: String) {
        super.init(frame: .zero)
        placeholder = whisper
        attributedPlaceholder = NSAttributedString(
            string: whisper,
            attributes: [
                .foregroundColor: AfterHoursPalette.mistPlaceholder,
                .font: AfterHoursType.foyerBody(15),
            ]
        )
        font = AfterHoursType.foyerBody(15)
        textColor = AfterHoursPalette.inkOnSnow
        backgroundColor = AfterHoursPalette.snowCard
        borderStyle = .none
        layer.cornerRadius = 22
        clipsToBounds = true
        autocapitalizationType = .words
        autocorrectionType = .no
        tintColor = AfterHoursPalette.magentaPeak
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 50))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 50))
        rightViewMode = .always
    }

    required init?(coder: NSCoder) { nil }
}

final class FoyerContinueSpine: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        let spoken = UILabel()
        spoken.text = "OR CONTINUE WITH"
        spoken.textColor = AfterHoursPalette.titleSnow.withAlphaComponent(0.92)
        spoken.font = AfterHoursType.foyerCaption(11)
        spoken.textAlignment = .center
        spoken.translatesAutoresizingMaskIntoConstraints = false

        let leading = UIView()
        let trailing = UIView()
        leading.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        trailing.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        leading.translatesAutoresizingMaskIntoConstraints = false
        trailing.translatesAutoresizingMaskIntoConstraints = false

        addSubview(leading)
        addSubview(spoken)
        addSubview(trailing)
        NSLayoutConstraint.activate([
            spoken.centerXAnchor.constraint(equalTo: centerXAnchor),
            spoken.centerYAnchor.constraint(equalTo: centerYAnchor),
            leading.leadingAnchor.constraint(equalTo: leadingAnchor),
            leading.trailingAnchor.constraint(equalTo: spoken.leadingAnchor, constant: -10),
            leading.centerYAnchor.constraint(equalTo: centerYAnchor),
            leading.heightAnchor.constraint(equalToConstant: 1),
            trailing.leadingAnchor.constraint(equalTo: spoken.trailingAnchor, constant: 10),
            trailing.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailing.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailing.heightAnchor.constraint(equalToConstant: 1),
            heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

final class FoyerLonelySnowNote: UIView, UITextViewDelegate {
    var spokenText: String {
        get { noteView.text ?? "" }
        set {
            noteView.text = newValue
            whisperPlate.isHidden = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private let noteView = UITextView()
    private let whisperPlate = UILabel()

    init(whisper: String) {
        super.init(frame: .zero)
        backgroundColor = AfterHoursPalette.snowCard
        layer.cornerRadius = 22
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 92).isActive = true

        noteView.backgroundColor = .clear
        noteView.font = AfterHoursType.foyerBody(15)
        noteView.textColor = AfterHoursPalette.inkOnSnow
        noteView.tintColor = AfterHoursPalette.magentaPeak
        noteView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        noteView.delegate = self
        noteView.translatesAutoresizingMaskIntoConstraints = false

        whisperPlate.text = whisper
        whisperPlate.font = AfterHoursType.foyerBody(15)
        whisperPlate.textColor = AfterHoursPalette.mistPlaceholder
        whisperPlate.translatesAutoresizingMaskIntoConstraints = false

        addSubview(noteView)
        addSubview(whisperPlate)
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: topAnchor),
            noteView.leadingAnchor.constraint(equalTo: leadingAnchor),
            noteView.trailingAnchor.constraint(equalTo: trailingAnchor),
            noteView.bottomAnchor.constraint(equalTo: bottomAnchor),
            whisperPlate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            whisperPlate.topAnchor.constraint(equalTo: topAnchor, constant: 14),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func textViewDidChange(_ textView: UITextView) {
        whisperPlate.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum NightSocialFoyerGuard {
    static func trimmed(_ raw: String?) -> String {
        (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func mailboxLooksValid(_ raw: String) -> Bool {
        let mail = trimmed(raw)
        guard mail.contains("@"), let at = mail.firstIndex(of: "@") else { return false }
        let domain = mail[mail.index(after: at)...]
        return mail.count >= 5 && domain.contains(".")
    }

    static func secretLooksValid(_ raw: String) -> Bool {
        raw.count >= 6
    }
}

enum FoyerNotice {
    static func present(on host: UIViewController, spokenTitle: String, spokenBody: String) {
        presentVelvet(on: host, spokenTitle: spokenTitle, spokenBody: spokenBody, settleTitle: "Keep sitting")
    }
}
