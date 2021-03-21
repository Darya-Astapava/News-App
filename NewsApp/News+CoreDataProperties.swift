//
//  News+CoreDataProperties.swift
//  
//
//  Created by Дарья Астапова on 21.03.21.
//
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var title: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var image: Data?

}
