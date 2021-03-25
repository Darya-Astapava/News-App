//
//  NANetworkingErrors.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

enum NANetworkingErrors {
    case incorrectUrl
    case networkError(error: Error)
    case requestError(error: Int)
    case serverError(statusCode: Int)
    case parsingError(error: Error)
    case unknown
}
