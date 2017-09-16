//
//  TumblrConnect+Moya.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import Moya
import OAuthSwift
import RxSwift
import RxBlocking

extension TumblrConnect {
    
    public static func addOAuthHeaders<T: ProviderOAuth1, Target: TargetType>(_ providerOAuth1: T.Type, endpoint: Endpoint<Target>) -> Endpoint<Target>? {
        
        do {
            let credential = try TumblrConnect.getOAuthCredential(T.self).toBlocking().first()
            let headers = credential!.makeHeaders(URL(string: endpoint.url)!, method: getOAuthSwiftMethod(endpoint.method), parameters: [:])
            return endpoint.adding(newHTTPHeaderFields: headers)
        } catch {
            return endpoint
        }
    }
    
    // MARK: - Private methods
    fileprivate static func getOAuthSwiftMethod(_ oAuthMethod: Moya.Method) -> OAuthSwiftHTTPRequest.Method {
        switch(oAuthMethod) {
        case .get:
            return .GET
        case .post:
            return .POST
        case .put:
            return .PUT
        case .delete:
            return .DELETE
        case .patch:
            return .PATCH
        case .head:
            return .HEAD
        default:
            return .GET
        }
    }
}
