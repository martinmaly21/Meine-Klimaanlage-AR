//
//  ScreenshotCollectionViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ScreenshotCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    public func setUpCell(with image: UIImage) {
        screenshotImageView.image = image
    }

}
