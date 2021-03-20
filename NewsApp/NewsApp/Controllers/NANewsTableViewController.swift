//
//  NANewsTableViewController.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit

class NANewsTableViewController: UITableViewController {
    // MARK: - Variables
    private lazy var model: [NANewsModel] = []
    private lazy var date = Date()
    private lazy var dateCount = 1
    private lazy var isMakingRequest: Bool = false
    private lazy var rowCount = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        Swift.debugPrint("First request")
        self.sendRequest(date: self.date)
    }
    
    // MARK: - Methods
    private func sendRequest(date: Date) {
        // For today news
        let parameters: [String: String] = ["from": date.formatDateToString(),
                                            "to": date.formatDateToString()]
        
        NANetworking.shared.request(parameters: parameters,
                                    successHandler: { [weak self] (model: NAResponseModel) in
                                        self?.handleResponse(model: model)
                                        self?.isMakingRequest = false
                                    },
                                    errorHandler: { [weak self] (error) in
                                        self?.handleError(error: error)
                                        self?.isMakingRequest = false
                                    })
    }
    
    private func setupTableView() {
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.refresh),
                                                 for: .valueChanged)
        self.tableView.register(NANewsCell.self,
                                forCellReuseIdentifier: NANewsCell.reuseIdentifier)
        
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
    }
    
    private func loadMoreArticles() {
        self.isMakingRequest = true
        let newDate = Date(timeInterval: -86400, since: self.date)
        self.date = newDate
        self.dateCount += 1
        
        self.sendRequest(date: self.date)
    }
    
    // MARK: - Actions
    @objc private func refresh() {
        self.date = Date()
        self.sendRequest(date: self.date)
        
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Handlers
    private func handleResponse(model: NAResponseModel) {
        var newModel: [NANewsModel] = []
        
        model.articles.forEach { (article) in
            newModel.append(article)
        }
        
        // Compare with 100 because page siza of response limited 100 articles
        self.rowCount = model.articles.count < 100
            ? self.rowCount + model.articles.count
            : self.rowCount + 100
        
        self.model += newModel
        self.tableView.reloadData()
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

extension NANewsTableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return self.rowCount
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NANewsCell.reuseIdentifier,
                                                 for: indexPath)
        if let cell = cell as? NANewsCell {
            let news = self.model[indexPath.row]
            
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
        // Create request to get new articles when left 10 articles.
        if indexPath.row == self.rowCount - 10,
           self.dateCount <= 7,
           self.isMakingRequest == false {
            self.loadMoreArticles()
        }
    }
}
