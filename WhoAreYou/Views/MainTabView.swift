import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1  // 0=가이드, 1=홈, 2=설정

    init() {
        // 기본 TabBar 숨기기 (커스텀 GlassNavBar 사용)
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack { InfoView() }
                    .tag(0)
                NavigationStack { HomeView() }
                    .tag(1)
                NavigationStack { SettingsView() }
                    .tag(2)
            }
            // 하단 GlassNavBar 높이만큼 여백 확보
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 88)
            }

            // 커스텀 글래스 탭바
            GlassNavBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard)
    }
}
