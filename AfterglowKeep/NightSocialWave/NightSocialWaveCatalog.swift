import Foundation

enum WavePartyLane: Int, CaseIterable {
    case party
    case follow
    case recent

    var spokenTitle: String {
        switch self {
        case .party: return "Party"
        case .follow: return "Follow"
        case .recent: return "Recent"
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
        WaveVoiceChamber(chamberKey: "wave.random.hangout", chamberTitle: "Random Hangout", moodLine: "Evening Ramble", hostDeskKey: "desk.ellis.hart", heatScore: 1540, listenerCount: 8, tongue: .english, vibeTags: ["Voice", "India"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.ellis.hart", "desk.marisol.vega", "desk.priya.raman", "desk.kohei.tanaka", "desk.sable.quinn", "desk.wren.solano", "desk.jonah.ellison", "desk.lila.moreau"]),
        WaveVoiceChamber(chamberKey: "wave.voice.party", chamberTitle: "Voice Live Party", moodLine: "Evening Ramble", hostDeskKey: "desk.marisol.vega", heatScore: 3540, listenerCount: 11, tongue: .spanish, vibeTags: ["Voice", "Talk"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.marisol.vega", "desk.ellis.hart", "desk.nadine.okonkwo", "desk.yara.haddad"]),
        WaveVoiceChamber(chamberKey: "wave.live.voice", chamberTitle: "Live With Your Voice", moodLine: "Evening Ramble", hostDeskKey: "desk.kohei.tanaka", heatScore: 5540, listenerCount: 10, tongue: .english, vibeTags: ["Voice", "Music"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.kohei.tanaka", "desk.idris.belkacem", "desk.amara.diallo"]),
        WaveVoiceChamber(chamberKey: "wave.warm.hangout", chamberTitle: "Warm Voice Hangout", moodLine: "Kitchen Watch", hostDeskKey: "desk.sable.quinn", heatScore: 2540, listenerCount: 6, tongue: .english, vibeTags: ["Chat", "Relax"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.sable.quinn", "desk.jonah.ellison"]),
        WaveVoiceChamber(chamberKey: "wave.roof.radio", chamberTitle: "Roof Radio Circle", moodLine: "After Sign-off", hostDeskKey: "desk.yara.haddad", heatScore: 1840, listenerCount: 7, tongue: .turkish, vibeTags: ["Music", "Night"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.yara.haddad", "desk.kohei.tanaka", "desk.nadine.okonkwo"]),
        WaveVoiceChamber(chamberKey: "wave.harbor.song", chamberTitle: "Harbor Song Desk", moodLine: "Late Tide", hostDeskKey: "desk.amara.diallo", heatScore: 980, listenerCount: 4, tongue: .hindi, vibeTags: ["Voice", "Tide"], isLive: true, isUpcoming: false, seatDeskKeys: ["desk.amara.diallo", "desk.ellis.hart"]),
        WaveVoiceChamber(chamberKey: "wave.kiln.soon", chamberTitle: "Kiln Quiet Preview", moodLine: "Starting after clay sets", hostDeskKey: "desk.wren.solano", heatScore: 220, listenerCount: 0, tongue: .english, vibeTags: ["Relax", "Studio"], isLive: false, isUpcoming: true, seatDeskKeys: ["desk.wren.solano"]),
        WaveVoiceChamber(chamberKey: "wave.dispatch.soon", chamberTitle: "Dispatch Window Soon", moodLine: "Board opens later", hostDeskKey: "desk.idris.belkacem", heatScore: 310, listenerCount: 0, tongue: .english, vibeTags: ["Talk"], isLive: false, isUpcoming: true, seatDeskKeys: ["desk.idris.belkacem"]),
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
                heatScore: 120,
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
