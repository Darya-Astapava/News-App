//
//  NANewsTableVC.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit

class NANewsTableVC: UITableViewController {
    // MARK: - Variables
    private lazy var model: [NANewsModel]? = nil {
        didSet {
            self.tableView.reloadData()
        }
    }
    private lazy var cellIdentifier: String = NANewsCell.reuseIdentifier

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.sendRequest()
    }
    
    // MARK: - Methods
    private func sendRequest() {
        NANetworking.shared.request(parameters: nil,
                                    successHandler: { [weak self] (model: NAResponseModel) in
                                        self?.handleResponse(model: model)
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
        Swift.debugPrint(model)
        self.model = model.articles
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
        return self.model?.count ?? 0
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier,
                                                 for: indexPath)
        if let cell = cell as? NANewsCell, let model = self.model {
            let news = model[indexPath.row]
            
            cell.setNews(title: news.title,
                         description: news.description ?? "")
        }

        return cell
    }

}
