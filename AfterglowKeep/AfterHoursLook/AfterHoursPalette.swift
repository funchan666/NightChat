import CoreText
import UIKit

enum AfterHoursPalette {
    static let magentaPeak = UIColor(red: 1.00, green: 0.22, blue: 0.72, alpha: 1)
    static let peachWash = UIColor(red: 1.00, green: 0.69, blue: 0.62, alpha: 1)
    static let snowCard = UIColor.white
    static let midnightPill = UIColor(red: 0.11, green: 0.07, blue: 0.12, alpha: 1)
    static let mistPlaceholder = UIColor(red: 0.73, green: 0.73, blue: 0.75, alpha: 1)
    static let titleSnow = UIColor.white
    static let inkOnSnow = UIColor(red: 0.10, green: 0.08, blue: 0.12, alpha: 1)
    static let hairlineMist = UIColor(red: 0.93, green: 0.93, blue: 0.94, alpha: 1)
    static let footerSnow = UIColor.white.withAlphaComponent(0.94)
    static let portraitDiscFill = UIColor.white.withAlphaComponent(0.28)
    static let stageDockPlum = UIColor(red: 0x8A / 255.0, green: 0x11 / 255.0, blue: 0x5C / 255.0, alpha: 1)
    static let loungeInk = UIColor(red: 0.165, green: 0.035, blue: 0.145, alpha: 1)
    static let loungeCard = UIColor(red: 0.31, green: 0.08, blue: 0.27, alpha: 1)
    static let loungePink = UIColor(red: 1.00, green: 0.29, blue: 0.62, alpha: 1)
    static let foyerGlowPink = UIColor(red: 1.00, green: 0.42, blue: 0.72, alpha: 1)
    static let foyerNightCard = UIColor(red: 0.17, green: 0.05, blue: 0.16, alpha: 0.94)
    static let levelMint = UIColor(red: 0.49, green: 0.98, blue: 0.70, alpha: 1)
}

enum AfterHoursType {
    private static var facesReady = false

    static func registerLampFaces() {
        guard !facesReady else { return }
        facesReady = true
        let files = ["Syne.ttf", "Outfit-Regular.ttf", "Outfit-Medium.ttf", "Outfit-SemiBold.ttf"]
        for file in files {
            let stem = (file as NSString).deletingPathExtension
            let ext = (file as NSString).pathExtension
            let url = Bundle.main.url(forResource: stem, withExtension: ext)
                ?? Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: "Fonts")
            guard let url else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func foyerHeadline(_ size: CGFloat) -> UIFont {
        face("Outfit-SemiBold", size: size, fallback: .bold)
    }

    static func foyerPill(_ size: CGFloat) -> UIFont {
        face("Outfit-SemiBold", size: size, fallback: .semibold)
    }

    static func foyerBody(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if weight.rawValue >= UIFont.Weight.semibold.rawValue {
            return face("Outfit-SemiBold", size: size, fallback: weight)
        }
        if weight.rawValue >= UIFont.Weight.medium.rawValue {
            return face("Outfit-Medium", size: size, fallback: weight)
        }
        return face("Outfit-Regular", size: size, fallback: weight)
    }

    static func foyerCaption(_ size: CGFloat) -> UIFont {
        face("Outfit-Medium", size: size, fallback: .medium)
    }

    private static func face(_ postscript: String, size: CGFloat, fallback: UIFont.Weight) -> UIFont {
        registerLampFaces()
        return UIFont(name: postscript, size: size) ?? UIFont.systemFont(ofSize: size, weight: fallback)
    }

}

enum NightSocialImageCabinet {
    static var stageWash: UIImage? {
        UIImage(named: "MagentaStageWash") ?? UIImage(named: "background")
    }

    static var stageMark: UIImage? {
        UIImage(named: "NightSocialStageMark") ?? UIImage(named: "Group_891")
    }

    static var portraitLens: UIImage? {
        UIImage(named: "PortraitLensBadge") ?? UIImage(named: "Frame_1")
    }

    static func dockHouse(lit: Bool) -> UIImage? {
        lit
            ? (UIImage(named: "DockHouseLit") ?? UIImage(named: "Group_146@2x(1)"))
            : (UIImage(named: "DockHouseIdle") ?? UIImage(named: "tab1"))
    }

    static func dockWave(lit: Bool) -> UIImage? {
        lit
            ? (UIImage(named: "DockWaveLit") ?? UIImage(named: "Frame@2x(59)"))
            : (UIImage(named: "DockWaveIdle") ?? UIImage(named: "tab2"))
    }

    static func dockChime(lit: Bool) -> UIImage? {
        lit
            ? (UIImage(named: "DockChimeLit") ?? UIImage(named: "Group_150@2x(1)"))
            : (UIImage(named: "DockChimeIdle") ?? UIImage(named: "tab3"))
    }

    static func dockSmile(lit: Bool) -> UIImage? {
        lit
            ? (UIImage(named: "DockSmileLit") ?? UIImage(named: "Group_148@2x(1)"))
            : (UIImage(named: "DockSmileIdle") ?? UIImage(named: "tab4"))
    }

    static func named(_ catalog: String, fallback: String) -> UIImage? {
        UIImage(named: catalog) ?? UIImage(named: fallback)
    }
}
