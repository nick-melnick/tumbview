//
//  CoreDataStack.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import CoreData

let dbName = "TumbView"
final class CoreDataStack {
    static let sharedStack = CoreDataStack()
    var errorHandler: (Error) -> Void = {_ in }
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.managedObjectContext)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bgContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.backgroundManagedObjectContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var libraryDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: dbName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:
            self.managedObjectModel)
        let url = self.libraryDirectory.appendingPathComponent("\(dbName).sqlite")
        do {
            try coordinator.addPersistentStore(ofType:
                NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: [
                                                NSMigratePersistentStoresAutomaticallyOption: true,
                                                NSInferMappingModelAutomaticallyOption: true
                ]
            )
        } catch {
            // Report any error we got.
            NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
            self.errorHandler(error)
        }
        return coordinator
    }()
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.persistentStoreCoordinator = coordinator
        return privateManagedObjectContext
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.persistentStoreCoordinator = coordinator
        return mainManagedObjectContext
    }()
    
    @objc func mainContextChanged(notification: NSNotification) {
        print("Main Context Changed")
        backgroundManagedObjectContext.perform { [unowned self] in
            self.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    @objc func bgContextChanged(notification: NSNotification) {
        print("Background Context Changed")
        managedObjectContext.perform{ [unowned self] in
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
}
