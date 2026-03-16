import Foundation

struct CallRecord: Codable, Identifiable {
    var id: String
    var callerName: String
    var callerTeam: String
    var callerJob: String
    var phone: String
    var timestampMs: Double     // Date().timeIntervalSince1970 * 1000
    var durationSeconds: Int

    init(id: String = UUID().uuidString,
         callerName: String,
         callerTeam: String,
         callerJob: String,
         phone: String,
         timestampMs: Double = Date().timeIntervalSince1970 * 1000,
         durationSeconds: Int = 0) {
        self.id = id
        self.callerName = callerName
        self.callerTeam = callerTeam
        self.callerJob = callerJob
        self.phone = phone
        self.timestampMs = timestampMs
        self.durationSeconds = durationSeconds
    }

    var date: Date {
        Date(timeIntervalSince1970: timestampMs / 1000)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd HH:mm"
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        if durationSeconds <= 0 { return "수신" }
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return m > 0 ? "\(m)분 \(s)초" : "\(s)초"
    }
}
