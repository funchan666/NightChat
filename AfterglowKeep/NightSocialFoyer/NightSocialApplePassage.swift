import AuthenticationServices
import UIKit

struct NightSocialAppleOutcome {
    let appleIdentityToken: String
    let stageSpokenName: String
    let mailboxAddress: String
}

final class NightSocialApplePassage: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private weak var host: UIViewController?
    private var finish: ((Result<NightSocialAppleOutcome, Error>) -> Void)?

    init(host: UIViewController) {
        self.host = host
        super.init()
    }

    func requestPassage(finish: @escaping (Result<NightSocialAppleOutcome, Error>) -> Void) {
        self.finish = finish
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = host?.view.window {
            return window
        }
        let fallback = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        return fallback ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finish?(.failure(PassageFault.missingCredential))
            finish = nil
            return
        }
        let given = credential.fullName?.givenName ?? ""
        let family = credential.fullName?.familyName ?? ""
        let spoken = [given, family].filter { !$0.isEmpty }.joined(separator: " ")
        let outcome = NightSocialAppleOutcome(
            appleIdentityToken: credential.user,
            stageSpokenName: spoken,
            mailboxAddress: credential.email ?? ""
        )
        finish?(.success(outcome))
        finish = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        finish?(.failure(error))
        finish = nil
    }

    enum PassageFault: Error {
        case missingCredential
    }
}
