import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared

    private let colorTeal = Color(red: 0.00, green: 0.71, blue: 0.85)
    private let colorRose = Color(red: 0.91, green: 0.12, blue: 0.55)

    var displayName: String { authManager.loginEmpNm ?? "사용자" }
    var displayOrgNm: String { authManager.loginOrgCd ?? "" }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // 상단 헤더
                    HStack {
                        if UIImage(named: "top_logo") != nil {
                            Image("top_logo")
                                .resizable().scaledToFit().frame(height: 36)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8).fill(AppTheme.primaryGradient).frame(width: 36, height: 36)
                                Text("BC").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            }
                        }
                        Text("후아유 임직원 서비스")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2))

                    VStack(spacing: 10) {
                        // 내 프로필 카드 (글래스)
                        NavigationLink {
                            if let empNo = authManager.loginEmpNo {
                                EmployeeDetailView(empNo: empNo)
                            }
                        } label: {
                            GlassCard {
                                HStack(spacing: 14) {
                                    // 아바타
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.primaryGradient)
                                            .frame(width: 54, height: 54)
                                        Text(String((authManager.loginEmpNm ?? "U").prefix(1)))
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(displayName)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("내 프로필 보기")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.4))
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(16)
                            }
                        }
                        .buttonStyle(.plain)

                        // 메뉴 그리드 3행 × 2열
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            NavigationLink { FavoritesView() } label: {
                                GlassMenuCard(icon: "star.fill",           title: "즐겨찾기",     color: AppTheme.accentOrange)
                            }.buttonStyle(.plain)

                            NavigationLink { TeamView() } label: {
                                GlassMenuCard(icon: "person.2.fill",       title: "팀원보기",     color: AppTheme.accentBlue)
                            }.buttonStyle(.plain)

                            NavigationLink { SearchView() } label: {
                                GlassMenuCard(icon: "magnifyingglass",     title: "검색",        color: AppTheme.accentGreen)
                            }.buttonStyle(.plain)

                            NavigationLink { OrgChartView() } label: {
                                GlassMenuCard(icon: "list.bullet.indent",  title: "조직도",      color: AppTheme.accentPurple)
                            }.buttonStyle(.plain)

                            NavigationLink { AddPhoneView() } label: {
                                GlassMenuCard(icon: "plus.circle.fill",    title: "전화번호 추가", color: colorTeal)
                            }.buttonStyle(.plain)

                            NavigationLink { CallHistoryView() } label: {
                                GlassMenuCard(icon: "phone.fill",          title: "통화내역",     color: colorRose)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct GlassMenuCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
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
        }
        .frame(height: 110)
    }
}
