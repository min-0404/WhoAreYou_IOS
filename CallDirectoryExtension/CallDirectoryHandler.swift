import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        addIdentificationPhoneNumbers(to: context)

        context.completeRequest()
    }

    private func addIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let appGroupID = "group.com.minseok.whoareyou"
        let defaults = UserDefaults(suiteName: appGroupID)

        var entries: [(phone: CXCallDirectoryPhoneNumber, name: String)] = []

        // 1. 임직원 목록 읽기 (key: "employees", 형식: "821012345678")
        if let data = defaults?.data(forKey: "employees"),
           let json = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            for entry in json {
                if let phoneStr = entry["phone"],
                   let name = entry["name"],
                   let phoneNumber = CXCallDirectoryPhoneNumber(phoneStr) {
                    entries.append((phone: phoneNumber, name: name))
                }
            }
        }

        // 2. 커스텀 연락처 읽기 (key: "custom_contacts", 형식: "010-xxxx-xxxx")
        if let data = defaults?.data(forKey: "custom_contacts"),
           let contacts = try? JSONDecoder().decode([CustomContactEntry].self, from: data) {
            for contact in contacts {
                let intlPhone = toInternationalFormat(contact.phone)
                if let phoneNumber = CXCallDirectoryPhoneNumber(intlPhone) {
                    entries.append((phone: phoneNumber, name: contact.name))
                }
            }
        }

        // 중복 제거 후 오름차순 정렬 (CallKit 필수 조건)
        var seen = Set<CXCallDirectoryPhoneNumber>()
        let sorted = entries
            .filter { seen.insert($0.phone).inserted }
            .sorted { $0.phone < $1.phone }

        for entry in sorted {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: entry.phone,
                label: entry.name
            )
        }
    }

    /// "010-1234-5678" → "821012345678"  (CallKit E.164 형식)
    private func toInternationalFormat(_ phone: String) -> String {
        var num = phone.filter { $0.isNumber }
        if num.hasPrefix("0") {
            num = "82" + num.dropFirst()
        }
        return num
    }
}

// CallKit 익스텐션 내에서 사용하는 간소화된 커스텀 연락처 구조체
private struct CustomContactEntry: Decodable {
    let name: String
    let phone: String
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("CallDirectory 오류: \(error.localizedDescription)")
    }
}
