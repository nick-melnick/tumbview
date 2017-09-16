//
//  Photos+JSON.swift
//  TumbView
//
//  Created by Nick Melnick on 9/16/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import CoreData
import SwiftyJSON

extension Photos {
    
    func updateFromJSON(_ json: JSON) {
        self.caption = json["caption"].string
        self.original_height = json["original_size"]["height"].doubleValue
        self.original_width = json["original_size"]["width"].doubleValue
        self.original_url = json["original_size"]["url"].string
        if let list = json["alt_sizes"].array {
            for item in list {
                if item["width"].int16Value < 400 {
                    self.thumb_url = item["url"].string
                    self.thumb_width = item["width"].int16Value
                    self.thumb_height = item["height"].int16Value
                    break
                }
            }
        }
    }
    
}
