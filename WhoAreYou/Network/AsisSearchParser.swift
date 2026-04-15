import Foundation

/// ASIS search.wru HTML 응답 파서
///
/// ASIS 서버는 모든 search.wru 요청에 순수 HTML 을 반환합니다.
/// API 종류별 HTML 구조:
///
/// - search/myFav → carousel-info 구조, empDetail('EMPNO') 사용
/// - myTeam/organizaion(팀레벨) → accordion-inner 구조, goEmpDetail('EMPNO') 사용
/// - organizaion(본부레벨) → goDeptList 구조
/// - detail → profile-usertitle 구조
struct AsisSearchParser {

    // MARK: - Employee List (search / myFav)

    static func parseEmployeeList(_ html: String) -> [Employee] {
        return parseCarouselList(html)
    }

    static func parseFavoriteList(_ html: String) -> [Employee] {
        return parseCarouselList(html).map { emp in
            var e = emp; e.isFavorite = true; return e
        }
    }

    // MARK: - Team List (myTeam / organizaion with team-level orgCd)

    static func parseTeamList(_ html: String) -> [Employee] {
        let blocks = html.components(separatedBy: #"<div class="accordion-inner">"#).dropFirst()
        let result = blocks.compactMap { block -> Employee? in
            guard block.contains("goEmpDetail") else { return nil }
            return parseEmpBlock(block)
        }
        return result
    }

    // MARK: - Employee Detail

    static func parseDetail(_ html: String, empNo: String) -> Employee? {
        // 성명
        guard let name = extractGroup(from: html, pattern: #"<div class="profile-usertitle-name">\s*<p>(.*?)</p>"#, group: 1)?
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else { return nil }

        // 팀 + 직책 + 닉네임
        let teamPosRaw = extractGroup(from: html,
            pattern: #"<div class="profile-usertitle-job">\s*<p[^>]*font-size\s*:\s*23px[^>]*>(.*?)</p>"#,
            group: 1, options: [.dotMatchesLineSeparators])?
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let slashIdx = teamPosRaw.range(of: " / ")
        let teamPosPart = slashIdx.map { String(teamPosRaw[..<$0.lowerBound]) } ?? teamPosRaw
        let nickname    = slashIdx.map { String(teamPosRaw[$0.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        let lastSpaceIdx = teamPosPart.lastIndex(of: " ")
        let team     = lastSpaceIdx.map { String(teamPosPart[..<$0]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? teamPosPart
        let position = lastSpaceIdx.map { String(teamPosPart[teamPosPart.index(after: $0)...]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        // 담당업무 (두 번째 profile-usertitle-job)
        let jobMatches = allGroups(from: html, pattern: #"<div class="profile-usertitle-job">\s*<p[^>]*>(.*?)</p>"#,
                                   options: [.dotMatchesLineSeparators])
        let jobTitle = (jobMatches.count > 1 ? jobMatches[1] : "")
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 연락처
        let internalPhone = extractGroup(from: html, pattern: #"glyphicon-phone-alt[^>]*>\s*(.*?)\s*</i>"#, group: 1,
                                         options: [.dotMatchesLineSeparators])?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mobilePhone   = extractGroup(from: html, pattern: #"glyphicon-phone"\s*>\s*(.*?)\s*</i>"#, group: 1,
                                         options: [.dotMatchesLineSeparators])?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fax           = extractGroup(from: html, pattern: #"glyphicon-print[^>]*>\s*(.*?)\s*</i>"#, group: 1,
                                         options: [.dotMatchesLineSeparators])?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email         = extractGroup(from: html, pattern: #"glyphicon-ok[^>]*>\s*(.*?)\s*</i>"#, group: 1,
                                         options: [.dotMatchesLineSeparators])?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let isFav   = html.contains(#"id="isFav" value="true""#)
        let finalEmpNo = extractGroup(from: html, pattern: #"toggleFav\('(\d+)'\)"#, group: 1) ?? empNo
        let imgSrc  = extractProfileImageUrl(html)

        return Employee(
            empNo: finalEmpNo, name: name, team: team, teamCode: "",
            position: position, nickname: nickname, jobTitle: jobTitle,
            internalPhone: internalPhone, mobilePhone: mobilePhone,
            fax: fax, email: email, imgdata: imgSrc, isFavorite: isFav
        )
    }

    // MARK: - Toggle Favorite

    static func parseToggleFavorite(_ html: String, empNo: String) -> Bool? {
        // 패턴1: id="isFav" value="true|false"
        if html.contains(#"id="isFav" value="true""#)  { return true }
        if html.contains(#"id="isFav" value="false""#) { return false }
        // 패턴2: JSON {"isFav":"Y"}
        if let v = extractGroup(from: html, pattern: #""isFav"\s*:\s*"([YN])""#, group: 1, options: [.caseInsensitive]) {
            return v.uppercased() == "Y"
        }
        // 패턴3: Y/N 단순 응답
        let t = html.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if t == "y" || t == "true"  || t == "1" { return true }
        if t == "n" || t == "false" || t == "0" { return false }
        return nil
    }

    // MARK: - Organization (org-level dept tree)

    static func parseOrganization(_ html: String) -> [Dept] {
        var result: [Dept] = []

        // 패턴1: accordion-toggle 에 goDeptList 직접 포함
        let p1 = #"class="accordion-toggle"[^>]*onclick="[^"]*goDeptList\('([^']+)'\)[^"]*"[^>]*>\s*(.*?)\s*</a>"#
        allCaptures(from: html, pattern: p1, options: [.dotMatchesLineSeparators]).forEach { caps in
            guard caps.count >= 2 else { return }
            let code = caps[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let name = caps[1].replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                              .trimmingCharacters(in: .whitespacesAndNewlines)
            if !code.isEmpty && !name.isEmpty { result.append(Dept(deptCode: code, deptName: name, level: 0)) }
        }

        // 패턴2: <li> 내부 goDeptList 링크
        let p2 = #"<li>\s*<a\b[^>]*onclick="[^"]*goDeptList\('([^']+)'\)[^"]*"[^>]*>(.*?)</a>\s*</li>"#
        allCaptures(from: html, pattern: p2, options: [.dotMatchesLineSeparators]).forEach { caps in
            guard caps.count >= 2 else { return }
            let code = caps[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let name = caps[1].replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                              .trimmingCharacters(in: .whitespacesAndNewlines)
            if !code.isEmpty && !name.isEmpty { result.append(Dept(deptCode: code, deptName: name, level: 1)) }
        }

        return result
    }

    // MARK: - Org Sections (accordion groups)

    static func parseOrgSections(_ html: String) -> [OrgSection] {
        let groups = html.components(separatedBy: #"<div class="accordion-group">"#).dropFirst()
        return groups.compactMap { groupHtml -> OrgSection? in
            guard let groupName = extractGroup(from: groupHtml,
                    pattern: #"class="accordion-toggle"[^>]*>(.*?)</a>"#, group: 1,
                    options: [.dotMatchesLineSeparators])?
                .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !groupName.isEmpty else { return nil }

            let directCode = extractGroup(from: groupHtml,
                pattern: #"class="accordion-toggle"[^>]*onclick="[^"]*goDeptList\('([^']+)'\)"#, group: 1) ?? ""

            let innerHtml = groupHtml.components(separatedBy: #"class="accordion-inner">"#).dropFirst().first ?? ""

            let headEmployee: Employee? = innerHtml.contains("goEmpDetail") ? parseEmpBlock(innerHtml) : nil

            var subDepts: [Dept] = []
            let deptPattern = #"onclick="[^"]*goDeptList\('([^']+)'\)[^"]*"[^>]*>(.*?)</a>"#
            allCaptures(from: innerHtml, pattern: deptPattern, options: [.dotMatchesLineSeparators]).forEach { caps in
                guard caps.count >= 2 else { return }
                let code = caps[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let name = caps[1].replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
                                  .trimmingCharacters(in: .whitespacesAndNewlines)
                if !code.isEmpty && !name.isEmpty { subDepts.append(Dept(deptCode: code, deptName: name, level: 1)) }
            }

            return OrgSection(name: groupName, deptCode: directCode, headEmployee: headEmployee, subDepts: subDepts)
        }
    }

    // MARK: - Private Helpers

    private static func parseCarouselList(_ html: String) -> [Employee] {
        let blocks = html.components(separatedBy: #"<div class="carousel-info""#).dropFirst()
        return blocks.compactMap { parseEmpBlock($0) }
    }

    private static func parseEmpBlock(_ block: String) -> Employee? {
        // empNo
        guard let empNo = extractGroup(from: block, pattern: #"(?:empDetail|goEmpDetail)\('(\d+)'\)"#, group: 1)
        else { return nil }

        // 성명
        guard let name = extractGroup(from: block,
            pattern: #"<span\s+class="testimonials-name"[^>]*>\s*(.*?)\s*</span>"#, group: 1,
            options: [.dotMatchesLineSeparators])?
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else { return nil }

        // 팀/직책/닉네임
        let postRaw = extractGroup(from: block,
            pattern: #"<span\s+class="testimonials-post"[^>]*>\s*(.*?)\s*</span>"#, group: 1,
            options: [.dotMatchesLineSeparators])?
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let hashIdx = postRaw.firstIndex(of: "#")
        let team      = hashIdx.map { String(postRaw[..<$0]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? postRaw
        let afterHash = hashIdx.map { String(postRaw[postRaw.index(after: $0)...]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        let parenStart = afterHash.firstIndex(of: "(")
        let parenEnd   = afterHash.lastIndex(of: ")")
        let position = parenStart.map { String(afterHash[..<$0]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? afterHash.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = (parenStart != nil && parenEnd != nil && parenEnd! > parenStart!)
            ? String(afterHash[afterHash.index(after: parenStart!)..<parenEnd!]).trimmingCharacters(in: .whitespacesAndNewlines)
            : ""

        // 연락처
        let phones = allGroups(from: block, pattern: #"callTo\('([^']+)'\)"#)
        let internalPhone = phones.first ?? ""
        let mobilePhone   = phones.count > 1 ? phones[1] : ""

        let imgSrc = extractProfileImageUrl(block)

        return Employee(
            empNo: empNo, name: name, team: team, teamCode: "",
            position: position, nickname: nickname, jobTitle: "",
            internalPhone: internalPhone, mobilePhone: mobilePhone,
            fax: "", email: "", imgdata: imgSrc, isFavorite: false
        )
    }

    private static func extractProfileImageUrl(_ html: String) -> String? {
        let patterns = [
            #"class="profile-userpic"[\s\S]*?<img[^>]+src="([^"]+)""#,
            #"class="testimonials-photo"[\s\S]*?<img[^>]+src="([^"]+)""#,
            #"<img[^>]+src="(/[^"]*photo[^"]*)"[^>]*/>"#,
            #"<img[^>]+src="(data:image/[^"]+)"[^>]*/>"#
        ]
        for pattern in patterns {
            if let url = extractGroup(from: html, pattern: pattern, group: 1, options: [.dotMatchesLineSeparators]),
               !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return url.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    // MARK: - Regex Utilities

    private static func extractGroup(from string: String, pattern: String, group: Int,
                                     options: NSRegularExpression.Options = []) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let range = NSRange(string.startIndex..., in: string)
        guard let match = regex.firstMatch(in: string, range: range) else { return nil }
        guard group < match.numberOfRanges else { return nil }
        let groupRange = match.range(at: group)
        guard let swiftRange = Range(groupRange, in: string) else { return nil }
        return String(string[swiftRange])
    }

    private static func allGroups(from string: String, pattern: String,
                                  options: NSRegularExpression.Options = []) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return [] }
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, range: range)
        return matches.compactMap { match -> String? in
            guard match.numberOfRanges > 1,
                  let r = Range(match.range(at: 1), in: string) else { return nil }
            return String(string[r])
        }
    }

    private static func allCaptures(from string: String, pattern: String,
                                    options: NSRegularExpression.Options = []) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return [] }
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, range: range)
        return matches.map { match in
            (1..<match.numberOfRanges).compactMap { i -> String? in
                guard let r = Range(match.range(at: i), in: string) else { return nil }
                return String(string[r])
            }
        }
    }
}
