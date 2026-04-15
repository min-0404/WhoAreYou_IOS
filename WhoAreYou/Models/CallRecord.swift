import Foundation

struct CallRecord: Identifiable, Codable {
    var id: String = UUID().uuidString
    var callerName: String
    var callerTeam: String
    var callerJob: String
    var phone: String
    var timestampMs: Int64
    var durationSeconds: Int64
    var callType: String = "incoming"  // "incoming", "outgoing", "missed"

    var formattedTime: String {
        let date = Date(timeIntervalSince1970: Double(timestampMs) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        if durationSeconds <= 0 { return "" }
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return m > 0 ? "\(m)분 \(s)초" : "\(s)초"
    }

    var callTypeIcon: String {
        switch callType {
        case "incoming": return "phone.arrow.down.left"
        case "outgoing": return "phone.arrow.up.right"
        case "missed":   return "phone.down"
        default:         return "phone"
        }
    }
}
