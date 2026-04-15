import Foundation

/// 조직도 부서/조직 단위 모델
struct Dept: Identifiable, Hashable {
    var id: String { deptCode }

    let deptCode: String    // 조직 코드
    let deptName: String    // 조직명
    let level: Int          // 계층 깊이
    var memberCount: Int = 0
}

/// 조직도 최상위 섹션 (예: CEO, 감사, 노동조합)
struct OrgSection: Identifiable {
    var id: String { name }

    let name: String                // 섹션명
    let deptCode: String            // 직접 부서 코드 (노동조합 등)
    let headEmployee: Employee?     // 책임자 직원
    let subDepts: [Dept]            // 하위 부서 목록

    init(name: String, deptCode: String = "", headEmployee: Employee? = nil, subDepts: [Dept] = []) {
        self.name = name
        self.deptCode = deptCode
        self.headEmployee = headEmployee
        self.subDepts = subDepts
    }
}
