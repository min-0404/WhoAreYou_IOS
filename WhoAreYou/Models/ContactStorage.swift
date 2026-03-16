import Foundation
import Combine
import CallKit

class ContactStorage: ObservableObject {
    static let shared = ContactStorage()

    private let appGroupID = "group.com.minseok.whoareyou"
    private let contactsKey = "custom_contacts"
    private let callRecordsKey = "call_records"
    private let maxCallRecords = 200

    private var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    @Published var contacts: [CustomContact] = []
    @Published var callRecords: [CallRecord] = []

    private init() {
        contacts = loadContacts()
        callRecords = loadCallRecords()
    }

    // ── Custom Contacts ──────────────────────────────────────

    func saveContact(_ contact: CustomContact) {
        if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[idx] = contact
        } else {
            contacts.insert(contact, at: 0)
        }
        persistContacts(contacts)
        reloadCallDirectoryExtension()
    }

    func deleteContact(id: String) {
        contacts.removeAll { $0.id == id }
        persistContacts(contacts)
        reloadCallDirectoryExtension()
    }

    private func loadContacts() -> [CustomContact] {
        // App Group 우선, 없으면 기존 standard UserDefaults에서 마이그레이션
        let data = appGroupDefaults?.data(forKey: contactsKey)
            ?? UserDefaults.standard.data(forKey: contactsKey)
        guard let data = data,
              let decoded = try? JSONDecoder().decode([CustomContact].self, from: data)
        else { return [] }
        return decoded
    }

    private func persistContacts(_ contacts: [CustomContact]) {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        // App Group에 저장 (CallKit 익스텐션이 읽을 수 있도록)
        appGroupDefaults?.set(data, forKey: contactsKey)
        appGroupDefaults?.synchronize()
        // 기존 standard UserDefaults 항목 제거
        UserDefaults.standard.removeObject(forKey: contactsKey)
    }

    private func reloadCallDirectoryExtension() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(
            withIdentifier: "com.minseok.WhoAreYou.CallDirectoryExtension"
        ) { _ in }
    }

    // ── Call Records ─────────────────────────────────────────

    func addCallRecord(_ record: CallRecord) {
        callRecords.insert(record, at: 0)
        if callRecords.count > maxCallRecords {
            callRecords = Array(callRecords.prefix(maxCallRecords))
        }
        persist(callRecords, key: callRecordsKey)
    }

    func clearCallRecords() {
        callRecords = []
        UserDefaults.standard.removeObject(forKey: callRecordsKey)
    }

    private func loadCallRecords() -> [CallRecord] {
        guard let data = UserDefaults.standard.data(forKey: callRecordsKey),
              let decoded = try? JSONDecoder().decode([CallRecord].self, from: data)
        else { return [] }
        return decoded
    }

    // ── 번호 조회 (임직원 + 커스텀 연락처 통합) ─────────────────

    func findCallerInfo(rawNumber: String) -> (name: String, team: String, job: String)? {
        let normalized = normalizePhone(rawNumber)

        // 1. 임직원 목록에서 검색
        if let emp = MockData.employees.first(where: {
            normalizePhone($0.mobilePhone) == normalized ||
            normalizePhone($0.internalPhone) == normalized
        }) {
            return (emp.name, emp.team, emp.jobTitle)
        }

        // 2. 커스텀 연락처에서 검색
        if let contact = contacts.first(where: { normalizePhone($0.phone) == normalized }) {
            return (contact.name, "", contact.note)
        }

        return nil
    }

    private func normalizePhone(_ phone: String) -> String {
        var num = phone.filter { $0.isNumber }
        if num.hasPrefix("82") && num.count > 10 {
            num = "0" + num.dropFirst(2)
        }
        return num
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
