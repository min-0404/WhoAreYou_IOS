import Foundation

struct CustomContact: Codable, Identifiable {
    var id: String
    var name: String
    var phone: String
    var note: String

    init(id: String = UUID().uuidString, name: String, phone: String, note: String = "") {
        self.id = id
        self.name = name
        self.phone = phone
        self.note = note
    }
}
