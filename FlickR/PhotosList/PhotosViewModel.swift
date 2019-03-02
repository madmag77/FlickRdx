//
//  PhotosViewModel.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

protocol ConfigurablePhotoCell {
    func configure(title: String, photo: UIImage?)
}

final class PhotoViewModel {
    private var dataSource: RxCollectionViewSectionedReloadDataSource<PhotosState>?
    var photos = Variable<[PhotosState]>([PhotosState(items: [
        Photo(title: "111", imageName: "sss"),
        Photo(title: "222", imageName: "sss"),
        Photo(title: "333", imageName: "sss"),
        Photo(title: "4444", imageName: "sss"),
        Photo(title: "5555", imageName: "sss"),
        ])])
    
    
    func getDataSource(photoCellDequeClosure: @escaping (IndexPath) -> (UICollectionViewCell?)) -> RxCollectionViewSectionedReloadDataSource<PhotosState> {
        
        dataSource = RxCollectionViewSectionedReloadDataSource<PhotosState>(
            configureCell:
            { (ds: CollectionViewSectionedDataSource<PhotosState>, cv: UICollectionView, ip: IndexPath, item: PhotosState.Item) in
                guard let cell = photoCellDequeClosure(ip) else {
                    fatalError("Cell wasn't created properly")
                }
                
                guard let cellToConfigure = cell as? ConfigurablePhotoCell else  {
                    fatalError("Cell can't be casted to ConfigurablePhotoCell")
                }
                
                cellToConfigure.configure(
                    title: ds[ip.section].items[ip.item].title,
                    photo: nil // TODO: add getting image from cache
                )
                
                return cell
        })
        
        return dataSource!
    }
}
