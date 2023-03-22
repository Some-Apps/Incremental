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

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Exercise")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure the persistent store to use the App Group's shared container
            let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.me.jareddanieljones.calisthenics")!.appendingPathComponent("Exercise.sqlite")
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

extension PersistenceController {
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
