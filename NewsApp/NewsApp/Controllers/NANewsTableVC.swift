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
    private lazy var isMakingRequest: Bool = false
    
    
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
        let parameters: [String: String] = ["from": date.formatDateToString()]
        
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
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.refresh),
                                                 for: .valueChanged)
        self.tableView.register(NANewsCell.self,
                                forCellReuseIdentifier: self.cellIdentifier)
        
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
        
        self.model += newModel
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
            
            // Create request to get new articles when left 10 articles.
            if indexPath.row == self.model.count - 10,
               self.dateCount <= 7,
               self.isMakingRequest == false {
                self.loadMoreArticles()
            }
            
            cell.setNews(title: news.title,
                         description: news.description ?? "",
                         date: news.publishedAt,
                         imageURL: news.urlToImage)
        }
        
        return cell
    }
}
