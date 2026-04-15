import SwiftUI

struct OrgChartView: View {
    @Environment(\.dismiss) var dismiss

    @State private var orgSections: [OrgSection] = []
    @State private var isLoading = true
    @State private var errorMessage: String = ""
    @State private var expandedSections: [String: Bool] = [:]
    @State private var deptSubTeams: [String: [Dept]] = [:]
    @State private var loadingDepts: Set<String> = []

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

                    Text("조직도")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    // 오른쪽 대칭 여백 (뒤로가기 버튼 폭만큼)
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
                } else if orgSections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("조직 정보를 불러올 수 없습니다")
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
                            Task { await loadOrgSections() }
                        } label: {
                            Text("다시 시도")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            // 회사 헤더 카드
                            CompanyHeaderCard()
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                                .padding(.bottom, 4)

                            // 섹션 목록
                            ForEach(orgSections) { section in
                                let isExpanded = expandedSections[section.name] == true

                                OrgSectionCard(
                                    section: section,
                                    isExpanded: isExpanded,
                                    deptSubTeams: deptSubTeams,
                                    loadingDepts: loadingDepts,
                                    onToggle: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expandedSections[section.name] = !isExpanded
                                        }
                                    },
                                    onDeptExpand: { dept in
                                        handleDeptExpand(dept)
                                    }
                                )
                                .padding(.horizontal, 20)
                            }

                            Spacer(minLength: 32)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await loadOrgSections() }
    }

    private func loadOrgSections() async {
        isLoading = true
        errorMessage = ""
        orgSections = await EmployeeRepository.shared.getOrgSections(orgCd: "")
        if orgSections.isEmpty {
            errorMessage = EmployeeRepository.shared.debugLastError
        }
        isLoading = false
    }

    private func handleDeptExpand(_ dept: Dept) {
        let code = dept.deptCode
        if deptSubTeams[code] != nil {
            // 이미 로드됨 → 토글 (제거)
            deptSubTeams.removeValue(forKey: code)
        } else if !loadingDepts.contains(code) {
            loadingDepts.insert(code)
            Task {
                let teams = await EmployeeRepository.shared.getOrganization(orgCd: code)
                deptSubTeams[code] = teams
                loadingDepts.remove(code)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// CompanyHeaderCard — 회사 헤더 카드
// ─────────────────────────────────────────────────────────────────────────────

private struct CompanyHeaderCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.primary)
                    .frame(width: 48, height: 48)
                Image(systemName: "house.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("비씨카드")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("BC Card Co., Ltd.")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// OrgSectionCard — 섹션 헤더 + 확장 내용
// ─────────────────────────────────────────────────────────────────────────────

private struct OrgSectionCard: View {
    let section: OrgSection
    let isExpanded: Bool
    let deptSubTeams: [String: [Dept]]
    let loadingDepts: Set<String>
    let onToggle: () -> Void
    let onDeptExpand: (Dept) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 섹션 헤더 버튼
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // 아이콘 박스
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isExpanded ? AppTheme.primary : AppTheme.primary.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "building.2")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isExpanded ? .white : AppTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isExpanded ? AppTheme.primary : AppTheme.textPrimary)
                        if !isExpanded && !section.subDepts.isEmpty {
                            Text("하위 조직 \(section.subDepts.count)개")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(isExpanded ? AppTheme.primary.opacity(0.10) : AppTheme.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
            }
            .buttonStyle(.plain)

            // 확장 내용
            if isExpanded {
                VStack(spacing: 0) {
                    // 책임자 직원 카드
                    if let headEmp = section.headEmployee {
                        HeadEmployeeCard(employee: headEmp)
                            .padding(.top, 6)
                    }

                    // 하위 부서 목록
                    ForEach(section.subDepts) { dept in
                        let subTeams = deptSubTeams[dept.deptCode]
                        let isLoading = loadingDepts.contains(dept.deptCode)
                        let isOpen = subTeams != nil

                        DeptExpandRow(
                            name: dept.deptName,
                            isOpen: isOpen,
                            isLoading: isLoading,
                            onToggle: { onDeptExpand(dept) }
                        )
                        .padding(.top, 4)

                        if isOpen {
                            if let teams = subTeams, teams.isEmpty {
                                HStack {
                                    Text("하위 부서가 없습니다")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                }
                                .padding(.leading, 28)
                                .padding(.vertical, 6)
                            } else if let teams = subTeams {
                                ForEach(teams) { team in
                                    NavigationLink(destination: OrgTeamMembersView(orgCd: team.deptCode, deptName: team.deptName)) {
                                        TeamLinkRow(deptName: team.deptName)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // 직접 코드가 있고 하위 부서 없는 섹션 (노동조합 등)
                    if !section.deptCode.isEmpty && section.subDepts.isEmpty {
                        NavigationLink(destination: OrgTeamMembersView(orgCd: section.deptCode, deptName: section.name)) {
                            TeamLinkRow(deptName: section.name)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 4)
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// HeadEmployeeCard — 섹션 책임자 직원 카드
// ─────────────────────────────────────────────────────────────────────────────

private struct HeadEmployeeCard: View {
    let employee: Employee

    var body: some View {
        NavigationLink(destination: EmployeeDetailView(empNo: employee.empNo)) {
            HStack(spacing: 14) {
                ProfileAvatarView(employee: employee, size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(employee.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    let subtitle: String = {
                        var parts: [String] = []
                        if !employee.position.isEmpty { parts.append(employee.position) }
                        if !employee.team.isEmpty     { parts.append(employee.team) }
                        return parts.joined(separator: "  /  ")
                    }()

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    // 인라인 전화 버튼
                    if !employee.internalPhone.isEmpty || !employee.mobilePhone.isEmpty {
                        HStack(spacing: 8) {
                            if !employee.internalPhone.isEmpty {
                                HeadCallButton(label: "사내", phone: employee.internalPhone, color: AppTheme.callGreen)
                            }
                            if !employee.mobilePhone.isEmpty {
                                HeadCallButton(label: "휴대", phone: employee.mobilePhone, color: AppTheme.primary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct HeadCallButton: View {
    let label: String
    let phone: String
    let color: Color

    var body: some View {
        Button {
            if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// DeptExpandRow — 본부/그룹 확장 행
// ─────────────────────────────────────────────────────────────────────────────

private struct DeptExpandRow: View {
    let name: String
    let isOpen: Bool
    let isLoading: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.primary.opacity(0.6))

                Text(name)
                    .font(.system(size: 14, weight: isOpen ? .semibold : .regular))
                    .foregroundColor(isOpen ? AppTheme.primary : AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isLoading {
                    ProgressView()
                        .tint(AppTheme.primary)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 14)
            .padding(.vertical, 12)
            .background(isOpen ? AppTheme.primary.opacity(0.07) : AppTheme.background)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamLinkRow — 팀 행 (NavigationLink 레이블로 사용)
// ─────────────────────────────────────────────────────────────────────────────

private struct TeamLinkRow: View {
    let deptName: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(AppTheme.accentBlue.opacity(0.5))
                .frame(width: 6, height: 6)

            Text(deptName)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.accentBlue.opacity(0.5))
        }
        .padding(.leading, 26)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .background(Color.clear)
        .cornerRadius(10)
    }
}
