//
//  UIImageView+Ex.swift
//  NewsApp
//
//  Created by Дарья Астапова on 19.03.21.
//

import UIKit

extension UIImageView {
    // Load and set image to UIImageView from string url.
    func load(with url: String) {
        DispatchQueue.global().async {
            guard let url = URL(string: url),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
