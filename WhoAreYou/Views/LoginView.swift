import SwiftUI

struct LoginView: View {
    @State private var employeeId = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isLoggedIn: Bool
    @Binding var loggedInEmployee: Employee?

    var body: some View {
        ZStack {
            // 흰색 배경
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 로고 영역
                    VStack(spacing: 4) {
                        Image("login_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 240)

                        Text("BC후아유")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("테스트 계정 id: test / pw: 1")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 72)
                    .padding(.bottom, 36)

                    // 로그인 카드
                    VStack(spacing: 16) {
                        InputField(icon: "person.circle.fill", placeholder: "사번", text: $employeeId, isSecure: false)
                        InputField(icon: "lock.circle.fill", placeholder: "비밀번호", text: $password, isSecure: true)

                        // 로그인 버튼
                        Button(action: login) {
                            Text("로그인")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(AppTheme.primaryGradient)
                                .cornerRadius(AppTheme.radiusM)
                                .shadow(color: AppTheme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .padding(.top, 4)

                        // 비밀번호 변경 버튼
                        NavigationLink(destination: ChangePasswordView()) {
                            Text("비밀번호 변경")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.primaryLight)
                                .cornerRadius(AppTheme.radiusM)
                        }
                    }
                    .padding(24)
                    .cardStyle()
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    func login() {
        guard !employeeId.isEmpty, !password.isEmpty else {
            alertMessage = "사번과 비밀번호를 입력해주세요."
            showAlert = true
            return
        }
        if employeeId == "test" && password == "1" {
            if let employee = MockData.employees.first(where: { $0.id == 13 }) {
                loggedInEmployee = employee
                isLoggedIn = true
            }
        } else {
            alertMessage = "사번 또는 비밀번호가 올바르지 않습니다."
            showAlert = true
        }
    }
}

// 공통 입력 필드 컴포넌트
struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .font(.system(size: 20))
                .frame(width: 24)
            if isSecure {
                SecureField(text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.textSecondary)) {}
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                TextField(text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.textSecondary)) {}
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(AppTheme.background)
        .cornerRadius(AppTheme.radiusS)
    }
}
