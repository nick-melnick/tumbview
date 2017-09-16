//
//  PhotoCollectionViewCell.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {

    func setup(withViewModel viewModel: PhotoCellViewModel) {
        self.likesLabel.text = "\(viewModel.likesCount)"
        if let thumbImage = viewModel.thumbImage {
            self.image.image = thumbImage
        } else {
            self.image.sd_setImage(with: viewModel.thumbURL, placeholderImage: UIImage(), options: [.handleCookies], completed: { (loadedImage, _, _, _) in
                if let data = loadedImage?.sd_imageData() {
                    viewModel.saveImage(imageData: data)
                }
            })
        }
    }
    
    @IBOutlet fileprivate var image: UIImageView!
    
    @IBOutlet fileprivate var infoPanel: UIView!
    
    @IBOutlet fileprivate var heartIconView: UIView!
    
    @IBOutlet fileprivate var likesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        infoPanel.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.sd_cancelCurrentImageLoad()
        togglePanel(toState: false, animated: false)
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            self.togglePanel(toState: newValue, animated: true)
        }
    }
    
    fileprivate func togglePanel(toState state:Bool, animated: Bool) {
        let alphaValue:CGFloat = state ? 1 : 0
        if animated {
            UIView.transition(with: infoPanel, duration: 0.5, options: [.beginFromCurrentState,.showHideTransitionViews], animations: { [weak self] in
                self?.infoPanel.alpha = alphaValue
                }, completion: nil)
        } else {
            self.infoPanel.alpha = alphaValue
        }
    }

}
