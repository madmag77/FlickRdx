//
//  CoreDataStorage.swift
//  FlickR
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import CoreData
import ReSwift

func persistenceMiddleware(_ directDispatch: @escaping DispatchFunction, _ getState: @escaping () -> MainState?) -> ((@escaping DispatchFunction) -> DispatchFunction) {
    return { nextDispatch in
        
        return {action in
            guard let state = getState() else {
                fatalError("State definitely should be here")
            }
            
            switch action {
            case _ as LoadDataFromPersistentStore:
                    directDispatch(LoadingStartedAction())
                    if loadData(directDispatch: directDispatch) { // If storage is empty - load from network
                        directDispatch(NextSearchImagesAction(initialSearch: true))
                    }
                break
                
            case let saveAction as SaveDataToPersistentStore:
                saveData(photos: saveAction.photos, pageNum: state.serverPageNum + 1)
                break
                
            default:
                nextDispatch(action)
            }
        }
    }
}

/// Returns whether the storage is empty
fileprivate func loadData(directDispatch: @escaping DispatchFunction) -> Bool {
    let context = persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntity")
    request.returnsObjectsAsFaults = false
    var emptyStorage = true
    
    let requestAppParams = NSFetchRequest<NSFetchRequestResult>(entityName: "AppParams")
    requestAppParams.returnsObjectsAsFaults = false
   
    
    do {
        let resultAppParams = try context.fetch(requestAppParams) as! [NSManagedObject]
        
        if resultAppParams.count > 0,
            let pageNum = resultAppParams[0].value(forKey: "serverPageNum") as? Int {
            directDispatch(SetSavedPageNum(pageNum: pageNum))
        }
        
        let result = try context.fetch(request) as! [NSManagedObject]
        
        let photoModels = result.map({ (entity: NSManagedObject) -> (Photo) in
            return Photo(id: entity.value(forKey: "id") as! String,
                         farm: entity.value(forKey: "farm") as! Int,
                         server: entity.value(forKey: "server") as! String,
                         secret: entity.value(forKey: "secret") as! String,
                         title: entity.value(forKey: "title") as! String,
                         photoLoaded: entity.value(forKey: "photoLoaded") as! Bool)
        })
        
        emptyStorage = photoModels.isEmpty
    
        directDispatch(NewPhotosAction(photos: photoModels, downloadImages: false))
        
    } catch {
        // TODO: publish Error Action
        print("CoreData loadData - Failed")
    }
    directDispatch(LoadingCompletedAction())
    
    return emptyStorage
}

// We want to dave data in background in order don't impact user experience
// Serial queue helps to save in strict order
fileprivate let saveSerialQueue = DispatchQueue(label: "SaveSerialQueue")

fileprivate func saveData(photos: [Photo], pageNum: Int) {
    saveSerialQueue.async {
        let context = persistentContainer.newBackgroundContext()
        let entity = NSEntityDescription.entity(forEntityName: "PhotoEntity", in: context)
        
        photos.forEach({ photo in
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(photo.id, forKey: "id")
            newEntity.setValue(photo.farm, forKey: "farm")
            newEntity.setValue(photo.server, forKey: "server")
            newEntity.setValue(photo.secret, forKey: "secret")
            newEntity.setValue(photo.title, forKey: "title")
            newEntity.setValue(photo.photoLoaded, forKey: "photoLoaded")
        })
        
        do {
            try context.save()
        } catch {
            // TODO: publish Error Action
            print("CoreData saveData - Failed")
        }
        
        // Save PageNum (in Flickr API) so next time app loads we start downloading from the proper Page
        do {
            // Load PageNum from store first
            let requestAppParams = NSFetchRequest<NSFetchRequestResult>(entityName: "AppParams")
            requestAppParams.returnsObjectsAsFaults = false
            let resultAppParams = try context.fetch(requestAppParams) as! [NSManagedObject]
            
            // Update or insert depends on loading result
            if resultAppParams.count > 0,
                let _ = resultAppParams[0].value(forKey: "serverPageNum") as? Int {
                resultAppParams[0].setValue(pageNum, forKey: "serverPageNum")
            } else {
                let appParams = NSEntityDescription.entity(forEntityName: "AppParams", in: context)
                let pageNumEntity = NSManagedObject(entity: appParams!, insertInto: context)
                pageNumEntity.setValue(pageNum, forKey: "serverPageNum")
            }
            
            try context.save()
        } catch {
            // TODO: publish Error Action
            print("CoreData saveData - Failed")
        }
    }
}


fileprivate var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "FlickR")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support

fileprivate func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
