import SwiftUI

/// Android 의 메인 탭 + PersistentGlassNavBar 와 동일한 구조
struct MainTabView: View {
    @State private var selectedTab = 1  // 0=가이드, 1=홈, 2=설정

    var body: some View {
        ZStack(alignment: .bottom) {
            // 탭 콘텐츠
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack { InfoView() }
                        .transition(.opacity)
                case 1:
                    NavigationStack { HomeView() }
                        .transition(.opacity)
                case 2:
                    NavigationStack { SettingsView() }
                        .transition(.opacity)
                default:
                    NavigationStack { HomeView() }
                }
            }
            .animation(.easeInOut(duration: 0.15), value: selectedTab)
            // 탭바 높이만큼 콘텐츠 아래 여백
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90)
            }

            // 글래스 내비바 오버레이
            VStack(spacing: 0) {
                GlassNavBar(selectedTab: $selectedTab)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, max(0, UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom ?? 0) - 8)
        }
        .ignoresSafeArea(.keyboard)
    }
}
