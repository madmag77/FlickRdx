//
//  PhotosState.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation

struct MainState {
    var photoState: PhotosState
}

struct PhotosState {
    var items: [Photo]
}

struct Photo {
    let title: String
    let imageName: String
}
