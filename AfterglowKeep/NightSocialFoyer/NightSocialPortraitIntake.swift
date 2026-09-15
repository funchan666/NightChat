import AVFoundation
import PhotosUI
import UIKit

final class NightSocialPortraitIntake: UIViewController {
    var onPickedLibrary: (() -> Void)?
    var onPickedCamera: (() -> Void)?

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.18, green: 0.04, blue: 0.12, alpha: 0.46)

        let card = UIView()
        card.backgroundColor = AfterHoursPalette.snowCard
        card.layer.cornerRadius = 28
        card.translatesAutoresizingMaskIntoConstraints = false

        let headline = UILabel()
        headline.text = "Set your night portrait"
        headline.textColor = AfterHoursPalette.midnightPill
        headline.font = AfterHoursType.foyerHeadline(20)
        headline.textAlignment = .center
        headline.translatesAutoresizingMaskIntoConstraints = false

        let camera = MidnightPillControl(spokenTitle: "Take a photo")
        let library = MidnightPillControl(spokenTitle: "Choose from library")
        let cancel = UIButton(type: .system)
        cancel.setTitle("Not now", for: .normal)
        cancel.setTitleColor(AfterHoursPalette.magentaPeak, for: .normal)
        cancel.titleLabel?.font = AfterHoursType.foyerBody(15, weight: .semibold)
        cancel.translatesAutoresizingMaskIntoConstraints = false

        camera.addTarget(self, action: #selector(pickCamera), for: .touchUpInside)
        library.addTarget(self, action: #selector(pickLibrary), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(foldPane), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [headline, camera, library, cancel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(18, after: headline)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
    }

    @objc private func pickCamera() {
        dismiss(animated: true) { [weak self] in self?.onPickedCamera?() }
    }

    @objc private func pickLibrary() {
        dismiss(animated: true) { [weak self] in self?.onPickedLibrary?() }
    }

    @objc private func foldPane() {
        dismiss(animated: true)
    }
}

enum NightSocialCameraGate {
    static func openCamera(from host: UIViewController, picker: UIImagePickerController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            FoyerNotice.present(
                on: host,
                spokenTitle: "No camera on this device",
                spokenBody: "This sitting has no camera. Choose a portrait from the library instead."
            )
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            picker.sourceType = .camera
            picker.allowsEditing = true
            host.present(picker, animated: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        picker.sourceType = .camera
                        picker.allowsEditing = true
                        host.present(picker, animated: true)
                    } else {
                        FoyerNotice.present(
                            on: host,
                            spokenTitle: "Camera still closed",
                            spokenBody: "Allow the camera in Settings if you want to take a night portrait."
                        )
                    }
                }
            }
        default:
            FoyerNotice.present(
                on: host,
                spokenTitle: "Camera still closed",
                spokenBody: "Allow the camera in Settings if you want to take a night portrait."
            )
        }
    }
}
