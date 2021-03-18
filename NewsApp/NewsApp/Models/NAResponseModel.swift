//
//  NAResponseModel.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

struct NAResponseModel: Decodable {
    let status: String
    let totalResults: Int
    let articles: [NANewsModel]
    
    enum CodingKeys: CodingKey {
        case status
        case totalResults
        case articles
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.totalResults = try container.decode(Int.self, forKey: .totalResults)
        self.articles = try container.decode([NANewsModel].self, forKey: .articles)
    }
}
