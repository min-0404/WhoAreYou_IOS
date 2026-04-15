import Foundation
import Combine

/// 커스텀 연락처와 통화 기록을 UserDefaults에 저장하는 싱글톤
@MainActor
final class ContactStorage: ObservableObject {
    static let shared = ContactStorage()

    @Published private(set) var contacts: [CustomContact] = []
    @Published private(set) var callRecords: [CallRecord] = []

    private enum Keys {
        static let contacts    = "custom_contacts"
        static let callRecords = "call_records"
    }

    private static let maxRecords = 200

    private init() { load() }

    // MARK: - Custom Contacts CRUD

    func addContact(_ contact: CustomContact) {
        contacts.append(contact)
        save()
    }

    func updateContact(_ contact: CustomContact) {
        if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[idx] = contact
            save()
        }
    }

    func deleteContact(id: String) {
        contacts.removeAll { $0.id == id }
        save()
    }

    func findContact(byPhone phone: String) -> CustomContact? {
        let normalized = normalizePhone(phone)
        return contacts.first { normalizePhone($0.phone) == normalized }
    }

    // MARK: - Call Records

    func addCallRecord(_ record: CallRecord) {
        callRecords.insert(record, at: 0)
        if callRecords.count > Self.maxRecords {
            callRecords = Array(callRecords.prefix(Self.maxRecords))
        }
        save()
    }

    func clearCallRecords() {
        callRecords.removeAll()
        save()
    }

    // MARK: - Private

    private func normalizePhone(_ phone: String) -> String {
        var num = phone.filter { $0.isNumber }
        if num.hasPrefix("82") && num.count > 10 { num = "0" + String(num.dropFirst(2)) }
        return num
    }

    private func load() {
        let ud = UserDefaults.standard
        if let data = ud.data(forKey: Keys.contacts),
           let loaded = try? JSONDecoder().decode([CustomContact].self, from: data) {
            contacts = loaded
        }
        if let data = ud.data(forKey: Keys.callRecords),
           let loaded = try? JSONDecoder().decode([CallRecord].self, from: data) {
            callRecords = loaded
        }
    }

    private func save() {
        let ud = UserDefaults.standard
        if let data = try? JSONEncoder().encode(contacts)    { ud.set(data, forKey: Keys.contacts)    }
        if let data = try? JSONEncoder().encode(callRecords) { ud.set(data, forKey: Keys.callRecords) }
    }
}
