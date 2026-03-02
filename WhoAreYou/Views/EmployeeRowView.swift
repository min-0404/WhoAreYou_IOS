import SwiftUI

struct EmployeeRowView: View {
    let employee: Employee
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        NavigationLink(destination: EmployeeDetailView(employee: employee, onToggleFavorite: onToggleFavorite)) {
            HStack(spacing: 14) {
                // 프로필 아바타
                ProfileAvatar(imageName: employee.profileImageName, initial: String(employee.name.prefix(1)), size: 52)

                // 직원 정보
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(employee.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(employee.position)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppTheme.primaryLight)
                            .cornerRadius(6)
                    }
                    Text("\(employee.team)  ·  \(employee.nickname)")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)

                    HStack(spacing: 8) {
                        CallButton(title: "사내전화", color: AppTheme.callGreen, phone: employee.internalPhone)
                        CallButton(title: "휴대전화", color: AppTheme.primary,   phone: employee.mobilePhone)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                // 즐겨찾기 버튼
                if let toggle = onToggleFavorite {
                    Button(action: toggle) {
                        Image(systemName: employee.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 18))
                            .foregroundColor(employee.isFavorite ? Color(red: 1.0, green: 0.75, blue: 0.0) : AppTheme.textSecondary.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

// 프로필 이미지 or 기본 프로필 아바타
struct ProfileAvatar: View {
    let imageName: String?
    let initial: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.primaryLight)
                .frame(width: size, height: size)

            if let name = imageName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if UIImage(named: "default_profile") != nil {
                Image("default_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(initial)
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }
        }
    }
}

struct CallButton: View {
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
            HStack(spacing: 4) {
                Image(systemName: "phone.fill").font(.system(size: 10))
                Text(title).font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
