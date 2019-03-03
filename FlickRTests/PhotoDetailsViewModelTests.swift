//
//  PhotoDetailsViewModelTests.swift
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
import RxBlocking

@testable import FlickR

class PhotoDetailsViewModelTests: XCTestCase {
    var viewModel: PhotoDetailsViewModel!
    let disposeBag = DisposeBag()
    let testPhoto =  Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
    var redux: MockRedux!
    var cache: PhotoCacheMock!
    
    override func setUp() {
        redux = MockRedux()
        redux.defaultState = MainState(
            choosedPhoto: testPhoto,
            loading: false,
            serverPageNum: 0,
            searchString: defaultSearchString,
            photoState: PhotosState(items: [])
        )

        cache = PhotoCacheMock()
        
        viewModel = PhotoDetailsViewModel(store: redux.photosStore, photoCache: cache)
    }
    
    override func tearDown() {
        viewModel = nil
        redux = nil
        cache = nil
    }
    
    func testViewModelProvidesChoosedImageFromCache() throws {
        // Given
        cache.photoToReturn = UIImage()
        
        // When
        let choosedPhoto = try viewModel.photo.toBlocking().first()
        
        // Then
        XCTAssertEqual(choosedPhoto!, cache.photoToReturn!)
        XCTAssertEqual(cache.getItemIdWasSet, testPhoto.uniqId)
    }
    
    func testViewModelProvidesChoosedTitle() throws {
        // Given
        
        // When
        let choosedTitle = try viewModel.photoTitle.toBlocking().first()
        
        // Then
        XCTAssertEqual(choosedTitle, testPhoto.title)
    }

}

