//
//  PersistenceController.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ExerciseLog") // Update the data model name here

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure the persistent store to use the App Group's shared container
            let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.me.jareddanieljones.calisthenics")!.appendingPathComponent("ExerciseLog.sqlite") // Update the SQLite file name here
            let storeDescription = NSPersistentStoreDescription(url: storeURL)

            // Enable CloudKit synchronization
            storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.me.jareddanieljones.calisthenics")
            
            // Enable lightweight migration
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            
            container.persistentStoreDescriptions = [storeDescription]
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleRemoteChange),
                    name: .NSPersistentStoreRemoteChange,
                    object: container.persistentStoreCoordinator
                )
    }
}

extension PersistenceController {
    @objc func handleRemoteChange(_ notification: Notification) {
            // Refresh your data here
            // You could post your own notification, update UI if needed, refresh fetched results controller, etc.
            DispatchQueue.main.async {
                // Your code to update UI or refresh data
            }
        }
    
    // Fetch entities
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        
        do {
            let result = try container.viewContext.fetch(request)
            return result as? [T] ?? []
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    // Save changes
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
    }
}

