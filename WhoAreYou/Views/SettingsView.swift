import SwiftUI
import CallKit

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertAction: (() -> Void)? = nil
    @State private var isUpdating = false

    var body: some View {
        NavigationView {
            List {
                // 비씨후아유 섹션
                Section(header: Text("비씨후아유").font(.footnote)) {
                    NavigationLink(destination: PhoneSettingsView()) {
                        Text("전화번호 설정")
                    }
                    NavigationLink(destination: InfoView()) {
                        Text("가이드")
                    }
                }

                // 앱 데이터 관리 섹션
                Section(header: Text("앱 데이터 관리").font(.footnote)) {
                    Button(action: {
                        alertMessage = "전화번호부를 업데이트하시겠습니까?"
                        alertAction = updateDatabase
                        showAlert = true
                    }) {
                        HStack {
                            Text("데이터베이스 업데이트")
                                .foregroundColor(.primary)
                            Spacer()
                            if isUpdating {
                                ProgressView()
                            }
                        }
                    }

                    Button(action: {
                        alertMessage = "데이터베이스를 초기화하시겠습니까?\n전화번호 정보가 모두 삭제됩니다."
                        alertAction = resetDatabase
                        showAlert = true
                    }) {
                        Text("데이터베이스 초기화")
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        alertMessage = "사용자 정보를 초기화하시겠습니까?\n로그아웃됩니다."
                        alertAction = resetUser
                        showAlert = true
                    }) {
                        Text("사용자정보 초기화")
                            .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.75, green: 0.1, blue: 0.1))
                }
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("취소", role: .cancel) {}
            Button("확인") { alertAction?() }
        } message: {
            Text(alertMessage)
        }
    }

    func updateDatabase() {
        isUpdating = true

        // 기존 ContentView의 전화번호 업데이트 로직 (하드코딩 → 추후 API로 교체)
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

        let appGroupID = "group.com.minseok.whoareyou"
        if let defaults = UserDefaults(suiteName: appGroupID),
           let data = try? JSONSerialization.data(withJSONObject: employees) {
            defaults.set(data, forKey: "employees")
            defaults.synchronize()
        }

        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: "com.minseok.WhoAreYou.CallDirectoryExtension"
        ) { error in
            DispatchQueue.main.async {
                isUpdating = false
                if let error = error {
                    alertMessage = "업데이트 실패: \(error.localizedDescription)"
                } else {
                    alertMessage = "데이터베이스 업데이트 완료! 총 15명 등록됨"
                }
                alertAction = nil
                showAlert = true
            }
        }
    }

    func resetDatabase() {
        let appGroupID = "group.com.minseok.whoareyou"
        if let defaults = UserDefaults(suiteName: appGroupID) {
            defaults.removeObject(forKey: "employees")
            defaults.synchronize()
        }
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: "com.minseok.WhoAreYou.CallDirectoryExtension"
        ) { _ in
            DispatchQueue.main.async {
                alertMessage = "데이터베이스가 초기화되었습니다."
                alertAction = nil
                showAlert = true
            }
        }
    }

    func resetUser() {
        isLoggedIn = false
        dismiss()
    }
}

// 전화번호 설정 화면 (iOS 설정 앱의 전화 차단 및 발신자 확인으로 안내)
struct PhoneSettingsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "phone.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.75, green: 0.1, blue: 0.1))

            Text("전화번호 발신자 표시 설정")
                .font(.title2).bold()

            Text("전화 수신 시 임직원 이름을 표시하려면\n아래 설정을 활성화해주세요.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                Text("설정 방법:")
                    .font(.headline)
                Text("1. iPhone 설정 앱 열기")
                Text("2. 전화 → 전화 차단 및 발신자 확인")
                Text("3. WhoAreYou 토글 ON")
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("설정 앱 열기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.75, green: 0.1, blue: 0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("전화번호 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}
