import SwiftUI

struct HomeView: View {
    let loggedInEmployee: Employee
    @Binding var isLoggedIn: Bool
    // 초기값은 MockData (API 호출 전 즉시 표시), 이후 .task에서 API 결과로 교체됨
    @State private var employees = MockData.employees
    @State private var showSettings = false
    @State private var showInfo = false
    @State private var showLogoutAlert = false

    // 트렌디한 신규 색상
    private let colorTeal = Color(red: 0.00, green: 0.71, blue: 0.85)  // #00B4D9
    private let colorRose = Color(red: 0.91, green: 0.12, blue: 0.55)  // #E91E8C

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 상단 헤더
                    HStack(spacing: 10) {
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

                        Text("후아유 임직원 서비스")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

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

                    // 콘텐츠 영역 (스크롤 없음, 화면에 꽉 맞춤)
                    VStack(spacing: 10) {
                        // 내 프로필 카드
                        MyProfileCard(employee: loggedInEmployee)

                        // 메뉴 그리드 3행 × 2열 (고정 높이 → 하단 여백 자동 확보)
                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                NavigationLink(destination: FavoritesView(employees: $employees)) {
                                    HomeMenuCard(icon: "star.fill", title: "즐겨찾기", color: AppTheme.accentOrange)
                                }
                                NavigationLink(destination: TeamView(employees: $employees)) {
                                    HomeMenuCard(icon: "person.2.fill", title: "팀원보기", color: AppTheme.accentBlue)
                                }
                            }
                            .frame(height: 100)

                            HStack(spacing: 12) {
                                NavigationLink(destination: SearchView(employees: $employees)) {
                                    HomeMenuCard(icon: "magnifyingglass", title: "검색", color: AppTheme.accentGreen)
                                }
                                NavigationLink(destination: OrgChartView(employees: $employees)) {
                                    HomeMenuCard(icon: "list.bullet.indent", title: "조직도", color: AppTheme.accentPurple)
                                }
                            }
                            .frame(height: 100)

                            HStack(spacing: 12) {
                                NavigationLink(destination: AddPhoneView()) {
                                    HomeMenuCard(icon: "plus.circle.fill", title: "전화번호 추가", color: colorTeal)
                                }
                                NavigationLink(destination: CallHistoryView()) {
                                    HomeMenuCard(icon: "phone.fill", title: "통화내역", color: colorRose)
                                }
                            }
                            .frame(height: 100)
                        }

                        // 전화번호부 업데이트 안내 카드
                        Button(action: { showSettings = true }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryLight)
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(AppTheme.primary)
                                        .font(.system(size: 16))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("전화번호부 업데이트")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("설정에서 주기적으로 데이터베이스 업데이트를 눌러주세요")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        .cardStyle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .frame(maxHeight: .infinity, alignment: .top)

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
            .task {
                // 앱 시작 시 API에서 임직원 목록을 불러옵니다.
                // API 실패 시 초기값 MockData가 그대로 유지됩니다.
                employees = await EmployeeAPIService.shared.fetchEmployees()
            }
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
            HStack(spacing: 14) {
                ProfileAvatar(photoUrl: employee.photoUrl, size: 54)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(employee.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(employee.nickname)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Text(employee.team)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

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
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }
}

// MARK: - 홈 메뉴 카드 (화면 높이에 비례해 자동 조절)
struct HomeMenuCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.14))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            Spacer(minLength: 8)
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardStyle()
    }
}
