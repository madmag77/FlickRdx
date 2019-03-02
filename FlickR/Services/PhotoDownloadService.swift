//
//  PhotoDownloadService.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoDownloadServiceDelegate: class {
    func justDownloadedImage(_ image: UIImage, for id: String)
    func errorOccured(_ error: Error)
}

protocol PhotoDownloadService {
    var delegate: PhotoDownloadServiceDelegate? {get set}
    func downloadPhoto(for model: RemotePhotoModel)
}

class PhotoDownloadFlickrWebService: PhotoDownloadService {
    weak var delegate: PhotoDownloadServiceDelegate?
    
    // TODO: Inject session via protocol in order to make this class testable
    private let urlSession = URLSession.shared
    private let urlBuilder: UrlBuilder
    
    init(urlBuilder: UrlBuilder) {
        self.urlBuilder = urlBuilder
    }
    
    public func downloadPhoto(for model: RemotePhotoModel) {
        
        let url = urlBuilder.getUrlToDownloadPhoto(farm: model.farm,
                                                   server: model.server,
                                                   secret: model.secret,
                                                   id: model.id)
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                // TODO think how log errors and show to user
                return
            }
            
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data else {
                    // TODO think how log errors and show to user
                    return
            }
            
            guard let image = UIImage(data: data) else {
                // TODO think how log errors and show to user
                return
            }
            
            self.delegate?.justDownloadedImage(image, for: model.id)
            
        }.resume()
    }
}
