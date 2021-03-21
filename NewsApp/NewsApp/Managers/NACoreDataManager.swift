//
//  NACoreDataManager.swift
//  NewsApp
//
//  Created by Дарья Астапова on 21.03.21.
//

import Foundation
import CoreData

class NACoreDataManager {
    // MARK: - Static Properties
    static let entityName: String = "NADataModel"
    static let shared = NACoreDataManager()
    
    // MARK: - Initializations
    private init() {}
    
    // MARK: - Core Data
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: NACoreDataManager.entityName)
        
        container.loadPersistentStores { (description, error) in
            Swift.debugPrint("Store \(description)")
            if let error = error {
                Swift.debugPrint("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    private var context: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }
    
    // MARK: - Methods
    func writeData(with name: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: name,
                                                      in: self.context) else { return }
        let newsObject = NSManagedObject(entity: entity,
                                         insertInto: self.context)
        newsObject.setValue("", forKeyPath: "title")
        newsObject.setValue("", forKeyPath: "newsDescription")
        newsObject.setValue("", forKeyPath: "image")
        newsObject.setValue("", forKeyPath: "publishedAt")
    }
}
