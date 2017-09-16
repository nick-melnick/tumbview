//
//  AppCoordinator.swift
//  TumbView
//
//  Created by Nick Melnick on 9/14/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift
import NSObject_Rx

final class AppCoordinator: Coordinator {
    
    func start() {
        if let response = TokenCache.instance.get("TumblrAuth", classToken: OAuthSwiftCredential.self) {
            response.asObservable()
                .subscribe(onNext: { [weak self] (credential) in
                    print(credential.oauthToken)
                    self?.successfulAuthorize()
                })
                .addDisposableTo(disposeBag)
        } else {
            let splashCoodinator = SplashScreenCoordinator(navigationController: self.navigationController)
            splashCoodinator.start()
        }
    }
    
    func successfulAuthorize() {
        let feedListCoordinator = FeedListCoordinator(navigationController: navigationController)
        feedListCoordinator.start()
    }
    
}
