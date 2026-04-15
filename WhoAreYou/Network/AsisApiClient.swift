import Foundation

/// ASIS 서버와 통신하는 HTTP 클라이언트 싱글톤.
///
/// 특이사항:
///   - dev 서버의 자체 서명 인증서 허용 (Trust-All SSL)
///   - 서버 응답이 EUC-KR 인코딩 → Data 를 직접 디코딩
///   - JSESSIONID 쿠키를 HTTPCookieStorage.shared 로 자동 관리
final class AsisApiClient {
    static let shared = AsisApiClient()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 60

        if ApiConstants.isDev {
            session = URLSession(configuration: config, delegate: TrustAllSSLDelegate(), delegateQueue: nil)
        } else {
            session = URLSession(configuration: config)
        }
    }

    // MARK: - Core POST (Form URL-Encoded)

    /// Form URL-Encoded POST 요청을 보내고 EUC-KR로 디코딩된 HTML 문자열을 반환합니다.
    func postForm(endpoint: String, params: [String: String]) async throws -> String {
        let urlString = ApiConstants.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        request.httpBody = params
            .map { key, value in
                let encodedKey   = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await session.data(for: request)

        // JSESSIONID 갱신
        if let httpResponse = response as? HTTPURLResponse,
           let fields = httpResponse.allHeaderFields as? [String: String],
           let cookieHeader = fields["Set-Cookie"],
           let range = cookieHeader.range(of: "JSESSIONID=") {
            let start = cookieHeader.index(range.upperBound, offsetBy: 0)
            let sid = String(cookieHeader[start...].prefix(while: { $0 != ";" && $0 != "," }))
            if !sid.isEmpty {
                await MainActor.run { AuthManager.shared.updateJsessionId(sid) }
            }
        }

        return data.toEUCKRString()
    }

    /// EUC-KR 인코딩된 키워드를 URL 인코딩합니다.
    func eucKREncode(_ keyword: String) -> String {
        let cfEncoding = CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        )
        let encoding = String.Encoding(rawValue: cfEncoding)
        guard let data = keyword.data(using: encoding) else { return keyword }
        return data.map { byte in
            let c = Character(Unicode.Scalar(byte))
            if c.isLetter || c.isNumber { return String(c) }
            return String(format: "%%%02X", byte)
        }.joined()
    }
}

// MARK: - Data Extension (EUC-KR Decoding)

extension Data {
    func toEUCKRString() -> String {
        let cfEncoding = CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        )
        let encoding = String.Encoding(rawValue: cfEncoding)
        if let s = String(data: self, encoding: encoding) { return s }
        if let s = String(data: self, encoding: .utf8) { return s }
        return String(data: self, encoding: .isoLatin1) ?? ""
    }
}

// MARK: - Trust-All SSL Delegate (dev only)

private class TrustAllSSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
