//
//  PhotoViewCoordinator.swift
//  TumbView
//
//  Created by Nick Melnick on 9/16/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit

class PhotoViewCoordinator: Coordinator {

    func start(withPhoto photo:Photos) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotoViewViewController") as! PhotoViewViewController
        let viewModel = PhotoViewViewModel(coordinator: self, photo: photo)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
