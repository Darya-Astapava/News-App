//
//  NANewsModel.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

struct NANewsModel: Codable {
    var title: String
    var description: String?
    var urlToImage: String?
    var publishedAt: String
    
    enum CodingKeys: CodingKey {
        case title, description, urlToImage, publishedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
    }
    
    init(title: String, description: String?, image: String?, date: String) {
        self.title = title
        self.description = description
        self.publishedAt = date
        self.urlToImage = image
    }
}

