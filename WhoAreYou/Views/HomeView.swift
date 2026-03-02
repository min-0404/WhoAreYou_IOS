import SwiftUI

struct HomeView: View {
    let loggedInEmployee: Employee
    @Binding var isLoggedIn: Bool
    @State private var employees = MockData.employees
    @State private var showSettings = false
    @State private var showInfo = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 상단 헤더
                    HStack(spacing: 10) {
                        // BC카드 로고 (이미지 있으면 표시, 없으면 텍스트 폴백)
                        if UIImage(named: "bccard_logo") != nil {
                            Image("bccard_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 36, height: 36)
                                Text("BC")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("후아유 임직원 서비스")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Spacer()

                        // 로그아웃 버튼
                        Button(action: { showLogoutAlert = true }) {
                            HStack(spacing: 5) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                                Text("로그아웃")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.background)
                            .cornerRadius(AppTheme.radiusS)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Color.white
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {

                            // 내 프로필 카드
                            MyProfileCard(employee: loggedInEmployee)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)

                            // 메뉴 2x2 그리드
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                NavigationLink(destination: FavoritesView(employees: $employees)) {
                                    HomeMenuCard(icon: "star.fill",          title: "즐겨찾기", color: AppTheme.accentOrange)
                                }
                                NavigationLink(destination: TeamView(employees: $employees)) {
                                    HomeMenuCard(icon: "person.2.fill",      title: "팀원보기", color: AppTheme.accentBlue)
                                }
                                NavigationLink(destination: SearchView(employees: $employees)) {
                                    HomeMenuCard(icon: "magnifyingglass",    title: "검색",    color: AppTheme.accentGreen)
                                }
                                NavigationLink(destination: OrgChartView(employees: $employees)) {
                                    HomeMenuCard(icon: "list.bullet.indent", title: "조직도",  color: AppTheme.accentPurple)
                                }
                            }
                            .padding(.horizontal, 20)

                            // 안내 카드
                            Button(action: { showSettings = true }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.primaryLight)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(AppTheme.primary)
                                            .font(.system(size: 18))
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("전화번호부 업데이트")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("설정에서 주기적으로 데이터베이스 업데이트를 눌러주세요")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                }
                                .padding(16)
                            }
                            .buttonStyle(.plain)
                            .cardStyle()
                            .padding(.horizontal, 20)

                            Spacer(minLength: 100)
                        }
                    }

                    // 하단 탭바
                    HStack {
                        Spacer()
                        Button(action: { showInfo = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "info.circle").font(.system(size: 22))
                                Text("가이드").font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "house.fill").font(.system(size: 22))
                            Text("홈").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(AppTheme.primary)
                        Spacer()
                        Button(action: { showSettings = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "gearshape").font(.system(size: 22))
                                Text("설정").font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(
                        Color.white.shadow(color: Color.black.opacity(0.07), radius: 14, x: 0, y: -4)
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) { isLoggedIn = false }
        } message: {
            Text("로그아웃 하시겠습니까?")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isLoggedIn: $isLoggedIn)
        }
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                InfoView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("닫기") { showInfo = false }
                                .foregroundColor(AppTheme.primary)
                        }
                    }
            }
        }
    }
}

// MARK: - 내 프로필 카드
struct MyProfileCard: View {
    let employee: Employee

    var body: some View {
        NavigationLink(destination: EmployeeDetailView(employee: employee)) {
            HStack(spacing: 16) {
                // 프로필 아바타
                ProfileAvatar(
                    imageName: employee.profileImageName,
                    initial: String(employee.name.prefix(1)),
                    size: 62
                )

                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(employee.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(employee.nickname)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Text(employee.team)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    // 업무명 뱃지
                    HStack(spacing: 5) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.75))
                        Text(employee.jobTitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.28, blue: 0.65))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.88, green: 0.93, blue: 1.00))
                    .cornerRadius(20)
                    .padding(.top, 2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(18)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }
}

// MARK: - 홈 메뉴 카드
struct HomeMenuCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.14))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .cardStyle()
    }
}
