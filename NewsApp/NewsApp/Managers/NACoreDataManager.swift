//
//  NACoreDataManager.swift
//  NewsApp
//
//  Created by Дарья Астапова on 21.03.21.
//

import UIKit
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
    func writeData(with object: NANewsModel) {
        let news = News(context: self.context)
        news.title = object.title
        news.newsDescription = object.description ?? ""
        news.publishedAt = object.publishedAt
        
        // Create data image object from string with url and set to news entity.
        self.transformUrlToPngData(url: object.urlToImage) { (image) in
            news.image = image
        }
        
        do {
            try self.context.save()
            Swift.debugPrint("Success store data.")
        } catch let error as NSError {
            Swift.debugPrint("Couldn't save data. \(error), \(error.userInfo)")
        }
    }
    
    func readData(completionHandler: (([News]) -> Void)?) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "News")
        do {
            guard let result = try self.context.fetch(fetchRequest) as? [News] else { return }
            completionHandler?(result)
        } catch {
            Swift.debugPrint("Couldn't read data. \(error.localizedDescription)")
        }
    }
    
    // Transform image url from string to data object.
    private func transformUrlToPngData(url: String?, completionHandler: ((Data)-> Void)?) {
        guard let url = url else { return }
        
        DispatchQueue.global().async {
            guard let url = URL(string: url),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data),
                  let pngData = image.pngData() else { return }
            
            DispatchQueue.main.async {
                completionHandler?(pngData)
            }
        }
    }
}
