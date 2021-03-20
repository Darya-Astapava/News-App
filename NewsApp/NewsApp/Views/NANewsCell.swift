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
        label.lineBreakMode = .byTruncatingTail
        
        
        return label
    }()
    
    private lazy var moreLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Show more"
        label.textColor = .blue
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        
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
                                        self.descriptionLabel,
                                        self.moreLabel
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
        //        if descriptionCount >= 120 {
        //            for _ in 110..<descriptionCount {
        //                array.removeLast()
        //            }
        //            let newDescription = String(array)
        //            self.descriptionLabel.text = newDescription
        //            self.moreLabel.isHidden = false
        //        } else {
        self.descriptionLabel.text = description
        //        }
        
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
        
        self.moreLabel.snp.updateConstraints { (make) in
            make.right.equalTo(self.descriptionLabel.snp.right)
            make.bottom.equalToSuperview().inset(self.edgeInsets)
        }
    }
}

extension UILabel {
    
    func addTrailing(with trailingText: String,
                     moreText: String,
                     moreTextFont: UIFont,
                     moreTextColor: UIColor) {
        
        let readMoreText: String = trailingText + moreText
        let lengthForVisibleString: Int = self.vissibleTextLength
        
        guard let text = self.text else { return }
        let mutableString: String = text
        let trimmedString: String? = (mutableString as NSString)
            .replacingCharacters(in: NSRange(location: lengthForVisibleString,
                                             length: (text.count - lengthForVisibleString)),
                                 with: "")
        
        let readMoreLength: Int = (readMoreText.count)
        
        guard let trimString = trimmedString else { return }
        let trimmedForReadMore: String = (trimString as NSString)
            .replacingCharacters(
                in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength),
                            length: readMoreLength),
                with: "") + trailingText
        
        let answerAttributed = NSMutableAttributedString(
            string: trimmedForReadMore,
            attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(
            string: moreText,
            attributes: [NSAttributedString.Key.font: moreTextFont,
                         NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth,
                                    height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        
        let attributedText = NSAttributedString(
            string: self.text ?? "",
            attributes: attributes as? [NSAttributedString.Key : Any])
        
        let boundingRect: CGRect = attributedText
            .boundingRect(with: sizeConstraint,
                          options: .usesLineFragmentOrigin,
                          context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString)
                        .rangeOfCharacter(from: characterSet,
                                          options: [],
                                          range: NSRange(location: index + 1,
                                                         length: self.text!.count - index - 1)).location
                }
                
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}
