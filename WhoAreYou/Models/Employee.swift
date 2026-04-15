import Foundation

/// 임직원 정보 모델 (Android Employee.kt 와 동일한 구조)
struct Employee: Identifiable, Hashable {
    var id: String { empNo }

    let empNo: String           // 사번 (고유 식별자)
    let name: String            // 성명
    let team: String            // 팀명
    let teamCode: String        // 팀 조직 코드
    let position: String        // 직책 (팀장/팀원 등)
    let nickname: String        // 영문 닉네임
    let jobTitle: String        // 담당 업무
    let internalPhone: String   // 사내 전화
    let mobilePhone: String     // 휴대 전화
    let fax: String             // 팩스
    let email: String           // 이메일
    var imgdata: String?        // 프로필 이미지 URL 또는 Base64 데이터
    var isFavorite: Bool = false

    // imgdata 가 상대경로(/app/...) 이면 절대 URL 로 변환
    var profileImageURL: URL? {
        guard let img = imgdata, !img.isEmpty else { return nil }
        if img.hasPrefix("data:") { return nil }  // Base64는 URL 아님
        if img.hasPrefix("http") { return URL(string: img) }
        // 상대경로 → baseURL 붙이기
        let base = ApiConstants.baseURL
        return URL(string: base + img)
    }

    // 아바타 표시용 이름 첫 글자
    var avatarLetter: String {
        String(name.prefix(1))
    }
}
