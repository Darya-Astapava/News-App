//
//  NACoreDataManager.swift
//  NewsApp
//
//  Created by Daria Astapova on 4/8/21.
//

import UIKit
import CoreData

class NACoreDataManager {
    // MARK: - Static properties
    static let shared = NACoreDataManager()
    
    // MARK: - Closures
    var dataWasStored: (() -> Void)?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Core Data
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NACoreDataModel")
        
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
    func storeData(with object: NANewsModel) {
        
        let news = News(context: self.context)
        news.title = object.title
        news.articleDescription = object.description ?? ""
        news.publishedAt = object.publishedAt
        
        self.transformImageToString64(from: object.urlToImage) { (date) in
            news.image = date
        }
        
        do {
            try self.context.save()
            Swift.debugPrint("data was stored")
        } catch let error as NSError {
            Swift.debugPrint("Could not save data. \(error), \(error.userInfo)")
        }
    }
    
    func readData(date: String, completionHandler: (([News]) -> Void)?, errorHandler: (() -> Void)?) {
        // TODO: request with selected date
        Swift.debugPrint("try read data")
     //   let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "News")
        
        do {
                        guard let result = try self.context.fetch(News.fetchRequest()) as? [News] else { return }
//            guard let result = try self.context.fetch(fetchRequest) as? [News] else { return }
            completionHandler?(result)
        } catch  let error as NSError {
            Swift.debugPrint("Couldn't read data. \(error), \(error.userInfo)")
            errorHandler?()
        }
    }
    
    /// Get image from url and transform it to String64 type
    private func transformImageToString64(from url: String?,
                                          completionHandler: ((String) -> Void)?) {
        guard let url = url else { return }
        
        DispatchQueue.global().async {
            guard let url = URL(string: url),
                  let data = try? Data(contentsOf: url) else { return }
            
            let imageData = data.base64EncodedString(options: .lineLength64Characters)
            
            DispatchQueue.main.async {
                completionHandler?(imageData)
            }
        }
    }
}
