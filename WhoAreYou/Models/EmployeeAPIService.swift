import Foundation

// MARK: - API 설정
// ⚠️ 서버 구현 후 baseURL을 실제 서버 주소로 변경하세요
enum APIConfig {
    static let baseURL = "https://api.whoareyou.bccard.com"   // 가상 URL (서버 완성 후 교체)

    enum Endpoints {
        static let employees          = "/api/v1/employees"          // GET  : 임직원 전체 목록
        static let login              = "/api/v1/auth/login"         // POST : 로그인
        static func employeePhoto(id: Int) -> String {
            "/api/v1/employees/\(id)/photo"                          // GET  : 프로필 사진
        }
    }
}

// MARK: - API 응답 모델
// ⚠️ 서버 JSON 스키마에 맞춰 CodingKeys를 조정하세요
struct EmployeeResponse: Codable {
    let id: Int
    let name: String
    let team: String
    let position: String
    let nickname: String
    let jobTitle: String
    let internalPhone: String
    let mobilePhone: String
    let fax: String
    let email: String
    let photoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, team, position, nickname, fax, email
        case jobTitle       = "job_title"
        case internalPhone  = "internal_phone"
        case mobilePhone    = "mobile_phone"
        case photoUrl       = "photo_url"
    }

    func toEmployee() -> Employee {
        Employee(
            id: id,
            name: name,
            team: team,
            position: position,
            nickname: nickname,
            jobTitle: jobTitle,
            internalPhone: internalPhone,
            mobilePhone: mobilePhone,
            fax: fax,
            email: email,
            photoUrl: photoUrl
        )
    }
}

// MARK: - API 서비스
final class EmployeeAPIService {
    static let shared = EmployeeAPIService()
    private init() {}

    /// 임직원 목록을 서버에서 가져옵니다.
    /// - API 호출 성공 시 서버 데이터를 반환합니다.
    /// - 네트워크 오류·서버 오류·디코딩 실패 시 MockData를 반환합니다.
    func fetchEmployees() async -> [Employee] {
        let urlString = APIConfig.baseURL + APIConfig.Endpoints.employees

        guard let url = URL(string: urlString) else {
            print("[APIService] 잘못된 URL → MockData 사용")
            return MockData.employees
        }

        do {
            var request = URLRequest(url: url, timeoutInterval: 10)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            // 인증 토큰이 필요할 경우 아래 주석을 해제하세요:
            // request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                print("[APIService] 서버 오류 → MockData 사용")
                return MockData.employees
            }

            let decoded = try JSONDecoder().decode([EmployeeResponse].self, from: data)
            print("[APIService] API 성공: \(decoded.count)명 로드")
            return decoded.map { $0.toEmployee() }

        } catch {
            print("[APIService] 실패 (\(error.localizedDescription)) → MockData 사용")
            return MockData.employees
        }
    }
}
