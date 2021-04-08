//
//  NANetworking.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import Foundation

class NANetworking {
    // MARK: - Static properties
    static var shared = NANetworking()
    
    // MARK: - Properties
    private let baseURL = "https://newsapi.org/v2/"
    private let path = "everything"
    private let apiKey = "f87c2dbc642640eaaa1986e82858c7da"
    
    private lazy var session = URLSession(configuration: .default)
    
    private lazy var parameters: [String: String] = [
        "apiKey": self.apiKey,
        "sources": "bbc-news",
        "language": "en",
        // Limit page size because free developer plan allow to get only 100 articles in one request.
        "pageSize": "100"
    ]
    
    // MARK: - Initializations
    private init() { }
    
    // MARK: - Methods
    func getNews(parameters: [String: String],
                 completionHandler: (() -> Void)?,
                 errorHandler: @escaping (NANetworkingErrors) -> Void) {
        Swift.debugPrint("getNews")
        self.request(parameters: parameters) { (response) in
            Swift.debugPrint("request with response")
            self.handleResponse(response) {
                completionHandler?()
            }
        } errorHandler: { (error) in
            Swift.debugPrint("request with error")
            Swift.debugPrint(error)
        }
    }
    
    /// Create request with path parameters.
    private func request(parameters: [String: String],
                 successHandler: @escaping (NAResponseModel) -> Void,
                 errorHandler: @escaping (NANetworkingErrors) -> Void) {
        // Add necessary parameters to apiKey
        var urlParameters = self.parameters
        parameters.forEach { urlParameters[$0.key] = $0.value }
        
        // Generate url with baseUrl, path and parameters
        guard let fullUrl = self.getUrlWith(url: self.baseURL,
                                            path: self.path,
                                            parameters: urlParameters) else {
            errorHandler(.incorrectUrl)
            return
        }
        
        let request = URLRequest(url: fullUrl)
        
        let dataTask = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                // Network error handling
                DispatchQueue.main.async {
                    errorHandler(.networkError(error: error))
                }
                return
            } else if let data = data,
                      let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    // Success server response handling
                    do {
                        let model = try JSONDecoder().decode(NAResponseModel.self, from: data)
                        DispatchQueue.main.async {
                            successHandler(model)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            errorHandler(.parsingError(error: error))
                        }
                    }
                case 400..<500:
                    // Handle request errors
                    DispatchQueue.main.async {
                        errorHandler(.requestError(error: response.statusCode))
                    }
                case 500...:
                    // Handle server errors
                    DispatchQueue.main.async {
                        errorHandler(.serverError(statusCode: response.statusCode))
                    }
                default:
                    // Handle unknown errors
                    DispatchQueue.main.async {
                        errorHandler(.unknown)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    private func handleResponse(_ response: NAResponseModel,
                                completionHandler: (() -> Void)?) {
        Swift.debugPrint("Handle Response")
        for article in response.articles {
            NACoreDataManager.shared.storeData(with: article)
        }
        completionHandler?()
    }
}

