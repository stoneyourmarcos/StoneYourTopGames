import Foundation
import CoreData

struct Image: Codable {
    var small: String
    var medium: String
    var large: String
    
    init?(entity: ImageEntity?) {
        small = entity?.small ?? ""
        medium = entity?.medium ?? ""
        large = entity?.large ?? ""
    }
}
