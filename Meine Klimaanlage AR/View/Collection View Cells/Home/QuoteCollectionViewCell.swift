//
//  QuoteCollectionViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class QuoteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func highlightCell() {
        removeShadow()
        dimView()
    }
    
    public func unHighlightCell() {
        addShadow()
        unDimView()
    }
    
    private func addShadow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = layer.shadowOpacity
        animation.toValue = 0.3
        animation.duration = 0.05
        containerView.layer.add(animation, forKey: animation.keyPath)
        containerView.layer.shadowOpacity = 0.3
    }
    
    private func removeShadow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = layer.shadowOpacity
        animation.toValue = 0.0
        animation.duration = 0.05
        containerView.layer.add(animation, forKey: animation.keyPath)
        containerView.layer.shadowOpacity = 0.0
    }
    
    private func dimView() {
        UIView.animate(
            withDuration: 0.05) {
            self.containerView.backgroundColor = Constants.Color.highlightGrey
        }
    }
    
    private func unDimView() {
        UIView.animate(
            withDuration: 0.05) {
            self.containerView.backgroundColor = UIColor.white
        }
    }
}
