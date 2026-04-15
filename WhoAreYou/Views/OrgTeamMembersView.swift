import SwiftUI

struct OrgTeamMembersView: View {
    let orgCd: String
    let deptName: String

    @Environment(\.dismiss) var dismiss

    @State private var employees: [Employee] = []
    @State private var isLoading = true
    @State private var errorMessage: String = ""

    // employees를 team 이름 기준으로 그룹핑 (삽입 순서 유지)
    private var groupedByTeam: [(key: String, value: [Employee])] {
        var ordered: [String] = []
        var dict: [String: [Employee]] = [:]
        for emp in employees {
            if dict[emp.team] == nil {
                ordered.append(emp.team)
                dict[emp.team] = []
            }
            dict[emp.team]!.append(emp)
        }
        return ordered.map { (key: $0, value: dict[$0]!) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 바
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppTheme.background)
                                .frame(width: 38, height: 38)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }

                    Spacer()

                    Text(deptName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    // 대칭 여백
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)

                // 본문
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppTheme.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else if employees.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                        Text("소속 직원이 없습니다")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        Button {
                            Task { await loadEmployees() }
                        } label: {
                            Text("다시 시도")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else {
                    List {
                        ForEach(groupedByTeam, id: \.key) { teamName, members in
                            Section {
                                ForEach(members) { emp in
                                    NavigationLink(destination: EmployeeDetailView(empNo: emp.empNo)) {
                                        TeamMemberRowView(
                                            employee: emp,
                                            onFavoriteToggle: { toggleFavorite(emp) }
                                        )
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                TeamSectionHeader(teamName: teamName, count: members.count)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await loadEmployees() }
    }

    private func loadEmployees() async {
        isLoading = true
        errorMessage = ""
        employees = await EmployeeRepository.shared.getTeamByOrgCd(orgCd: orgCd)
        if employees.isEmpty {
            errorMessage = EmployeeRepository.shared.debugLastError
        }
        isLoading = false
    }

    private func toggleFavorite(_ employee: Employee) {
        Task {
            let newFav = await EmployeeRepository.shared.toggleFavorite(
                empNo: employee.empNo,
                currentIsFavorite: employee.isFavorite
            )
            if let idx = employees.firstIndex(where: { $0.empNo == employee.empNo }) {
                employees[idx] = Employee(
                    empNo: employees[idx].empNo,
                    name: employees[idx].name,
                    team: employees[idx].team,
                    teamCode: employees[idx].teamCode,
                    position: employees[idx].position,
                    nickname: employees[idx].nickname,
                    jobTitle: employees[idx].jobTitle,
                    internalPhone: employees[idx].internalPhone,
                    mobilePhone: employees[idx].mobilePhone,
                    fax: employees[idx].fax,
                    email: employees[idx].email,
                    imgdata: employees[idx].imgdata,
                    isFavorite: newFav
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamSectionHeader — 팀 구분 헤더 (세로 바 + 팀명 + 인원수)
// ─────────────────────────────────────────────────────────────────────────────

private struct TeamSectionHeader: View {
    let teamName: String
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.primary)
                .frame(width: 3, height: 18)
            Text(teamName)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text("\(count)명")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // List Section 헤더 기본 배경 제거
        .listRowInsets(EdgeInsets())
        .background(AppTheme.background)
    }
}
