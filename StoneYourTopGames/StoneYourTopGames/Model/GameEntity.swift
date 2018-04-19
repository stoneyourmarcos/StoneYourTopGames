import Foundation
import CoreData

struct GameEntity: Codable {
    let name: String
    let popularity: Int
    let id: Int
    let giantBombId: Int
    let viewers: Int
    let channels: Int
    
    enum GameCodingKeys: String, CodingKey {
        case name
        case popularity
        case id = "_id"
        case giantBombId = "giantbomb_id"
        case viewers
        case channels
    }
}

extension GameEntity {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        popularity = try container.decode(Int.self, forKey: .popularity)
        id = try container.decode(Int.self, forKey: .id)
        giantBombId = try container.decode(Int.self, forKey: .giantBombId)
        viewers = try container.decode(Int.self, forKey: .viewers)
        channels = try container.decode(Int.self, forKey: .channels)
    }
    
    
}
