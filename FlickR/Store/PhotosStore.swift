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
    state: MainState(
        loading: false,
        serverPageNum: 0,
        searchString: defaultSearchString,
        photoState: PhotosState(items: testData)
    ),
    middleware: [printActionsMiddleware, sendServerActionsMiddleware]
)

let testData = [
    Photo(id: "1", farm: 1, server: "1", secret: "1", title: "111", photoLoaded: false),
    Photo(id: "2", farm: 1, server: "1", secret: "1", title: "222", photoLoaded: false),
    Photo(id: "3", farm: 1, server: "1", secret: "1", title: "333", photoLoaded: false),
    Photo(id: "4", farm: 1, server: "1", secret: "1", title: "444", photoLoaded: false),
]

func mainReducer(action: Action, state: MainState?) -> MainState {
    return MainState(
        loading: loadingReducer(action: action, state: state?.loading),
        serverPageNum: serverPageNumReducer(action: action, state: state?.serverPageNum),
        searchString: defaultSearchString,
        photoState: photosReducer(action: action, state: state?.photoState)
    )
}

func serverPageNumReducer(action: Action, state: Int?) -> Int {
    let state = state ?? 0
    
    switch action {
    case _ as NewPhotosAction:
        return state + 1
    default: break
    }
    
    return state
}

func loadingReducer(action: Action, state: Bool?) -> Bool {
    switch action {
    case _ as LoadingStartedAction: return true
    case _ as LoadingCompletedAction: return false
    default: return false
    }
}

func photosReducer(action: Action, state: PhotosState?) -> PhotosState {
    var state = state ?? PhotosState(items: [])
    
    switch action {
    case let newPhotosAction as NewPhotosAction:
        state.items.append(contentsOf: newPhotosAction.photos)
    default: break
    }
    
    return state
}

extension MainState: StateType {}

struct NextSearchImagesAction: Action {
}

struct DownloadImageAction: Action {
    let photo: Photo
}

struct ServerErrorAction: Action {
    let error: Error
}

struct LoadingStartedAction: Action {
}

struct LoadingCompletedAction: Action {
}

struct NewPhotosAction: Action {
    let photos: [Photo]
}
