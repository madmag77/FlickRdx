//
//  ImageCache.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit

protocol PhotoCache {
    static var sharedInstance: PhotoCache { get }
    func photo(for itemId: String) -> () -> UIImage?
    func setPhoto(_ image: UIImage, for itemId: String)
    func clearCache()
}

class PhotoCacheInMemory {
    static let sharedInstance: PhotoCache = PhotoCacheInMemory()
    
    // Sure thing it's not good to store maybe thousands of images in memory
    // so memory cache should be limited, and persistent file cache introduced
    // TODO: Make separate class - storage with limited storage in memory and big
    // one in FS
    private var imageCache: [String: UIImage] = [:]
    
    // Since a lot of images are downloading simultaneously
    // we want to make our cache threadsafe with usage of serial queue
    private let cacheQueue = DispatchQueue(label: "PhotoCacheInMemoryCacheQueue")
}

extension PhotoCacheInMemory: PhotoCache {
    func photo(for itemId: String) -> () -> UIImage? {
        return {
            self.cacheQueue.sync {
                return self.imageCache[itemId]
            }
        }
    }
    
    func setPhoto(_ image: UIImage, for itemId: String) {
        cacheQueue.async {
            self.imageCache[itemId] = image
        }
    }
    
    func clearCache() {
        cacheQueue.async {
            self.imageCache = [:]
        }
    }
}

class PhotoCacheOnDisk {
    static let sharedInstance: PhotoCache = PhotoCacheOnDisk()
    
    private let folderName: String = "Flickr_images"
    private let fileManager = FileManager.default

    // We want to have same cache in memory in order not to load everytime from disk
    // TODO: Optimize inmemory storage map so it will limit the amount of images stored there
    private var imageCache: [String: UIImage] = [:]

    // Since a lot of images are downloading simultaneously
    // we want to make our cache threadsafe with usage of serial queue
    private let cacheQueue = DispatchQueue(label: "PhotoCacheOnDiskCacheQueue")
}

extension PhotoCacheOnDisk: PhotoCache {
    func photo(for itemId: String) -> () -> UIImage? {
        return {
            self.cacheQueue.sync {
                if let image = self.imageCache[itemId] {
                    return image
                }
                
                guard let imageCacheDirectory = try? self.fileManager.url(for: .cachesDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: true),
                    let data = try? Data(contentsOf: imageCacheDirectory.appendingPathComponent(self.folderName).appendingPathComponent(itemId)) else {
                        
                        return nil
                }
                
                let image = UIImage(data: data)
                self.imageCache[itemId] = image
                
                return image
            }
        }
    }
    
    func setPhoto(_ image: UIImage, for itemId: String) {
        cacheQueue.async {
            self.imageCache[itemId] = image
            do {
                let imageCacheDirectory = try self.fileManager.url(for: .cachesDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: true)
                
                let folderURL = imageCacheDirectory.appendingPathComponent(self.folderName)
                try? self.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

                let fileURL = imageCacheDirectory.appendingPathComponent(self.folderName).appendingPathComponent(itemId)
                
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    try imageData.write(to: fileURL)
                }
            } catch {
                print("PhotoCacheOnDisk file saving error: ", error) // TODO: Log it properly
            }
        }
    }
    
    func clearCache() {
        cacheQueue.async {
            guard let imageCacheDirectory = try? self.fileManager.url(for: .cachesDirectory,
                                                                      in: .userDomainMask,
                                                                      appropriateFor: nil,
                                                                      create: true)
                else {
                                                                return
            }
            
            let folderURL = imageCacheDirectory.appendingPathComponent(self.folderName)
            
            do {
                try self.fileManager.removeItem(at: folderURL)
            } catch {
                print("PhotoCacheOnDisk file clearCache error: ", error) // TODO: Log it properly
            }
        }
    }
}

let defaultCacheToUse: PhotoCache = PhotoCacheOnDisk.sharedInstance
