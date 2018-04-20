import Foundation
import CoreData

class GameModel {
    var game: Game?
    var viewers: Int
    var channels: Int
    var isFavorited: Bool = false
    var isRecorded: Bool = false
    
    struct Game: Codable {
        var id: Int
        var giantbombId: Int
        var popularity: Int
        var name: String
        var localizedName: String
        var locale: String
        var image: Image?
        var logo: Logo?
    }
    
    init?(entity: GameEntity) {
        game = Game(entity: entity)
        viewers = Int(entity.viewers)
        channels = Int(entity.channels)
        isFavorited = Bool(entity.isFavorite)
        isRecorded = true
    }
}

extension GameModel.Game {
    fileprivate enum GameCodingKey: String, CodingKey {
        case id = "_id"
        case giantbombId
        case popularity
        case name
        case localizedName = "localized_name"
        case locale
        case image = "box"
        case logo
    }
    
    init?(entity: GameEntity) {
        id = Int(entity.id)
        giantbombId = Int(entity.giantbomb_id)
        popularity = Int(entity.popularity)
        name = entity.name ?? ""
        localizedName = entity.localizedName ?? ""
        locale = entity.locale ?? ""
        image = Image(entity: entity.image)
        logo = Logo(entity: entity.logo)
    }
}

