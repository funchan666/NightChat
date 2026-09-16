import AVFoundation
import UIKit

/// A looping local video behind a room's controls. Only the visible surface
/// owns a player; navigating away or backgrounding the app releases playback.
final class NightSocialVideoSurface: UIView {
    private static weak var activeSurface: NightSocialVideoSurface?
    private let poster: UIImageView
    private let playerLayer = AVPlayerLayer()
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var readiness: NSKeyValueObservation?
    private var applicationObservers: [NSObjectProtocol] = []
    private let url: URL?
    private var wantsPlayback = false
    private var hasStarted = false

    init(ownerKey: String) {
        url = NightSocialMediaAssets.videoURL(for: ownerKey)
        poster = UIImageView(image: NightSocialMediaAssets.cover(for: ownerKey, size: CGSize(width: 430, height: 932)))
        super.init(frame: .zero)
        clipsToBounds = true
        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        addSubview(poster)
        playerLayer.videoGravity = .resizeAspectFill
        layer.insertSublayer(playerLayer, at: 0)
        applicationObservers = [
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.releasePlayer()
            },
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self, self.wantsPlayback, self.window != nil else { return }
                self.start()
            },
        ]
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        poster.frame = bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = bounds
        CATransaction.commit()
    }

    func start() {
        wantsPlayback = true
        guard window != nil, UIApplication.shared.applicationState == .active, let url else { return }
        guard !hasStarted else { return }
        Self.activeSurface?.stop()
        Self.activeSurface = self
        hasStarted = true
        let queue = AVQueuePlayer()
        queue.isMuted = false
        queue.automaticallyWaitsToMinimizeStalling = true
        player = queue
        playerLayer.player = queue
        looper = AVPlayerLooper(player: queue, templateItem: AVPlayerItem(url: url))
        readiness = playerLayer.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] layer, _ in
            DispatchQueue.main.async {
                guard let self, self.hasStarted else { return }
                self.poster.isHidden = layer.isReadyForDisplay
            }
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        queue.play()
    }

    func stop() {
        wantsPlayback = false
        releasePlayer()
    }

    private func releasePlayer() {
        readiness = nil
        player?.pause()
        looper?.disableLooping()
        looper = nil
        playerLayer.player = nil
        player?.removeAllItems()
        player = nil
        hasStarted = false
        poster.isHidden = false
        if Self.activeSurface === self {
            Self.activeSurface = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { releasePlayer() }
    }

    deinit {
        applicationObservers.forEach(NotificationCenter.default.removeObserver)
        readiness = nil
        player?.pause()
        looper?.disableLooping()
    }
}
