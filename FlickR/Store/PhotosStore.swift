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
        overallError: false,
        choosedPhoto: nil,
        loading: false,
        serverPageNum: 0,
        searchString: defaultSearchString,
        photoState: PhotosState(items: [])
    ),
    middleware: [printActionsMiddleware,
                 sendServerActionsMiddleware,
                 persistenceMiddleware]
)

// MARK: - Reducers

func mainReducer(action: Action, state: MainState?) -> MainState {
    return MainState(
        overallError: errorReducer(action: action, state: state),
        choosedPhoto: choosedPhotoReducer(action: action, state: state?.choosedPhoto),
        loading: loadingReducer(action: action, state: state?.loading),
        serverPageNum: serverPageNumReducer(action: action, state: state?.serverPageNum),
        searchString: defaultSearchString,
        photoState: photosReducer(action: action, state: state?.photoState)
    )
}

func errorReducer(action: Action, state: MainState?) -> Bool {
    switch action {
    case let errorAction as ErrorOccuredAction:
        return errorAction.error != nil && (state?.photoState.items.count ?? 0) == 0
     case _ as NewPhotosAction:
        return false
    default: break
    }
    
    return state?.overallError ?? false

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
    case let newPhotosAction as NewPhotosAction:
        return newPhotosAction.downloadImages ? state + 1 :  state
    case let setSavedPageNum as SetSavedPageNum:
        return setSavedPageNum.pageNum
    default: break
    }
    
    return state
}

func loadingReducer(action: Action, state: Bool?) -> Bool {
    switch action {
    case _ as LoadingStartedAction: return true
    case _ as LoadingCompletedAction: return false
    default: return state ?? false
    }
}

func photosReducer(action: Action, state: PhotosState?) -> PhotosState {
    var state = state ?? PhotosState(items: [])
    
    switch action {
    case let newPhotosAction as NewPhotosAction:
        state.items.append(contentsOf: newPhotosAction.photos)
    case let newPhotoDownloadedAction as NewPhotoDownloadedAction:
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

// MARK: - Actions

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
    let downloadImages: Bool
}

struct NewPhotoDownloadedAction: Action {
    let photo: Photo
}

struct ChoosePhotoForDetailsAction: Action {
    let photo: Photo
}

struct LoadDataFromPersistentStore: Action {
}

struct SaveDataToPersistentStore: Action {
    let photos: [Photo]
}

struct SetSavedPageNum: Action {
    let pageNum: Int
}

struct ErrorOccuredAction: Action {
    let error: Error?
}

// MARK: - Convenient state getters

func photo(state: MainState?, index: Int) -> Photo? {
    guard let state = state, index < state.photoState.items.count else { return nil }
    
    return state.photoState.items[index]
}
