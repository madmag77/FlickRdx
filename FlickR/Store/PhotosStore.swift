//
//  PhotosStore.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import ReSwift

let photosStore: Store<MainState> = Store<MainState> (
    reducer: mainReducer,
    state: MainState(photoState: PhotosState(items: [Photo(title: "111", imageName: "sss"),
                                                     Photo(title: "222", imageName: "sss"),
                                                     Photo(title: "333", imageName: "sss"),
                                                     Photo(title: "4444", imageName: "sss"),
                                                     Photo(title: "5555", imageName: "sss"),
                                                     ])),
    middleware: []
)

func mainReducer(action: Action, state: MainState?) -> MainState {
    return MainState(
        photoState: photosReducer(action: action, state: state?.photoState)
    )
}

extension MainState: StateType {}

func photosReducer(action: Action, state: PhotosState?) -> PhotosState {
    return state ?? PhotosState(items: [])
}
