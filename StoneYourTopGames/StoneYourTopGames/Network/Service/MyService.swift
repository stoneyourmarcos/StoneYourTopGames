import Foundation

struct parameters {
    static let offset = "offset"
    static let limit = "limit"
}

enum MyService {
    case topGames
}

extension MyService: EndPointType {
    var baseURL: URL { return URL(string: "https://api.twitch.tv/kraken/")! }
    
    var path: String {
        switch self {
        case .topGames: return "games/top"
        }
    }
    
    var httpMethod: HTTPMethod { return .get }
    
    var task: HTTPTask { return .request }
    
    var headers: HTTPHeaders? {
        return ["Accept": "application/vnd.twitchtv.v5+json", "Client-ID": "pcz0gqdyrbov2qwa75jcx0k2k8tfn0"]
    }

    
}
