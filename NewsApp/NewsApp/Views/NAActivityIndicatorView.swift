//
//  NAActivityIndicatorView.swift
//  NewsApp
//
//  Created by Дарья Астапова on 20.03.21.
//

import UIKit
import SnapKit

// Возможно не понадобится
class NAActivityIndicatorView: UIView {
    private lazy var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
