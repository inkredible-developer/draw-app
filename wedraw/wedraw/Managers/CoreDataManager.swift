//
//  CoreDataManager.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "wedraw_model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
