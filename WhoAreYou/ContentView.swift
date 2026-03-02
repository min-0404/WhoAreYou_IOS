import SwiftUI
import CallKit

struct ContentView: View {
    @State private var statusMessage = "전화번호부 업데이트 전"

    var body: some View {
        VStack(spacing: 24) {
            Text("WhoAreYou")
                .font(.largeTitle)
                .bold()

            Text(statusMessage)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: updatePhoneBook) {
                Text("전화번호부 업데이트")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    func updatePhoneBook() {
        // 하드코딩 테스트 데이터 (국제번호 형식: 82 + 0 제거 + 나머지)
        let employees: [[String: String]] = [
            ["phone": "821035599618", "name": "플랫폼DX팀 이지호"],
            ["phone": "821042111072", "name": "플랫폼DX팀 이명재"],
            ["phone": "821036877487", "name": "플랫폼DX팀 최호성"],
            ["phone": "821034961230", "name": "플랫폼DX팀 김명일"],
            ["phone": "821071326367", "name": "플랫폼DX팀 홍진수"],
            ["phone": "821024620807", "name": "플랫폼DX팀 문지용"],
            ["phone": "821037758142", "name": "플랫폼DX팀 양인호"],
            ["phone": "821066263706", "name": "플랫폼DX팀 오태건"],
            ["phone": "821074607903", "name": "플랫폼DX팀 정태호"],
            ["phone": "821045622780", "name": "플랫폼DX팀 노현경"],
            ["phone": "821074134005", "name": "플랫폼DX팀 원정희"],
            ["phone": "821046049423", "name": "플랫폼DX팀 김채윤"],
            ["phone": "821051339755", "name": "플랫폼DX팀 김민석"],
            ["phone": "821024786657", "name": "플랫폼DX팀 김동현"],
            ["phone": "821028743600", "name": "플랫폼DX팀 이동재"]
        ]

        // App Group 공유 저장소에 저장
        let appGroupID = "group.com.minseok.whoareyou"
        if let defaults = UserDefaults(suiteName: appGroupID),
           let data = try? JSONSerialization.data(withJSONObject: employees) {
            defaults.set(data, forKey: "employees")
            defaults.synchronize()
        }

        // CallKit Extension 재로드 (이걸 해야 전화 수신 시 이름이 뜸)
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: "com.minseok.WhoAreYou.CallDirectoryExtension"
        ) { error in
            DispatchQueue.main.async {
                if let error = error {
                    statusMessage = "오류: \(error.localizedDescription)"
                } else {
                    statusMessage = "업데이트 완료! 총 15명 등록됨"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
