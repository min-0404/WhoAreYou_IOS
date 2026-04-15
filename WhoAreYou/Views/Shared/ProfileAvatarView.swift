import SwiftUI

/// 직원 프로필 아바타 뷰 (이름 첫 글자 or 사진)
struct ProfileAvatarView: View {
    let employee: Employee
    let size: CGFloat

    private var avatarColors: [Color] {
        let colors: [[Color]] = [
            [Color(red: 1.0, green: 0.27, blue: 0.27), Color(red: 0.88, green: 0.13, blue: 0.13)],
            [Color(red: 0.22, green: 0.55, blue: 1.0),  Color(red: 0.13, green: 0.38, blue: 0.88)],
            [Color(red: 0.15, green: 0.78, blue: 0.50), Color(red: 0.10, green: 0.62, blue: 0.38)],
            [Color(red: 0.55, green: 0.30, blue: 0.95), Color(red: 0.42, green: 0.18, blue: 0.82)],
            [Color(red: 1.0,  green: 0.60, blue: 0.20), Color(red: 0.88, green: 0.45, blue: 0.10)],
        ]
        let idx = (employee.name.unicodeScalars.first?.value ?? 0) % UInt32(colors.count)
        return colors[Int(idx)]
    }

    var body: some View {
        ZStack {
            if let url = employee.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        fallbackView
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                fallbackView
            }
        }
    }

    private var fallbackView: some View {
        Circle()
            .fill(LinearGradient(colors: avatarColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .overlay(
                Text(employee.avatarLetter)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            )
    }
}
