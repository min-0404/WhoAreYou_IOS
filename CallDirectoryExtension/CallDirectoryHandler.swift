import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        addIdentificationPhoneNumbers(to: context)

        context.completeRequest()
    }

    private func addIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // App Group 공유 저장소에서 직원 목록 읽기
        let appGroupID = "group.com.minseok.whoareyou"
        let defaults = UserDefaults(suiteName: appGroupID)
        let data = defaults?.data(forKey: "employees")

        var employees: [(phone: CXCallDirectoryPhoneNumber, name: String)] = []

        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            for entry in json {
                if let phoneStr = entry["phone"],
                   let name = entry["name"],
                   let phoneNumber = CXCallDirectoryPhoneNumber(phoneStr) {
                    employees.append((phone: phoneNumber, name: name))
                }
            }
        }

        // CallKit은 번호가 반드시 오름차순 정렬이어야 함
        let sorted = employees.sorted { $0.phone < $1.phone }

        for entry in sorted {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: entry.phone,
                label: entry.name
            )
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("CallDirectory 오류: \(error.localizedDescription)")
    }
}
