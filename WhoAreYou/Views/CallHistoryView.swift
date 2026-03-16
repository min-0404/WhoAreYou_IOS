import SwiftUI

struct CallHistoryView: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryLight)
                        .frame(width: 72, height: 72)
                    Image(systemName: "iphone.slash")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.primary)
                }
                Text("이 기기에서는 지원하지 않는 기능입니다")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("통화내역 기능은 Android 기기에서\n이용하실 수 있습니다")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("통화내역")
        .navigationBarTitleDisplayMode(.inline)
    }
}
