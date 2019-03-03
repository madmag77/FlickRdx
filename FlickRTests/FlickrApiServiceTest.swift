//
//  FlickrApiServiceTest.swift
//  FlickRTests
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import XCTest
import ReSwift

@testable import FlickR

class FlickrApiServiceTest: XCTestCase {
    var viewModel: FlickrApiServiceImpl!
    var urlSessionMock: URLSessionMock!
    var urlBuilderMock: URLBuilderMock!
    var dispatchedActions: [Action] = []
    var parserMock: FlickeParserMock!
    let testPhoto =  Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)

    let mockedUrl: URL = URL(string: "www.ggg.ccc")!
    
    override func setUp() {
        urlSessionMock = URLSessionMock()
        urlBuilderMock = URLBuilderMock(url: mockedUrl)
        parserMock = FlickeParserMock()
        viewModel = FlickrApiServiceImpl(directDispatch: { action in
            self.dispatchedActions.append(action)
        },
                                         urlSession: urlSessionMock,
                                         urlBuilder: urlBuilderMock,
                                         parser: parserMock)
    }
    
    override func tearDown() {
        viewModel = nil
        parserMock = nil
        urlBuilderMock = nil
        urlSessionMock = nil
    }
    
    func testServiceReturnModels() {
        // Given
        let models = [testPhoto]
        let httpStatusCode = 200
        
        urlSessionMock.dataToReturn = Data(bytes: [1,1,1])
        urlSessionMock.urlResponseToReturn = HTTPURLResponse(url: mockedUrl, statusCode: httpStatusCode, httpVersion: "", headerFields: nil)
        parserMock.modelsToReturn = models
        
        // When
        viewModel.searchPhotos(with: "", page: 0)
        
        // Then
        XCTAssertEqual(dispatchedActions.count, 2, "Service should publich 1. action with new photos from Flickr and 2. stopLoading action")
        XCTAssertTrue(dispatchedActions[0] is NewPhotosAction, "Service should publich 1. action with new photos from Flickr and 2. stopLoading action")
        XCTAssertTrue(dispatchedActions[1] is LoadingCompletedAction, "Service should publich 1. action with new photos from Flickr and 2. stopLoading action")
        XCTAssertEqual((dispatchedActions[0] as! NewPhotosAction).photos[0], testPhoto, "Service should publich NewPhotosAction with new photos")
    }
    
    func testServiceReturnNothingIfHttpError() {
        // Given
        let models = [testPhoto]
        let httpStatusCode = 500
        
        urlSessionMock.dataToReturn = Data(bytes: [1,1,1])
        urlSessionMock.urlResponseToReturn = HTTPURLResponse(url: mockedUrl, statusCode: httpStatusCode, httpVersion: "", headerFields: nil)
        parserMock.modelsToReturn = models
        
        // When
        viewModel.searchPhotos(with: "", page: 0)
        
        // Then
        XCTAssertEqual(dispatchedActions.count, 1, "Service should publich only stopLoading action in case error")
        XCTAssertTrue(dispatchedActions[0] is LoadingCompletedAction, "Service should publich only stopLoading action in case error")
    }

    // TODO: implement more tests for all exception paths
    
}
