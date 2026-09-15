import UIKit

enum AfterHoursPalette {
    static let inkWell = UIColor(red: 0.086, green: 0.067, blue: 0.047, alpha: 1)
    static let walnut = UIColor(red: 0.165, green: 0.122, blue: 0.086, alpha: 1)
    static let brass = UIColor(red: 0.769, green: 0.631, blue: 0.353, alpha: 1)
    static let lampAmber = UIColor(red: 0.902, green: 0.694, blue: 0.361, alpha: 1)
    static let ember = UIColor(red: 0.769, green: 0.361, blue: 0.149, alpha: 1)
    static let creamPaper = UIColor(red: 0.957, green: 0.906, blue: 0.820, alpha: 1)
    static let teaStain = UIColor(red: 0.851, green: 0.769, blue: 0.627, alpha: 1)
    static let hushInk = UIColor(red: 0.173, green: 0.141, blue: 0.110, alpha: 1)
}

enum AfterHoursType {
    static func sittingTitle(_ size: CGFloat) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: .semibold)
        guard let serif = base.fontDescriptor.withDesign(.serif) else { return base }
        return UIFont(descriptor: serif, size: size)
    }

    static func deskBody(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
