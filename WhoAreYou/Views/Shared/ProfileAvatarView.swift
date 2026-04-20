import SwiftUI

/// 직원 프로필 아바타 뷰 (이름 첫 글자 or 사진)
/// - URL 이미지(상대/절대) → AsisApiClient 세션으로 로드 (JSESSIONID 쿠키 + TrustAllSSL)
///   AsyncImage 는 URLSession.shared 사용 → TrustAllSSLDelegate 없어 SSL 타임아웃 발생
/// - data:image/... Base64 → UIImage 디코딩 후 표시
/// - 로드 실패 / nil → 이름 첫 글자 그라디언트 아바타
struct ProfileAvatarView: View {
    let employee: Employee
    let size: CGFloat

    @State private var loadedImage: UIImage? = nil
    @State private var isLoading = false

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
        Group {
            if let img = loadedImage {
                // 성공적으로 로드된 이미지
                Image(uiImage: img)
                    .resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if let decoded = decodeBase64(employee.imgdata) {
                // Base64 / data URI 이미지 (즉시 표시 가능)
                Image(uiImage: decoded)
                    .resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                // URL 로딩 중이거나 이미지 없음 → 폴백
                fallbackView
            }
        }
        .task(id: employee.empNo) {
            await loadRemoteImage()
        }
    }

    // MARK: - 원격 이미지 로드 (AsisApiClient 세션 사용)

    private func loadRemoteImage() async {
        guard let url = employee.profileImageURL else { return }
        // Base64 이미지는 별도 처리하므로 스킵
        guard employee.imgdata?.hasPrefix("data:") != true else { return }
        guard !isLoading else { return }
        isLoading = true
        if let data = await AsisApiClient.shared.downloadImage(from: url),
           let img = UIImage(data: data) {
            loadedImage = img
        }
        isLoading = false
    }

    // MARK: - Fallback: 이름 첫 글자 아바타

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

    // MARK: - Base64 디코딩

    private func decodeBase64(_ imgdata: String?) -> UIImage? {
        guard let imgdata, !imgdata.isEmpty else { return nil }
        let b64: String
        if imgdata.hasPrefix("data:image") {
            guard let commaIdx = imgdata.firstIndex(of: ",") else { return nil }
            b64 = String(imgdata[imgdata.index(after: commaIdx)...])
        } else {
            // 순수 Base64 (URL이 아닌 경우)
            guard !imgdata.hasPrefix("/") && !imgdata.hasPrefix("http") else { return nil }
            b64 = imgdata
        }
        guard let data = Data(base64Encoded: b64, options: .ignoreUnknownCharacters),
              let image = UIImage(data: data) else { return nil }
        return image
    }
}
