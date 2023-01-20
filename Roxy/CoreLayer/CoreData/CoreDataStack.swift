//
//  CoreDataStack.swift
//  Roxy
//
//  Created by username on 11.01.2023.
//

import Foundation
import CoreData


final class CoreDataStack: CoreDataStackProtocol {
    
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        container.viewContext.mergePolicy = NSMergePolicy.overwrite
        container.loadPersistentStores { _, error in
            if let error = error {
                NSLog("Критическая ошибка инициализации CoreData \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        let context = storeContainer.viewContext
        
        context.mergePolicy = NSOverwriteMergePolicy
        
        return context
    }()

    func saveContext () {
        guard managedContext.hasChanges else {
            return
        }

        do {
            try managedContext.save()
        } catch {
            NSLog("Ошибка сохранения контекста CoreData \(error.localizedDescription)")
        }
    }
}
