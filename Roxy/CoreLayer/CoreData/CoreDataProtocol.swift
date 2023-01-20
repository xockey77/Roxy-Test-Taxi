//
//  CoreDataProtocol.swift
//  Roxy
//
//  Created by username on 11.01.2023.
//

import CoreData


protocol CoreDataStackProtocol {
    
    var managedContext: NSManagedObjectContext { get }
    
    func saveContext()
    
    init(modelName: String)
}
