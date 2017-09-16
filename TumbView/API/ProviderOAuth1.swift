//
//  ProviderOAuth1.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import OAuthSwift

public protocol ProviderOAuth {
    
}

public protocol ProviderOAuth1: ProviderOAuth {
    
    var consumerKey: String {get set}
    var consumerSecret: String {get set}
    var callbackUrl: URL {get set}
    
    var requestTokenUrl: String {get set}
    var authorizeUrl: String {get set}
    var accessTokenUrl: String {get set}
    
    init(consumerKey: String, consumerSecret: String, callbackUrl: URL)
}

public extension ProviderOAuth1 {
    
    internal func getOauth1Swift() -> OAuth1Swift {
        return OAuth1Swift(consumerKey: consumerKey, consumerSecret: consumerSecret, requestTokenUrl: requestTokenUrl, authorizeUrl: authorizeUrl, accessTokenUrl: accessTokenUrl)
    }
    
}
