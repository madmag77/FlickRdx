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
        choosedPhoto: nil,
        loading: false,
        serverPageNum: 0,
        searchString: defaultSearchString,
        photoState: PhotosState(items: [])
    ),
    middleware: [printActionsMiddleware, sendServerActionsMiddleware]
)

func mainReducer(action: Action, state: MainState?) -> MainState {
    return MainState(
        choosedPhoto: choosedPhotoReducer(action: action, state: state?.choosedPhoto),
        loading: loadingReducer(action: action, state: state?.loading),
        serverPageNum: serverPageNumReducer(action: action, state: state?.serverPageNum),
        searchString: defaultSearchString,
        photoState: photosReducer(action: action, state: state?.photoState)
    )
}

func choosedPhotoReducer(action: Action, state: Photo?) -> Photo? {
    switch action {
    case let choosedPhoto as ChoosePhotoForDetailsAction:
        return choosedPhoto.photo
    default: break
    }
    
    return state
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
    case let newPhotoDownloadedAction as NewPhotoDownloadedAction:
        let uniqId = newPhotoDownloadedAction.photo.uniqId
        if let ind = state.items.firstIndex(where: { photo in
            return photo == newPhotoDownloadedAction.photo
        }) {
            state.items[ind].photoLoaded = true
        }
    default: break
    }
    
    return state
}

extension MainState: StateType {}

struct NextSearchImagesAction: Action {
    let initialSearch: Bool
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

struct NewPhotoDownloadedAction: Action {
    let photo: Photo
}

struct ChoosePhotoForDetailsAction: Action {
    let photo: Photo
}

func photo(state: MainState?, index: Int) -> Photo? {
    guard let state = state, index < state.photoState.items.count else { return nil }
    
    return state.photoState.items[index]
}
