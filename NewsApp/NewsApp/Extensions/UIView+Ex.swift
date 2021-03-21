//
//  UIView+Ex.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit

extension UIView {
    // Add several subviews to view.
    func addSubviews(_ views: [UIView]) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
