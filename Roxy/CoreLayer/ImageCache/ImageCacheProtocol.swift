//
//  ImageCacheProtocol.swift
//  Roxy
//
//  Created by username on 18.01.2023.
//

import Foundation
import UIKit


protocol ImageCacheProtocol {
    
    func image(for url: URL) -> UIImage?
    
    func saveImage(url: URL, data: Data)
    
    func deleteOldCachedImages()
}
