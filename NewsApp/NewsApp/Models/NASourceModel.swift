//
//  NASourceModel.swift
//  NewsApp
//
//  Created by Дарья Астапова on 19.03.21.
//
// TODO: - delete if don't need
struct NASourceModel: Codable {
    let id, name: String
    
    enum CodingKeys: CodingKey {
        case id, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}
