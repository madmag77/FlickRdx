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
import ReSwift

protocol ConfigurablePhotoCell {
    func configure(title: String, photo: UIImage?)
}

final class PhotoViewModel {
    private var dataSource: RxCollectionViewSectionedReloadDataSource<PhotosState>?
    private var store: Store<MainState>?
   
    var photos = Variable<[PhotosState]>([PhotosState(items: [])])

    init(store: Store<MainState>?) {
        self.store = store
        self.store?.subscribe(self) { subcription in
            return subcription.select { state in
                return state.photoState
            }
        }
    }
    
    deinit {
        store?.unsubscribe(self)
    }
    
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

extension PhotoViewModel: StoreSubscriber {
    func newState(state: PhotosState) {
        self.photos.value = [state]
    }
}
