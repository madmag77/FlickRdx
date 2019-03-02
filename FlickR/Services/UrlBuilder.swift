//
//  UrlBuilder.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation

protocol UrlBuilder {
    var url: URL {get}
    func getUrlToDownloadPhoto(farm: Int, server: String, secret: String, id: String) -> URL
}

struct FlickrUrlBuilder: UrlBuilder {
    private let defaultParams = "method=flickr.photos.search&format=json&nojsoncallback=1&safe_search=1"
    private let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    var url: URL {
        return URL(string: "https://api.flickr.com/services/rest/?" + defaultParams + "&api_key=" + apiKey)!
    }
    
    func getUrlToDownloadPhoto(farm: Int, server: String, secret: String, id: String) -> URL {
        return URL(string: "https://farm" + String(farm) + ".static.flickr.com/" + server + "/" + id + "_" + secret + ".jpg")!
    }
}
