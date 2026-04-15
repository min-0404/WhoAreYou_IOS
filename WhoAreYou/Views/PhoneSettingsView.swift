import SwiftUI

struct PhoneSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryLight)
                                    .frame(width: 100, height: 100)
                                Image(systemName: "phone.badge.checkmark")
                                    .font(.system(size: 42, weight: .medium))
                                    .foregroundColor(AppTheme.primary)
                            }

                            Text("iOS 전화번호 설정")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("iOS에서는 연락처를 통해\n임직원 전화 수신 표시를 지원합니다.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.top, 32)

                        // iOS info card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppTheme.accentBlue.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppTheme.accentBlue)
                                }
                                Text("iOS 안내")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Text("Android와 달리 iOS에서는 수신 전화 팝업을 통한 임직원 자동 표시 기능은 제공되지 않습니다. 대신, 아래 방법으로 임직원 번호를 연락처에 추가하여 수신 시 이름을 확인할 수 있습니다.")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(5)

                            Divider()

                            VStack(alignment: .leading, spacing: 12) {
                                stepRow(number: "1", text: "아래 \"전화번호 추가하기\" 버튼을 눌러 임직원 번호를 추가합니다.")
                                stepRow(number: "2", text: "저장된 번호는 수신 전화 시 이름으로 표시됩니다.")
                                stepRow(number: "3", text: "iOS 10 이상 버전에서 임직원 전화 수신 기능을 이용할 수 있습니다.")
                            }
                        }
                        .padding(20)
                        .cardStyle()
                        .padding(.horizontal, 16)

                        // NavigationLink button to AddPhoneView
                        NavigationLink(destination: AddPhoneView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 17))
                                Text("전화번호 추가하기")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryGradient)
                            .foregroundColor(.white)
                            .cornerRadius(AppTheme.radiusM)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 32)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        ZStack {
            AppTheme.cardBackground
                .ignoresSafeArea(edges: .top)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text("전화번호 설정")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 56)
    }

    // MARK: - Step Row

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 22, height: 22)
                Text(number)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
