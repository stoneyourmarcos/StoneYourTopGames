import Foundation
import CoreData

private var dataManager = DataManager()
private struct AttributeName {
    static let id = "id"
}

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
        case giantbombId = "giantbomb_id"
        case popularity
        case name
        case localizedName = "localized_name"
        case locale
        case image = "box"
        case logo
    }
    
    init?(entity: GameEntity) {
        id = Int(entity.id)
        giantbombId = Int(entity.giantbombId)
        popularity = Int(entity.popularity)
        name = entity.name ?? ""
        localizedName = entity.localizedName ?? ""
        locale = entity.locale ?? ""
        image = Image(entity: entity.image)
        logo = Logo(entity: entity.logo)
    }
}

extension GameModel {
    private func record(completion: ((String?) -> Void)? = nil) {
        guard let entity = dataManager.getManagedObject(type: .game) as? GameEntity,
            let id = game?.id else {
                completion?(localizedUtil.Text.errorSaveData)
                return
        }
        entity.id = Int32(id)
        entity.name = game?.name
        entity.popularity = Int32(game?.popularity ?? 0)
        entity.giantbombId = Int32(game?.giantbombId ?? 0)
        entity.localizedName = game?.localizedName
        entity.locale = game?.locale
        entity.viewers = Int32(viewers)
        entity.channels = Int32(channels)
        entity.isFavorite = isFavorited
        
        dataManager.record(entity.managedObjectContext!) { recordGameError in
            self.game?.image?.record(imageWith: id) { _ in
                self.game?.logo?.record(logoWith: id) { _ in
                    self.isRecorded = true
                    completion?(recordGameError?.localizedDescription)
                }
            }
        }
    }
    
    private func update(_ entities: [GameEntity]) {
        for entity in entities {
            entity.name = game?.name
            entity.popularity = Int32(game?.popularity ?? 0)
            entity.giantbombId = Int32(game?.giantbombId ?? 0)
            entity.localizedName = game?.localizedName
            entity.locale = game?.locale
            entity.viewers = Int32(viewers)
            entity.channels = Int32(channels)
            entity.isFavorite = isFavorited
            
            dataManager.record(entity.managedObjectContext!) { error in
                if error == nil, let gameId = self.game?.id {
                    self.game?.image?.record(imageWith: gameId)
                    self.game?.logo?.record(logoWith: gameId)
                    self.isRecorded = true
                }
            }
        }
    }
    
    
    func recordGame(completion: ((String?) -> Void)? = nil) {
        let predicate = dataManager.predicate(withId: game?.id, key: AttributeName.id, type: .equal)
        let fetchResult = dataManager.fetchResult(from: .game, predicate: predicate)
        
        func record() {
            self.record(completion: completion)
        }
        
        if fetchResult.items == nil {
            record()
        } else {
            if var entities = fetchResult.items as? [GameEntity], let id = game?.id {
                if predicate == nil {
                    entities = entities.filter({ $0.id == id})
                }
                if entities.count > 0 {
                    self.update(entities)
                    completion?(nil)
                } else {
                    record()
                }
            } else {
                record()
            }
        }
    }
    
    func checkFavorite() -> GameModel {
        guard let gameId = game?.id else { return self }
        let recorded = GameModel.fetchModel(by: gameId)
        self.isFavorited = (recorded?.isFavorited)!
        return self
    }
    
    func deleteObjectData() -> Error? {
        let predicate = dataManager.predicate(withId: game?.id, key: AttributeName.id, type: .equal)
        let error = dataManager.delete(entity: .game, predicate: predicate)
        return error
    }
    
    static func delete() -> Bool {
        let isImageDeleted = dataManager.delete(entity: .image)
        let isLogoDeleted = dataManager.delete(entity: .logo)
        let isGameDeleted = dataManager.delete(entity: .game)
        let results = [isImageDeleted, isLogoDeleted, isGameDeleted]
        return results.map({ $0 != nil }).count > 0
    }

    static func fetchResult(with paramValueNumber: (value: Int, key: String, type: DataManager.PredicateType)? = nil, paramValueText: (value: String, key: String, type: DataManager.PredicateType)? = nil) -> (games: [GameModel]?, error: String?) {
        
        var result: (games: [GameModel]?, error: String?) = (nil, LocalizedUtil.Text.errorDataNoFound)
        var resultItems = [GameModel]()
        var predicate: NSPredicate?
        
        if let paramValueNumber = paramValueNumber {
            predicate = dataManager.predicate(withId: paramValueNumber.value, key: paramValueNumber.key, type: paramValueNumber.type)
        } else if let paramValueText = paramValueText {
            predicate = dataManager.predicate(withValue: paramValueText.value, key: paramValueText.key, type: paramValueText.type)
        }
        
        let fetchResult = dataManager.fetchResult(from: .game, predicate: predicate)
        
        if let entities = fetchResult.items as? [GameEntity], entities.count > 0 {
            
            for entity in entities {
                guard let item = GameModel(entity: entity) else { continue }
                resultItems.append(item)
            }
            
            if resultItems.count > 0 {
                result = (resultItems, nil)
            }
        }
        
        return result
    }
    
    static func fetchEntity(by id: Int) -> GameEntity? {
        let predicate = dataManager.predicate(withId: id, key: AttributeName.id, type: .equal)
        let result = dataManager.fetchResult(from: .game, predicate: predicate).items?.last as? GameEntity
        return result
    }
    
    static func fetchModel(by id: Int) -> GameModel? {
        guard let entity = fetchEntity(by: id) else { return nil }
        return GameModel(entity: entity)
    }
    
    static func updateFavorite(withValue value: Bool, id: Int, completion: ((Error?) -> Void)? = nil) {
        let entity = fetchEntity(by: id)
        entity?.isFavorite = value
        dataManager.record((entity?.managedObjectContext)!, completion: completion)
    }
    
}
