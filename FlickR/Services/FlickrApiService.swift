//
//  FlickrApiService.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import ReSwift

class ServerError: Error {
    var localizedDescription = "Server returns error"
}

class SearchInputError: Error {
    var localizedDescription = "Search string is invalid"
}

class ParseError: Error {
    var localizedDescription = "Search returns unreadable data"
}

protocol PhotoSearchServiceDelegate: class {
    func photosFound(_ photoModels: [Photo])
    func errorOccured(_ error: Error)
}

protocol FlickrApiService {
    func searchPhotos(with phrase: String, page: Int)
}

protocol URLSessionDataTaskable {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionDataTaskable {}

class FlickrApiServiceImpl: FlickrApiService {    
    private let urlSession: URLSessionDataTaskable
    private let urlBuilder: UrlBuilder
    private let parser: FlickrParser
    private let directDispatch: DispatchFunction?
    
    init(directDispatch: @escaping DispatchFunction,
         urlSession: URLSessionDataTaskable = URLSession.shared,
         urlBuilder: UrlBuilder = FlickrUrlBuilder(),
         parser: FlickrParser = FlickrParserImpl()) {
        self.urlBuilder = urlBuilder
        self.parser = parser
        self.directDispatch = directDispatch
        self.urlSession = urlSession
    }
    
    func searchPhotos(with phrase: String, page: Int) {
        guard let urlWithPhrase = URL(string: urlBuilder.url.absoluteString + "&text=" + phrase + "&page=" + String(page)) else {
            print("search error")
            self.directDispatch?(LoadingCompletedAction())
            return
        }
        
        urlSession.dataTask(with: urlWithPhrase) { (data, response, error) in
            if let error = error {
                print("network error")
                self.directDispatch?(LoadingCompletedAction())
                return
            }
            
            // Check if server returns not 200
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data else {
                    print("server error")
                    self.directDispatch?(LoadingCompletedAction())
                    return
            }
            
            let (parserError, photoModels) = self.parser.parseServerResponse(data: data)
            
            guard parserError == nil else {
                print("parse error")
                self.directDispatch?(LoadingCompletedAction())
                return
            }
            
            self.directDispatch?(NewPhotosAction(photos: photoModels))
            self.directDispatch?(LoadingCompletedAction())
        }.resume()
    }
}
