import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert = false
    @State private var isLoggingOut = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 비씨후아유 Section
                        sectionHeader("비씨후아유")
                        VStack(spacing: 0) {
                            NavigationLink(destination: PhoneSettingsView()) {
                                SettingsRow(
                                    icon: "phone.fill",
                                    iconColor: AppTheme.accentGreen,
                                    title: "전화번호 설정",
                                    subtitle: "전화번호 추가 및 관리"
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, 64)

                            NavigationLink(destination: InfoView()) {
                                SettingsRow(
                                    icon: "info.circle.fill",
                                    iconColor: AppTheme.accentBlue,
                                    title: "가이드",
                                    subtitle: "앱 이용 안내 및 FAQ"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .cardStyle()
                        .padding(.horizontal, 16)

                        // 계정 Section
                        sectionHeader("계정")
                        VStack(spacing: 0) {
                            Button {
                                showLogoutAlert = true
                            } label: {
                                SettingsRow(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    iconColor: .red,
                                    title: "로그아웃",
                                    subtitle: "계정에서 로그아웃합니다",
                                    titleColor: .red,
                                    chevronColor: .red.opacity(0.5),
                                    trailingContent: {
                                        if isLoggingOut {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isLoggingOut)
                        }
                        .cardStyle()
                        .padding(.horizontal, 16)

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("로그아웃 하시겠습니까?")
        }
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

                Text("설정")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                // Balance the back button
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 56)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, 24)
            .padding(.bottom, -8)
    }

    // MARK: - Logout Logic

    private func performLogout() {
        isLoggingOut = true
        Task {
            _ = try? await AsisApiClient.shared.postForm(
                endpoint: ApiConstants.endpointMember,
                params: [
                    "actnKey": ApiConstants.actnLogout,
                    "authKey": AuthManager.shared.authKey ?? ""
                ]
            )
            await MainActor.run {
                AuthManager.shared.clearSession()
                isLoggingOut = false
            }
        }
    }
}

// MARK: - SettingsRow

private struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var titleColor: Color = AppTheme.textPrimary
    var chevronColor: Color = AppTheme.textSecondary.opacity(0.5)
    @ViewBuilder var trailingContent: () -> Trailing

    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        titleColor: Color = AppTheme.textPrimary,
        chevronColor: Color = AppTheme.textSecondary.opacity(0.5),
        @ViewBuilder trailingContent: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.titleColor = titleColor
        self.chevronColor = chevronColor
        self.trailingContent = trailingContent
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon box
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(titleColor)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            trailingContent()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(chevronColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
