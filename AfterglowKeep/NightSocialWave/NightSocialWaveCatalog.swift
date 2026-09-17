import Foundation

enum WavePartyLane: Int, CaseIterable {
    case party
    case follow
    case recent

    var spokenTitle: String {
        switch self {
        case .party: return NightLang.t(.party)
        case .follow: return NightLang.t(.followTab)
        case .recent: return NightLang.t(.recent)
        }
    }
}

enum WaveTongueLane: String, CaseIterable {
    case all = "All"
    case english = "English"
    case hindi = "Hindi"
    case spanish = "Spanish"
    case turkish = "Turkish"
}

struct WaveVoiceChamber: Equatable {
    let chamberKey: String
    let chamberTitle: String
    let moodLine: String
    let hostDeskKey: String
    let heatScore: Int
    let listenerCount: Int
    let tongue: WaveTongueLane
    let vibeTags: [String]
    let isLive: Bool
    let isUpcoming: Bool
    let seatDeskKeys: [String]
}

enum NightSocialWaveCatalog {
    static let chambers: [WaveVoiceChamber] = [
        WaveVoiceChamber(chamberKey: "wave.random.hangout", chamberTitle: "Random Hangout", moodLine: "Evening Ramble", hostDeskKey: "desk.ada.bell", heatScore: 86, listenerCount: 6, tongue: .english, vibeTags: ["Voice", "Chat"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.ada.bell", "desk.ivy.stone", "desk.zoe.wells", "desk.clara.june", "desk.ella.moss", "desk.alex.park"]),
        WaveVoiceChamber(chamberKey: "wave.voice.party", chamberTitle: "Voice Live Party", moodLine: "Evening Ramble", hostDeskKey: "desk.sophia.lane", heatScore: 164, listenerCount: 4, tongue: .spanish, vibeTags: ["Voice", "Talk"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.sophia.lane", "desk.theo.miles", "desk.emma.reed", "desk.luca.brooks"]),
        WaveVoiceChamber(chamberKey: "wave.live.voice", chamberTitle: "Live With Your Voice", moodLine: "Evening Ramble", hostDeskKey: "desk.isla.west", heatScore: 198, listenerCount: 3, tongue: .english, vibeTags: ["Voice", "Music"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.isla.west", "desk.felix.hayes", "desk.nora.blake"]),
        WaveVoiceChamber(chamberKey: "wave.warm.hangout", chamberTitle: "Warm Voice Hangout", moodLine: "Kitchen Watch", hostDeskKey: "desk.noah.rivers", heatScore: 72, listenerCount: 2, tongue: .english, vibeTags: ["Chat", "Relax"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.noah.rivers", "desk.maya.rose"]),
        WaveVoiceChamber(chamberKey: "wave.roof.radio", chamberTitle: "Roof Radio Circle", moodLine: "After Sign-off", hostDeskKey: "desk.leo.gray", heatScore: 91, listenerCount: 3, tongue: .turkish, vibeTags: ["Music", "Night"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.leo.gray", "desk.jude.ford", "desk.finn.woods"]),
        WaveVoiceChamber(chamberKey: "wave.harbor.song", chamberTitle: "Harbor Song Desk", moodLine: "Late Tide", hostDeskKey: "desk.ruby.lake", heatScore: 44, listenerCount: 1, tongue: .hindi, vibeTags: ["Voice", "Tide"], isLive: false, isUpcoming: true, seatDeskKeys: ["desk.ruby.lake"]),
        WaveVoiceChamber(chamberKey: "wave.kiln.soon", chamberTitle: "Kiln Quiet Preview", moodLine: "Starting after clay sets", hostDeskKey: "desk.owen.hill", heatScore: 18, listenerCount: 0, tongue: .english, vibeTags: ["Relax", "Studio"], isLive: false, isUpcoming: true, seatDeskKeys: ["desk.owen.hill"]),
    ]

    static func chamber(_ key: String) -> WaveVoiceChamber? {
        if let found = chambers.first(where: { $0.chamberKey == key }) { return found }
        if let rec = NightSocialSessionDrawer.shared.hostedChamberRecords().first(where: { $0["key"] == key }),
           let title = rec["title"], let host = rec["host"] {
            return WaveVoiceChamber(
                chamberKey: key,
                chamberTitle: title,
                moodLine: rec["mood"] ?? "Hosted sitting",
                hostDeskKey: host,
                heatScore: 16,
                listenerCount: 1,
                tongue: .english,
                vibeTags: (rec["tags"] ?? "Voice").split(separator: ",").map(String.init),
                isLive: true,
                isUpcoming: false,
                seatDeskKeys: [host]
            )
        }
        return nil
    }

    static func hostName(_ chamber: WaveVoiceChamber) -> String {
        NightSocialLoungeCatalog.creator(deskKey: chamber.hostDeskKey)?.spokenName ?? "Host"
    }
}
