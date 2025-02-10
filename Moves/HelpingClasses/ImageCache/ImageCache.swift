//
//  ImageCache.swift
// //
//
//  Created by Wasiq Tayyab on 13/08/2024.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func cache(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
