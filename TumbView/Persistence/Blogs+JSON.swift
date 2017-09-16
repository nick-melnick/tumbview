//
//  File.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import CoreData
import SwiftyJSON

extension Blogs {
    
    func updateFromJSON(_ json:JSON) {
        self.name = json["name"].string
        self.blogDescription = json["description"].string
        self.postsCount = json["posts"].int32Value
        self.primary = json["primary"].boolValue
        self.title = json["title"].string
        self.total_posts = json["total_posts"].int32Value
        self.type = json["type"].string
        self.url = json["url"].string
        self.blogUpdated = json["updated"].int64Value
        self.needLoad = false
    }
    
}
