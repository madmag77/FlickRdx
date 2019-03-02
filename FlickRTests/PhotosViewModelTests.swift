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
    
    override func setUp() {
        redux = MockRedux()
        viewModel = PhotoViewModel(store: redux.photosStore)
        viewModel.photos = BehaviorRelay<[PhotosState]>(value: [PhotosState(items: [
            testPhoto
            ])])
    }
    
    override func tearDown() {
        viewModel = nil
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
        var tempArr = self.viewModel.photos.value
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

        var tempArr = self.viewModel.photos.value
        tempArr[0].items.append(anotherTestPhoto)
        viewModel.photos.accept(tempArr)
        
        // When
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertNil(redux.lastAction, "Don't have to triffer Next page call when user requests first element")
        
        // When
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 1, section: 0))
        
        // Then
        XCTAssertNotNil(redux.lastAction)
        XCTAssertTrue(redux.lastAction is NextSearchImagesAction, "Have to triffer Next page call when user requests LAST element")
    }

}

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
        loading: false,
        serverPageNum: 0,
        searchString: defaultSearchString,
        photoState: PhotosState(items: testData)
    )
    
    lazy var photosStore: Store<MainState> = Store<MainState> (
        reducer: getMockReducer(),
        state: defaultState,
        middleware: []
    )

    func getMockReducer() -> (Action, MainState?) -> MainState {
        return { (action: Action, state: MainState?) -> MainState in
            self.lastAction = action
            return state ?? MainState(loading: false,
                                      serverPageNum: 0,
                                      searchString: "",
                                      photoState: PhotosState(items: []))
        }
    }
}
