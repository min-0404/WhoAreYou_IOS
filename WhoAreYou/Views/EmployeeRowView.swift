import SwiftUI

/// 직원 목록에서 사용하는 공통 행 컴포넌트
struct EmployeeRowView: View {
    let employee: Employee
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileAvatarView(employee: employee, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(employee.name).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    if !employee.position.isEmpty {
                        Text(employee.position)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Color(white: 0.93))
                            .foregroundColor(AppTheme.textPrimary).cornerRadius(6)
                    }
                }
                if !employee.team.isEmpty {
                    Text(employee.team).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
            }
            Spacer()
            Button(action: onFavoriteToggle) {
                Image(systemName: employee.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundColor(employee.isFavorite ? AppTheme.accentOrange : AppTheme.textSecondary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(Color.white).cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

/// 팀원보기 화면용 확장 행 (전화 버튼 포함)
struct TeamMemberRowView: View {
    let employee: Employee
    let onFavoriteToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ProfileAvatarView(employee: employee, size: 46)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(employee.name).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        if !employee.position.isEmpty {
                            Text(employee.position)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 7).padding(.vertical, 2)
                                .background(Color(white: 0.93))
                                .foregroundColor(AppTheme.textPrimary).cornerRadius(6)
                        }
                    }
                    Text("\(employee.team) · \(employee.nickname)").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Button(action: onFavoriteToggle) {
                    Image(systemName: employee.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18))
                        .foregroundColor(employee.isFavorite ? AppTheme.accentOrange : AppTheme.textSecondary.opacity(0.4))
                }.buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                PhoneBtn(label: "사내전화", phone: employee.internalPhone, color: AppTheme.accentGreen)
                PhoneBtn(label: "휴대전화", phone: employee.mobilePhone, color: AppTheme.primary)
            }
            .padding(.top, 14)
        }
        .padding(16)
        .background(Color.white).cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

private struct PhoneBtn: View {
    let label: String; let phone: String; let color: Color
    var body: some View {
        Button {
            if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") { UIApplication.shared.open(url) }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "phone.fill").font(.system(size: 11))
                Text(label).font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(color).cornerRadius(8)
        }
        .disabled(phone.isEmpty)
        .opacity(phone.isEmpty ? 0.4 : 1)
    }
}
