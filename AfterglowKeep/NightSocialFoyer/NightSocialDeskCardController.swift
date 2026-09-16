import PhotosUI
import UIKit

final class NightSocialDeskCardController: NightSocialWashController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    private let arrival: DeskCardArrival
    private let spokenNameField = FoyerLonelySnowField(whisper: "Enter your name")
    private let signatureNote = FoyerLonelySnowNote(whisper: "Write a short night signature")
    private let portraitDisc = UIImageView()
    private let scroller = UIScrollView()
    private let chipStrip = UIStackView()
    private var chosenPortrait: UIImage?
    private let cameraPicker = UIImagePickerController()
    private let portraitHint = UIImageView()
    private let cameraWell = UIView()
    private let birthField = FoyerPickSnowRow(whisper: "Choose your birthday")
    private let landField = FoyerPickSnowRow(whisper: "Choose your country")
    private var birthDay: Date?
    private var landCode = "US"

    init(arrival: DeskCardArrival) {
        self.arrival = arrival
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraPicker.delegate = self
        cameraPicker.allowsEditing = true

        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.alwaysBounceVertical = true
        scroller.keyboardDismissMode = .onDrag
        scroller.insetsLayoutMarginsFromSafeArea = false
        scroller.contentInsetAdjustmentBehavior = .never
        view.addSubview(scroller)
        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let titlePlate = UILabel()
        titlePlate.text = "Please finish your profile details."
        titlePlate.textColor = AfterHoursPalette.titleSnow
        titlePlate.font = AfterHoursType.foyerHeadline(26)
        titlePlate.numberOfLines = 0
        titlePlate.translatesAutoresizingMaskIntoConstraints = false

        let kicker = UILabel()
        kicker.text = "Start Your Night Social"
        kicker.textColor = AfterHoursPalette.footerSnow
        kicker.font = AfterHoursType.foyerBody(15)
        kicker.translatesAutoresizingMaskIntoConstraints = false

        let session = NightSocialSessionDrawer.shared.restoredSession()
        chosenPortrait = nil
        portraitDisc.image = nil
        portraitDisc.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        portraitDisc.contentMode = .scaleAspectFill
        portraitDisc.clipsToBounds = true
        portraitDisc.layer.cornerRadius = 64
        portraitDisc.layer.borderWidth = 2
        portraitDisc.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        portraitDisc.isUserInteractionEnabled = true
        portraitDisc.translatesAutoresizingMaskIntoConstraints = false
        portraitDisc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPortraitIntake)))

        portraitHint.image = UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .medium))
        portraitHint.tintColor = UIColor.white.withAlphaComponent(0.92)
        portraitHint.contentMode = .scaleAspectFit
        portraitHint.isUserInteractionEnabled = false
        portraitHint.translatesAutoresizingMaskIntoConstraints = false

        cameraWell.backgroundColor = .white
        cameraWell.layer.cornerRadius = 20
        cameraWell.layer.shadowColor = UIColor.black.cgColor
        cameraWell.layer.shadowOpacity = 0.18
        cameraWell.layer.shadowRadius = 8
        cameraWell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cameraWell.translatesAutoresizingMaskIntoConstraints = false
        cameraWell.isUserInteractionEnabled = false
        let cameraGlyph = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        cameraGlyph.tintColor = AfterHoursPalette.loungePink
        cameraGlyph.translatesAutoresizingMaskIntoConstraints = false
        cameraWell.addSubview(cameraGlyph)

        let namePlate = makeFieldPlate("Name")
        let pickPlate = makeFieldPlate("Choose a name")
        let birthPlate = makeFieldPlate("Birthday")
        let landPlate = makeFieldPlate("Country")
        let signPlate = makeFieldPlate("Signature")
        birthField.addTarget(self, action: #selector(openBirthPick), for: .touchUpInside)
        landField.addTarget(self, action: #selector(openLandPick), for: .touchUpInside)
        paintLand()

        spokenNameField.delegate = self
        spokenNameField.textContentType = .name
        let seeded = NightSocialFoyerGuard.trimmed(session?.nightAlias).isEmpty
            ? NightSocialFoyerGuard.trimmed(session?.stageSpokenName)
            : NightSocialFoyerGuard.trimmed(session?.nightAlias)
        spokenNameField.text = seeded
        signatureNote.spokenText = session?.nightSignature ?? ""

        chipStrip.axis = .horizontal
        chipStrip.spacing = 8
        chipStrip.alignment = .center
        chipStrip.translatesAutoresizingMaskIntoConstraints = false
        fillNameChips(session?.suggestionSpokenNames ?? [])

        let settle = MidnightPillControl(spokenTitle: arrival.settleTitle)
        settle.addTarget(self, action: #selector(finishDeskCard), for: .touchUpInside)

        scroller.addSubview(titlePlate)
        scroller.addSubview(kicker)
        scroller.addSubview(portraitDisc)
        scroller.addSubview(portraitHint)
        scroller.addSubview(cameraWell)
        scroller.addSubview(namePlate)
        scroller.addSubview(spokenNameField)
        scroller.addSubview(pickPlate)
        scroller.addSubview(chipStrip)
        scroller.addSubview(birthPlate)
        scroller.addSubview(birthField)
        scroller.addSubview(landPlate)
        scroller.addSubview(landField)
        scroller.addSubview(signPlate)
        scroller.addSubview(signatureNote)
        view.addSubview(settle)

        NSLayoutConstraint.activate([
            titlePlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titlePlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titlePlate.topAnchor.constraint(equalTo: scroller.topAnchor, constant: 72),

            kicker.leadingAnchor.constraint(equalTo: titlePlate.leadingAnchor),
            kicker.topAnchor.constraint(equalTo: titlePlate.bottomAnchor, constant: 8),

            portraitDisc.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portraitDisc.topAnchor.constraint(equalTo: kicker.bottomAnchor, constant: 28),
            portraitDisc.widthAnchor.constraint(equalToConstant: 128),
            portraitDisc.heightAnchor.constraint(equalToConstant: 128),

            portraitHint.centerXAnchor.constraint(equalTo: portraitDisc.centerXAnchor),
            portraitHint.centerYAnchor.constraint(equalTo: portraitDisc.centerYAnchor),
            portraitHint.widthAnchor.constraint(equalToConstant: 54),
            portraitHint.heightAnchor.constraint(equalToConstant: 54),
            cameraWell.widthAnchor.constraint(equalToConstant: 40),
            cameraWell.heightAnchor.constraint(equalToConstant: 40),
            cameraWell.trailingAnchor.constraint(equalTo: portraitDisc.trailingAnchor, constant: 4),
            cameraWell.bottomAnchor.constraint(equalTo: portraitDisc.bottomAnchor, constant: 4),
            cameraGlyph.centerXAnchor.constraint(equalTo: cameraWell.centerXAnchor),
            cameraGlyph.centerYAnchor.constraint(equalTo: cameraWell.centerYAnchor),

            namePlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            namePlate.topAnchor.constraint(equalTo: portraitDisc.bottomAnchor, constant: 28),

            spokenNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            spokenNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            spokenNameField.topAnchor.constraint(equalTo: namePlate.bottomAnchor, constant: 8),

            pickPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            pickPlate.topAnchor.constraint(equalTo: spokenNameField.bottomAnchor, constant: 16),

            chipStrip.leadingAnchor.constraint(equalTo: spokenNameField.leadingAnchor),
            chipStrip.trailingAnchor.constraint(lessThanOrEqualTo: spokenNameField.trailingAnchor),
            chipStrip.topAnchor.constraint(equalTo: pickPlate.bottomAnchor, constant: 8),
            chipStrip.heightAnchor.constraint(equalToConstant: 36),

            birthPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            birthPlate.topAnchor.constraint(equalTo: chipStrip.bottomAnchor, constant: 16),
            birthField.leadingAnchor.constraint(equalTo: spokenNameField.leadingAnchor),
            birthField.trailingAnchor.constraint(equalTo: spokenNameField.trailingAnchor),
            birthField.topAnchor.constraint(equalTo: birthPlate.bottomAnchor, constant: 8),
            landPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            landPlate.topAnchor.constraint(equalTo: birthField.bottomAnchor, constant: 16),
            landField.leadingAnchor.constraint(equalTo: spokenNameField.leadingAnchor),
            landField.trailingAnchor.constraint(equalTo: spokenNameField.trailingAnchor),
            landField.topAnchor.constraint(equalTo: landPlate.bottomAnchor, constant: 8),
            signPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            signPlate.topAnchor.constraint(equalTo: landField.bottomAnchor, constant: 16),

            signatureNote.leadingAnchor.constraint(equalTo: spokenNameField.leadingAnchor),
            signatureNote.trailingAnchor.constraint(equalTo: spokenNameField.trailingAnchor),
            signatureNote.topAnchor.constraint(equalTo: signPlate.bottomAnchor, constant: 8),

            settle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            settle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            settle.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -42),

            scroller.contentLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: signatureNote.bottomAnchor, constant: 140),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(liftForKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeFieldPlate(_ spoken: String) -> UILabel {
        let plate = UILabel()
        plate.text = spoken
        plate.textColor = AfterHoursPalette.titleSnow
        plate.font = AfterHoursType.foyerBody(16, weight: .semibold)
        plate.translatesAutoresizingMaskIntoConstraints = false
        return plate
    }

    private func fillNameChips(_ names: [String]) {
        chipStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let visible = names.isEmpty ? ["Night guest"] : names
        for spoken in visible {
            var config = UIButton.Configuration.filled()
            config.title = spoken
            config.baseBackgroundColor = AfterHoursPalette.snowCard
            config.baseForegroundColor = AfterHoursPalette.inkOnSnow
            config.background.cornerRadius = 16
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            let chip = UIButton(configuration: config)
            chip.titleLabel?.font = AfterHoursType.foyerBody(13, weight: .semibold)
            chip.addAction(UIAction { [weak self] _ in
                self?.spokenNameField.text = spoken
            }, for: .touchUpInside)
            chipStrip.addArrangedSubview(chip)
        }
    }

    @objc private func openPortraitIntake() {
        let chooser = NightSocialPortraitIntake()
        chooser.onPickedLibrary = { [weak self] in self?.openLibraryPicker() }
        chooser.onPickedCamera = { [weak self] in
            guard let self else { return }
            NightSocialCameraGate.openCamera(from: self, picker: self.cameraPicker)
        }
        present(chooser, animated: true)
    }

    private func openLibraryPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.applyPortrait(image)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        if let image {
            applyPortrait(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func applyPortrait(_ image: UIImage) {
        chosenPortrait = image
        portraitDisc.image = image
        portraitHint.isHidden = true
    }

    @objc private func openBirthPick() {
        let pane = FoyerDatePickPane(seed: birthDay ?? Calendar.current.date(byAdding: .year, value: -21, to: Date()))
        pane.onPick = { [weak self] day in
            self?.birthDay = day
            self?.birthField.paint(Self.birthPhrase(day))
        }
        present(pane, animated: true)
    }

    @objc private func openLandPick() {
        let lands = NightSocialLampAtlas.lands
        let pane = FoyerListPickPane(titles: lands.map(\.spokenTitle), seed: lands.firstIndex(where: { $0.code == landCode }) ?? 0)
        pane.onPick = { [weak self] index in
            guard let self, lands.indices.contains(index) else { return }
            self.landCode = lands[index].code
            self.paintLand()
        }
        present(pane, animated: true)
    }

    private func paintLand() {
        let land = NightSocialLampAtlas.land(code: landCode)
        landField.paint(land.spokenTitle)
    }

    private static func birthPhrase(_ day: Date) -> String {
        let form = DateFormatter()
        form.locale = Locale(identifier: "en_US_POSIX")
        form.dateFormat = "MMM d, yyyy"
        return form.string(from: day)
    }

    @objc private func finishDeskCard() {
        foldKeyboard()
        let alias = NightSocialFoyerGuard.trimmed(spokenNameField.text)
        let signature = NightSocialFoyerGuard.trimmed(signatureNote.spokenText)
        if alias.isEmpty {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Name still empty",
                spokenBody: "Write or choose a name for this night desk before you enter."
            )
            return
        }
        if signature.isEmpty {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Signature still empty",
                spokenBody: "Leave a short night signature so the sitting knows your chair."
            )
            return
        }
        if chosenPortrait == nil {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Portrait still empty",
                spokenBody: "Take a photo or choose one from the library for your night portrait."
            )
            return
        }
        guard let birthDay else {
            FoyerNotice.present(
                on: self,
                spokenTitle: "Birthday still open",
                spokenBody: "Pick the day you arrived so the night desk can keep your chair."
            )
            return
        }
        let tongue = NightSocialLampAtlas.land(code: landCode).tongueTitle
        NightSocialSessionDrawer.shared.finishDeskCard(
            nightAlias: alias,
            nightSignature: signature,
            portrait: chosenPortrait,
            birthMeridianPhrase: Self.birthPhrase(birthDay),
            homeCountryCode: landCode,
            spokenTongue: tongue
        )
        AfterglowRootCoordinator.revealLoungeFloor(from: self)
    }

    @objc private func liftForKeyboard(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = view.convert(frame, from: nil).intersection(view.bounds).height
        scroller.contentInset.bottom = overlap
        scroller.verticalScrollIndicatorInsets.bottom = overlap
    }
}

enum NightSocialLampAtlas {
    struct Land {
        let code: String
        let spokenTitle: String
        let tongueTitle: String
    }

    static let tongues = [
        "English",
        "中文 (简体)",
        "中文 (繁體)",
        "日本語",
        "한국어",
        "Español",
        "Français",
        "Deutsch",
        "العربية",
        "Português",
        "Italiano",
        "Русский",
        "हिन्दी",
        "Türkçe",
        "ไทย",
        "Tiếng Việt",
        "Bahasa Indonesia",
        "Nederlands",
        "Polski",
    ]

    static let lands: [Land] = [
        .init(code: "US", spokenTitle: "United States", tongueTitle: "English"),
        .init(code: "GB", spokenTitle: "United Kingdom", tongueTitle: "English"),
        .init(code: "CA", spokenTitle: "Canada", tongueTitle: "English"),
        .init(code: "AU", spokenTitle: "Australia", tongueTitle: "English"),
        .init(code: "CN", spokenTitle: "China", tongueTitle: "中文 (简体)"),
        .init(code: "TW", spokenTitle: "Taiwan", tongueTitle: "中文 (繁體)"),
        .init(code: "HK", spokenTitle: "Hong Kong", tongueTitle: "中文 (繁體)"),
        .init(code: "JP", spokenTitle: "Japan", tongueTitle: "日本語"),
        .init(code: "KR", spokenTitle: "South Korea", tongueTitle: "한국어"),
        .init(code: "ES", spokenTitle: "Spain", tongueTitle: "Español"),
        .init(code: "MX", spokenTitle: "Mexico", tongueTitle: "Español"),
        .init(code: "AR", spokenTitle: "Argentina", tongueTitle: "Español"),
        .init(code: "FR", spokenTitle: "France", tongueTitle: "Français"),
        .init(code: "DE", spokenTitle: "Germany", tongueTitle: "Deutsch"),
        .init(code: "AT", spokenTitle: "Austria", tongueTitle: "Deutsch"),
        .init(code: "SA", spokenTitle: "Saudi Arabia", tongueTitle: "العربية"),
        .init(code: "AE", spokenTitle: "United Arab Emirates", tongueTitle: "العربية"),
        .init(code: "EG", spokenTitle: "Egypt", tongueTitle: "العربية"),
        .init(code: "BR", spokenTitle: "Brazil", tongueTitle: "Português"),
        .init(code: "PT", spokenTitle: "Portugal", tongueTitle: "Português"),
        .init(code: "IT", spokenTitle: "Italy", tongueTitle: "Italiano"),
        .init(code: "RU", spokenTitle: "Russia", tongueTitle: "Русский"),
        .init(code: "IN", spokenTitle: "India", tongueTitle: "हिन्दी"),
        .init(code: "TR", spokenTitle: "Turkey", tongueTitle: "Türkçe"),
        .init(code: "TH", spokenTitle: "Thailand", tongueTitle: "ไทย"),
        .init(code: "VN", spokenTitle: "Vietnam", tongueTitle: "Tiếng Việt"),
        .init(code: "ID", spokenTitle: "Indonesia", tongueTitle: "Bahasa Indonesia"),
        .init(code: "NL", spokenTitle: "Netherlands", tongueTitle: "Nederlands"),
        .init(code: "PL", spokenTitle: "Poland", tongueTitle: "Polski"),
    ]

    static func land(code: String) -> Land {
        lands.first { $0.code == code } ?? lands[0]
    }
}

final class FoyerPickSnowRow: UIControl {
    private let plate = UILabel()

    init(whisper: String) {
        super.init(frame: .zero)
        backgroundColor = AfterHoursPalette.snowCard
        layer.cornerRadius = 22
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        plate.text = whisper
        plate.font = AfterHoursType.foyerBody(15)
        plate.textColor = AfterHoursPalette.mistPlaceholder
        plate.translatesAutoresizingMaskIntoConstraints = false
        let chev = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        chev.tintColor = AfterHoursPalette.mistPlaceholder
        chev.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plate)
        addSubview(chev)
        NSLayoutConstraint.activate([
            plate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            plate.centerYAnchor.constraint(equalTo: centerYAnchor),
            chev.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chev.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func paint(_ spoken: String) {
        plate.text = spoken
        plate.textColor = AfterHoursPalette.inkOnSnow
    }
}

final class FoyerDatePickPane: UIViewController {
    var onPick: ((Date) -> Void)?
    private let picker = UIDatePicker()

    init(seed: Date?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -90, to: Date())
        if let seed { picker.date = seed }
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.snowCard
        picker.translatesAutoresizingMaskIntoConstraints = false
        let done = MidnightPillControl(spokenTitle: "Save")
        done.addTarget(self, action: #selector(settle), for: .touchUpInside)
        view.addSubview(picker)
        view.addSubview(done)
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            done.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            done.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 12),
        ])
    }

    @objc private func settle() {
        onPick?(picker.date)
        dismiss(animated: true)
    }
}

final class FoyerListPickPane: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var onPick: ((Int) -> Void)?
    private let titles: [String]
    private let picker = UIPickerView()
    private var seed: Int

    init(titles: [String], seed: Int) {
        self.titles = titles
        self.seed = seed
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.snowCard
        picker.dataSource = self
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectRow(min(seed, max(0, titles.count - 1)), inComponent: 0, animated: false)
        let done = MidnightPillControl(spokenTitle: "Save")
        done.addTarget(self, action: #selector(settle), for: .touchUpInside)
        view.addSubview(picker)
        view.addSubview(done)
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            done.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            done.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 8),
        ])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { titles.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { titles[row] }

    @objc private func settle() {
        onPick?(picker.selectedRow(inComponent: 0))
        dismiss(animated: true)
    }
}
