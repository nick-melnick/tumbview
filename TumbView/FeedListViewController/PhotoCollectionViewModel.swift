//
//  PhotoCellViewModel.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCellViewModel: CellRepresentable {

    fileprivate let photo:Photos
    
    init(photo: Photos) {
        self.photo = photo
    }
    
    var likesCount: Int {
        return Int(photo.post?.notes_count ?? 0)
    }
    
    var thumbURL: URL? {
        return URL(string: photo.thumb_url!)
    }
    
    var thumbImage: UIImage? {
        guard let thumbData = self.photo.thumb as? Data else { return nil }

        return UIImage(data: thumbData)
    }
    
    func saveImage(imageData:Data) {
        let photoID = self.photo.objectID
        let context = CoreDataStack.sharedStack.backgroundManagedObjectContext
        let photo = context.object(with: photoID) as! Photos
        photo.thumb = imageData as NSData
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func cellInstance(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.setup(withViewModel: self)
        return cell
    }
    
}
