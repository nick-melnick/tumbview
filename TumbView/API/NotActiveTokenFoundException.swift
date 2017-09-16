//
//  NotActiveTokenFoundException.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import Foundation

open class NotActiveTokenFoundException {
    
    // FIXME: Error code and userInfo for details
    open static let error = NSError(domain: "There is no active token for the provider requested", code: -1, userInfo: nil)
    
}

