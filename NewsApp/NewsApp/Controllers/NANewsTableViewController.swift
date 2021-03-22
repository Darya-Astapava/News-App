//
//  NANewsTableViewController.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit
import ExpandableLabel

class NANewsTableViewController: UITableViewController {
    // MARK: - Variables
    private lazy var model: [NANewsModel] = []
    private lazy var date = Date()
    private lazy var dateCount = 1
    private lazy var isMakingRequest: Bool = false
    private lazy var rowCount = 0
    private lazy var filteredNews: [NANewsModel] = []
    private lazy var states: [Bool] = []
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - GUI Variables
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.navigationController?.navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        self.setupTableView()
        self.setupRefreshControl()
        self.sendRequest(date: self.date)
    }
    
    // MARK: - Methods
    private func sendRequest(date: Date) {
        // Date for request
        let parameters: [String: String] = ["from": date.formatDateToString(),
                                            "to": date.formatDateToString()]
        
        NANetworking.shared.request(parameters: parameters,
                                    successHandler: { [weak self] (model: NAResponseModel) in
                                        self?.handleResponse(model: model)
                                        self?.isMakingRequest = false
                                        DispatchQueue.main.async {
                                            self?.tableView.refreshControl?.endRefreshing()
                                        }
                                    },
                                    errorHandler: { [weak self] (error) in
                                        self?.handleError(error: error)
                                        self?.isMakingRequest = false
                                        DispatchQueue.main.async {
                                            self?.tableView.refreshControl?.endRefreshing()
                                        }
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
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching news",
                                                            attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemGray2])
        refreshControl.tintColor = UIColor.systemGray2
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self,
                                 action: #selector(self.refresh),
                                 for: .valueChanged)
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
        self.model = []
        self.rowCount = 0
        self.date = Date()
        self.sendRequest(date: self.date)
    }
    
    // MARK: - Handlers
    private func handleResponse(model: NAResponseModel) {
        var newModel: [NANewsModel] = []
        
        model.articles.forEach { (article) in
            // Set table from API
            newModel.append(article)
            
            // Store image and title into CoreData
            NACoreDataManager.shared.writeData(with: article)
        }
        
        // Compare with 100 because page siza of response limited 100 articles
        self.rowCount = model.articles.count < 100
            ? self.rowCount + model.articles.count
            : self.rowCount + 100

        self.model += newModel

        // For Show more
        let statesForNewArticles = [Bool](repeating: true, count: newModel.count)
        self.states += statesForNewArticles

        self.tableView.reloadData()
    }
    
    private func setImageFromCoreDataToNewsModel() {
        NACoreDataManager.shared.readData { (news) in
            // Set image using title
            news.forEach { [weak self] (article) in
                guard let self = self else { return }
                
                Swift.debugPrint("Article title from Core Data - \(article.title ?? "")")
                
                guard let index = self.model.firstIndex(
                        where: { $0.title == article.title }) else { return }
                self.model[index].pngData = article.image
            }
        }
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
        if isFiltering {
            return self.filteredNews.count
        } else {
            return self.rowCount
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NANewsCell.reuseIdentifier,
                                                 for: indexPath)
        if let cell = cell as? NANewsCell {
            // For expandable label delegate
            cell.setStateForDescription(state: self.states[indexPath.row])
            
            let news: NANewsModel = isFiltering
                ? self.filteredNews[indexPath.row]
                : self.model[indexPath.row]
            
            cell.setNews(title: news.title ,
                         description: news.description ?? "",
                         date: news.publishedAt ,
                         imageURL: news.urlToImage,
                         pngImage: news.pngData)
            
            Swift.debugPrint("title: \(news.title), description: \(news.description ?? ""), date: \(news.publishedAt ), imageURL: \(String(describing: news.urlToImage)), pngImage: \(String(describing: news.pngData))")
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

// MARK: - Search bar delegate
extension NANewsTableViewController: UISearchResultsUpdating,
                                     UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.searchController.searchBar.text else { return }
        filterContentForSearchText(text)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
//        self.filteredNews = self.model.filter({ (news: NANewsModel) -> Bool in
//            return news.title.lowercased().contains(searchText.lowercased())
//        })
        
        tableView.reloadData()
    }
}

// MARK: - Expandable Label Delegate Methods
extension NANewsTableViewController: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        Swift.debugPrint("willExpandLabel")
        self.tableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        Swift.debugPrint("didExpandLabel")
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            self.states[indexPath.row] = false
            DispatchQueue.main.async { [weak self] in
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        self.tableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        Swift.debugPrint("willCollapseLabel")
        self.tableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        Swift.debugPrint("didCollapseLabel")
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            self.states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        tableView.endUpdates()
    }
}
