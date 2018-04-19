import Foundation
import CoreData

struct DataManager {
    private let dataBase = "StoneYourDataBase"
    
    enum Entity: String {
        case game = "GameEntity"
        case image = "ImageEntity"
        case logo = "LogoEntity"
    }
    
    enum predicateType: String {
        case equal = "=="
        case different = "<>"
        case AND = "AND"
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dataBase)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    mutating func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    mutating func getManagedObject(type: Entity) -> Any? {
        return NSEntityDescription.insertNewObject(forEntityName: type.rawValue,
                                                   into: persistentContainer.viewContext)
    }
    
    mutating func fetchResult(from entity: Entity,
                              predicate: NSPredicate? = nil) -> (items: [Any]?, error: String?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            return (results.count > 0 ? results : nil, nil)
        } catch {
            return (nil, error.localizedDescription)
        }
    }
    
    mutating func delete(entity: Entity, predicate: NSPredicate? = nil) -> Error? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        do {
            try persistentContainer.persistentStoreCoordinator
                .execute(NSBatchDeleteRequest(fetchRequest: fetchRequest),
                         with: persistentContainer.viewContext)
            return nil
        } catch {
            return error
        }
    }
    
    func record(_ context: NSManagedObjectContext, completion: ((Error?) -> Void)? = nil) {
        context.performAndWait {
            do {
                try context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func predicate(with id: Int?, key: String, type: predicateType) -> NSPredicate? {
        guard let id = id else { return nil }
        return NSPredicate(format: "\(key) \(type.rawValue) %d", id)
    }
    
    func predicate(with value: String?, key: String, type: predicateType) -> NSPredicate? {
        guard let value = value,
            !value.isEmpty else {
                return NSPredicate(format: "\(key) \(type.rawValue)")
        }
        return NSPredicate(format: "\(key) \(type.rawValue) %@", value)
    }
    
    func showDataPath() {
        guard let url = FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .userDomainMask).last else { return }
        print("CoreData url: \(url)")
    }
}
