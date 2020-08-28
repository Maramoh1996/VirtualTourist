//
//  DataController.swift
//  VirtualTourist
//
//  Created by Maram Moh on 14/08/2020.
//  Copyright © 2020 Maram Moh. All rights reserved.
//

import Foundation
import CoreData
class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    let shared = DataController(modelName: "VirualTourist")
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
