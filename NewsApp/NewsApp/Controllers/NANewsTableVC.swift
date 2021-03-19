//
//  NANewsTableVC.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit

class NANewsTableVC: UITableViewController {
    // MARK: - Variables
    private lazy var model: [NANewsModel] = [] {
        didSet {
            self.tableView.reloadData()
            Swift.debugPrint("Reload data")
        }
    }
    
    private lazy var cellIdentifier: String = NANewsCell.reuseIdentifier
    private lazy var date = Date()
    private lazy var dateCount = 1
    private lazy var page: Int = 1
    private lazy var articlesCount: Int = 0
    private lazy var displayedArticlesCount: Int = 0
    private lazy var isMakingRequest: Bool = false
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        Swift.debugPrint("First request")
        self.sendRequest(date: self.date)
    }
    
    // MARK: - Methods
    private func sendRequest(date: Date, page: Int = 1) {
        // For today news
        let parameters: [String: String] = ["from": date.formatDateToString(), "page": String(page)]
        
        NANetworking.shared.request(parameters: parameters,
                                    successHandler: { [weak self] (model: NAResponseModel) in
                                        self?.handleResponse(model: model)
                                        self?.isMakingRequest = false
                                    },
                                    errorHandler: { [weak self] (error) in
                                        self?.handleError(error: error)
                                    })
    }
    
    private func setupTableView() {
        self.tableView.register(NANewsCell.self,
                                forCellReuseIdentifier: self.cellIdentifier)
        
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Handlers
    private func handleResponse(model: NAResponseModel) {
        var newModel: [NANewsModel] = []
        model.articles.forEach { (article) in
            newModel.append(article)
        }
        self.articlesCount = model.totalResults
        
        self.model += newModel
        Swift.debugPrint("Total articles count - \(articlesCount)")
    }
    
    private func handleError(error: NANetworkingErrors) {
        let title = "Error"
        var message = ""
        
        switch error {
        case .incorrectUrl:
            message = "Incorrect URL"
        case .networkError(let error):
            Swift.debugPrint("networkError")
            message = error.localizedDescription
        case .parsingError(let error):
            Swift.debugPrint("parsingError")
            message = error.localizedDescription
        case .requestError(let error):
            message = "Request error with code \(error)"
        case .serverError(let error):
            message = "Server error with code \(error)"
        default:
            message = "Unknown error"
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        self.present(alert, animated: true)
    }
    
}

extension NANewsTableVC {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return self.model.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier,
                                                 for: indexPath)
        if let cell = cell as? NANewsCell {
            let news = self.model[indexPath.row]
            
            // TODO: перегружает всю таблицу и ячейки начинают повторяться
            if indexPath.row == self.model.count - 5 {
                if self.articlesCount > self.displayedArticlesCount,
                   self.isMakingRequest == false {
                    self.displayedArticlesCount += 20
                    if self.displayedArticlesCount < self.articlesCount {
                        self.page += 1
                        self.isMakingRequest = true
                        self.sendRequest(date: self.date, page: self.page)
                        
                        Swift.debugPrint("DisplayedArticlesCount - \(self.displayedArticlesCount)")
                    }
                }
                
                if self.articlesCount == self.model.count, self.dateCount <= 7 {
                    // TODO: new request with yesterday date and add data to model
                    self.displayedArticlesCount = 0
                    self.page = 1
                    let date = Date(timeInterval: -86400, since: self.date)
                    self.date = date
                    self.dateCount += 1
                    Swift.debugPrint("Date for new request", date, "displayedArticlesCount - \(self.displayedArticlesCount)")
                    self.sendRequest(date: date)
                }
            }
            
            cell.setNews(title: news.title,
                         description: news.description ?? "",
                         date: news.publishedAt,
                         imageURL: news.urlToImage)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let modelCount = self.model.count
        
    }
}
