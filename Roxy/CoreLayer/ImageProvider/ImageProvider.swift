//
//  ImageProvider.swift
//  Roxy
//
//  Created by username on 09.01.2023.
//

import Foundation
import UIKit


class ImageProvider: ImageProviderProtocol {
    
    let cache: ImageCacheProtocol?
    
    var requestCompletions: [URL: [(UIImage?) -> Void]] = [:]
    
    init(cache: ImageCacheProtocol?) {
        self.cache = cache
    }
    
    func getImage(for url: URL, completion: @escaping ((UIImage?) -> Void)) {
        
        if let cachedImage = cache?.image(for: url) {
            completion(cachedImage)
            return
        }
        
        if requestCompletions[url] == nil {
            requestCompletions[url] = [completion]
            
            let urlSession = URLSession(configuration: .ephemeral)
            urlSession.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            
            let dataTask = urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                
                self.cache?.saveImage(url: url, data: data)
                
                if let completions = self.requestCompletions[url] {
                    completions.forEach { $0.self(image) }
                    self.requestCompletions[url] = nil
                }
            }
            
            dataTask.resume()
            NSLog("Запустил загрузку картинки \(url)")
            
        } else {
            
            requestCompletions[url]?.append(completion)
            NSLog("Добавил в очередь запросов к уже существующему \(url)")
            
        }
    }
}

