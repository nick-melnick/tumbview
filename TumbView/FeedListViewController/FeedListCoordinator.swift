//
//  FeedListCoordinator.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit

class FeedListCoordinator: Coordinator {
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let navigationController = self.navigationController,
            let nc = storyboard.instantiateViewController(withIdentifier: "AppNavController") as? UINavigationController,
            let vc = nc.topViewController as? FeedListViewController
            else { return }
        
        let viewModel = FeedListViewModel(coordinator: self, fetchControllerDelegate: vc)
        vc.viewModel = viewModel
        if navigationController.isNavigationBarHidden == true {
            navigationController.setNavigationBarHidden(false, animated: false)
        }
        if navigationController.viewControllers.count > 0 {
            navigationController.viewControllers = [vc]
        } else {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showPhoto(_ photo: Photos) {
        let coordinator = PhotoViewCoordinator(navigationController: navigationController)
        coordinator.start(withPhoto: photo)
    }
    
}
