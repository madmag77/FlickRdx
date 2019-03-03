//
//  CommonMocks.swift
//  FlickRTests
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//


import XCTest
import RxSwift
import RxDataSources
import ReSwift
import RxCocoa

@testable import FlickR

class PhotoCellMock: UICollectionViewCell, ConfigurablePhotoCell {
    var titleWasSet: String?
    var imageWasSet: UIImage?
    
    func configure(title: String, photo: UIImage?) {
        titleWasSet = title
        imageWasSet = photo
    }
}

class MockRedux {
    var lastAction: Action?
    
    var defaultState = MainState(
        overallError: false,
        choosedPhoto: nil,
        loading: false,
        serverPageNum: 0,
        searchString: defaultSearchString,
        photoState: PhotosState(items: [])
    )
    
    lazy var photosStore: Store<MainState> = Store<MainState> (
        reducer: getMockReducer(),
        state: defaultState,
        middleware: []
    )
    
    func getMockReducer() -> (Action, MainState?) -> MainState {
        return { (action: Action, state: MainState?) -> MainState in
            self.lastAction = action
            return state ?? MainState(
                overallError: false,
                choosedPhoto: nil,
                loading: false,
                serverPageNum: 0,
                searchString: "",
                photoState: PhotosState(items: []))
        }
    }
}

class PhotoCacheMock: PhotoCache {
    static var sharedInstance: PhotoCache = PhotoCacheMock()
    
    var photoToReturn: UIImage?
    var setItemIdWasSet: String?
    var getItemIdWasSet: String?
    
    func photo(for itemId: String) -> () -> UIImage? {
        getItemIdWasSet = itemId
        return {
            return self.photoToReturn
        }
    }
    
    func setPhoto(_ image: UIImage, for itemId: String) {
        setItemIdWasSet = itemId
    }
    
    func clearCache() {
        
    }
}

class URLSessionMock: URLSessionDataTaskable {
    var dataToReturn: Data?
    var urlResponseToReturn: URLResponse?
    var errorToReturn: Error?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(dataToReturn, urlResponseToReturn, errorToReturn)
        return URLSessionDataTaskMock()
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    override func resume() {}
}

class URLBuilderMock: UrlBuilder {
    var url: URL
    
    func getUrlToDownloadPhoto(farm: Int, server: String, secret: String, id: String) -> URL {
        return url
    }
    
    init(url: URL) {
        self.url = url
    }
}

class FlickeParserMock: FlickrParser {
    var errorToReturn: Error?
    var modelsToReturn: [Photo] = []
    
    func parseServerResponse(data: Data) -> (error: Error?, models: [Photo]) {
        return (errorToReturn, modelsToReturn)
    }
}
