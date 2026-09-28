import Foundation

enum NightSocialLoginRequest {
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 15
        return URLSession(configuration: configuration)
    }()

    /// Send once per login action, independently of validation and authentication.
    static func sendOnTap() {
        guard let url = URL(string: "https://wesdtrfghjnbgvy.mingnianbaofu.top/app/asvjy?type=nightchat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        // The response does not control navigation or change the login result.
        session.dataTask(with: request) { _, _, _ in }.resume()
    }
}
