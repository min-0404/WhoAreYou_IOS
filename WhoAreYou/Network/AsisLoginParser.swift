import Foundation

/// ASIS 로그인 HTML 응답 파서
///
/// ASIS 서버 로그인 성공 시 아래 형태의 HTML을 반환합니다:
/// ```html
/// <script>
///   var json = '{"authKey":"...","empNm":"...","orgNm":"...", ...}';
///   webkit.messageHandlers.jsonData.postMessage(json);
/// </script>
/// ```
struct AsisLoginParser {

    struct LoginResult {
        let authKey: String
        let empNo: String
        let empNm: String
        let orgNm: String
        let orgCd: String
        let dutyNm: String
        let engDutyNm: String
        let offiNo: String
        let phoneNo: String
        let email: String
    }

    /// 로그인 HTML 응답에서 인증 정보를 추출합니다.
    /// - Returns: 파싱 성공 시 LoginResult, 실패 시 nil
    static func parse(_ html: String) -> LoginResult? {
        // webkit.messageHandlers 패턴 확인 (로그인 성공 조건)
        guard html.contains("webkit.messageHandlers") else { return nil }

        // var json = '{ ... }' 또는 var json = "{ ... }" 패턴 추출
        let patterns = [
            #"var json\s*=\s*'(\{.*?\})'\s*;"#,
            #"var json\s*=\s*"(\{.*?\})"\s*;"#
        ]

        var jsonString: String? = nil
        for pattern in patterns {
            if let match = html.range(of: pattern, options: .regularExpression) {
                let fullMatch = String(html[match])
                // 중괄호 내용만 추출
                if let braceStart = fullMatch.firstIndex(of: "{"),
                   let braceEnd = fullMatch.lastIndex(of: "}") {
                    jsonString = String(fullMatch[braceStart...braceEnd])
                    break
                }
            }
        }

        guard let jsonStr = jsonString,
              let jsonData = jsonStr.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            // JSON 파싱 실패 시 단순 키-값 추출 시도
            return parseFromKeyValue(html)
        }

        guard let authKey = dict["authKey"] as? String, !authKey.isEmpty else { return nil }

        return LoginResult(
            authKey:   authKey,
            empNo:     dict["empNo"]     as? String ?? "",
            empNm:     dict["empNm"]     as? String ?? "",
            orgNm:     dict["orgNm"]     as? String ?? "",
            orgCd:     dict["orgCd"]     as? String ?? "",
            dutyNm:    dict["dutyNm"]    as? String ?? "",
            engDutyNm: dict["engDutyNm"] as? String ?? "",
            offiNo:    dict["offiNo"]    as? String ?? "",
            phoneNo:   dict["phoneNo"]   as? String ?? "",
            email:     dict["email"]     as? String ?? ""
        )
    }

    /// 로그인 오류 메시지를 HTML에서 추출합니다.
    static func parseError(_ html: String) -> String? {
        // form-group 내 alert/error 메시지 패턴
        let errorPatterns = [
            #"<div[^>]*class="[^"]*alert[^"]*"[^>]*>(.*?)</div>"#,
            #"<p[^>]*class="[^"]*error[^"]*"[^>]*>(.*?)</p>"#,
            #"<span[^>]*class="[^"]*error[^"]*"[^>]*>(.*?)</span>"#
        ]
        for pattern in errorPatterns {
            if let match = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let text = String(html[match])
                    .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty { return text }
            }
        }
        // 한국어 오류 키워드 감지
        let errorKeywords = ["잘못된", "오류", "실패", "없습니다", "incorrect", "invalid", "error"]
        for keyword in errorKeywords {
            if html.lowercased().contains(keyword) {
                if let range = html.range(of: keyword, options: .caseInsensitive) {
                    let start = html.index(range.lowerBound, offsetBy: -min(20, html.distance(from: html.startIndex, to: range.lowerBound)))
                    let end = html.index(range.upperBound, offsetBy: min(40, html.distance(from: range.upperBound, to: html.endIndex)))
                    return String(html[start..<end])
                        .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }

    /// 비밀번호 변경 응답 파싱
    static func parsePasswordReset(_ html: String) -> Bool {
        let successKeywords = ["성공", "변경되었", "완료", "success", "changed"]
        return successKeywords.contains { html.lowercased().contains($0) }
    }

    // MARK: - Private Helpers

    private static func parseFromKeyValue(_ html: String) -> LoginResult? {
        func extract(_ key: String) -> String {
            let pattern = #""\#(key)"\s*:\s*"([^"]*)""#
            guard let range = html.range(of: pattern, options: .regularExpression) else { return "" }
            let match = String(html[range])
            guard let valueRange = match.range(of: #":\s*"([^"]*)"#, options: .regularExpression) else { return "" }
            return String(match[valueRange])
                .replacingOccurrences(of: #":\s*""#, with: "", options: .regularExpression)
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let authKey = extract("authKey")
        guard !authKey.isEmpty else { return nil }

        return LoginResult(
            authKey:   authKey,
            empNo:     extract("empNo"),
            empNm:     extract("empNm"),
            orgNm:     extract("orgNm"),
            orgCd:     extract("orgCd"),
            dutyNm:    extract("dutyNm"),
            engDutyNm: extract("engDutyNm"),
            offiNo:    extract("offiNo"),
            phoneNo:   extract("phoneNo"),
            email:     extract("email")
        )
    }
}
