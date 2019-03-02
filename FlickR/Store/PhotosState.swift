//
//  PhotosState.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation

let defaultSearchString = "kittens"

struct MainState {
    var loading: Bool
    var serverPageNum: Int
    var searchString: String
    var photoState: PhotosState
}

struct PhotosState {
    var items: [Photo]
}

struct Photo {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
    let photoLoaded: Bool
}
