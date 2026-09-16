import Foundation

struct ChimeLine: Codable, Equatable {
    var speakerIsMe: Bool
    var hushBody: String
    var spokenAt: TimeInterval
}

struct ChimeNotice: Equatable {
    let noticeKey: String
    let spokenBody: String
    let minutesAgo: Int
}

enum NightSocialChimeCatalog {
    static let supportDeskKey = "desk.house.support"

    static let platformNotices: [ChimeNotice] = [
        ChimeNotice(noticeKey: "plat.1", spokenBody: "You have a new system update notification", minutesAgo: 5),
        ChimeNotice(noticeKey: "plat.2", spokenBody: "House rules were refreshed for night sittings", minutesAgo: 18),
        ChimeNotice(noticeKey: "plat.3", spokenBody: "Diamond purse activity was recorded on this desk", minutesAgo: 42),
    ]

    static let likeNotices: [ChimeNotice] = [
        ChimeNotice(noticeKey: "like.1", spokenBody: "Someone liked your post.", minutesAgo: 5),
        ChimeNotice(noticeKey: "like.2", spokenBody: "You have received a new like.", minutesAgo: 5),
        ChimeNotice(noticeKey: "like.3", spokenBody: "A user liked your video content.", minutesAgo: 9),
    ]

    static let supportSeed: [ChimeLine] = [
        ChimeLine(speakerIsMe: false, hushBody: "NightChat house desk here. How can we tend your sitting?", spokenAt: Date().timeIntervalSince1970 - 3600),
    ]

    static func extraDesk(named spoken: String, key: String) -> LoungeCreatorDesk {
        LoungeCreatorDesk(
            deskKey: key,
            spokenName: spoken,
            cityLabel: "Night desk",
            handleTag: "@\(key.split(separator: ".").last ?? "guest")",
            vibeLine: "Keeping company after hours.",
            vibeTags: ["CasualTalk"],
            levelMark: 12,
            likeCount: 40,
            followerCount: "120",
            friendCount: "8",
            watchingCount: "3",
            matchPercent: "64%",
            activityScore: 80,
            isHot: false,
            isLive: false,
            meridian: .global,
            clipCaptions: [],
            musicTitle: ""
        )
    }

    static func desk(for key: String) -> LoungeCreatorDesk? {
        if key == supportDeskKey {
            return extraDesk(named: "Support", key: key)
        }
        if let found = NightSocialLoungeCatalog.creator(deskKey: key) { return found }
        return extraDesk(named: "Night guest", key: key)
    }
}
