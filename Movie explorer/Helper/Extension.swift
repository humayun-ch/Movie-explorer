//
//  Extension.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 6/3/25.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        let cacheKey = NSString(string: url.absoluteString)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        self.image = nil
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageCache.setObject(image, forKey: cacheKey)
                    self.image = image
                }
            }
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()
