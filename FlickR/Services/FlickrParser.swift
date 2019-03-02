//
//  FlickrParser.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol FlickrParser {
    func parseServerResponse(data: Data) -> (error: Error?, models: [Photo])
}

class FlickrParserImpl: FlickrParser {
    func parseServerResponse(data: Data) -> (error: Error?, models: [Photo]) {
        // Check if server returns error in json
        guard let objectResponse = try? JSONSerialization.jsonObject(with: data, options: []),
            let photosRootDict = objectResponse as? [String: Any],
            let stat = photosRootDict["stat"] as? String,
            stat != "fail" else {
                // TODO: Parse server error and log it
                return (ServerError(), [])
        }
        
        guard let photosRoot = photosRootDict["photos"],
            let photoDict = photosRoot as? [String: Any],
            let photos = photoDict["photo"],
            let photosArray = photos as? [NSDictionary] else {
                return (ServerError(), [])
        }
        
        guard let photoModels = self.deserializePhotosInfo(photosArray) else {
            return (ParseError(), [])
        }
        
        return (nil, photoModels)
    }
    
    private func deserializePhotosInfo(_ photos:  [NSDictionary]) -> [Photo]? {
        var models: [Photo] = []
        
        for model in photos {
            guard let id = model["id"] as? String,
                let secret = model["secret"] as? String,
                let server = model["server"] as? String,
                let farm = model["farm"] as? Int,
                let title = model["title"] as? String else { return nil }
            
            models.append(Photo(id: id, farm: farm, server: server, secret: secret, title: title, photoLoaded: false))
        }
        
        return models
    }
}
