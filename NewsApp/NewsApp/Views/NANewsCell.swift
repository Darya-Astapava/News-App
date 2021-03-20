//
//  NANewsCell.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit
import SnapKit

class NANewsCell: UITableViewCell {
    // MARK: - Static Variables
    static let reuseIdentifier = "NewsCell"
    
    // MARK: - Variables
    private let edgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
    private let contentOffset = CGFloat(10)
    private let imageHeight = CGFloat(150)
    
    // MARK: - GUI Variables
    private lazy var containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5
        
        return view
    }()
    
    private lazy var newsImageView: UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(named: "defaultImage")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .black
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private lazy var moreLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    // MARK: - Initializations
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.contentView.addSubview(self.containerView)
        self.containerView.addSubviews([self.newsImageView,
                                        self.dateLabel,
                                        self.titleLabel,
                                        self.descriptionLabel//,
                                        // self.moreLabel
        ])
        self.constraints()
    }
    
    // MARK: - Methods
    func setNews(title: String,
                 description: String,
                 date: String,
                 imageURL: String?) {
        self.titleLabel.text = title
        self.dateLabel.text = date
        
        var array = Array(description)
        let descriptionCount = array.count
        Swift.debugPrint(array, "count - ", descriptionCount)
        if descriptionCount >= 120 {
            for _ in 110..<descriptionCount {
                array.removeLast()
            }
            let string = String(array)
            let fullString = string + "... " + "Show more"
            self.descriptionLabel.text = fullString
        } else {
            self.descriptionLabel.text = description
        }
        
        guard let url = imageURL else { return }
        self.newsImageView.load(with: url)
    }
    
    // MARK: - Constraints
    private func constraints() {
        self.containerView.snp.updateConstraints { (make) in
            make.edges.equalToSuperview().inset(self.edgeInsets)
        }
        
        self.newsImageView.snp.updateConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.imageHeight)
        }
        
        self.dateLabel.snp.updateConstraints { (make) in
            make.right.equalTo(self.newsImageView.snp.right).offset(-self.contentOffset)
            make.bottom.equalTo(self.newsImageView.snp.bottom).offset(-self.contentOffset)
        }
        
        self.titleLabel.snp.updateConstraints { (make) in
            make.top.equalTo(self.newsImageView.snp.bottom).offset(self.contentOffset)
            make.left.right.equalToSuperview().inset(self.edgeInsets)
        }
        
        self.descriptionLabel.snp.updateConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.contentOffset)
            make.left.right.bottom.equalToSuperview().inset(self.edgeInsets)
        }
        
        //        self.moreLabel.snp.updateConstraints { (make) in
        //            make.left.equalTo(self.descriptionLabel.snp.right).offset(self.contentOffset)
        //            make.right.bottom.equalToSuperview()
        //        }
    }
    
    private func showMore() {
        // TODO
    }
}
