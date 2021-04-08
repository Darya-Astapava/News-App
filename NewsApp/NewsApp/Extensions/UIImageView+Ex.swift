//
//  UIImageView+Ex.swift
//  NewsApp
//
//  Created by Дарья Астапова on 19.03.21.
//

import UIKit

extension UIImageView {
    // Load and set image to UIImageView from string url.
    func loadFromURL(with url: String) {
        DispatchQueue.global().async {
            guard let url = URL(string: url),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    func loadFromStringData(with stringData: String) {
        DispatchQueue.global().async {
            guard let dataDecoded: Data = NSData(base64Encoded: stringData,
                                                 options: NSData.Base64DecodingOptions(rawValue: 0)) as Data?,
                  let decodedImage: UIImage = UIImage(data: dataDecoded) else { return }
            
            DispatchQueue.main.async {
                self.image = decodedImage
            }
        }
        Swift.debugPrint("loadFromStringData was worked")
    }
}
