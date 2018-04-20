import Foundation
import CoreData

private var dataManager = DataManager()

private struct AttributeName {
    static let id  = "game.id"
}

struct Logo: Codable {
    var small: String
    var medium: String
    var large: String
    
    init?(entity: LogoEntity?) {
        small = entity?.small ?? ""
        medium = entity?.medium ?? ""
        large = entity?.large ?? ""
    }
}

extension Logo {
    private func record(with game: GameEntity, completion: ((String?) -> Void)? = nil) {
        guard let entity = dataManager.getManagedObject(type: .logo) as? LogoEntity else {
            completion?(LocalizedUtil.Text.errorSaveData);
            return
        }
        
        entity.large = large
        entity.medium = medium
        entity.small = small
        entity.game = game
        
        dataManager.record(entity.managedObjectContext!) { error in
            completion?(error?.localizedDescription)
        }
    }
    
    private func update(_ entities: [LogoEntity]) {
        for entity in entities {
            
            entity.large = large
            entity.medium = medium
            entity.small = small
            
            dataManager.record(entity.managedObjectContext!)
        }
    }
    
    func record(logoWith gameId: Int, completion: ((String?) -> Void)? = nil) {

        let predicate = dataManager.predicate(withId: gameId, key: AttributeName.id, type: .equal)
        let fetchResult = dataManager.fetchResult(from: .logo, predicate: predicate)
        
        func record() {
            guard let game = (dataManager.fetchResult(from: .game).items as? [GameEntity])?.filter({ $0.id == Int32(gameId) }).last else { return }
            self.record(with: game, completion: completion)
        }
        
        if fetchResult.items == nil {
            record()
        } else {
            if var entities = fetchResult.items as? [LogoEntity], gameId > 0 {
                if predicate == nil {entities = entities.filter({ $0.game?.id == Int32(gameId) })}
                if entities.count > 0 {
                    self.update(entities)
                    completion?(nil)
                } else { record() }
            } else { record() }
        }
    }
    
    static func delete() -> Error? {
        return dataManager.delete(entity: .logo)
    }
}
