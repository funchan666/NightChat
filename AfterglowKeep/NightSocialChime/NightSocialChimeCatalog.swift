import Foundation

struct ChimeLine: Codable, Equatable {
    var speakerIsMe: Bool
    var hushBody: String
    var spokenAt: TimeInterval
}

struct ChimeNotice: Equatable {
    let noticeKey: String
    let spokenTitle: String
    let spokenBody: String
    let minutesAgo: Int
    let speakerDeskKey: String?
    let clipKey: String?
    let glyph: String
    let tintKind: Int
}

enum NightSocialChimeCatalog {
    static let supportDeskKey = "desk.house.support"

    static let platformNotices: [ChimeNotice] = [
        ChimeNotice(noticeKey: "plat.1", spokenTitle: "Room update", spokenBody: "Night rooms were refreshed. Take a look when you are free.", minutesAgo: 5, speakerDeskKey: nil, clipKey: nil, glyph: "sparkles", tintKind: 0),
        ChimeNotice(noticeKey: "plat.2", spokenTitle: "Night note", spokenBody: "Keep rooms kind after dark. Thanks for being here.", minutesAgo: 18, speakerDeskKey: nil, clipKey: nil, glyph: "moon.stars.fill", tintKind: 1),
        ChimeNotice(noticeKey: "plat.3", spokenTitle: "Coins", spokenBody: "A coin change was added to your balance.", minutesAgo: 42, speakerDeskKey: nil, clipKey: nil, glyph: "diamond.fill", tintKind: 2),
    ]

    static var likeNotices: [ChimeNotice] {
        let desks = NightSocialLoungeCatalog.creators
        let clips = NightSocialLoungeCatalog.clips
        let one = desks.indices.contains(0) ? desks[0] : nil
        let two = desks.indices.contains(2) ? desks[2] : nil
        let three = desks.indices.contains(4) ? desks[4] : nil
        let clipA = clips.indices.contains(0) ? clips[0].clipKey : nil
        let clipB = clips.indices.contains(1) ? clips[1].clipKey : nil
        return [
            ChimeNotice(noticeKey: "like.1", spokenTitle: one?.spokenName ?? "A guest", spokenBody: "liked your video", minutesAgo: 5, speakerDeskKey: one?.deskKey, clipKey: clipA, glyph: "heart.fill", tintKind: 0),
            ChimeNotice(noticeKey: "like.2", spokenTitle: two?.spokenName ?? "A guest", spokenBody: "liked your post", minutesAgo: 5, speakerDeskKey: two?.deskKey, clipKey: clipB, glyph: "heart.fill", tintKind: 0),
            ChimeNotice(noticeKey: "like.3", spokenTitle: three?.spokenName ?? "A guest", spokenBody: "liked your video", minutesAgo: 9, speakerDeskKey: three?.deskKey, clipKey: clipA, glyph: "heart.fill", tintKind: 0),
        ]
    }

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
