//
//  PhotosReducersTests.swift
//  FlickRTests
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import XCTest
import ReSwift

@testable import FlickR

class PhotosReducersTests: XCTestCase {
    func testServerPageNumIncrementReducer() {
        // Given
        let action = NewPhotosAction(photos: [], downloadImages: true)
        let state = 0
        
        // When
        let newState = serverPageNumReducer(action: action, state: state)
        
        // Then
        XCTAssertEqual(newState, state + 1, "Reducer should increment currentPage once newPhotosAction comes from service with attribute downloadImages = TRUE")
    }
    
    func testLoadingStateReducer() {
        // Given
        let loadingStartAction = LoadingStartedAction()
        let loadingCompleteAction = LoadingCompletedAction()
        let state = false
        
        // When
        let newState = loadingReducer(action: loadingStartAction, state: state)
        
        // Then
        XCTAssertTrue(newState, "Reducer should put loading to TRUE once service start loading meta data")
        
        // When
        let newStoppedState = loadingReducer(action: loadingCompleteAction, state: state)
        
        // Then
        XCTAssertFalse(newStoppedState, "Reducer should put loading to FALSE once service stop loading meta data")
    }
    
    func testPhotosReducerAddedNewPhotos() {
        // Given
        let testPhoto = Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
        let action = NewPhotosAction(photos: [testPhoto], downloadImages: false)
        let state = PhotosState(items: [])
        
        // When
        let newState = photosReducer(action: action, state: state)
        
        // Then
        XCTAssertEqual(newState.items.count, 1, "Reducer should add new Photo from action")
        XCTAssertEqual(newState.items[0], testPhoto, "Reducer should add new Photo from action")
    }
    
    func testPhotosReducerUpdateInfoAboutDownloadedPhoto() {
        // Given
        let testPhoto =  Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
        let anotherTestPhoto =  Photo(id: "2", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
        let action = NewPhotoDownloadedAction(photo: anotherTestPhoto)
        let state = PhotosState(items: [testPhoto, anotherTestPhoto])
        
        // When
        let newState = photosReducer(action: action, state: state)
        
        // Then
        XCTAssertFalse(newState.items[0].photoLoaded, "Reducer shouldn't update other photos properties")
        XCTAssertTrue(newState.items[1].photoLoaded, "Reducer should update PhotoLoaded property")
    }
    
    func testOverallErrorReducerShowError() {
         // Given
        let action = ErrorOccuredAction(error: ServerError())
        let state = MainState(
            overallError: false,
            choosedPhoto: nil,
            loading: false,
            serverPageNum: 0,
            searchString: "",
            photoState: PhotosState(items: []))
        
        // When
        let newState = errorReducer(action: action, state: state)
        
        // Then
        XCTAssertTrue(newState, "Reducer should return true as there is no photo and network error occured")
    }
    
    func testOverallErrorReducerDoesntShowErrorWhenThereIsStoragePhoto() {
        // Given
        let action = ErrorOccuredAction(error: ServerError())
        let testPhoto =  Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
        let state = MainState(
            overallError: false,
            choosedPhoto: nil,
            loading: false,
            serverPageNum: 0,
            searchString: "",
            photoState: PhotosState(items: [testPhoto]))
        
        // When
        let newState = errorReducer(action: action, state: state)
        
        // Then
        XCTAssertFalse(newState, "Reducer should return fasle as there is photo from storage")
    }


}
