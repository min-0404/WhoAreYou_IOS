import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var currentEmployee: Employee? = nil
    @State private var showLogoutAlert = false
    @State private var isFetchingProfile = false

    private let colorTeal = Color(red: 0.00, green: 0.71, blue: 0.85)
    private let colorRose = Color(red: 0.91, green: 0.12, blue: 0.55)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 상단 헤더 ─────────────────────────────────────────────
                headerBar

                Divider().foregroundColor(Color(white: 0.92))

                // ── 스크롤 콘텐츠 ─────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // 내 프로필 카드
                        profileCard
                            .padding(.horizontal, 16)
                            .padding(.top, 20)

                        // 바로가기 라벨
                        HStack {
                            Text("바로가기")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        // 메뉴 그리드 3행 × 2열
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            NavigationLink { FavoritesView() } label: {
                                HomeMenuCard(icon: "star.fill",          title: "즐겨찾기",      color: AppTheme.accentOrange)
                            }.buttonStyle(.plain)

                            NavigationLink { TeamView() } label: {
                                HomeMenuCard(icon: "person.2.fill",      title: "팀원보기",      color: AppTheme.accentBlue)
                            }.buttonStyle(.plain)

                            NavigationLink { SearchView() } label: {
                                HomeMenuCard(icon: "magnifyingglass",    title: "검색",          color: AppTheme.accentGreen)
                            }.buttonStyle(.plain)

                            NavigationLink { OrgChartView() } label: {
                                HomeMenuCard(icon: "list.bullet.indent", title: "조직도",        color: AppTheme.accentPurple)
                            }.buttonStyle(.plain)

                            NavigationLink { AddPhoneView() } label: {
                                HomeMenuCard(icon: "plus.circle.fill",   title: "전화번호 추가", color: colorTeal)
                            }.buttonStyle(.plain)

                            NavigationLink { CallHistoryView() } label: {
                                HomeMenuCard(icon: "phone.fill",         title: "통화내역",      color: colorRose)
                            }.buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        // 로그인 후 프로필 이미지 비동기 로드 (중복 호출 방지)
        .task {
            guard !isFetchingProfile, currentEmployee == nil,
                  let empNo = authManager.loginEmpNo else { return }
            isFetchingProfile = true
            currentEmployee = await EmployeeRepository.shared.getDetail(empNo: empNo)
            isFetchingProfile = false
        }
        // 로그아웃 확인 알림
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("로그아웃", role: .destructive) {
                authManager.clearSession()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("로그아웃 하시겠습니까?")
        }
    }

    // MARK: - 헤더

    private var headerBar: some View {
        HStack(spacing: 10) {
            // 로고
            if UIImage(named: "top_logo") != nil {
                Image("top_logo")
                    .resizable().scaledToFit().frame(height: 36)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 36, height: 36)
                    Text("BC")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text("후아유 임직원 서비스")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            // 로그아웃 버튼
            Button {
                showLogoutAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 13))
                    Text("로그아웃")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(white: 0.95))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
    }

    // MARK: - 프로필 카드

    private var profileCard: some View {
        // 프로필 표시용 Employee (API 응답 또는 로그인 세션 기반 임시)
        let displayEmployee = currentEmployee ?? Employee(
            empNo:         authManager.loginEmpNo  ?? "",
            name:          authManager.loginEmpNm  ?? "?",
            team:          "",
            teamCode:      "",
            position:      "",
            nickname:      "",
            jobTitle:      "",
            internalPhone: "",
            mobilePhone:   "",
            fax:           "",
            email:         "",
            imgdata:       nil
        )

        return NavigationLink {
            if let empNo = authManager.loginEmpNo {
                EmployeeDetailView(empNo: empNo)
            }
        } label: {
            HStack(spacing: 16) {
                // 프로필 아바타 (URL / Base64 / 첫 글자 폴백)
                ProfileAvatarView(employee: displayEmployee, size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    // 이름 + 닉네임 배지
                    HStack(spacing: 8) {
                        Text(displayEmployee.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        if let nick = currentEmployee?.nickname, !nick.isEmpty {
                            Text(nick)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.primary.opacity(0.10))
                                .cornerRadius(6)
                        }
                    }

                    // 팀 · 직책
                    if let emp = currentEmployee, !emp.team.isEmpty {
                        let sub = emp.position.isEmpty ? emp.team : "\(emp.team)  ·  \(emp.position)"
                        Text(sub)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(white: 0.4))
                    } else {
                        Text("내 프로필 보기")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    // 담당업무 배지
                    if let job = currentEmployee?.jobTitle, !job.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "wrench.fill").font(.system(size: 10))
                            Text(job).font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.3, green: 0.45, blue: 0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.92, green: 0.95, blue: 1.0))
                        .cornerRadius(20)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Color(white: 0.7))
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(white: 0.88), lineWidth: 1.5))
            .shadow(color: Color(white: 0.67).opacity(0.45), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 홈 메뉴 카드

struct HomeMenuCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            // 아이콘 배경
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.14))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 3)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(white: 0.88), lineWidth: 1.5))
        .shadow(color: Color(white: 0.67).opacity(0.40), radius: 10, x: 0, y: 4)
        .frame(height: 110)
    }
}
