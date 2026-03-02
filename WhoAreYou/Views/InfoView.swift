import SwiftUI

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 로고
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                        Text("BC")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)

                // FAQ
                VStack(alignment: .leading, spacing: 10) {
                    Text("- FAQ")
                        .font(.system(size: 14, weight: .bold))

                    Group {
                        Text("- 비씨후아유는 BC임직원(G,J,K,M,P)만 이용할 수 있습니다.")
                        Text("- 휴직자, 퇴직자는 비씨후아유에 로그인할 수 없습니다.")
                        Text("- 비씨후아유 앱은 HRMS에 등록된 휴대폰번호와 사용중인 휴대폰 번호가 같은 경우에만 이용할 수 있습니다.")
                        Text("- 비밀번호는 문자, 숫자, 특수문자가 포함된 8자리 이상으로 설정해야 합니다.")
                        Text("- 비밀번호 변경 시 BC-OTP 앱 비밀번호가 아니라 BC-OTP 앱의 인증번호 7자리가 필요합니다.")
                        Text("- iOS 10버전 이상만 임직원 전화 수신 기능을 이용할 수 있습니다.")
                        Text("- 안드로이드 전화 수신 팝업은 네트워크 상태에 따라 지연될 수 있습니다.")
                        Text("- 비씨후아유앱 업데이트 시 반드시 기존 비씨후아유 앱을 삭제 후 재설치하여 주시기 바랍니다.")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                // 다운로드 URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("- 비씨후아유 다운로드 URL")
                        .font(.system(size: 14, weight: .bold))

                    HStack {
                        Text("안드로이드 : ")
                            .font(.system(size: 13))
                        Text("http://bc.cr/?AGdwq")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.8))
                    }

                    HStack {
                        Text("iOS : ")
                            .font(.system(size: 13))
                        Text("http://bc.cr/?oDZaN")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("가이드")
        .navigationBarTitleDisplayMode(.inline)
    }
}
