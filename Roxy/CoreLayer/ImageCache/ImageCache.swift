//
//  Cache.swift
//  Roxy
//
//  Created by username on 18.01.2023.
//

import Foundation
import UIKit


final class ImageCache: ImageCacheProtocol {
    
    private var cacheDirectory: URL
    private let entryLifetime: TimeInterval
    
    init(cacheDirectory: URL, entryLifetime: TimeInterval = 60 * 10) {
        self.cacheDirectory = cacheDirectory
        self.entryLifetime = entryLifetime
    }
    
    func image(for url: URL) -> UIImage? {
        
        let fileName = url.absoluteString.replacingOccurrences(of: "/", with: "_")
        let imageUrl = cacheDirectory.appendingPathComponent(fileName)
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: imageUrl.path),
           let creationtDate = attributes[.creationDate] as? Date {

            let expirationDate = creationtDate.addingTimeInterval(entryLifetime)
            if expirationDate > Date() {
                
                if let data = try? Data(contentsOf: imageUrl),
                   let cachedImage = UIImage(data: data) {
                    NSLog("Считал картинку из файла \(url)")
                    return cachedImage
                }
                
            } else {
                deleteFile(with: imageUrl)
            }
        }
        
        return nil
    }
    
    func saveImage(url: URL, data: Data) {
        
        do {
            let fileName = url.absoluteString.replacingOccurrences(of: "/", with: "_")
            let imageUrl = cacheDirectory.appendingPathComponent(fileName)
            try data.write(to: imageUrl, options: .noFileProtection)
            NSLog("Сохранил картинку в файл \(url)")
        } catch {
            NSLog("Ошибка записи файла: \(error.localizedDescription)")
        }
    }
    
    func deleteOldCachedImages() {
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: cacheDirectory,
                                                                   includingPropertiesForKeys: nil)
            for url in urls {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                   let creationtDate = attributes[.creationDate] as? Date,
                   creationtDate.addingTimeInterval(entryLifetime) < Date() {
                    
                    deleteFile(with: url)
                }
            }
        } catch {
            NSLog("Ошибка чтения директории")
        }
    }
    
    private func deleteFile(with url: URL) {
        
        do {
            try FileManager.default.removeItem(at: url)
            NSLog("Удалил файл \(url.lastPathComponent)")
        } catch {
            NSLog("Ошибка удаления файла \(url): \(error.localizedDescription)")
        }
    }
}
