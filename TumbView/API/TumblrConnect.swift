//
//  TumblrConnect.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import RxSwift
import OAuthSwift

class TumblrConnect {

    fileprivate let ERROR_RETRIEVING_TOKEN = "Error retrieving token"
    private static var oauth1Swift: OAuth1Swift!
    
    static func with<T: ProviderOAuth1>(_ viewController: UIViewController, providerOAuth1: T) -> Observable<OAuthSwiftCredential> {
        
        let key = String(describing: T.self).components(separatedBy: ".").last!
        
        if let response = TokenCache.instance.get(key, classToken: OAuthSwiftCredential.self) {
            return response
        }
        
        oauth1Swift = providerOAuth1.getOauth1Swift()
        
        oauth1Swift.authorizeURLHandler = CustomURLHandler(viewController: viewController, callbackUrl: providerOAuth1.callbackUrl)
        
        return Observable.create({ subscribe in
            oauth1Swift.authorize(withCallbackURL:
                providerOAuth1.callbackUrl,
                                  success: { credential, response, parameters in
                                    parseParametersIntoCredential(credential, parameters: parameters)
                                    TokenCache.instance.save(key, data: credential)
                                    subscribe.onNext(credential)
                                    subscribe.onCompleted()
            },
                                  failure: { error in
                                    print(error.localizedDescription)
                                    
                                    subscribe.onError(error)
                                    subscribe.onCompleted()
            }
            )
            return Disposables.create()
        })
    }
    
    open static func closeConnection<T>(_ classToken: T.Type) -> Observable<Void> {
        return Observable.deferred {
            let key = String(describing: classToken).components(separatedBy: ".").last!
            TokenCache.instance.evict(key)
            return Observable.empty()
        }
    }
    
    open static func closeConnections() -> Observable<Void> {
        return Observable.deferred {
            TokenCache.instance.evictAll()
            return Observable.empty()
        }
    }
    
    open static func getOAuthCredential<T>(_ classToken: T.Type) -> Observable<OAuthSwiftCredential> {
        return Observable.deferred {
            
            let key = String(describing: T.self).components(separatedBy: ".").last!
            
            if let credential = TokenCache.instance.get(key, classToken: OAuthSwiftCredential.self) {
                return credential
            }
            
            return Observable.error(NotActiveTokenFoundException.error)
        }
    }

    // MARK: - Private methods
    fileprivate static func generateStateWithLength (_ len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    fileprivate static func parseParametersIntoCredential(_ credential: OAuthSwiftCredential, parameters: OAuthSwift.Parameters) {
        if let expiresIn = parameters["expires_in"] as? String,
            let offset = Double(expiresIn)  {
            credential.oauthTokenExpiresAt = Date(timeInterval: offset, since: Date())
        }
    }
    

}

