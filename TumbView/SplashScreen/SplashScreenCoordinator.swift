//
//  SplashScreenCoordinator.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit

class SplashScreenCoordinator: Coordinator {
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SplashScreen") as? SplashScreenViewController {
            vc.coodrinator = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func successfulAuthorization() {
        let feedListCoordinator = FeedListCoordinator(navigationController: navigationController)
        feedListCoordinator.start()
    }
}
