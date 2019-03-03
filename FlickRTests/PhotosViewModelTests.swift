//
//  PhotosViewModelTests.swift
//  FlickRTests
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import XCTest
import RxSwift
import RxDataSources
import ReSwift
import RxCocoa

@testable import FlickR

class PhotosViewModelTests: XCTestCase {
    var viewModel: PhotoViewModel!
    let disposeBag = DisposeBag()
    let testPhoto =  Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false)
    let anotherTestPhoto = Photo(id: "1", farm: 1, server: "1", secret: "1", title: "222", photoLoaded: false)
    var redux: MockRedux!
    var cache: PhotoCacheMock!
    
    override func setUp() {
        redux = MockRedux()
        cache = PhotoCacheMock()
        
        viewModel = PhotoViewModel(store: redux.photosStore, photoCache: cache)
        viewModel.photos = BehaviorRelay<[PhotosState]>(value: [PhotosState(items: [
            testPhoto
            ])])
    }
    
    override func tearDown() {
        viewModel = nil
        redux = nil
        cache = nil
    }
    
    func testDataSourceSetupCell() {
        // Given
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: UICollectionViewFlowLayout())
        
        let cell = PhotoCellMock()
        let datasource = viewModel.getDataSource(photoCellDequeClosure: { ip in
            return cell
        })
        
        viewModel.photos.asObservable()
            .bind(to: collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        // When
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertEqual(cell.titleWasSet, testPhoto.title)
        XCTAssertEqual(cache.getItemIdWasSet, testPhoto.uniqId)
    }
    
    func testDataSourceSetupDynamiclyAddedCell() {
        // Given
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: UICollectionViewFlowLayout())
        
        let cell = PhotoCellMock()
        let datasource = viewModel.getDataSource(photoCellDequeClosure: { ip in
            return cell
        })
        
        viewModel.photos.asObservable()
            .bind(to: collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        // When
        // Simulate receiving of Photo
        var tempArr = viewModel.photos.value
        tempArr[0].items.append(anotherTestPhoto)
        viewModel.photos.accept(tempArr)

        let itemsCount = datasource.collectionView(collectionView, numberOfItemsInSection: 0)
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 1, section: 0))

        // Then
        XCTAssertEqual(itemsCount, 2)
        XCTAssertEqual(cell.titleWasSet, anotherTestPhoto.title)
    }

    func testDataSourceTriggerNextPageCall() {
        // Given
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: UICollectionViewFlowLayout())
        
        let cell = PhotoCellMock()
        let datasource = viewModel.getDataSource(photoCellDequeClosure: { ip in
            return cell
        })
        
        viewModel.photos.asObservable()
            .bind(to: collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        // Simulate receiving of Photo
        var tempArr = self.viewModel.photos.value
        tempArr[0].items.append(anotherTestPhoto)
        viewModel.photos.accept(tempArr)
        
        // When
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        
        // Then
         XCTAssertTrue(redux.lastAction is LoadDataFromPersistentStore, "Have to trigger LoadDataFromPersistentStore at the start of app")
        
        // When
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 1, section: 0))
        
        // Then
        XCTAssertNotNil(redux.lastAction)
        XCTAssertTrue(redux.lastAction is NextSearchImagesAction, "Have to trigger Next page call when user requests LAST element")
        XCTAssertFalse((redux.lastAction as! NextSearchImagesAction).initialSearch, "Have to trigger Next page call when user requests LAST element")
    }
    
    func testSendChoosedPhotoAction() {
        // Given
        let cellIndex = 1
        let photos = [testPhoto, anotherTestPhoto]
        redux = MockRedux()
        redux.defaultState = MainState(
            overallError: false,
            choosedPhoto: nil,
            loading: false,
            serverPageNum: 0,
            searchString: defaultSearchString,
            photoState: PhotosState(items: photos)
        )        
        viewModel = PhotoViewModel(store: redux.photosStore, photoCache: cache)
        
        // When
        viewModel.tapOnCell(with: cellIndex)
        
        // Then
        XCTAssertTrue(redux.lastAction is ChoosePhotoForDetailsAction)
        XCTAssertEqual((redux.lastAction as! ChoosePhotoForDetailsAction).photo.id, anotherTestPhoto.id)        
    }

    func testDontSendChoosedPhotoActionIfPhotoDoesntExists() {
        // Given
        let cellIndex = 20
        
        // When
        viewModel.tapOnCell(with: cellIndex)
        
        // Then
        XCTAssertFalse(redux.lastAction is ChoosePhotoForDetailsAction)
    }


}
