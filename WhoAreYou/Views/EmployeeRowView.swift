import SwiftUI
import Kingfisher

struct EmployeeRowView: View {
    let employee: Employee
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── 상단: 프로필 정보 + 즐겨찾기 별 ──
            HStack(spacing: 14) {
                // NavigationLink는 아바타 + 이름 영역만 감쌈
                NavigationLink(destination: EmployeeDetailView(employee: employee, onToggleFavorite: onToggleFavorite)) {
                    HStack(spacing: 14) {
                        ProfileAvatar(photoUrl: employee.photoUrl, size: 52)

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
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // 즐겨찾기 별 버튼 – NavigationLink 바깥에 위치
                if let toggle = onToggleFavorite {
                    Button(action: toggle) {
                        Image(systemName: employee.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 20))
                            .foregroundColor(
                                employee.isFavorite
                                    ? Color(red: 1.0, green: 0.75, blue: 0.0)
                                    : AppTheme.textSecondary.opacity(0.4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // ── 하단: 전화 버튼 – NavigationLink 바깥에 위치 ──
            HStack(spacing: 8) {
                CallButton(title: "사내전화", color: AppTheme.callGreen, phone: employee.internalPhone)
                CallButton(title: "휴대전화", color: AppTheme.primary,   phone: employee.mobilePhone)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

// 프로필 아바타
// - photoUrl 있음 → Kingfisher 다운로드 + 캐시 (로딩 중·실패 시 default_profile 표시)
// - photoUrl 없음 → default_profile 즉시 표시
struct ProfileAvatar: View {
    var photoUrl: String? = nil    // 서버 사진 URL
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = photoUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder { defaultProfileImage }
                    .resizable()
                    .scaledToFill()
            } else {
                defaultProfileImage
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var defaultProfileImage: some View {
        Image("default_profile")
            .resizable()
            .scaledToFill()
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
