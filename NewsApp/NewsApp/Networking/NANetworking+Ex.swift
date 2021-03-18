//
//  NANetworking+Ex.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import Foundation

import Foundation

extension NANetworking {
    func getUrlWith(url: String, path: String,
                    parameters: [String: String]? = nil) -> URL? {
        guard var components = URLComponents(string: url + path) else { return nil }
        if let parameters = parameters {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key,
                                                                  value: $0.value) }
        }
        return components.url
    }
}
