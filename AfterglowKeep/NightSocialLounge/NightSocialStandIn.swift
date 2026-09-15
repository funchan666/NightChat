import UIKit

enum NightSocialStandIn {
    static func plate(seed: String, size: CGSize) -> UIImage {
        let hash = seed.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let hue = CGFloat((hash * 37) % 360) / 360.0
        let colorA = UIColor(hue: hue, saturation: 0.45, brightness: 0.38, alpha: 1)
        let colorB = UIColor(hue: (hue + 0.12).truncatingRemainder(dividingBy: 1), saturation: 0.55, brightness: 0.22, alpha: 1)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let colors = [colorA.cgColor, colorB.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
            let initials = seed.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
            let mark = initials.isEmpty ? "N" : initials
            let font = UIFont.systemFont(ofSize: min(size.width, size.height) * 0.22, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white.withAlphaComponent(0.88),
            ]
            let text = mark as NSString
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2), withAttributes: attrs)
            ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.12).cgColor)
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.stroke(rect.insetBy(dx: 0.5, dy: 0.5))
        }
    }
}
