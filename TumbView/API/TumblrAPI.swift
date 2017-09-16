//
//  TumblrAPI.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import RxSwift
import Moya

// MARK: - Endpoint Closure
let endpointClosure = { (target: TumblrTarget) -> Endpoint<TumblrTarget> in
    let endpoint: Endpoint<TumblrTarget> = Endpoint<TumblrTarget>(url: url(target),
                                                      sampleResponseClosure: {.networkResponse(200, target.sampleData)},
                                                      method: target.method,
                                                      task: target.task,
                                                      httpHeaderFields: target.headers)
    
    // Add this line to add OAuthHeaders
    return TumblrConnect.addOAuthHeaders(TumblrAuth.self, endpoint: endpoint)!
}

enum TumblrPostsType:String {
    case all    = ""
    case photo  = "photo"
    case text   = "text"
    case quote  = "quote"
    case link   = "link"
    case chat   = "chat"
    case audio  = "audio"
    case video  = "video"
    case answer = "answer"
}

enum TumblrAPIError:Error {
    case cantParseJSON
}

class TumblrAPI: NSObject {
    
    // MARK: - Provider setup
    private let provider = RxMoyaProvider<TumblrTarget>(endpointClosure: endpointClosure)
    
    
    func getMe() -> Single<Response> {
        return provider.request(TumblrTarget.me)
    }
    
    func getDashboard(withType type:TumblrPostsType = .all, offset: Int = 0, sinceID: Int = 0) -> Single<Response> {
        return provider.request(.dashboard(type: type.rawValue, offset: offset, since_id: sinceID))
    }
    
}

// MARK: - Targets Description

public enum TumblrTarget: TargetType {
    /// User Info
    case me
    /// User Dashboard
    case dashboard(type:String, offset:Int, since_id: Int)
    
    public var baseURL: URL {
        return URL(string: "https://api.tumblr.com/v2")!
    }
    
    public var path: String {
        switch self {
        case .me:
            return "/user/info"
        case .dashboard:
            return "/user/dashboard"
        }
    }
    
    public var method: Moya.Method {
        switch(self) {
        default:
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch (self) {
        case .dashboard(type: let type, offset: let offset, since_id: let since_id):
            var params = [String:Any]()
            params.updateValue(since_id, forKey: "since_id")
            params.updateValue(offset, forKey: "offset")
            if type != "" {
                params.updateValue(type, forKey: "type")
            }
            return params
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding()
//            return JSONEncoding()
        }
    }

    
    public var task: Task {
        return .requestPlain
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        }
    }
    
    public var headers: [String: String]? {
        return [:]
    }

}


public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
