import Foundation
import CoreData

struct Logo: Codable {
    var small: String
    var medium : String
    var large: String
    
    init?(entity: LogoEntity?) {
        small = entity?.small ?? ""
        medium = entity?.medium ?? ""
        large = entity?.large ?? ""
    }
}
