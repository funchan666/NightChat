import ImageIO
import UIKit

/// Every bundled photo and video has one owner. Navigation never reassigns it.
/// A person's avatar stays consistent across lists, messages and room seats.
enum NightSocialMediaAssets {
    struct Person: Decodable {
        let deskKey: String
        let spokenName: String
        let portrait: String
        let cover: String
        let presentation: String
        let video: String?
        let videoPresentation: String?
    }
    private struct Manifest: Decodable {
        let localPortrait: String
        let people: [Person]
    }
    private static let manifest: Manifest = {
        guard let url = Bundle.main.url(forResource: "media-manifest", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(Manifest.self, from: data) else {
            assertionFailure("Missing or invalid media-manifest.json")
            return Manifest(localPortrait: "DdRRhFgjMbk.jpg", people: [])
        }
        return decoded
    }()
    static var people: [Person] { manifest.people }
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 40 * 1024 * 1024
        return cache
    }()

    static func person(_ key: String) -> Person? {
        people.first { $0.deskKey == key || $0.spokenName == key }
    }

    static func portrait(for key: String, size: CGSize) -> UIImage {
        if key == NightSocialChimeCatalog.supportDeskKey || key == "Support" {
            return NightSocialImageCabinet.named("ChimeSupportTile", fallback: "Group_920") ?? UIImage()
        }
        if let person = person(key) { return image(person.portrait, size: size) }
        return localPortrait(size: size)
    }

    static func cover(for key: String, size: CGSize) -> UIImage {
        if let person = person(key) { return image(person.cover, size: size) }
        return localCover(size: size)
    }

    static func clipCover(_ key: String, size: CGSize) -> UIImage {
        guard let clip = NightSocialLoungeCatalog.clip(clipKey: key) else { return localCover(size: size) }
        return cover(for: clip.authorDeskKey, size: size)
    }

    static func localPortrait(size: CGSize) -> UIImage {
        NightSocialSessionDrawer.shared.loadPortrait() ?? image(manifest.localPortrait, size: size)
    }

    static func localCover(size: CGSize) -> UIImage {
        NightSocialSessionDrawer.shared.loadCover() ?? localPortrait(size: size)
    }

    static func videoURL(for key: String) -> URL? {
        guard let file = person(key)?.video else { return nil }
        return resource(file, directory: "videos")
    }

    private static func resource(_ file: String, directory: String) -> URL? {
        let path = file as NSString
        return Bundle.main.url(forResource: path.deletingPathExtension, withExtension: path.pathExtension, subdirectory: directory)
    }

    private static func image(_ file: String, size: CGSize) -> UIImage {
        // Decode only the resolution required by this display instead of every
        // full-size photograph when a list scrolls.
        let pixels = min(1600, max(128, Int(max(size.width, size.height) * UIScreen.main.scale)))
        let key = "\(file):\(pixels)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        guard let url = resource(file, directory: "pics"),
              let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: pixels,
                kCGImageSourceShouldCacheImmediately: true,
              ] as CFDictionary) else {
            assertionFailure("Missing photograph: \(file)")
            return UIImage()
        }
        let image = UIImage(cgImage: thumbnail)
        cache.setObject(image, forKey: key, cost: thumbnail.bytesPerRow * thumbnail.height)
        return image
    }
}
