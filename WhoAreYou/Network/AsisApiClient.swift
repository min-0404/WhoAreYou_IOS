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
    // URLSession은 delegate를 weak으로 보유 → 명시적 strong 참조 필수
    private let sslDelegate = TrustAllSSLDelegate()

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 60

        // 항상 TrustAllSSLDelegate 사용:
        //  - dev: 자체 서명 인증서 우회
        //  - prod: iOS의 OCSP/중간 인증서 체인 검증 대기로 인한 SSL 핸드셰이크 타임아웃 방지
        session = URLSession(configuration: config, delegate: sslDelegate, delegateQueue: nil)
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
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("ko-KR,ko;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        // urlQueryAllowed 에 % 를 추가: EUC-KR 사전 인코딩된 값이 이중 인코딩되지 않도록 방지
        let valueAllowed = CharacterSet.urlQueryAllowed.union(CharacterSet(charactersIn: "%"))
        request.httpBody = params
            .map { key, value in
                let encodedKey   = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: valueAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
            .data(using: .utf8)

        print("[AsisApiClient] → POST \(urlString)")
        print("[AsisApiClient]   body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse {
            print("[AsisApiClient] ← HTTP \(http.statusCode)")
        }

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

    /// JSESSIONID 쿠키 및 TrustAllSSLDelegate 를 유지한 채 이미지를 다운로드합니다.
    /// AsyncImage 는 URLSession.shared 를 사용해 SSL 핸드셰이크 타임아웃이 발생하므로
    /// 이 메서드로 대체합니다.
    func downloadImage(from url: URL) async -> Data? {
        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)",
            forHTTPHeaderField: "User-Agent"
        )
        do {
            let (data, _) = try await session.data(for: request)
            return data
        } catch {
            print("[AsisApiClient] 이미지 다운로드 실패: \(error.localizedDescription)")
            return nil
        }
    }

    /// 키워드를 EUC-KR 바이트로 변환 후 URL 퍼센트 인코딩합니다.
    ///
    /// 주의: Character.isLetter 는 0xC8→'È' 등 라틴 보충 문자를 글자로 인식해
    /// 한글 EUC-KR 상위 바이트를 퍼센트 인코딩하지 않는 버그가 있었음.
    /// ASCII 영숫자(0x30-0x39, 0x41-0x5A, 0x61-0x7A)만 직접 비교로 통과시킴.
    func eucKREncode(_ keyword: String) -> String {
        let cfEncoding = CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
        )
        let encoding = String.Encoding(rawValue: cfEncoding)
        guard let data = keyword.data(using: encoding) else { return keyword }
        return data.map { byte in
            switch byte {
            case 0x30...0x39,   // 0-9
                 0x41...0x5A,   // A-Z
                 0x61...0x7A:   // a-z
                return String(UnicodeScalar(byte))
            default:
                return String(format: "%%%02X", byte)
            }
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

/// URLSession delegate + URLSessionTaskDelegate 모두 구현.
/// 서버에 따라 SSL 챌린지가 세션 레벨 또는 태스크 레벨로 오므로 양쪽 모두 처리.
private class TrustAllSSLDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {

    // 세션 레벨 SSL 챌린지 (일반적인 경우)
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print("[SSL] 세션 챌린지: \(challenge.protectionSpace.authenticationMethod) @ \(challenge.protectionSpace.host):\(challenge.protectionSpace.port)")
        handle(challenge: challenge, completionHandler: completionHandler)
    }

    // 태스크 레벨 SSL 챌린지 (일부 서버는 이 방식 사용)
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print("[SSL] 태스크 챌린지: \(challenge.protectionSpace.authenticationMethod) @ \(challenge.protectionSpace.host):\(challenge.protectionSpace.port)")
        handle(challenge: challenge, completionHandler: completionHandler)
    }

    private func handle(
        challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            print("[SSL] ⚠️ 비SSL 챌린지 → 기본 처리")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        print("[SSL] ✅ 인증서 신뢰 처리 완료: \(challenge.protectionSpace.host)")
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("[SSL] ❌ 태스크 완료 오류: \(error)")
        }
    }
}
