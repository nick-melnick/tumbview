//
//  FeedListViewModel.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import CoreData
import SwiftyJSON

class FeedListViewModel: NSObject {
    
    fileprivate let tumblrApi = TumblrAPI()
    
    fileprivate let coordinator: FeedListCoordinator!
    
    init(coordinator: FeedListCoordinator, fetchControllerDelegate: NSFetchedResultsControllerDelegate) {
        self.coordinator = coordinator
        self.fetchController.delegate = fetchControllerDelegate
    }
    
    fileprivate var fetchController: NSFetchedResultsController<Photos> = {
        let sortDescriptor = NSSortDescriptor(key: "post.timestamp", ascending: true)
        let request = NSFetchRequest<Photos>(entityName: "Photos")
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
        } catch let error as NSError {
            print(error)
        }
        return controller
    }()
    
    // MARK: - DataSource
    func numberOfSections() -> Int {
        let count = fetchController.sections?.count ?? 0
        return count
    }
    
    func itemsIn(section: Int) -> Int {
        guard (fetchController.sections?.count)! > 0 else {
            return 0
        }
        if let sectionInfo = fetchController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func itemFor(collectionView:UICollectionView, forCellAtIndexPath indexPath:IndexPath) -> UICollectionViewCell {
        let photo = fetchController.object(at: indexPath)
        let cellViewModel = PhotoCellViewModel(photo: photo)
        return cellViewModel.cellInstance(collectionView, indexPath: indexPath)
    }

    // MARK: - Get New data
    
    /// Get new post in dashboard in background context
    func getNewPosts() {
        let updateContext = CoreDataStack.sharedStack.backgroundManagedObjectContext
        getPostsRequest()
            .subscribe(onSuccess: { (posts) in
                updateContext.perform {
                    let foundedPosts: [Posts]
                    do {
                        foundedPosts = try updateContext.fetch(Posts.fetchRequest())
                    } catch let error as NSError {
                        print(error)
                        foundedPosts = [Posts]()
                    }
                    for postJSON in posts {
                        let post: Posts
                        if let foundedPost = foundedPosts.first(where: { $0.id == postJSON["id"].int64Value }) {
                            post = foundedPost
                        } else {
                            post = NSEntityDescription.insertNewObject(forEntityName: "Posts", into: updateContext) as! Posts
                        }
                        post.updateFromJSON(postJSON)
                    }
                    if updateContext.hasChanges {
                        if updateContext.insertedObjects.count > 0 {
                            print("Inserted: \(updateContext.insertedObjects.count)")
                        }
                        if updateContext.updatedObjects.count > 0 {
                            print("Updated: \(updateContext.updatedObjects.count)")
                        }
                        if updateContext.deletedObjects.count > 0 {
                            print("Deleted: \(updateContext.deletedObjects.count)")
                        }
                        do {
                            try updateContext.save()
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            }, onError: { error in
                
            })
            .addDisposableTo(disposeBag)
    }
    
    
    /// Request posts from dashboard
    ///
    /// - Parameters:
    ///   - type: Type of requested posts
    ///   - offset: Offset from start (field for pagination)
    ///   - sinceID: Alternative way getting old posts from specified post ID
    /// - Returns: Single trait with array of JSON
    private func getPostsRequest(type: TumblrPostsType = .photo, offset: Int = 0, sinceID: Int = 0) -> Single<[JSON]> {
        return Single<[JSON]>.create { [weak self] single in
            guard let me = self else {
                return Disposables.create {}
            }
            
            return me.tumblrApi.getDashboard(withType: type, offset: offset, sinceID: sinceID)
                .subscribe(onSuccess: { (response) in
                    let json = JSON(response.data)
                    if let posts = json["response"]["posts"].array {
                        single(.success(posts))
                    } else {
                        // TODO: Parse error and unsuccessful requests
                        single(.error(TumblrAPIError.cantParseJSON))
                    }
                }, onError: { (error) in
                    single(.error(error))
                })
        }
    }
    
}
