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
import RxCocoa

protocol ConfigurablePhotoCell {
    func configure(title: String, photo: UIImage?)
}

final class PhotoViewModel {
    private var dataSource: RxCollectionViewSectionedReloadDataSource<PhotosState>?
    private var store: Store<MainState>?
    private let photoCache: PhotoCache
    
    var photos = BehaviorRelay<[PhotosState]>(value: [PhotosState(items: [])])
    var loading = BehaviorRelay<Bool>(value: false)
    var overallError = BehaviorRelay<Bool>(value: false)

    init(store: Store<MainState>?,
         photoCache: PhotoCache = defaultCacheToUse) {
        
        self.photoCache = photoCache
        self.store = store
        self.store?.subscribe(self) { subcription in
            return subcription.select { state in
                return state
            }
        }
        
        self.store?.dispatch(LoadDataFromPersistentStore())
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
                    title: item.title,
                    photo: self.photoCache.photo(for: item.uniqId)()
                )
                
                if ip.item == ds[ip.section].items.count - 1 {
                    self.store?.dispatch(NextSearchImagesAction(initialSearch: false))
                }
                
                return cell
        })
        
        return dataSource!
    }
    
    func tapOnCell(with index: Int) {
        guard let photoToShowDetailsFor = photo(state: store?.state, index: index) else {
            // TODO: logging?
            return
        }
        store?.dispatch(ChoosePhotoForDetailsAction(photo: photoToShowDetailsFor))
    }
}

extension PhotoViewModel: StoreSubscriber {
    func newState(state: MainState) {
        DispatchQueue.main.async {
            self.photos.accept([state.photoState])
            self.loading.accept(state.loading)
            self.overallError.accept(state.overallError)
        }
    }
}
