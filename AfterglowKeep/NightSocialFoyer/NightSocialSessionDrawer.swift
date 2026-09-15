import CryptoKit
import Foundation
import UIKit

enum DeskCardArrival {
    case applePassage
    case mailboxEnrollment

    var settleTitle: String {
        switch self {
        case .applePassage: return "Enter"
        case .mailboxEnrollment: return "Next"
        }
    }

    static func fromSession(_ session: NightSocialStageSession) -> DeskCardArrival {
        session.appleIdentityToken.isEmpty ? .mailboxEnrollment : .applePassage
    }
}

struct NightSocialStageSession: Codable, Equatable {
    var deskHolderId: String
    var mailboxAddress: String
    var deskSecretFingerprint: String
    var stageSpokenName: String
    var nightAlias: String
    var nightSignature: String
    var birthMeridianPhrase: String
    var appleIdentityToken: String
    var deskCardCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case deskHolderId, mailboxAddress, deskSecretFingerprint
        case stageSpokenName, nightAlias, nightSignature
        case birthMeridianPhrase, appleIdentityToken, deskCardCompleted
    }

    init(
        deskHolderId: String,
        mailboxAddress: String,
        deskSecretFingerprint: String,
        stageSpokenName: String,
        nightAlias: String,
        nightSignature: String,
        birthMeridianPhrase: String,
        appleIdentityToken: String,
        deskCardCompleted: Bool
    ) {
        self.deskHolderId = deskHolderId
        self.mailboxAddress = mailboxAddress
        self.deskSecretFingerprint = deskSecretFingerprint
        self.stageSpokenName = stageSpokenName
        self.nightAlias = nightAlias
        self.nightSignature = nightSignature
        self.birthMeridianPhrase = birthMeridianPhrase
        self.appleIdentityToken = appleIdentityToken
        self.deskCardCompleted = deskCardCompleted
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        deskHolderId = try box.decode(String.self, forKey: .deskHolderId)
        mailboxAddress = try box.decode(String.self, forKey: .mailboxAddress)
        deskSecretFingerprint = try box.decode(String.self, forKey: .deskSecretFingerprint)
        stageSpokenName = try box.decodeIfPresent(String.self, forKey: .stageSpokenName) ?? ""
        nightAlias = try box.decodeIfPresent(String.self, forKey: .nightAlias) ?? ""
        nightSignature = try box.decodeIfPresent(String.self, forKey: .nightSignature) ?? ""
        birthMeridianPhrase = try box.decodeIfPresent(String.self, forKey: .birthMeridianPhrase) ?? ""
        appleIdentityToken = try box.decodeIfPresent(String.self, forKey: .appleIdentityToken) ?? ""
        deskCardCompleted = try box.decodeIfPresent(Bool.self, forKey: .deskCardCompleted) ?? false
    }

    var suggestionSpokenNames: [String] {
        var names: [String] = []
        let full = NightSocialFoyerGuard.trimmed(stageSpokenName)
        if !full.isEmpty { names.append(full) }
        if let first = full.split(separator: " ").first.map(String.init), first != full, !first.isEmpty {
            names.append(first)
        }
        let alias = NightSocialFoyerGuard.trimmed(nightAlias)
        if !alias.isEmpty, !names.contains(alias) { names.append(alias) }
        return names
    }
}

final class NightSocialSessionDrawer {
    static let shared = NightSocialSessionDrawer()

    private enum DrawerSlot {
        static let stageSession = "lampdesk.nightSocial.stageSession.v1"
        static let portraitFile = "night-social-desk-portrait.jpg"
        static let houseCovenant = "lampdesk.nightSocial.houseCovenant.v1"
        static let seatedFlag = "lampdesk.nightSocial.seatedAtLounge.v1"
        static let diamondPurse = "lampdesk.nightSocial.diamondPurse.v1"
        static let followedDesks = "lampdesk.nightSocial.followedDesks.v1"
        static let blockedDesks = "lampdesk.nightSocial.blockedDesks.v1"
    }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var liveSession: NightSocialStageSession?

    private init() {}

    func openDrawer() {
        liveSession = decode(NightSocialStageSession.self, key: DrawerSlot.stageSession)
        if liveSession?.deskCardCompleted == true {
            defaults.set(true, forKey: DrawerSlot.seatedFlag)
        }
    }

    func restoredSession() -> NightSocialStageSession? {
        liveSession
    }

    var isSeatedAtLounge: Bool {
        (liveSession?.deskCardCompleted ?? false) || defaults.bool(forKey: DrawerSlot.seatedFlag)
    }

    var houseCovenantAccepted: Bool {
        defaults.bool(forKey: DrawerSlot.houseCovenant)
    }

    func rememberHouseCovenant(_ accepted: Bool) {
        defaults.set(accepted, forKey: DrawerSlot.houseCovenant)
    }

    func beginEnrollment(stageSpokenName: String, mailboxAddress: String, deskSecret: String) {
        let trimmedMail = mailboxAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let spoken = NightSocialFoyerGuard.trimmed(stageSpokenName)
        let card = NightSocialStageSession(
            deskHolderId: UUID().uuidString,
            mailboxAddress: trimmedMail,
            deskSecretFingerprint: Self.fingerprint(deskSecret),
            stageSpokenName: spoken,
            nightAlias: spoken,
            nightSignature: "",
            birthMeridianPhrase: "",
            appleIdentityToken: "",
            deskCardCompleted: false
        )
        persist(card)
        defaults.set(false, forKey: DrawerSlot.seatedFlag)
    }

    func beginApplePassage(appleIdentityToken: String, stageSpokenName: String, mailboxAddress: String) {
        if var existing = liveSession, existing.appleIdentityToken == appleIdentityToken {
            if !stageSpokenName.isEmpty { existing.stageSpokenName = stageSpokenName }
            if existing.nightAlias.isEmpty, !stageSpokenName.isEmpty { existing.nightAlias = stageSpokenName }
            if !mailboxAddress.isEmpty { existing.mailboxAddress = mailboxAddress }
            persist(existing)
            return
        }
        let spoken = NightSocialFoyerGuard.trimmed(stageSpokenName)
        let card = NightSocialStageSession(
            deskHolderId: appleIdentityToken.isEmpty ? UUID().uuidString : appleIdentityToken,
            mailboxAddress: mailboxAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            deskSecretFingerprint: "",
            stageSpokenName: spoken,
            nightAlias: spoken,
            nightSignature: "",
            birthMeridianPhrase: "",
            appleIdentityToken: appleIdentityToken,
            deskCardCompleted: false
        )
        persist(card)
        defaults.set(false, forKey: DrawerSlot.seatedFlag)
    }

    func attemptReturn(mailboxAddress: String, deskSecret: String) -> Bool {
        let trimmedMail = mailboxAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let card = liveSession else { return false }
        guard card.mailboxAddress == trimmedMail else { return false }
        guard card.deskSecretFingerprint == Self.fingerprint(deskSecret) else { return false }
        return true
    }

    func finishDeskCard(nightAlias: String, nightSignature: String, portrait: UIImage?) {
        guard var card = liveSession else { return }
        card.nightAlias = NightSocialFoyerGuard.trimmed(nightAlias)
        card.nightSignature = NightSocialFoyerGuard.trimmed(nightSignature)
        card.deskCardCompleted = true
        persist(card)
        defaults.set(true, forKey: DrawerSlot.seatedFlag)
        if let portrait {
            writePortrait(portrait)
        }
    }

    func markSeatedAfterReturn() {
        guard var card = liveSession else { return }
        card.deskCardCompleted = true
        persist(card)
        defaults.set(true, forKey: DrawerSlot.seatedFlag)
    }

    func loadPortrait() -> UIImage? {
        let url = portraitURL()
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    var diamondPurse: Int {
        if defaults.object(forKey: DrawerSlot.diamondPurse) == nil { return 369 }
        return defaults.integer(forKey: DrawerSlot.diamondPurse)
    }

    func writeDiamondPurse(_ amount: Int) {
        defaults.set(max(0, amount), forKey: DrawerSlot.diamondPurse)
    }

    func followedDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.followedDesks) ?? ["desk.ellis.hart", "desk.kohei.tanaka", "desk.marisol.vega"])
    }

    func isFollowing(_ deskKey: String) -> Bool {
        followedDeskKeys().contains(deskKey)
    }

    func toggleFollow(_ deskKey: String) {
        var keys = followedDeskKeys()
        if keys.contains(deskKey) { keys.remove(deskKey) } else { keys.insert(deskKey) }
        defaults.set(Array(keys), forKey: DrawerSlot.followedDesks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func blockedDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.blockedDesks) ?? [])
    }

    func isBlocked(_ deskKey: String) -> Bool {
        blockedDeskKeys().contains(deskKey)
    }

    func blockDesk(_ deskKey: String) {
        var keys = blockedDeskKeys()
        keys.insert(deskKey)
        defaults.set(Array(keys), forKey: DrawerSlot.blockedDesks)
        var followed = followedDeskKeys()
        followed.remove(deskKey)
        defaults.set(Array(followed), forKey: DrawerSlot.followedDesks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    private func persist(_ card: NightSocialStageSession) {
        liveSession = card
        if let data = try? encoder.encode(card) {
            defaults.set(data, forKey: DrawerSlot.stageSession)
        }
        defaults.synchronize()
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func portraitURL() -> URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(DrawerSlot.portraitFile)
    }

    private func writePortrait(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.86) else { return }
        try? data.write(to: portraitURL(), options: .atomic)
    }

    static func fingerprint(_ secret: String) -> String {
        let digest = SHA256.hash(data: Data(secret.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
