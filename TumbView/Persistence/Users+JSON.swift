//
//  Users+JSON.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import CoreData
import SwiftyJSON

extension Users {
    
    func updateFromJSON(_ json: JSON) {
        self.name = json["name"].string
        self.likes = json["likes"].int32Value
        self.following = json["following"].int32Value
        self.default_post_format = json["default_post_format"].string
        let blogsData = json["blogs"].arrayValue
        let allBlogs = self.blogs?.allObjects as! [Blogs]
        var blogNamesList:[String] = allBlogs.map { $0.name ?? "" }.filter({ $0 != ""})
        for blogData in blogsData {
            if let blogName = blogData["name"].string {
                let blog:Blogs
                if blogNamesList.contains(blogName) {
                    blog = allBlogs.first(where: { $0.name == blogName })!
                    blogNamesList.remove(at: blogNamesList.index(of: blogName)!)
                } else {
                    blog = NSEntityDescription.insertNewObject(forEntityName: "Blogs", into: managedObjectContext!) as! Blogs
                }
                blog.updateFromJSON(blogData)
            }
        }
        for blogName in blogNamesList {
            if let blog = allBlogs.first(where: {$0.name == blogName}) {
                removeFromBlogs(blog)
            }
        }
        
    }
}
