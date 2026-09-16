import Foundation

enum LoungeBrowseLane: Int, CaseIterable {
    case all
    case live
    case fresh
    case follow
    case music

    var spokenTitle: String {
        switch self {
        case .all: return "ALL"
        case .live: return "Live"
        case .fresh: return "New"
        case .follow: return "Follow"
        case .music: return "Music"
        }
    }

    var sectionTitle: String {
        switch self {
        case .all: return "Featured creators"
        case .live: return "Live rooms"
        case .fresh: return "New Video"
        case .follow: return "Follow creators"
        case .music: return "Night tracks"
        }
    }
}

enum LoungeMeridianLane: String, CaseIterable {
    case global = "Global"
    case europe = "Europe"
    case eastAsia = "East Asia"
    case latin = "Latin"
    case africa = "Africa"
}

struct LoungeCreatorDesk: Equatable {
    let deskKey: String
    let spokenName: String
    let cityLabel: String
    let handleTag: String
    let vibeLine: String
    let vibeTags: [String]
    let levelMark: Int
    let likeCount: Int
    let followerCount: String
    let friendCount: String
    let watchingCount: String
    let matchPercent: String
    let activityScore: Int
    let isHot: Bool
    let isLive: Bool
    let meridian: LoungeMeridianLane
    let clipCaptions: [String]
    let musicTitle: String
}

struct LoungeLiveBooth: Equatable {
    let boothKey: String
    let boothTitle: String
    let moodLine: String
    let hostDeskKey: String
    let hostSpokenName: String
    let hostAge: Int
    let hostCity: String
    let vibeTags: [String]
    let watcherCount: Int
    let giftCount: Int
    let likeCount: Int
    let durationPhrase: String
    let regionLabel: String
    let meridian: LoungeMeridianLane
}

struct LoungeClipReel: Equatable {
    let clipKey: String
    let authorDeskKey: String
    let authorSpokenName: String
    let caption: String
    let placeLabel: String
    let timePhrase: String
    let likeCount: Int
    let commentCount: Int
    let shareCount: Int
    let meridian: LoungeMeridianLane
    let musicTitle: String

    var trackSeconds: Int {
        95 + abs(clipKey.hashValue % 140)
    }

    var durationPhrase: String {
        String(format: "%d:%02d", trackSeconds / 60, trackSeconds % 60)
    }
}

struct LoungeGiftToken: Equatable {
    let giftKey: String
    let spokenTitle: String
    let diamondCost: Int
    let glyphCatalog: String
}

struct LoungeDiscussLine: Equatable, Codable {
    var lineKey: String
    var speakerDeskKey: String
    var speakerName: String
    var spokenBody: String
    var spokenAt: TimeInterval

    init(
        lineKey: String = UUID().uuidString,
        speakerDeskKey: String = "",
        speakerName: String,
        spokenBody: String,
        spokenAt: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.lineKey = lineKey
        self.speakerDeskKey = speakerDeskKey
        self.speakerName = speakerName
        self.spokenBody = spokenBody
        self.spokenAt = spokenAt
    }
}

enum NightSocialLoungeCatalog {
    private static let originalCreators: [LoungeCreatorDesk] = [
        LoungeCreatorDesk(deskKey: "desk.marisol.vega", spokenName: "Marisol Vega", cityLabel: "Mexico City", handleTag: "@cardamom.proof", vibeLine: "Ovens after midnight, rain on bakery glass, slow talk.", vibeTags: ["CasualTalk", "NightBake"], levelMark: 28, likeCount: 245, followerCount: "8.2k", friendCount: "18", watchingCount: "214", matchPercent: "84%", activityScore: 1720, isHot: true, isLive: true, meridian: .latin, clipCaptions: ["Keep the proof warm.", "Rain on the glass still talks."], musicTitle: "Cardamom After Rain"),
        LoungeCreatorDesk(deskKey: "desk.ellis.hart", spokenName: "Ellis Hart", cityLabel: "Halifax", handleTag: "@harbor.watch", vibeLine: "Wind, charts, and a thermos that lasts the shift.", vibeTags: ["MoodTalk", "Harbor"], levelMark: 32, likeCount: 318, followerCount: "12.4k", friendCount: "24", watchingCount: "356", matchPercent: "88%", activityScore: 2410, isHot: true, isLive: true, meridian: .europe, clipCaptions: ["Barometer dropped.", "Send the weather back."], musicTitle: "Late Tide"),
        LoungeCreatorDesk(deskKey: "desk.priya.raman", spokenName: "Priya Raman", cityLabel: "London", handleTag: "@overlap.desk", vibeLine: "Hours that only meet after someone else's dinner.", vibeTags: ["VoiceChat", "Overlap"], levelMark: 21, likeCount: 190, followerCount: "6.1k", friendCount: "31", watchingCount: "142", matchPercent: "76%", activityScore: 980, isHot: false, isLive: true, meridian: .europe, clipCaptions: ["San Jose is pouring coffee.", "Last stand-up of the night."], musicTitle: "Two Offices"),
        LoungeCreatorDesk(deskKey: "desk.kohei.tanaka", spokenName: "Kohei Tanaka", cityLabel: "Osaka", handleTag: "@after.signoff", vibeLine: "Headphones on the hook, playlist still warm.", vibeTags: ["RelaxChat", "SignOff"], levelMark: 34, likeCount: 412, followerCount: "15.8k", friendCount: "22", watchingCount: "401", matchPercent: "91%", activityScore: 3100, isHot: true, isLive: true, meridian: .eastAsia, clipCaptions: ["Last weather read is done.", "Sit without the microphone."], musicTitle: "After Sign-off"),
        LoungeCreatorDesk(deskKey: "desk.sable.quinn", spokenName: "Sable Quinn", cityLabel: "Portland", handleTag: "@kettle.watch", vibeLine: "A saucepan and a chair that is not ready for bed.", vibeTags: ["MoodTalk", "Kitchen"], levelMark: 16, likeCount: 156, followerCount: "3.4k", friendCount: "12", watchingCount: "88", matchPercent: "71%", activityScore: 640, isHot: false, isLive: true, meridian: .global, clipCaptions: ["Lentils and steam.", "No advice, just the kettle."], musicTitle: "Kitchen at Two"),
        LoungeCreatorDesk(deskKey: "desk.nadine.okonkwo", spokenName: "Nadine Okonkwo", cityLabel: "Lagos", handleTag: "@late.score", vibeLine: "Phrases that will not behave in daylight.", vibeTags: ["VoiceChat", "Studio"], levelMark: 25, likeCount: 278, followerCount: "9.7k", friendCount: "19", watchingCount: "265", matchPercent: "82%", activityScore: 1540, isHot: true, isLive: true, meridian: .africa, clipCaptions: ["A phrase for daylight.", "Bakers hear more than musicians."], musicTitle: "Clay and Strings"),
        LoungeCreatorDesk(deskKey: "desk.wren.solano", spokenName: "Wren Solano", cityLabel: "Santa Fe", handleTag: "@kiln.night", vibeLine: "Kiln night. I listen more than I talk.", vibeTags: ["RelaxChat", "Clay"], levelMark: 19, likeCount: 201, followerCount: "4.8k", friendCount: "15", watchingCount: "121", matchPercent: "79%", activityScore: 870, isHot: false, isLive: true, meridian: .latin, clipCaptions: ["Kiln is closed for the hour.", "Cardamom travels farther than clay."], musicTitle: "Kiln Quiet"),
        LoungeCreatorDesk(deskKey: "desk.jonah.ellison", spokenName: "Jonah Ellison", cityLabel: "Pittsburgh", handleTag: "@night.floor", vibeLine: "Forty minutes is a long break if the sitting is kind.", vibeTags: ["CasualTalk", "NightFloor"], levelMark: 22, likeCount: 233, followerCount: "7.1k", friendCount: "27", watchingCount: "198", matchPercent: "80%", activityScore: 1210, isHot: true, isLive: true, meridian: .global, clipCaptions: ["The new charge is doing well.", "Hospitals and hotels share the carpet hour."], musicTitle: "Board Quiet"),
        LoungeCreatorDesk(deskKey: "desk.lila.moreau", spokenName: "Lila Moreau", cityLabel: "Montreal", handleTag: "@night.audit", vibeLine: "Ledger, keys, and the lobby after the last check-in.", vibeTags: ["CasualTalk", "Lobby"], levelMark: 27, likeCount: 167, followerCount: "5.2k", friendCount: "11", watchingCount: "93", matchPercent: "74%", activityScore: 760, isHot: false, isLive: true, meridian: .europe, clipCaptions: ["Last check-in was a violin case.", "Ledger is behaving."], musicTitle: "Green Lamp"),
        LoungeCreatorDesk(deskKey: "desk.idris.belkacem", spokenName: "Idris Belkacem", cityLabel: "Algiers", handleTag: "@long.haul", vibeLine: "Boards, radios, and a window that never quite sleeps.", vibeTags: ["MoodTalk", "Dispatch"], levelMark: 29, likeCount: 289, followerCount: "11.0k", friendCount: "16", watchingCount: "277", matchPercent: "86%", activityScore: 1980, isHot: true, isLive: true, meridian: .africa, clipCaptions: ["Board is thin tonight.", "Wind from a different coast."], musicTitle: "Thin Board"),
        LoungeCreatorDesk(deskKey: "desk.amara.diallo", spokenName: "Amara Diallo", cityLabel: "Dakar", handleTag: "@harbor.song", vibeLine: "Late drums and a window on the tide.", vibeTags: ["VoiceChat", "Tide"], levelMark: 18, likeCount: 144, followerCount: "2.9k", friendCount: "9", watchingCount: "64", matchPercent: "69%", activityScore: 510, isHot: false, isLive: true, meridian: .africa, clipCaptions: ["The tide keeps better time.", "Sing after the market closes."], musicTitle: "Market Close"),
        LoungeCreatorDesk(deskKey: "desk.yara.haddad", spokenName: "Yara Haddad", cityLabel: "Beirut", handleTag: "@roof.radio", vibeLine: "Roof radio and a city that glows in pieces.", vibeTags: ["NewFriends", "Roof"], levelMark: 23, likeCount: 221, followerCount: "6.6k", friendCount: "20", watchingCount: "175", matchPercent: "77%", activityScore: 1120, isHot: true, isLive: true, meridian: .eastAsia, clipCaptions: ["The generator hummed first.", "Keep the roof lamp low."], musicTitle: "Roof Radio"),
    ]

    private static let originalBooths: [LoungeLiveBooth] = [
        LoungeLiveBooth(boothKey: "booth.random.hangout", boothTitle: "Random Hangout", moodLine: "Evening Ramble", hostDeskKey: "desk.ellis.hart", hostSpokenName: "Ellis Hart", hostAge: 32, hostCity: "Halifax", vibeTags: ["CasualTalk", "NewFriends"], watcherCount: 256, giftCount: 2400, likeCount: 12, durationPhrase: "01:14:58", regionLabel: "Canada", meridian: .europe),
        LoungeLiveBooth(boothKey: "booth.mood.sharing", boothTitle: "Mood Sharing", moodLine: "Evening Ramble", hostDeskKey: "desk.marisol.vega", hostSpokenName: "Marisol Vega", hostAge: 34, hostCity: "Mexico City", vibeTags: ["MoodTalk", "RelaxChat"], watcherCount: 256, giftCount: 1800, likeCount: 18, durationPhrase: "00:47:12", regionLabel: "Mexico", meridian: .latin),
        LoungeLiveBooth(boothKey: "booth.chill.vent", boothTitle: "Chill & Vent", moodLine: "Evening Ramble", hostDeskKey: "desk.kohei.tanaka", hostSpokenName: "Kohei Tanaka", hostAge: 41, hostCity: "Osaka", vibeTags: ["CasualTalk", "NewFriends"], watcherCount: 256, giftCount: 3200, likeCount: 22, durationPhrase: "02:03:40", regionLabel: "Japan", meridian: .eastAsia),
        LoungeLiveBooth(boothKey: "booth.thin.board", boothTitle: "Dispatch Window", moodLine: "Night Board", hostDeskKey: "desk.idris.belkacem", hostSpokenName: "Idris Belkacem", hostAge: 38, hostCity: "Algiers", vibeTags: ["MoodTalk", "Dispatch"], watcherCount: 188, giftCount: 960, likeCount: 9, durationPhrase: "00:33:05", regionLabel: "Algeria", meridian: .africa),
        LoungeLiveBooth(boothKey: "booth.kiln.quiet", boothTitle: "Kiln Quiet", moodLine: "Late Studio", hostDeskKey: "desk.wren.solano", hostSpokenName: "Wren Solano", hostAge: 36, hostCity: "Santa Fe", vibeTags: ["RelaxChat", "Clay"], watcherCount: 94, giftCount: 410, likeCount: 6, durationPhrase: "00:21:18", regionLabel: "USA", meridian: .latin),
    ]

    static let creators: [LoungeCreatorDesk] = originalCreators + NightSocialMediaAssets.people
        .filter { person in !originalCreators.contains { $0.deskKey == person.deskKey } }
        .map { person in
            LoungeCreatorDesk(
                deskKey: person.deskKey, spokenName: person.spokenName,
                cityLabel: "NightChat", handleTag: "@" + person.deskKey.dropFirst(5),
                vibeLine: "Sharing moments and meeting new friends.", vibeTags: ["NewFriends", "CasualTalk"],
                levelMark: 1, likeCount: 0, followerCount: "0", friendCount: "0", watchingCount: "0",
                matchPercent: "", activityScore: 0, isHot: false, isLive: person.video != nil,
                meridian: .global, clipCaptions: [], musicTitle: ""
            )
        }

    // One room per supplied video. The original room keys remain stable so
    // existing navigation and stored relations still work.
    static let booths: [LoungeLiveBooth] = originalBooths + NightSocialMediaAssets.people
        .filter { person in person.video != nil && !originalBooths.contains { $0.hostDeskKey == person.deskKey } }
        .map { person in
            LoungeLiveBooth(
                boothKey: "booth.media." + person.deskKey, boothTitle: person.spokenName + "'s room",
                moodLine: "Come say hello", hostDeskKey: person.deskKey, hostSpokenName: person.spokenName,
                hostAge: 25, hostCity: "NightChat", vibeTags: ["CasualTalk", "NewFriends"],
                watcherCount: 0, giftCount: 0, likeCount: 0, durationPhrase: "00:00:00",
                regionLabel: "Global", meridian: .global
            )
        }

    static let clips: [LoungeClipReel] = [
        LoungeClipReel(clipKey: "clip.marisol.1", authorDeskKey: "desk.marisol.vega", authorSpokenName: "Marisol Vega", caption: "Keep my world soft, and meet interesting souls in live spaces.", placeLabel: "Mexico City", timePhrase: "2026-04-11 01:12", likeCount: 2254, commentCount: 154, shareCount: 88, meridian: .latin, musicTitle: "Cardamom After Rain"),
        LoungeClipReel(clipKey: "clip.ellis.1", authorDeskKey: "desk.ellis.hart", authorSpokenName: "Ellis Hart", caption: "The wind off the dock still knows my name.", placeLabel: "Halifax", timePhrase: "2026-04-10 23:40", likeCount: 1802, commentCount: 96, shareCount: 41, meridian: .europe, musicTitle: "Late Tide"),
        LoungeClipReel(clipKey: "clip.priya.1", authorDeskKey: "desk.priya.raman", authorSpokenName: "Priya Raman", caption: "Two offices, one lamp, no daylight required.", placeLabel: "London", timePhrase: "2026-04-09 21:05", likeCount: 990, commentCount: 44, shareCount: 19, meridian: .europe, musicTitle: "Two Offices"),
        LoungeClipReel(clipKey: "clip.nadine.1", authorDeskKey: "desk.nadine.okonkwo", authorSpokenName: "Nadine Okonkwo", caption: "A phrase I will not play until morning.", placeLabel: "Lagos", timePhrase: "2026-04-08 02:18", likeCount: 1340, commentCount: 71, shareCount: 28, meridian: .africa, musicTitle: "Clay and Strings"),
        LoungeClipReel(clipKey: "clip.sable.1", authorDeskKey: "desk.sable.quinn", authorSpokenName: "Sable Quinn", caption: "Soup is a form of sitting.", placeLabel: "Portland", timePhrase: "2026-04-07 02:02", likeCount: 640, commentCount: 33, shareCount: 12, meridian: .global, musicTitle: "Kitchen at Two"),
        LoungeClipReel(clipKey: "clip.yara.1", authorDeskKey: "desk.yara.haddad", authorSpokenName: "Yara Haddad", caption: "Keep the roof lamp low so the city can rest.", placeLabel: "Beirut", timePhrase: "2026-04-06 00:55", likeCount: 870, commentCount: 51, shareCount: 17, meridian: .eastAsia, musicTitle: "Roof Radio"),
        LoungeClipReel(clipKey: "clip.kohei.1", authorDeskKey: "desk.kohei.tanaka", authorSpokenName: "Kohei Tanaka", caption: "Headphones on the hook. Come sit without the microphone.", placeLabel: "Osaka", timePhrase: "2026-04-05 23:11", likeCount: 2110, commentCount: 120, shareCount: 64, meridian: .eastAsia, musicTitle: "After Sign-off"),
        LoungeClipReel(clipKey: "clip.jonah.1", authorDeskKey: "desk.jonah.ellison", authorSpokenName: "Jonah Ellison", caption: "Forty minutes. Kind sitting. Then the board.", placeLabel: "Pittsburgh", timePhrase: "2026-04-04 19:48", likeCount: 720, commentCount: 29, shareCount: 11, meridian: .global, musicTitle: "Board Quiet"),
    ]

    static let gifts: [LoungeGiftToken] = [
        LoungeGiftToken(giftKey: "gift.wand", spokenTitle: "Wand", diamondCost: 99, glyphCatalog: "GiftWand"),
        LoungeGiftToken(giftKey: "gift.fist", spokenTitle: "Fist", diamondCost: 99, glyphCatalog: "GiftFist"),
        LoungeGiftToken(giftKey: "gift.heart", spokenTitle: "Heart", diamondCost: 99, glyphCatalog: "GiftHeart"),
        LoungeGiftToken(giftKey: "gift.bolt", spokenTitle: "Bolt", diamondCost: 99, glyphCatalog: "GiftBolt"),
        LoungeGiftToken(giftKey: "gift.laugh", spokenTitle: "Cheer", diamondCost: 199, glyphCatalog: "GiftLaugh"),
        LoungeGiftToken(giftKey: "gift.balloons", spokenTitle: "Lift", diamondCost: 199, glyphCatalog: "GiftBalloons"),
        LoungeGiftToken(giftKey: "gift.cake", spokenTitle: "Cake", diamondCost: 199, glyphCatalog: "GiftCake"),
        LoungeGiftToken(giftKey: "gift.whistle", spokenTitle: "Whistle", diamondCost: 199, glyphCatalog: "GiftWhistle"),
    ]

    static func creator(deskKey: String) -> LoungeCreatorDesk? {
        creators.first { $0.deskKey == deskKey }
    }

    static func booth(boothKey: String) -> LoungeLiveBooth? {
        booths.first { $0.boothKey == boothKey }
    }

    static func booth(hostedBy deskKey: String) -> LoungeLiveBooth? {
        booths.first { $0.hostDeskKey == deskKey }
    }

    static func clip(clipKey: String) -> LoungeClipReel? {
        clips.first { $0.clipKey == clipKey }
    }

    static func clips(for deskKey: String) -> [LoungeClipReel] {
        clips.filter { $0.authorDeskKey == deskKey }
    }

    static func visibleCreators() -> [LoungeCreatorDesk] {
        creators.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.deskKey) }
    }

    static func visibleClips() -> [LoungeClipReel] {
        clips.filter { !NightSocialSessionDrawer.shared.shouldHideClip($0.clipKey, authorDeskKey: $0.authorDeskKey) }
    }

    static func visibleBooths() -> [LoungeLiveBooth] {
        booths.filter { !NightSocialSessionDrawer.shared.shouldHideDesk($0.hostDeskKey) }
    }

    static func discussLines(for clipKey: String) -> [LoungeDiscussLine] {
        guard let clip = clip(clipKey: clipKey) else { return [] }
        let others = creators.filter { $0.deskKey != clip.authorDeskKey }
        guard others.count >= 2 else { return [] }
        let seed = abs(clipKey.hashValue)
        let first = others[seed % others.count]
        let second = others[(seed / 7) % others.count]
        let phrases = [
            "That sitting was really amazing.",
            "The lamp talk landed.",
            "Saving this for the morning shift.",
            "Keep the roof lamp low.",
        ]
        return [
            LoungeDiscussLine(
                lineKey: "\(clipKey).seed.\(first.deskKey)",
                speakerDeskKey: first.deskKey,
                speakerName: first.spokenName,
                spokenBody: phrases[seed % phrases.count],
                spokenAt: Date().timeIntervalSince1970 - 3600
            ),
            LoungeDiscussLine(
                lineKey: "\(clipKey).seed.\(second.deskKey).b",
                speakerDeskKey: second.deskKey,
                speakerName: second.spokenName,
                spokenBody: phrases[(seed / 3) % phrases.count],
                spokenAt: Date().timeIntervalSince1970 - 1800
            ),
        ]
    }
}
