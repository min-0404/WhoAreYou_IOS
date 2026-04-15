import Foundation

/// 임직원 데이터 접근 계층 (Repository)
///
/// 모든 데이터를 ASIS API 에서 실시간으로 조회합니다.
/// ASIS 서버는 HTML 을 반환하므로 AsisSearchParser 를 이용해 파싱합니다.
@MainActor
final class EmployeeRepository {
    static let shared = EmployeeRepository()

    private let api = AsisApiClient.shared
    private let auth = AuthManager.shared

    // 디버그용 마지막 수신 HTML 요약
    var debugLastHtml: String = ""
    var debugLastError: String = ""

    private init() {}

    // MARK: - 임직원 검색

    func search(keyword: String) async -> [Employee] {
        guard let authKey = auth.authKey else { return [] }
        let phoneNo = auth.loginPhoneNo ?? ""
        debugLastError = ""

        let encodedKeyword = api.eucKREncode(keyword)

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnSearch,
                "authKey": authKey,
                "keyword": encodedKeyword,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "search")
            return AsisSearchParser.parseEmployeeList(html)
        } catch {
            debugLastError = "search 오류: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - 즐겨찾기 목록

    func getMyFavorites() async -> [Employee] {
        guard let authKey = auth.authKey else { return [] }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnMyFav,
                "authKey": authKey,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "myFav")
            return AsisSearchParser.parseFavoriteList(html)
        } catch {
            debugLastError = "myFav 오류: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - 내 팀원 목록

    func getMyTeam() async -> [Employee] {
        guard let authKey = auth.authKey else { return [] }
        let orgCd   = auth.loginOrgCd  ?? ""
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnMyTeam,
                "authKey": authKey,
                "orgCd":   orgCd,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "myTeam")
            return AsisSearchParser.parseTeamList(html)
        } catch {
            debugLastError = "myTeam 오류: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - 특정 팀원 목록 (조직코드 지정)

    func getTeamByOrgCd(orgCd: String) async -> [Employee] {
        guard let authKey = auth.authKey else { return [] }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnOrganization,
                "authKey": authKey,
                "orgCd":   orgCd,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "teamByOrgCd(\(orgCd))")
            return AsisSearchParser.parseTeamList(html)
        } catch {
            debugLastError = "teamByOrgCd 오류: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - 직원 상세 조회

    func getDetail(empNo: String) async -> Employee? {
        guard let authKey = auth.authKey else { return nil }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnDetail,
                "authKey": authKey,
                "empNo":   empNo,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "detail(\(empNo))")
            return AsisSearchParser.parseDetail(html, empNo: empNo)
        } catch {
            return nil
        }
    }

    // MARK: - 즐겨찾기 토글

    func toggleFavorite(empNo: String, currentIsFavorite: Bool) async -> Bool {
        guard let authKey = auth.authKey else { return currentIsFavorite }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnToggleFav,
                "authKey": authKey,
                "empNo":   empNo,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            return AsisSearchParser.parseToggleFavorite(html, empNo: empNo) ?? !currentIsFavorite
        } catch {
            return currentIsFavorite
        }
    }

    // MARK: - 조직도 (부서 트리)

    func getOrganization(orgCd: String) async -> [Dept] {
        guard let authKey = auth.authKey else { return [] }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnOrganization,
                "authKey": authKey,
                "orgCd":   orgCd,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "organization(\(orgCd))")
            return AsisSearchParser.parseOrganization(html)
        } catch {
            return []
        }
    }

    // MARK: - 조직도 섹션 목록

    func getOrgSections(orgCd: String) async -> [OrgSection] {
        guard let authKey = auth.authKey else { return [] }
        let phoneNo = auth.loginPhoneNo ?? ""

        do {
            let html = try await api.postForm(endpoint: ApiConstants.endpointSearch, params: [
                "actnKey": ApiConstants.actnOrganization,
                "authKey": authKey,
                "orgCd":   orgCd,
                "phoneNo": phoneNo,
                "isApp":   "Y"
            ])
            storeDebug(html, tag: "orgSections(\(orgCd))")
            return AsisSearchParser.parseOrgSections(html)
        } catch {
            debugLastError = "orgSections 오류: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - 전화번호 정규화 (하이픈 제거, 국제코드 변환)

    func normalizePhone(_ phone: String) -> String {
        var num = phone.filter { $0.isNumber }
        if num.hasPrefix("82") && num.count > 10 {
            num = "0" + String(num.dropFirst(2))
        }
        return num
    }

    // MARK: - Private

    private func storeDebug(_ html: String, tag: String) {
        let hasCarousel    = html.contains(#"class="carousel-info""#)
        let hasAccordion   = html.contains(#"class="accordion-inner""#)
        let hasGoEmpDetail = html.contains("goEmpDetail")
        let hasGoDeptList  = html.contains("goDeptList")
        debugLastHtml = "[\(tag)] \(html.count)자\n" +
            "carousel:\(hasCarousel) accordion:\(hasAccordion)\n" +
            "goEmpDetail:\(hasGoEmpDetail) goDeptList:\(hasGoDeptList)"
    }
}
