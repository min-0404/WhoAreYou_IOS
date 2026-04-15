import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                ScrollView {
                    VStack(spacing: 24) {
                        // Logo section
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 80, height: 80)
                                Text("BC")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 24)

                        // FAQ card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("- FAQ")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            VStack(alignment: .leading, spacing: 10) {
                                faqItem("비씨후아유는 BC임직원(G,J,K,M,P)만 이용할 수 있습니다.")
                                faqItem("휴직자, 퇴직자는 비씨후아유에 로그인할 수 없습니다.")
                                faqItem("비씨후아유 앱은 HRMS에 등록된 휴대폰번호와 사용중인 휴대폰 번호가 같은 경우에만 이용할 수 있습니다.")
                                faqItem("비밀번호는 문자, 숫자, 특수문자가 포함된 8자리 이상으로 설정해야 합니다.")
                                faqItem("비밀번호 변경 시 BC-OTP 앱 비밀번호가 아니라 BC-OTP 앱의 인증번호 7자리가 필요합니다.")
                                faqItem("iOS 10버전 이상만 임직원 전화 수신 기능을 이용할 수 있습니다.")
                                faqItem("안드로이드 전화 수신 팝업은 네트워크 상태에 따라 지연될 수 있습니다.")
                                faqItem("비씨후아유앱 업데이트 시 반드시 기존 비씨후아유 앱을 삭제 후 재설치하여 주시기 바랍니다.")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .cardStyle()
                        .padding(.horizontal, 16)

                        // Download URL card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("- 비씨후아유 다운로드 URL")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            HStack(alignment: .top, spacing: 4) {
                                Text("안드로이드 :")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("http://bc.cr/?AGdwq")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.accentBlue)
                            }

                            HStack(alignment: .top, spacing: 4) {
                                Text("iOS :")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("http://bc.cr/?oDZaN")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.accentBlue)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .cardStyle()
                        .padding(.horizontal, 16)

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

                Text("가이드")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 56)
    }

    // MARK: - FAQ Item

    private func faqItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("-")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
