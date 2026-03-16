import Foundation

struct Employee: Identifiable {
    let id: Int
    let name: String
    let team: String
    let position: String
    let nickname: String
    let jobTitle: String           // 담당 업무명
    let internalPhone: String      // 사내전화
    let mobilePhone: String        // 휴대전화
    let fax: String                // 팩스
    let email: String              // 이메일
    var profileImageName: String? = nil  // Assets에 등록된 이미지명, nil이면 기본 프로필
    var photoUrl: String? = nil          // 서버 API 연결 후 실제 사진 URL이 여기에 들어옴
    var isFavorite: Bool = false
}

// MARK: - Mock 데이터 (나중에 API 연동으로 교체)
struct MockData {
    static var employees: [Employee] = [
        Employee(id: 1,  name: "이지호",  team: "플랫폼DX팀", position: "팀장", nickname: "J tiger",        jobTitle: "플랫폼 아키텍처 총괄",        internalPhone: "02-520-4434",  mobilePhone: "010-3559-9618", fax: "02-3496-1674", email: "jihoyi@bccard.com"),
        Employee(id: 2,  name: "이명재",  team: "플랫폼DX팀", position: "팀원", nickname: "Espero 에스페로",  jobTitle: "백엔드 API 개발",             internalPhone: "02-1234-0002",  mobilePhone: "010-4211-1072", fax: "02-3496-0002", email: "mjlee@bccard.com"),
        Employee(id: 3,  name: "최호성",  team: "플랫폼DX팀", position: "팀원", nickname: "호돌",            jobTitle: "클라우드 인프라 운영",          internalPhone: "02-1234-0003",  mobilePhone: "010-3687-7487", fax: "02-3496-0003", email: "hschoi@bccard.com"),
        Employee(id: 4,  name: "김명일",  team: "플랫폼DX팀", position: "팀원", nickname: "플요",            jobTitle: "iOS 모바일 앱 개발",           internalPhone: "02-1234-0004",  mobilePhone: "010-3496-1230", fax: "02-3496-0004", email: "mikim@bccard.com"),
        Employee(id: 5,  name: "홍진수",  team: "플랫폼DX팀", position: "팀원", nickname: "플라비어",         jobTitle: "데이터 파이프라인 구축",         internalPhone: "02-1234-0005",  mobilePhone: "010-7132-6367", fax: "02-3496-0005", email: "jshong@bccard.com"),
        Employee(id: 6,  name: "문지용",  team: "플랫폼DX팀", position: "팀원", nickname: "제이디",           jobTitle: "UI/UX 프론트엔드 개발",        internalPhone: "02-1234-0006",  mobilePhone: "010-2462-0807", fax: "02-3496-0006", email: "jymoon@bccard.com"),
        Employee(id: 7,  name: "양인호",  team: "플랫폼DX팀", position: "팀원", nickname: "이노",            jobTitle: "AI 모델 서빙 및 MLOps",       internalPhone: "02-1234-0007",  mobilePhone: "010-3775-8142", fax: "02-3496-0007", email: "ihyang@bccard.com"),
        Employee(id: 8,  name: "오태건",  team: "플랫폼DX팀", position: "팀원", nickname: "태건",            jobTitle: "보안 취약점 분석 및 대응",       internalPhone: "02-1234-0008",  mobilePhone: "010-6626-3706", fax: "02-3496-0008", email: "tgoh@bccard.com"),
        Employee(id: 9,  name: "정태호",  team: "플랫폼DX팀", position: "팀원", nickname: "태호",            jobTitle: "DevOps CI/CD 파이프라인",     internalPhone: "02-1234-0009",  mobilePhone: "010-7460-7903", fax: "02-3496-0009", email: "thjung@bccard.com"),
        Employee(id: 10, name: "노현경",  team: "플랫폼DX팀", position: "팀원", nickname: "현경",            jobTitle: "DB 설계 및 쿼리 최적화",        internalPhone: "02-1234-0010",  mobilePhone: "010-4562-2780", fax: "02-3496-0010", email: "hknoh@bccard.com"),
        Employee(id: 11, name: "원정희",  team: "플랫폼DX팀", position: "팀원", nickname: "정희",            jobTitle: "QA 테스트 자동화",             internalPhone: "02-1234-0011",  mobilePhone: "010-7413-4005", fax: "02-3496-0011", email: "jhwon@bccard.com"),
        Employee(id: 12, name: "김채윤",  team: "플랫폼DX팀", position: "팀원", nickname: "채윤",            jobTitle: "서비스 모니터링 및 장애 대응",   internalPhone: "02-1234-0012",  mobilePhone: "010-4604-9423", fax: "02-3496-0012", email: "cykim@bccard.com"),
        Employee(id: 13, name: "김민석",  team: "플랫폼DX팀", position: "팀원", nickname: "민석",            jobTitle: "Android 모바일 앱 개발",      internalPhone: "02-1234-0013",  mobilePhone: "010-5133-9755", fax: "02-3496-0013", email: "mskim@bccard.com"),
        Employee(id: 14, name: "김동현",  team: "플랫폼DX팀", position: "팀원", nickname: "동현",            jobTitle: "마이크로서비스 아키텍처 설계",   internalPhone: "02-1234-0014",  mobilePhone: "010-2478-6657", fax: "02-3496-0014", email: "dhkim@bccard.com"),
        Employee(id: 15, name: "이동재",  team: "플랫폼DX팀", position: "팀원", nickname: "동재",            jobTitle: "API 게이트웨이 및 인증 시스템", internalPhone: "02-1234-0015",  mobilePhone: "010-2874-3600", fax: "02-3496-0015", email: "djlee@bccard.com")
    ]
}
