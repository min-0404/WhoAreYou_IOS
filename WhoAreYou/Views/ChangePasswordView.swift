import SwiftUI

struct ChangePasswordView: View {
    @State private var employeeId = ""
    @State private var otp = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isSuccess = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // 로고
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 90, height: 90)
                                .shadow(color: AppTheme.primary.opacity(0.4), radius: 16, x: 0, y: 8)
                            VStack(spacing: 2) {
                                Text("BC")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        Text("비밀번호 변경")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(.top, 40)

                    // 입력 카드
                    VStack(spacing: 12) {
                        GlassInputField(icon: "person.circle.fill", placeholder: "사번을 입력하세요", text: $employeeId, isSecure: false)
                        GlassInputField(icon: "circle.grid.cross.fill", placeholder: "OTP 번호를 입력하세요", text: $otp, isSecure: false)
                        GlassInputField(icon: "lock.circle.fill", placeholder: "새 비밀번호를 입력하세요", text: $newPassword, isSecure: true)
                        GlassInputField(icon: "lock.rotation", placeholder: "비밀번호를 재입력하세요", text: $confirmPassword, isSecure: true)

                        Button(action: changePassword) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("비밀번호 변경")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(AppTheme.radiusS)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isLoading)
                        .padding(.top, 4)
                    }
                    .padding(22)
                    .cardStyle()
                    .padding(.horizontal, 24)

                    // 안내 카드
                    VStack(alignment: .leading, spacing: 10) {
                        Label("비밀번호 안내", systemImage: "info.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                        VStack(alignment: .leading, spacing: 6) {
                            GuideRow(text: "8자리 이상, 문자/숫자/특수문자 포함 필수")
                            GuideRow(text: "변경 완료 후 로그인 페이지로 이동합니다")
                        }
                    }
                    .padding(18)
                    .cardStyle()
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("비밀번호 변경")
        .navigationBarTitleDisplayMode(.inline)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                if isSuccess { dismiss() }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func changePassword() {
        guard !employeeId.isEmpty, !otp.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "모든 항목을 입력해주세요."
            isSuccess = false
            showAlert = true
            return
        }
        guard newPassword == confirmPassword else {
            alertMessage = "비밀번호가 일치하지 않습니다."
            isSuccess = false
            showAlert = true
            return
        }
        guard isValidPassword(newPassword) else {
            alertMessage = "비밀번호는 8자리 이상, 문자/숫자/특수문자를 포함해야 합니다."
            isSuccess = false
            showAlert = true
            return
        }

        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let html = try await AsisApiClient.shared.postForm(
                    endpoint: ApiConstants.endpointMember,
                    params: [
                        "actnKey": "updatePwd",
                        "empNo": employeeId,
                        "otpNo": otp,
                        "pwd": newPassword
                    ]
                )
                // Treat any non-empty response as success; adapt if server returns an error token
                if html.contains("error") || html.contains("fail") || html.contains("실패") {
                    alertMessage = "비밀번호 변경에 실패했습니다. 사번 또는 OTP를 확인해주세요."
                    isSuccess = false
                } else {
                    alertMessage = "비밀번호 변경이 완료되었습니다."
                    isSuccess = true
                }
            } catch {
                alertMessage = "네트워크 오류: \(error.localizedDescription)"
                isSuccess = false
            }
            showAlert = true
        }
    }

    private func isValidPassword(_ password: String) -> Bool {
        let hasLetter  = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasNumber  = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        return password.count >= 8 && hasLetter && hasNumber && hasSpecial
    }
}

struct GuideRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(AppTheme.textSecondary).frame(width: 4, height: 4).padding(.top, 6)
            Text(text).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
        }
    }
}
