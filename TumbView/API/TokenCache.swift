//
//  TokenCache.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import RxSwift
import OAuthSwift

class TokenCache {
    
    fileprivate let disk: Disk
    fileprivate var memory: [String: AnyObject]
    
    static let instance = TokenCache()
    
    fileprivate init() {
        disk = Disk()
        memory = [String: AnyObject]()
    }
    
    func save<T: OAuthSwiftCredential>(_ key: String, data: T) {
        memory.updateValue(Observable.just(data), forKey: key)
        _ = disk.save(key, data: data)
    }
    
    func get<T: OAuthSwiftCredential>(_ keyToken: String, classToken: T.Type) -> Observable<T>? {
        var token = memory[keyToken]
        if token == nil {
            token = disk.get(keyToken, classToken: classToken)
            if let token = token {
                memory.updateValue(token, forKey: keyToken)
            }
        }
        return token as? Observable<T>
    }
    
    func evict(_ key: String) {
        memory.removeValue(forKey: key)
        disk.evict(key)
    }
    
    func evictAll() {
        memory.removeAll()
        disk.evictAll()
    }
}

