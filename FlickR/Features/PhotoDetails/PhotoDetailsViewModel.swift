//
//  PhotoDetailsViewModel.swift
//  FlickR
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift

final class PhotoDetailsViewModel {
    private let store: Store<MainState>?
    private let photoCache: PhotoCache
    
    lazy var photoTitle: Observable<String> = Observable<String>.just(store?.state.choosedPhoto?.title ?? "")
    lazy var photo: Observable<UIImage?> = Observable<UIImage?>.just(
        photoCache.photo(for: store?.state.choosedPhoto?.uniqId ?? "")())

    init(store: Store<MainState>?,
         photoCache: PhotoCache = PhotoCacheInMemory.sharedInstance) {
        self.photoCache = photoCache
        self.store = store
    }
}
