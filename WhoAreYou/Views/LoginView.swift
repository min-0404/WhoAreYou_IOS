import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared

    // 탭 선택: 0=로그인, 1=비밀번호 초기화
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 로고
                    VStack(spacing: 6) {
                        Image("login_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)

                        Text("BC후아유")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                    // 탭 + 카드
                    GlassCard {
                        VStack(spacing: 16) {
                            // 슬라이딩 탭
                            SlidingTabSelector(
                                tabs: ["로그인", "비밀번호 초기화"],
                                selectedIndex: $selectedTab
                            )

                            if selectedTab == 0 {
                                LoginFormView()
                            } else {
                                PasswordResetFormView()
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

// MARK: - Login Form

private struct LoginFormView: View {
    @StateObject private var authManager = AuthManager.shared

    @State private var empNo = ""
    @State private var password = ""
    @State private var phoneNo = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 12) {
            GlassInputField(icon: "person.circle.fill", placeholder: "사번", text: $empNo, isSecure: false)
            GlassInputField(icon: "lock.circle.fill",   placeholder: "비밀번호", text: $password, isSecure: true)
            GlassInputField(icon: "iphone",             placeholder: "휴대폰번호 (하이픈 없이)", text: $phoneNo, isSecure: false)
                .keyboardType(.numberPad)
                .frame(height: 44)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: login) {
                ZStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("로그인")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(AppTheme.primaryGradient)
                .cornerRadius(AppTheme.radiusM)
                .shadow(color: AppTheme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
            }
            .disabled(isLoading)
            .padding(.top, 4)
        }
    }

    private func login() {
        errorMessage = ""
        guard !empNo.isEmpty, !password.isEmpty else {
            errorMessage = "사번과 비밀번호를 입력해주세요."
            return
        }
        guard !phoneNo.isEmpty else {
            errorMessage = "휴대폰번호를 입력해주세요."
            return
        }

        isLoading = true
        Task {
            defer { isLoading = false }

            do {
                let html = try await AsisApiClient.shared.postForm(
                    endpoint: ApiConstants.endpointMember,
                    params: [
                        "actnKey": ApiConstants.actnLogin,
                        "empNo":   empNo,
                        "passwd":  password,
                        "phoneNo": phoneNo.filter { $0.isNumber },
                        "isApp":   "Y",
                        "version": "14"
                    ]
                )

                if let result = AsisLoginParser.parse(html) {
                    await authManager.saveSession(
                        authKey:  result.authKey,
                        empNo:    result.empNo.isEmpty ? empNo : result.empNo,
                        empNm:    result.empNm,
                        orgCd:    result.orgCd,
                        phoneNo:  phoneNo.filter { $0.isNumber }
                    )
                } else {
                    errorMessage = AsisLoginParser.parseError(html) ?? "로그인에 실패했습니다."
                }
            } catch {
                errorMessage = "네트워크 오류: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Password Reset Form

private struct PasswordResetFormView: View {
    @State private var empNo    = ""
    @State private var phoneNo  = ""
    @State private var newPwd   = ""
    @State private var motp     = ""
    @State private var isLoading = false
    @State private var message  = ""
    @State private var isSuccess = false

    var body: some View {
        VStack(spacing: 12) {
            GlassInputField(icon: "person.circle.fill", placeholder: "사번",             text: $empNo,   isSecure: false)
            GlassInputField(icon: "iphone",             placeholder: "휴대폰번호 (하이픈 없이)", text: $phoneNo, isSecure: false).keyboardType(.numberPad)
            GlassInputField(icon: "lock.circle.fill",   placeholder: "새 비밀번호",        text: $newPwd,  isSecure: true)
            GlassInputField(icon: "key.fill",           placeholder: "MOTP 값",          text: $motp,    isSecure: false).keyboardType(.numberPad)

            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(isSuccess ? AppTheme.accentGreen : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: resetPassword) {
                ZStack {
                    if isLoading { ProgressView().tint(.white) }
                    else {
                        Text("비밀번호 초기화")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 17)
                .background(AppTheme.primaryLight)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusM).stroke(AppTheme.primary, lineWidth: 1.5))
                .cornerRadius(AppTheme.radiusM)
            }
            .disabled(isLoading)
            .padding(.top, 4)
        }
    }

    private func resetPassword() {
        message = ""; isSuccess = false
        guard !empNo.isEmpty, !phoneNo.isEmpty, !newPwd.isEmpty, !motp.isEmpty else {
            message = "모든 항목을 입력해주세요."; return
        }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let html = try await AsisApiClient.shared.postForm(
                    endpoint: ApiConstants.endpointMember,
                    params: [
                        "actnKey": ApiConstants.actnChangePwd,
                        "empNo":   empNo,
                        "phoneNo": phoneNo.filter { $0.isNumber },
                        "passwd":  newPwd,
                        "motp":    motp,
                        "isApp":   "Y"
                    ]
                )
                if AsisLoginParser.parsePasswordReset(html) {
                    message = "비밀번호가 변경되었습니다."; isSuccess = true
                } else {
                    message = "비밀번호 변경에 실패했습니다."
                }
            } catch {
                message = "네트워크 오류: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Shared Components

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
            .cornerRadius(28)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white, lineWidth: 2))
            .shadow(color: Color(white: 0.67).opacity(0.45), radius: 18, x: 0, y: 8)
            .shadow(color: Color(white: 0.53).opacity(0.25), radius: 6, x: 0, y: 2)
    }
}

struct GlassInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .font(.system(size: 18))
                .frame(width: 22)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(red: 0.93, green: 0.93, blue: 0.94))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.8), lineWidth: 1.5))
        .shadow(color: Color(white: 0.67).opacity(0.30), radius: 5, x: 0, y: 2)
    }
}

struct SlidingTabSelector: View {
    let tabs: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.91, green: 0.91, blue: 0.92))

                // 선택 pill
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                    .shadow(color: Color(white: 0.67).opacity(0.30), radius: 4, x: 0, y: 1)
                    .frame(width: (geo.size.width - 8) / CGFloat(tabs.count))
                    .offset(x: 4 + (geo.size.width - 8) / CGFloat(tabs.count) * CGFloat(selectedIndex))
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedIndex)

                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { idx in
                        Button { selectedIndex = idx } label: {
                            Text(tabs[idx])
                                .font(.system(size: 14, weight: selectedIndex == idx ? .semibold : .regular))
                                .foregroundColor(selectedIndex == idx ? AppTheme.textPrimary : AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: 40)
    }
}
