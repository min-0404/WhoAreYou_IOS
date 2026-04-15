import SwiftUI

/// Android 앱의 PersistentGlassNavBar 와 동일한 유리 스타일 하단 탭바
struct GlassNavBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, label: String)] = [
        ("info.circle.fill", "가이드"),
        ("house.fill",       "홈"),
        ("gearshape.fill",   "설정")
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 슬라이딩 pill
                let tabWidth = geo.size.width / CGFloat(tabs.count)
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(white: 0.1).opacity(0.08))
                    .frame(width: tabWidth, height: geo.size.height - 14)
                    .offset(x: tabWidth * CGFloat(selectedTab) + 0, y: 7)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)

                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { idx in
                        Button {
                            selectedTab = idx
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tabs[idx].icon)
                                    .font(.system(size: 22))
                                Text(tabs[idx].label)
                                    .font(.system(size: 10, weight: selectedTab == idx ? .bold : .regular))
                            }
                            .foregroundColor(selectedTab == idx ? Color(red: 0.1, green: 0.1, blue: 0.18) : Color(white: 0.67))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white, lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }
}
