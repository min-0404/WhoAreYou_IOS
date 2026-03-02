import SwiftUI

struct EmployeeDetailView: View {
    let employee: Employee
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // 프로필 헤더 카드
                    VStack(spacing: 14) {
                        // 프로필 아바타
                        ProfileAvatar(imageName: employee.profileImageName, initial: String(employee.name.prefix(1)), size: 96)

                        // 이름
                        Text(employee.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        // 팀 / 직책 / 닉네임
                        Text("\(employee.team)  \(employee.position)  /  \(employee.nickname)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)

                        // 담당 업무
                        HStack(spacing: 6) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.75))
                            Text(employee.jobTitle)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.12, green: 0.28, blue: 0.65))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.88, green: 0.93, blue: 1.00))
                        .cornerRadius(20)

                        // 전화 버튼
                        HStack(spacing: 10) {
                            DetailCallButton(title: "사내전화", color: AppTheme.callGreen, phone: employee.internalPhone)
                            DetailCallButton(title: "휴대전화", color: AppTheme.primary, phone: employee.mobilePhone)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .cardStyle()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // 연락처 정보 카드
                    VStack(spacing: 0) {
                        ContactRow(icon: "phone.fill",          label: "사내전화", value: employee.internalPhone, actionURL: "tel://\(employee.internalPhone.replacingOccurrences(of: "-", with: ""))")
                        Divider().padding(.leading, 64)
                        ContactRow(icon: "iphone",              label: "휴대전화", value: employee.mobilePhone,   actionURL: "tel://\(employee.mobilePhone.replacingOccurrences(of: "-", with: ""))")
                        Divider().padding(.leading, 64)
                        ContactRow(icon: "printer.fill",        label: "팩스",    value: employee.fax,           actionURL: nil)
                        Divider().padding(.leading, 64)
                        ContactRow(icon: "checkmark.seal.fill", label: "이메일",  value: employee.email,         actionURL: "mailto:\(employee.email)")
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle(employee.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let toggle = onToggleFavorite {
                    Button(action: toggle) {
                        Image(systemName: employee.isFavorite ? "star.fill" : "star")
                            .foregroundColor(employee.isFavorite ? Color(red: 1.0, green: 0.75, blue: 0.0) : AppTheme.textSecondary)
                    }
                }
            }
        }
    }
}

struct DetailCallButton: View {
    let title: String
    let color: Color
    let phone: String

    var body: some View {
        Button(action: {
            let cleaned = phone.replacingOccurrences(of: "-", with: "")
            if let url = URL(string: "tel://\(cleaned)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "phone.fill").font(.system(size: 13))
                Text(title).font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 11)
            .background(color)
            .cornerRadius(AppTheme.radiusM)
            .shadow(color: color.opacity(0.30), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let actionURL: String?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.10))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            if let urlString = actionURL, let url = URL(string: urlString) {
                Button(action: { UIApplication.shared.open(url) }) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.background)
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
