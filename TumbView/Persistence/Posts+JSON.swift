//
//  Posts+JSON.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import CoreData
import SwiftyJSON

extension Posts {
    
    // TODO: Parse all fields
    
    func updateFromJSON(_ json: JSON) {
        self.id = json["id"].int64Value
        self.blog_name = json["blog_name"].string
        self.caption = json["caption"].string
        self.format = json["format"].string
        self.type = json["type"].string
        self.timestamp = json["timestame"].doubleValue
        self.title = json["title"].string
        self.state = json["state"].string
        self.notes_count = json["notes_count"].int16Value
        self.liked = json["liked"].boolValue
        self.source_title = json["source_title"].string
        self.source_url = json["source_url"].string
        let photosList = self.photos?.allObjects as! [Photos]
        for photoJSON in json["photos"].arrayValue {
            if let orgUrl = photoJSON["original_size"]["url"].string {
                let photo: Photos
                if let founded = photosList.first(where: { $0.original_url == orgUrl }) {
                    photo = founded
                } else {
                    photo = NSEntityDescription.insertNewObject(forEntityName: "Photos", into: self.managedObjectContext!) as! Photos
                }
                photo.updateFromJSON(photoJSON)
            }
        }
        self.needLoad = false
    }
    
}
