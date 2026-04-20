import Foundation

enum ApiConstants {
    // Build config - use production server
    static let isDev = false
    static let baseURL = isDev
        ? "https://isrnd.bccard.com:64443"
        : "https://u2.bccard.com"

    static let endpointMember = "/app/ubi/member.wru"
    static let endpointSearch = "/app/ubi/search.wru"

    static let actnLogin        = "login"
    static let actnLogout       = "logout"
    static let actnMyInfo       = "myinfo"
    static let actnChangePwd    = "chgPwd"
    static let actnSearch       = "search"
    static let actnDetail       = "detail"
    static let actnMyFav        = "myFav"
    static let actnToggleFav    = "toggleFav"
    static let actnMyTeam       = "myTeam"
    static let actnOrganization = "organizaion"  // intentional server typo
}
