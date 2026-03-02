import SwiftUI

struct AppTheme {
    // MARK: - Primary (Coral/Red)
    static let primary       = Color(red: 1.00, green: 0.27, blue: 0.27)   // #FF4545
    static let primaryDark   = Color(red: 0.88, green: 0.13, blue: 0.13)   // #E12020
    static let primaryLight  = Color(red: 1.00, green: 0.93, blue: 0.93)   // #FFEDED

    // MARK: - Backgrounds
    static let background    = Color(red: 0.97, green: 0.97, blue: 0.98)   // #F7F7FA
    static let cardBackground = Color.white

    // MARK: - Text
    static let textPrimary   = Color(red: 0.10, green: 0.10, blue: 0.12)   // #1A1A1F
    static let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.60)   // #8C8C99

    // MARK: - Utility
    static let divider       = Color(red: 0.92, green: 0.92, blue: 0.94)   // #EBEBF0
    static let callGreen     = Color(red: 0.13, green: 0.75, blue: 0.45)   // #22BF73

    // MARK: - Accent colors (for menu cards)
    static let accentOrange  = Color(red: 1.00, green: 0.60, blue: 0.20)   // #FF9933
    static let accentBlue    = Color(red: 0.22, green: 0.55, blue: 1.00)   // #388CFF
    static let accentGreen   = Color(red: 0.15, green: 0.78, blue: 0.50)   // #26C780
    static let accentPurple  = Color(red: 0.55, green: 0.30, blue: 0.95)   // #8C4DF2

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 1.00, green: 0.38, blue: 0.38), Color(red: 0.95, green: 0.15, blue: 0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.90, blue: 0.90),
            Color(red: 0.97, green: 0.97, blue: 0.98)
        ],
        startPoint: .top,
        endPoint: .center
    )

    // MARK: - Corner Radius
    static let radiusS: CGFloat = 12
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 24

    // MARK: - Shadow
    static func cardShadow() -> some View {
        RoundedRectangle(cornerRadius: radiusM)
            .fill(Color.black.opacity(0.05))
            .blur(radius: 10)
            .offset(y: 4)
    }
}

// MARK: - 카드 컨테이너 ViewModifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.radiusM)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
