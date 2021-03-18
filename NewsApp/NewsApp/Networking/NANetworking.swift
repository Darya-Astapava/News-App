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
    private let apiKey = "9c0dc5e64be84dabad65a3656eb7c6f4"
    
    private lazy var session = URLSession(configuration: .default)
    
    private lazy var parameters: [String: String] = [
        "apiKey": self.apiKey,
        "sources": "cnn",
        "language": "en"
    ]
    
    // MARK: - Initializations
    private init() { }
    
    // MARK: - Methods
    /// Create request with path parameters.
    func request(parameters: [String: String]? = nil,
                               successHandler: @escaping (NAResponseModel) -> Void,
                               errorHandler: @escaping (NANetworkingErrors) -> Void) {
        // Add necessary parameters to apiKey
        var urlParameters = self.parameters
        
        if let parameters = parameters {
            parameters.forEach { urlParameters[$0.key] = $0.value }
        } else {
            let date = Date()
            urlParameters["from"] = self.formatDateToString(date: date)
        }
        
        // Generate url with baseUrl, path and parameters
        guard let fullUrl = self.getUrlWith(url: self.baseURL,
                                            path: self.path,
                                            parameters: urlParameters) else {
            errorHandler(.incorrectUrl)
            return
        }
        
        Swift.debugPrint(fullUrl)
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
                        Swift.debugPrint("case 200..<300 do")
                        let model = try JSONDecoder().decode(NAResponseModel.self, from: data)
                        DispatchQueue.main.async {
                            successHandler(model)
                        }
                    } catch let error {
                        Swift.debugPrint("case 200..<300 catch")

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
    
    private func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

