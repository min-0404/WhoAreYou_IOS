import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared

    // 탭 선택: 0=로그인, 1=비밀번호 초기화
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // 바깥 탭 → 키보드 닫기
            Color.white.ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
                }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 로고
                    VStack(spacing: 6) {

                        Image("login_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)

                        (Text("BC").foregroundColor(Color(red: 0.85, green: 0.10, blue: 0.10))
                         + Text("후아유").foregroundColor(AppTheme.textPrimary))
                            .font(.system(size: 26, weight: .bold, design: .rounded))

                        Text("임직원정보 조회 서비스")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.75))
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
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Login Form

private struct LoginFormView: View {
    @StateObject private var authManager = AuthManager.shared

    @State private var empNo    = ""
    @State private var password = ""
    @State private var phone1   = ""   // 010
    @State private var phone2   = ""   // 1234
    @State private var phone3   = ""   // 5678
    @State private var isLoading    = false
    @State private var errorMessage = ""

    // 포커스 상태
    @FocusState private var focusedField: PhoneField?
    enum PhoneField { case p1, p2, p3 }

    // 서버로 보낼 전화번호 (하이픈 없이)
    private var normalizedPhone: String { phone1 + phone2 + phone3 }

    var body: some View {
        VStack(spacing: 12) {
            GlassInputField(icon: "person.circle.fill", placeholder: "사번", text: $empNo, isSecure: false)
                .keyboardType(.numberPad)
            GlassInputField(icon: "lock.circle.fill",   placeholder: "비밀번호", text: $password, isSecure: true)

            // ── 3칸 전화번호 입력 ──────────────────────────────────
            PhoneNumberInput(
                phone1: $phone1,
                phone2: $phone2,
                phone3: $phone3,
                focusedField: $focusedField
            )

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
        // 숫자패드에 완료 버튼 추가 (숫자패드는 리턴키 없음)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
                }
                .font(.system(size: 15, weight: .semibold))
            }
        }
    }

    private func login() {
        errorMessage = ""
        guard !empNo.isEmpty, !password.isEmpty else {
            errorMessage = "사번과 비밀번호를 입력해주세요."
            return
        }
        guard normalizedPhone.count >= 10 else {
            errorMessage = "올바른 휴대폰번호를 입력해주세요.\n(예: 010 · 1234 · 5678)"
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
                        "phoneNo": normalizedPhone,
                        "isApp":   "Y",
                        "version": "14"
                    ]
                )
                if let result = AsisLoginParser.parse(html) {
                    authManager.saveSession(
                        authKey:  result.authKey,
                        empNo:    result.empNo.isEmpty ? empNo : result.empNo,
                        empNm:    result.empNm,
                        orgCd:    result.orgCd,
                        phoneNo:  normalizedPhone
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

// MARK: - 3칸 전화번호 입력 컴포넌트

private struct PhoneNumberInput: View {
    @Binding var phone1: String
    @Binding var phone2: String
    @Binding var phone3: String
    @FocusState.Binding var focusedField: LoginFormView.PhoneField?

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "iphone")
                .foregroundColor(AppTheme.primary)
                .font(.system(size: 18))
                .frame(width: 22)
                .padding(.leading, 14)

            Spacer().frame(width: 12)

            // 010 칸 (최대 3자리)
            TextField("010", text: $phone1)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(minWidth: 40)
                .focused($focusedField, equals: .p1)
                .onChange(of: phone1) { _, val in
                    phone1 = String(val.filter { $0.isNumber }.prefix(3))
                    if phone1.count >= 3 { focusedField = .p2 }
                }

            Text("-")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 6)

            // 중간 4자리
            TextField("0000", text: $phone2)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(minWidth: 50)
                .focused($focusedField, equals: .p2)
                .onChange(of: phone2) { _, val in
                    phone2 = String(val.filter { $0.isNumber }.prefix(4))
                    if phone2.count >= 4 { focusedField = .p3 }
                }

            Text("-")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 6)

            // 마지막 4자리
            TextField("0000", text: $phone3)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(minWidth: 50)
                .focused($focusedField, equals: .p3)
                .onChange(of: phone3) { _, val in
                    phone3 = String(val.filter { $0.isNumber }.prefix(4))
                }

            Spacer()
        }
        .padding(.vertical, 14)
        .background(Color(red: 0.93, green: 0.93, blue: 0.94))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.8), lineWidth: 1.5))
        .shadow(color: Color(white: 0.67).opacity(0.30), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Password Reset Form

private struct PasswordResetFormView: View {
    @State private var empNo    = ""
    @State private var phone1   = ""
    @State private var phone2   = ""
    @State private var phone3   = ""
    @State private var newPwd   = ""
    @State private var motp     = ""
    @State private var isLoading = false
    @State private var message  = ""
    @State private var isSuccess = false

    @FocusState private var focusedField: LoginFormView.PhoneField?

    private var normalizedPhone: String { phone1 + phone2 + phone3 }

    var body: some View {
        VStack(spacing: 12) {
            GlassInputField(icon: "person.circle.fill", placeholder: "사번",       text: $empNo,  isSecure: false)
                .keyboardType(.numberPad)
            PhoneNumberInput(phone1: $phone1, phone2: $phone2, phone3: $phone3, focusedField: $focusedField)
            GlassInputField(icon: "lock.circle.fill",   placeholder: "신규 비밀번호", text: $newPwd, isSecure: true)
            GlassInputField(icon: "key.fill",           placeholder: "OTP 인증번호",  text: $motp,   isSecure: false).keyboardType(.numberPad)

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
        guard !empNo.isEmpty, normalizedPhone.count >= 10, !newPwd.isEmpty, !motp.isEmpty else {
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
                        "phoneNo": normalizedPhone,
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
                SecureField("", text: $text,
                            prompt: Text(placeholder).foregroundColor(Color(white: 0.6)))
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                TextField("", text: $text,
                          prompt: Text(placeholder).foregroundColor(Color(white: 0.6)))
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
