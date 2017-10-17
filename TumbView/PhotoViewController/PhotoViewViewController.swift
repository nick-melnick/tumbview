//
//  PhotoViewViewController.swift
//  TumbView
//
//  Created by Nick Melnick on 9/16/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit

class PhotoViewViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint: NSLayoutConstraint!
    
    var viewModel: PhotoViewViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        setupGestureRecognizer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = viewModel.image {
            imageView.image = image
            imageView.sizeToFit()
            updateMinZoomScaleForSize(view.bounds.size)
        } else {
            imageView.sd_setImage(with: viewModel.imageURL, placeholderImage: viewModel.thumbImage, options: [], completed: { [weak self] (image, error, _, _) in
                if let image = image {
                    self?.updatePhoto(image)
                }
            })
        }
    }
    
    func updatePhoto(_ image: UIImage) {
        imageView.sizeToFit()
        viewModel.saveOriginalImage(image)
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
}

extension PhotoViewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }

}
