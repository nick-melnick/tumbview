//
//  TumblrAPIProvider.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import OAuthSwift

open class TumblrAuth: ProviderOAuth1 {
    open var consumerKey: String
    open var consumerSecret: String
    open var callbackUrl: URL
    
    open var requestTokenUrl: String = "https://www.tumblr.com/oauth/request_token"
    open var authorizeUrl: String = "https://www.tumblr.com/oauth/authorize"
    open var accessTokenUrl: String = "https://www.tumblr.com/oauth/access_token"

    required public init(consumerKey: String, consumerSecret: String, callbackUrl: URL) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.callbackUrl = callbackUrl
    }

}
