import SwiftUI

struct OrgUnit: Identifiable {
    let id: Int
    let name: String
    let isTop: Bool
}

struct OrgChartView: View {
    @Binding var employees: [Employee]

    let orgUnits: [OrgUnit] = [
        OrgUnit(id: 1,  name: "CEO",          isTop: true),
        OrgUnit(id: 2,  name: "신금융연구소",    isTop: false),
        OrgUnit(id: 3,  name: "매입사업본부",    isTop: false),
        OrgUnit(id: 4,  name: "매입운영본부",    isTop: false),
        OrgUnit(id: 5,  name: "카드사업본부",    isTop: false),
        OrgUnit(id: 6,  name: "금융사업본부",    isTop: false),
        OrgUnit(id: 7,  name: "BC.AI본부",     isTop: false),
        OrgUnit(id: 8,  name: "데이터사업본부",  isTop: false),
        OrgUnit(id: 9,  name: "신용관리본부",    isTop: false),
        OrgUnit(id: 10, name: "경영기획총괄",    isTop: false),
        OrgUnit(id: 11, name: "페이북컴퍼니",    isTop: false),
        OrgUnit(id: 12, name: "준법감시그룹장",  isTop: false),
        OrgUnit(id: 13, name: "소비자보호그룹장", isTop: false),
        OrgUnit(id: 14, name: "위험관리그룹장",  isTop: false),
        OrgUnit(id: 15, name: "정보보호그룹장",  isTop: false),
        OrgUnit(id: 16, name: "플랫폼DX팀",    isTop: false)
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(orgUnits) { unit in
                        if unit.isTop {
                            // CEO 섹션 헤더
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryGradient)
                                        .frame(width: 32, height: 32)
                                    Text("C")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text(unit.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 8)
                        } else {
                            NavigationLink(destination: TeamDetailView(teamName: unit.name, employees: $employees)) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppTheme.primary.opacity(0.10))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 17))
                                            .foregroundColor(AppTheme.primary)
                                    }
                                    Text(unit.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.4))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                            }
                            .buttonStyle(.plain)
                            .cardStyle()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                        }
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("조직도")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 조직도에서 부서 탭했을 때 보여주는 팀원 목록
struct TeamDetailView: View {
    let teamName: String
    @Binding var employees: [Employee]

    var teamMembers: [Employee] {
        employees.filter { $0.team == teamName }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if teamMembers.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.background)
                            .frame(width: 72, height: 72)
                        Image(systemName: "person.slash")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    }
                    Text("등록된 팀원이 없습니다")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(teamMembers) { employee in
                            EmployeeRowView(employee: employee) {
                                toggleFavorite(employee)
                            }
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle(teamName)
        .navigationBarTitleDisplayMode(.inline)
    }

    func toggleFavorite(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            employees[index].isFavorite.toggle()
        }
    }
}
