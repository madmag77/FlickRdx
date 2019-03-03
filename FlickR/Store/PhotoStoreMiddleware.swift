//
//  PhotoStoreMiddleware.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import ReSwift

func printActionsMiddleware<T>(_ directDispatch: @escaping DispatchFunction, _ getState: @escaping () -> T?) -> ((@escaping DispatchFunction) -> DispatchFunction) {
    let t: T? = nil
    return { nextDispatch in
        return {action in
            print("\(type(of: t)): \(type(of: action))")
            nextDispatch(action)
        }
    }
}

func sendServerActionsMiddleware(_ directDispatch: @escaping DispatchFunction, _ getState: @escaping () -> MainState?) -> ((@escaping DispatchFunction) -> DispatchFunction) {
    return { nextDispatch in
        
        // TODO: Use protocols here and inject implementation from outside
        let apiService = FlickrApiServiceImpl(directDispatch: directDispatch)
        let imageDownloadService = PhotoDownloadFlickrWebService(directDispatch: directDispatch)
        
        return {action in
            guard let state = getState() else {
                fatalError("State definitely should be here")
            }
            
            switch action {
            case let nextSearchImagesAction as NextSearchImagesAction:
                if !state.loading { // we want to request one page in a time
                    directDispatch(LoadingStartedAction())
                    guard !nextSearchImagesAction.initialSearch else {
                        apiService.searchPhotos(with: state.searchString, page: 0)
                        return
                    }
                    
                    apiService.searchPhotos(with: state.searchString, page: state.serverPageNum + 1)
                }
                break
                
            case let newPhotosAction as NewPhotosAction:
                newPhotosAction.photos.forEach({ photo in
                    imageDownloadService.downloadPhoto(for: photo)
                })
                directDispatch(SaveDataToPersistentStore())
                nextDispatch(action)
                break

            default:
                nextDispatch(action)
            }
        }
    }
}
