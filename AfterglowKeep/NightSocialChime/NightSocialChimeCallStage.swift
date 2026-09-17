import AVFoundation
import UIKit

final class NightSocialChimeCallStage: UIViewController {
    private let spokenName: String
    private let deskKey: String
    private let cover = UIImageView()
    private let avatar = UIImageView()
    private let namePlate = UILabel()
    private let pip = UIView()
    private let clock = UILabel()
    private var connected = false
    private var muted = false
    private var speakerOn = true
    private var ticks = 0
    private var timer: Timer?
    private let capture = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(spokenName: String, deskKey: String) {
        self.spokenName = spokenName
        self.deskKey = deskKey
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.loungeInk
        additionalSafeAreaInsets = .zero
        cover.image = NightSocialMediaAssets.cover(for: deskKey, size: CGSize(width: 420, height: 760))
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false
        let back = NightSocialLoungeChrome.backControl()
        back.addTarget(self, action: #selector(fold), for: .touchUpInside)
        namePlate.text = spokenName
        namePlate.font = AfterHoursType.foyerHeadline(20)
        namePlate.textColor = .white
        namePlate.isUserInteractionEnabled = true
        namePlate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        namePlate.translatesAutoresizingMaskIntoConstraints = false
        avatar.image = NightSocialMediaAssets.portrait(for: deskKey, size: CGSize(width: 220, height: 220))
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 70
        avatar.clipsToBounds = true
        avatar.layer.borderWidth = 3
        avatar.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDesk)))
        avatar.translatesAutoresizingMaskIntoConstraints = false
        pip.backgroundColor = AfterHoursPalette.loungeCard
        pip.clipsToBounds = true
        pip.layer.cornerRadius = 14
        pip.layer.borderWidth = 1
        pip.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        pip.translatesAutoresizingMaskIntoConstraints = false
        clock.text = "Calling..."
        clock.font = AfterHoursType.foyerCaption(13)
        clock.textColor = .white
        clock.translatesAutoresizingMaskIntoConstraints = false
        let speaker = circleButton(system: "speaker.wave.2.fill", #selector(flipSpeaker))
        let hang = UIButton(type: .custom)
        hang.setImage(NightSocialImageCabinet.named("CallHangUp", fallback: "CallHangUp"), for: .normal)
        hang.imageView?.contentMode = .scaleAspectFit
        hang.addTarget(self, action: #selector(fold), for: .touchUpInside)
        hang.translatesAutoresizingMaskIntoConstraints = false
        let mic = circleButton(system: "mic.fill", #selector(flipMute))
        view.addSubview(cover)
        view.addSubview(back)
        view.addSubview(namePlate)
        view.addSubview(avatar)
        view.addSubview(pip)
        view.addSubview(clock)
        view.addSubview(speaker)
        view.addSubview(hang)
        view.addSubview(mic)
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: view.topAnchor),
            cover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            back.topAnchor.constraint(equalTo: view.topAnchor, constant: 54),
            namePlate.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            namePlate.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            avatar.widthAnchor.constraint(equalToConstant: 140),
            avatar.heightAnchor.constraint(equalToConstant: 140),
            pip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pip.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 24),
            pip.widthAnchor.constraint(equalToConstant: 110),
            pip.heightAnchor.constraint(equalToConstant: 150),
            hang.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hang.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            hang.widthAnchor.constraint(equalToConstant: 64),
            hang.heightAnchor.constraint(equalToConstant: 64),
            speaker.trailingAnchor.constraint(equalTo: hang.leadingAnchor, constant: -28),
            speaker.centerYAnchor.constraint(equalTo: hang.centerYAnchor),
            mic.leadingAnchor.constraint(equalTo: hang.trailingAnchor, constant: 28),
            mic.centerYAnchor.constraint(equalTo: hang.centerYAnchor),
            clock.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clock.bottomAnchor.constraint(equalTo: hang.topAnchor, constant: -18),
        ])
        askLensAndMic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            self?.connectCall()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = pip.bounds
    }

    deinit {
        timer?.invalidate()
        if capture.isRunning { capture.stopRunning() }
    }

    private func circleButton(system: String, _ sel: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: system), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        button.layer.cornerRadius = 28
        button.addTarget(self, action: sel, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 56).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }

    private func askLensAndMic() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] videoOk in
            AVCaptureDevice.requestAccess(for: .audio) { audioOk in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if videoOk {
                        self.startLocalPreview()
                    }
                    if !videoOk || !audioOk {
                        FoyerNotice.present(
                            on: self,
                            spokenTitle: "Lens or mic still closed",
                            spokenBody: "NightChat needs the camera and microphone so you can preview yourself on a video call."
                        )
                    }
                }
            }
        }
    }

    private func startLocalPreview() {
        capture.beginConfiguration()
        capture.sessionPreset = .medium
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: device),
           capture.canAddInput(input) {
            capture.addInput(input)
        }
        capture.commitConfiguration()
        let layer = AVCaptureVideoPreviewLayer(session: capture)
        layer.videoGravity = .resizeAspectFill
        layer.frame = pip.bounds
        pip.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.capture.startRunning()
        }
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func connectCall() {
        connected = true
        clock.text = "00:00"
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.ticks += 1
            let m = self.ticks / 60
            let s = self.ticks % 60
            self.clock.text = String(format: "%02d:%02d", m, s)
        }
    }

    @objc private func openDesk() {
        NightSocialDeskGate.revealDesk(from: self, deskKey: deskKey)
    }
    @objc private func flipSpeaker() {
        speakerOn.toggle()
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(speakerOn ? .speaker : .none)
    }
    @objc private func flipMute() { muted.toggle() }
    @objc private func fold() {
        timer?.invalidate()
        if capture.isRunning { capture.stopRunning() }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        navigationController?.popViewController(animated: true)
    }
}
