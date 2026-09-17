import CryptoKit
import Foundation
import UIKit

extension Notification.Name {
    static let deskDrawerDidChange = Notification.Name("lampdesk.afterglow.deskDrawer.didChange")
}

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
        static let lampWelcome = "lampdesk.nightSocial.lampWelcome.v1"
        static let lampReceipts = "lampdesk.nightSocial.lampReceipts.v1"
        static let followedDesks = "lampdesk.nightSocial.followedDesks.v2"
        static let followerDesks = "lampdesk.nightSocial.followerDesks.v1"
        static let welcomeFansSeeded = "lampdesk.nightSocial.welcomeFansSeeded.v1"
        static let welcomeFanQueue = "lampdesk.nightSocial.welcomeFanQueue.v1"
        static let blockedDesks = "lampdesk.nightSocial.blockedDesks.v1"
        static let reportedDesks = "lampdesk.nightSocial.reportedDesks.v1"
        static let reportedClips = "lampdesk.nightSocial.reportedClips.v1"
        static let reportedLines = "lampdesk.nightSocial.reportedLines.v1"
        static let clipComments = "lampdesk.nightSocial.clipComments.v1"
        static let pendingClips = "lampdesk.nightSocial.pendingClips.v1"
        static let sentFriendAsks = "lampdesk.nightSocial.sentFriendAsks.v1"
        static let incomingFriendAsks = "lampdesk.nightSocial.incomingFriendAsks.v1"
        static let acceptedFriends = "lampdesk.nightSocial.acceptedFriends.v1"
        static let recentChambers = "lampdesk.nightSocial.recentVoiceChambers.v1"
        static let hostedChambers = "lampdesk.nightSocial.hostedVoiceChambers.v1"
        static let seatedChamber = "lampdesk.nightSocial.seatedVoiceChamber.v1"
        static let chimeLines = "lampdesk.nightSocial.chimeLines.v2"
        static let chimeRead = "lampdesk.nightSocial.chimeRead.v2"
        static let platformRead = "lampdesk.nightSocial.platformRead.v1"
        static let likesRead = "lampdesk.nightSocial.likesRead.v1"
        static let spokenTongue = "lampdesk.nightSocial.spokenTongue.v1"
        static let homeCountry = "lampdesk.nightSocial.homeCountry.v1"
        static let genderMark = "lampdesk.nightSocial.genderMark.v1"
        static let profileTags = "lampdesk.nightSocial.profileTags.v1"
        static let checkInDays = "lampdesk.nightSocial.checkInDays.v1"
        static let coverFile = "night-social-desk-cover.jpg"
        static let inviteCode = "lampdesk.nightSocial.inviteCode.v1"
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
        defaults.bool(forKey: DrawerSlot.seatedFlag) && (liveSession?.deskCardCompleted ?? false)
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
        openMailboxDoor(mailboxAddress: mailboxAddress, deskSecret: deskSecret)
        return true
    }

    /// Any well-formed mailbox and secret opens the desk. Matching an existing
    /// session keeps that profile; otherwise a new seated desk is created.
    func openMailboxDoor(mailboxAddress: String, deskSecret: String) {
        let trimmedMail = mailboxAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let print = Self.fingerprint(deskSecret)
        if var card = liveSession, card.mailboxAddress == trimmedMail {
            card.deskSecretFingerprint = print
            card.deskCardCompleted = true
            persist(card)
            defaults.set(true, forKey: DrawerSlot.seatedFlag)
            return
        }
        let spoken = Self.spokenName(fromMailbox: trimmedMail)
        let card = NightSocialStageSession(
            deskHolderId: UUID().uuidString,
            mailboxAddress: trimmedMail,
            deskSecretFingerprint: print,
            stageSpokenName: spoken,
            nightAlias: spoken,
            nightSignature: "",
            birthMeridianPhrase: "",
            appleIdentityToken: "",
            deskCardCompleted: true
        )
        persist(card)
        defaults.set(true, forKey: DrawerSlot.seatedFlag)
    }

    func finishDeskCard(
        nightAlias: String,
        nightSignature: String,
        portrait: UIImage?,
        birthMeridianPhrase: String? = nil,
        homeCountryCode: String? = nil,
        spokenTongue: String? = nil
    ) {
        guard var card = liveSession else { return }
        card.nightAlias = NightSocialFoyerGuard.trimmed(nightAlias)
        card.nightSignature = NightSocialFoyerGuard.trimmed(nightSignature)
        if let birthMeridianPhrase { card.birthMeridianPhrase = birthMeridianPhrase }
        card.deskCardCompleted = true
        persist(card)
        defaults.set(true, forKey: DrawerSlot.seatedFlag)
        if let homeCountryCode { writeHomeCountry(homeCountryCode) }
        if let spokenTongue { writeSpokenTongue(spokenTongue) }
        if let portrait {
            writePortrait(portrait)
        }
    }

    var homeCountryCode: String {
        defaults.string(forKey: DrawerSlot.homeCountry) ?? "US"
    }

    func writeHomeCountry(_ value: String) {
        defaults.set(value, forKey: DrawerSlot.homeCountry)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    var genderMark: String {
        defaults.string(forKey: DrawerSlot.genderMark) ?? ""
    }

    func writeGenderMark(_ value: String) {
        defaults.set(value, forKey: DrawerSlot.genderMark)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    var profileTags: [String] {
        defaults.stringArray(forKey: DrawerSlot.profileTags) ?? ["ChillSocial", "LiveTogether"]
    }

    func writeProfileTags(_ tags: [String]) {
        defaults.set(tags, forKey: DrawerSlot.profileTags)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
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
        if defaults.object(forKey: DrawerSlot.diamondPurse) == nil { return 0 }
        return defaults.integer(forKey: DrawerSlot.diamondPurse)
    }

    func writeDiamondPurse(_ amount: Int) {
        defaults.set(max(0, amount), forKey: DrawerSlot.diamondPurse)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func grantNightLampWelcomeIfNeeded() -> Int {
        if defaults.bool(forKey: DrawerSlot.lampWelcome) { return 0 }
        defaults.set(true, forKey: DrawerSlot.lampWelcome)
        writeDiamondPurse(diamondPurse + NightSocialLampStore.welcomeGrant)
        return NightSocialLampStore.welcomeGrant
    }

    func creditLampPack(productId: String, transactionId: String) {
        var receipts = defaults.stringArray(forKey: DrawerSlot.lampReceipts) ?? []
        if receipts.contains(transactionId) { return }
        guard let pack = NightSocialLampPack.allCases.first(where: { $0.productId == productId }) else { return }
        receipts.append(transactionId)
        defaults.set(receipts, forKey: DrawerSlot.lampReceipts)
        writeDiamondPurse(diamondPurse + pack.coins)
    }

    func followedDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.followedDesks) ?? [])
    }

    func followerDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.followerDesks) ?? [])
    }

    func isFollowing(_ deskKey: String) -> Bool {
        followedDeskKeys().contains(deskKey)
    }

    func isMutualFollow(_ deskKey: String) -> Bool {
        followedDeskKeys().contains(deskKey) && followerDeskKeys().contains(deskKey)
    }

    func toggleFollow(_ deskKey: String) {
        var keys = followedDeskKeys()
        if keys.contains(deskKey) { keys.remove(deskKey) } else { keys.insert(deskKey) }
        defaults.set(Array(keys), forKey: DrawerSlot.followedDesks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func addFollower(_ deskKey: String) {
        var keys = followerDeskKeys()
        guard keys.insert(deskKey).inserted else { return }
        defaults.set(Array(keys), forKey: DrawerSlot.followerDesks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func beginWelcomeFansIfNeeded() {
        if !defaults.bool(forKey: DrawerSlot.welcomeFansSeeded) {
            let pool = NightSocialLoungeCatalog.creators.map(\.deskKey).filter { !shouldHideDesk($0) }
            let count = min(pool.count, Int.random(in: 1...3))
            let picked = Array(pool.shuffled().prefix(count))
            defaults.set(true, forKey: DrawerSlot.welcomeFansSeeded)
            defaults.set(picked, forKey: DrawerSlot.welcomeFanQueue)
        }
        pumpWelcomeFans()
    }

    private var welcomeFanPumping = false

    private func pumpWelcomeFans() {
        guard !welcomeFanPumping else { return }
        let queue = defaults.stringArray(forKey: DrawerSlot.welcomeFanQueue) ?? []
        guard !queue.isEmpty else { return }
        welcomeFanPumping = true
        let delay = Double.random(in: 5...12)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.welcomeFanPumping = false
            var remaining = self.defaults.stringArray(forKey: DrawerSlot.welcomeFanQueue) ?? []
            guard let next = remaining.first else { return }
            remaining.removeFirst()
            self.defaults.set(remaining, forKey: DrawerSlot.welcomeFanQueue)
            self.addFollower(next)
            self.pumpWelcomeFans()
        }
    }

    func sentFriendAskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.sentFriendAsks) ?? [])
    }

    func incomingFriendAskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.incomingFriendAsks) ?? [])
    }

    func acceptedFriendKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.acceptedFriends) ?? [])
    }

    func isFriend(_ deskKey: String) -> Bool {
        acceptedFriendKeys().contains(deskKey)
    }

    func hasSentFriendAsk(_ deskKey: String) -> Bool {
        sentFriendAskKeys().contains(deskKey)
    }

    func sendFriendAsk(_ deskKey: String) {
        guard !isFriend(deskKey), !hasSentFriendAsk(deskKey) else { return }
        var keys = sentFriendAskKeys()
        keys.insert(deskKey)
        defaults.set(Array(keys), forKey: DrawerSlot.sentFriendAsks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func acceptFriendAsk(_ deskKey: String) {
        var incoming = incomingFriendAskKeys()
        guard incoming.contains(deskKey) else { return }
        incoming.remove(deskKey)
        defaults.set(Array(incoming), forKey: DrawerSlot.incomingFriendAsks)
        var friends = acceptedFriendKeys()
        friends.insert(deskKey)
        defaults.set(Array(friends), forKey: DrawerSlot.acceptedFriends)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func reportedDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.reportedDesks) ?? [])
    }

    func reportedClipKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.reportedClips) ?? [])
    }

    func reportedLineKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.reportedLines) ?? [])
    }

    func shouldHideDesk(_ deskKey: String) -> Bool {
        isBlocked(deskKey) || reportedDeskKeys().contains(deskKey)
    }

    func shouldHideClip(_ clipKey: String, authorDeskKey: String) -> Bool {
        shouldHideDesk(authorDeskKey) || reportedClipKeys().contains(clipKey)
    }

    func shouldHideLine(_ line: LoungeDiscussLine) -> Bool {
        reportedLineKeys().contains(line.lineKey) || shouldHideDesk(line.speakerDeskKey)
    }

    func rememberReport(_ target: NightSocialSafetyTarget, kind: NightSocialReportKind) {
        _ = kind
        switch target {
        case .desk(let key):
            var keys = reportedDeskKeys()
            keys.insert(key)
            defaults.set(Array(keys), forKey: DrawerSlot.reportedDesks)
        case .clip(let clipKey, _):
            var keys = reportedClipKeys()
            keys.insert(clipKey)
            defaults.set(Array(keys), forKey: DrawerSlot.reportedClips)
        case .comment(let lineKey, _):
            var keys = reportedLineKeys()
            keys.insert(lineKey)
            defaults.set(Array(keys), forKey: DrawerSlot.reportedLines)
        }
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func storedComments(for clipKey: String) -> [LoungeDiscussLine] {
        let box = decode([String: [LoungeDiscussLine]].self, key: DrawerSlot.clipComments) ?? [:]
        return box[clipKey] ?? []
    }

    func appendComment(_ line: LoungeDiscussLine, clipKey: String) {
        var box = decode([String: [LoungeDiscussLine]].self, key: DrawerSlot.clipComments) ?? [:]
        var rows = box[clipKey] ?? []
        rows.append(line)
        box[clipKey] = rows
        persist(box, key: DrawerSlot.clipComments)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func discussLines(for clipKey: String) -> [LoungeDiscussLine] {
        let seed = NightSocialLoungeCatalog.discussLines(for: clipKey)
        let extra = storedComments(for: clipKey)
        return (seed + extra).filter { !shouldHideLine($0) }
    }

    func rememberPendingClip(caption: String) {
        var rows = decode([[String: String]].self, key: DrawerSlot.pendingClips) ?? []
        rows.insert([
            "key": "pending.\(UUID().uuidString)",
            "caption": caption,
            "state": "pending",
            "at": "\(Date().timeIntervalSince1970)",
        ], at: 0)
        persist(rows, key: DrawerSlot.pendingClips)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func pendingClipRecords() -> [[String: String]] {
        decode([[String: String]].self, key: DrawerSlot.pendingClips) ?? []
    }

    func chimeThreadKeys() -> [String] {
        let box = decode([String: [ChimeLine]].self, key: DrawerSlot.chimeLines) ?? [:]
        return box.keys.filter { key in
            guard let rows = box[key], !rows.isEmpty else { return false }
            if NightSocialDeskGate.isHouseDesk(key) { return true }
            return !isBlocked(key)
        }.sorted { a, b in
            (box[a]?.last?.spokenAt ?? 0) > (box[b]?.last?.spokenAt ?? 0)
        }
    }

    func blockedDeskKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: DrawerSlot.blockedDesks) ?? [])
    }

    func isBlocked(_ deskKey: String) -> Bool {
        blockedDeskKeys().contains(deskKey)
    }

    func rememberVisitedChamber(_ chamberKey: String) {
        var keys = recentChamberKeys()
        keys.removeAll { $0 == chamberKey }
        keys.insert(chamberKey, at: 0)
        if keys.count > 12 { keys = Array(keys.prefix(12)) }
        defaults.set(keys, forKey: DrawerSlot.recentChambers)
    }

    func recentChamberKeys() -> [String] {
        defaults.stringArray(forKey: DrawerSlot.recentChambers) ?? []
    }

    func rememberSeatedChamber(_ chamberKey: String, seatIndex: Int) {
        defaults.set(["key": chamberKey, "seat": "\(seatIndex)"], forKey: DrawerSlot.seatedChamber)
    }

    func seatedChamberSeat() -> (String, Int)? {
        guard let box = defaults.dictionary(forKey: DrawerSlot.seatedChamber),
              let key = box["key"] as? String,
              let seat = (box["seat"] as? String).flatMap(Int.init) else { return nil }
        return (key, seat)
    }

    func clearSeatedChamber() {
        defaults.removeObject(forKey: DrawerSlot.seatedChamber)
    }

    func hostedChamberRecords() -> [[String: String]] {
        defaults.array(forKey: DrawerSlot.hostedChambers) as? [[String: String]] ?? []
    }

    func chimeLines(for deskKey: String) -> [ChimeLine] {
        let box = decode([String: [ChimeLine]].self, key: DrawerSlot.chimeLines) ?? [:]
        return box[deskKey] ?? []
    }

    func chimeThreadExists(_ deskKey: String) -> Bool {
        let box = decode([String: [ChimeLine]].self, key: DrawerSlot.chimeLines) ?? [:]
        return box[deskKey] != nil
    }

    func appendChimeLine(_ line: ChimeLine, deskKey: String) {
        var box = decode([String: [ChimeLine]].self, key: DrawerSlot.chimeLines) ?? [:]
        var rows = box[deskKey] ?? []
        rows.append(line)
        box[deskKey] = rows
        persist(box, key: DrawerSlot.chimeLines)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func clearChimeLines(deskKey: String) {
        var box = decode([String: [ChimeLine]].self, key: DrawerSlot.chimeLines) ?? [:]
        box[deskKey] = []
        persist(box, key: DrawerSlot.chimeLines)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func markChimeRead(_ deskKey: String) {
        var keys = Set(defaults.stringArray(forKey: DrawerSlot.chimeRead) ?? [])
        keys.insert(deskKey)
        defaults.set(Array(keys), forKey: DrawerSlot.chimeRead)
    }

    func chimeIsRead(_ deskKey: String) -> Bool {
        Set(defaults.stringArray(forKey: DrawerSlot.chimeRead) ?? []).contains(deskKey)
    }

    func markPlatformRead() { defaults.set(true, forKey: DrawerSlot.platformRead) }
    func platformIsRead() -> Bool { defaults.bool(forKey: DrawerSlot.platformRead) }
    func markLikesRead() { defaults.set(true, forKey: DrawerSlot.likesRead) }
    func likesAreRead() -> Bool { defaults.bool(forKey: DrawerSlot.likesRead) }

    var spokenTongue: String {
        defaults.string(forKey: DrawerSlot.spokenTongue) ?? "English"
    }

    func writeSpokenTongue(_ value: String) {
        defaults.set(value, forKey: DrawerSlot.spokenTongue)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func checkInDays() -> Set<Int> {
        Set(defaults.array(forKey: DrawerSlot.checkInDays) as? [Int] ?? [])
    }

    func markCheckInPreview(_ day: Int) {
        var days = checkInDays()
        days.insert(day)
        defaults.set(Array(days), forKey: DrawerSlot.checkInDays)
    }

    func inviteCode() -> String {
        if let existing = defaults.string(forKey: DrawerSlot.inviteCode), !existing.isEmpty {
            return existing
        }
        let seed = (liveSession?.deskHolderId ?? "NIGHT")
            .replacingOccurrences(of: "-", with: "")
            .prefix(6)
            .uppercased()
        let code = "NIGHT\(seed)"
        defaults.set(code, forKey: DrawerSlot.inviteCode)
        return code
    }

    func loadCover() -> UIImage? {
        let url = coverURL()
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func writeCover(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.86) else { return }
        try? data.write(to: coverURL(), options: .atomic)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func parkDesk() {
        defaults.set(false, forKey: DrawerSlot.seatedFlag)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func leaveDesk() {
        parkDesk()
    }

    func eraseDesk() {
        liveSession = nil
        let keys = [
            DrawerSlot.stageSession, DrawerSlot.houseCovenant, DrawerSlot.seatedFlag,
            DrawerSlot.diamondPurse, DrawerSlot.followedDesks, DrawerSlot.followerDesks,
            DrawerSlot.welcomeFansSeeded, DrawerSlot.welcomeFanQueue,
            DrawerSlot.blockedDesks, DrawerSlot.reportedDesks, DrawerSlot.reportedClips,
            DrawerSlot.reportedLines, DrawerSlot.clipComments, DrawerSlot.pendingClips,
            DrawerSlot.sentFriendAsks, DrawerSlot.incomingFriendAsks, DrawerSlot.acceptedFriends,
            DrawerSlot.recentChambers, DrawerSlot.hostedChambers, DrawerSlot.seatedChamber,
            DrawerSlot.chimeLines, DrawerSlot.chimeRead, DrawerSlot.platformRead,
            DrawerSlot.likesRead, DrawerSlot.spokenTongue, DrawerSlot.homeCountry, DrawerSlot.genderMark,
            DrawerSlot.profileTags, DrawerSlot.checkInDays,
            DrawerSlot.inviteCode,
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        try? FileManager.default.removeItem(at: portraitURL())
        try? FileManager.default.removeItem(at: coverURL())
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func unblockDesk(_ deskKey: String) {
        var keys = blockedDeskKeys()
        keys.remove(deskKey)
        defaults.set(Array(keys), forKey: DrawerSlot.blockedDesks)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func fanDeskKeys() -> [String] {
        Array(followerDeskKeys()).filter { !shouldHideDesk($0) }
    }

    private func coverURL() -> URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(DrawerSlot.coverFile)
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func rememberHostedChamber(_ record: [String: String]) {
        var rows = hostedChamberRecords()
        rows.insert(record, at: 0)
        defaults.set(rows, forKey: DrawerSlot.hostedChambers)
        NotificationCenter.default.post(name: .deskDrawerDidChange, object: self)
    }

    func blockDesk(_ deskKey: String) {
        var keys = blockedDeskKeys()
        keys.insert(deskKey)
        defaults.set(Array(keys), forKey: DrawerSlot.blockedDesks)
        var followed = followedDeskKeys()
        followed.remove(deskKey)
        defaults.set(Array(followed), forKey: DrawerSlot.followedDesks)
        var sent = sentFriendAskKeys()
        sent.remove(deskKey)
        defaults.set(Array(sent), forKey: DrawerSlot.sentFriendAsks)
        var friends = acceptedFriendKeys()
        friends.remove(deskKey)
        defaults.set(Array(friends), forKey: DrawerSlot.acceptedFriends)
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

    static func spokenName(fromMailbox mailbox: String) -> String {
        let local = mailbox.split(separator: "@").first.map(String.init) ?? "Guest"
        let cleaned = local.replacingOccurrences(of: "[^A-Za-z0-9]+", with: " ", options: .regularExpression)
        let trimmed = NightSocialFoyerGuard.trimmed(cleaned)
        guard !trimmed.isEmpty else { return "Night guest" }
        return trimmed
            .split(separator: " ")
            .map { part in
                part.prefix(1).uppercased() + part.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }
}
