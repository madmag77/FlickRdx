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
@testable import FlickR

class PhotosViewModelTests: XCTestCase {
    var viewModel: PhotoViewModel!
    let disposeBag = DisposeBag()
    let testPhoto = Photo(title: "testPhoto", imageName: "sss")
    let anotherTestPhoto = Photo(title: "anotherTestPhoto", imageName: "ggg")

    override func setUp() {
        viewModel = PhotoViewModel()
        viewModel.photos = Variable<[PhotosState]>([PhotosState(items: [
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
        viewModel.photos.value = tempArr
        
        let itemsCount = datasource.collectionView(collectionView, numberOfItemsInSection: 0)
        _ = datasource.collectionView(collectionView, cellForItemAt: IndexPath(row: 1, section: 0))

        // Then
        XCTAssertEqual(itemsCount, 2)
        XCTAssertEqual(cell.titleWasSet, anotherTestPhoto.title)
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
