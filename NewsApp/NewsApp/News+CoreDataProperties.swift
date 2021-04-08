//
//  News+CoreDataProperties.swift
//  
//
//  Created by Daria Astapova on 4/8/21.
//
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var articleDescription: String?
    @NSManaged public var image: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var title: String?

}
