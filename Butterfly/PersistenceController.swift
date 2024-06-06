import Foundation
import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  
  let container: NSPersistentCloudKitContainer
  
  init() {
    container = NSPersistentCloudKitContainer(name: "Main")
    let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let url = storeDirectory.appendingPathComponent("Butterfly.sqlite")
    let description = NSPersistentStoreDescription(url: url)
    description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.southern.butterfly")
    description.shouldInferMappingModelAutomatically = true
    description.shouldMigrateStoreAutomatically = true
    
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { description, error in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
  
  func save() {
    let context = container.viewContext

    if context.hasChanges {
      do {
        try context.save()
        print("--------------------------saved context-----------------------------")
      } catch {
        print("--------------------------error saving data-------------------------")
      }
    }
  }
  
  public func dropData() {
    let entities = container.managedObjectModel.entities
    entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
  }
  
  private func clearDeepObjectEntity(_ entity: String) {
    let context = container.viewContext
    
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
    
    do {
      try context.execute(deleteRequest)
      try context.save()
    } catch {
      print ("There was an error")
    }
  }
}
