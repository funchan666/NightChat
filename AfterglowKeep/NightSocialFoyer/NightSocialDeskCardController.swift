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
        portraitDisc.image = NightSocialSessionDrawer.shared.loadPortrait()
        chosenPortrait = portraitDisc.image
        portraitDisc.backgroundColor = AfterHoursPalette.portraitDiscFill
        portraitDisc.contentMode = .scaleAspectFill
        portraitDisc.clipsToBounds = true
        portraitDisc.layer.cornerRadius = 64
        portraitDisc.layer.borderWidth = 3
        portraitDisc.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        portraitDisc.isUserInteractionEnabled = true
        portraitDisc.translatesAutoresizingMaskIntoConstraints = false
        portraitDisc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPortraitIntake)))

        let lens = UIImageView(image: NightSocialImageCabinet.portraitLens)
        lens.contentMode = .scaleAspectFit
        lens.translatesAutoresizingMaskIntoConstraints = false

        let namePlate = makeFieldPlate("Name")
        let pickPlate = makeFieldPlate("Choose a name")
        let signPlate = makeFieldPlate("Signature")

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
        scroller.addSubview(lens)
        scroller.addSubview(namePlate)
        scroller.addSubview(spokenNameField)
        scroller.addSubview(pickPlate)
        scroller.addSubview(chipStrip)
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

            lens.widthAnchor.constraint(equalToConstant: 36),
            lens.heightAnchor.constraint(equalToConstant: 36),
            lens.trailingAnchor.constraint(equalTo: portraitDisc.trailingAnchor, constant: 2),
            lens.bottomAnchor.constraint(equalTo: portraitDisc.bottomAnchor, constant: 2),

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

            signPlate.leadingAnchor.constraint(equalTo: namePlate.leadingAnchor),
            signPlate.topAnchor.constraint(equalTo: chipStrip.bottomAnchor, constant: 16),

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
            config.cornerRadius = 16
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
        NightSocialSessionDrawer.shared.finishDeskCard(
            nightAlias: alias,
            nightSignature: signature,
            portrait: chosenPortrait
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
