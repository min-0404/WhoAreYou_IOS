import Foundation
import Combine

/// 세션 인증 정보를 관리하는 싱글톤 클래스.
/// AuthManager.shared 를 통해 앱 전역에서 접근합니다.
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // MARK: - Published (UI 반응용)
    @Published private(set) var authKey: String?
    @Published private(set) var loginEmpNo: String?
    @Published private(set) var loginEmpNm: String?
    @Published private(set) var loginOrgCd: String?
    @Published private(set) var loginPhoneNo: String?
    @Published private(set) var jsessionId: String?

    var isLoggedIn: Bool { authKey != nil && !(authKey?.isEmpty ?? true) }

    // MARK: - Persistence Keys
    private enum Keys {
        static let authKey      = "auth_authKey"
        static let loginEmpNo   = "auth_loginEmpNo"
        static let loginEmpNm   = "auth_loginEmpNm"
        static let loginOrgCd   = "auth_loginOrgCd"
        static let loginPhoneNo = "auth_loginPhoneNo"
        static let jsessionId   = "auth_jsessionId"
    }

    private init() {
        restore()
    }

    // MARK: - Session Management

    func saveSession(
        authKey: String,
        empNo: String,
        empNm: String,
        orgCd: String,
        phoneNo: String,
        jsessionId: String? = nil
    ) {
        self.authKey      = authKey
        self.loginEmpNo   = empNo
        self.loginEmpNm   = empNm
        self.loginOrgCd   = orgCd
        self.loginPhoneNo = phoneNo
        self.jsessionId   = jsessionId

        let ud = UserDefaults.standard
        ud.set(authKey,  forKey: Keys.authKey)
        ud.set(empNo,    forKey: Keys.loginEmpNo)
        ud.set(empNm,    forKey: Keys.loginEmpNm)
        ud.set(orgCd,    forKey: Keys.loginOrgCd)
        ud.set(phoneNo,  forKey: Keys.loginPhoneNo)
        if let sid = jsessionId { ud.set(sid, forKey: Keys.jsessionId) }
    }

    func updateJsessionId(_ sid: String) {
        jsessionId = sid
        UserDefaults.standard.set(sid, forKey: Keys.jsessionId)
        // Restore cookie to HTTPCookieStorage
        restoreSessionCookie(sid: sid)
    }

    func clearSession() {
        authKey      = nil
        loginEmpNo   = nil
        loginEmpNm   = nil
        loginOrgCd   = nil
        loginPhoneNo = nil
        jsessionId   = nil

        let ud = UserDefaults.standard
        [Keys.authKey, Keys.loginEmpNo, Keys.loginEmpNm,
         Keys.loginOrgCd, Keys.loginPhoneNo, Keys.jsessionId].forEach { ud.removeObject(forKey: $0) }

        // Clear cookies
        HTTPCookieStorage.shared.cookies?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
    }

    // MARK: - Private

    private func restore() {
        let ud = UserDefaults.standard
        authKey      = ud.string(forKey: Keys.authKey)
        loginEmpNo   = ud.string(forKey: Keys.loginEmpNo)
        loginEmpNm   = ud.string(forKey: Keys.loginEmpNm)
        loginOrgCd   = ud.string(forKey: Keys.loginOrgCd)
        loginPhoneNo = ud.string(forKey: Keys.loginPhoneNo)
        jsessionId   = ud.string(forKey: Keys.jsessionId)

        if let sid = jsessionId { restoreSessionCookie(sid: sid) }
    }

    private func restoreSessionCookie(sid: String) {
        let hosts = ["isrnd.bccard.com", "u2.bccard.com"]
        for host in hosts {
            let props: [HTTPCookiePropertyKey: Any] = [
                .name:    "JSESSIONID",
                .value:   sid,
                .domain:  host,
                .path:    "/",
                .secure:  "TRUE"
            ]
            if let cookie = HTTPCookie(properties: props) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
}
