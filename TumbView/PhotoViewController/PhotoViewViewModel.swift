//
//  PhotoViewViewModel.swift
//  TumbView
//
//  Created by Nick Melnick on 9/16/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit

class PhotoViewViewModel: NSObject {
    
    private let coordinator: PhotoViewCoordinator
    private let photo: Photos
    
    init(coordinator: PhotoViewCoordinator, photo: Photos) {
        self.coordinator = coordinator
        self.photo = photo
    }
    
    var imageURL:URL? {
        guard let string = photo.original_url else { return nil }
        return URL(string: string)
    }
    
    var image: UIImage? {
        guard let data = photo.original as Data? else { return nil }
        return UIImage(data: data)
    }
    
    var thumbImage: UIImage? {
        guard let data = photo.thumb as Data? else { return nil }
        return UIImage(data: data)
    }
    
    func saveOriginalImage(_ image: UIImage) {
        
        if let data = image.sd_imageData() as NSData? {
            let context = CoreDataStack.sharedStack.backgroundManagedObjectContext
            let photoID = photo.objectID
            context.perform {
                let photo = context.object(with: photoID) as! Photos
                photo.original = data
                do {
                    try context.save()
                } catch let err as NSError {
                    print(err)
                }
            }
        }
    }

}
