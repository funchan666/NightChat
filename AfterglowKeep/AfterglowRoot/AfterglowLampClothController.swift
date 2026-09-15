import UIKit

final class AfterglowLampClothController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AfterHoursPalette.inkWell

        let lampCloth = UIImageView(image: UIImage(named: "LaunchLampCloth"))
        lampCloth.contentMode = .scaleAspectFill
        lampCloth.clipsToBounds = true
        lampCloth.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lampCloth)
        NSLayoutConstraint.activate([
            lampCloth.topAnchor.constraint(equalTo: view.topAnchor),
            lampCloth.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lampCloth.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lampCloth.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
