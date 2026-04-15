import Foundation

struct CustomContact: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var phone: String
    var note: String = ""
}
