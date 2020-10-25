//
//  ACUnitBrandsCollectionViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-10-24.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ACUnitBrandsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var brandImageContainerView: UIView!
    @IBOutlet weak var brandLabel: UILabel!
    
    public var brand: ACBrand!

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }
    
    public func setUpCell(with brand: ACBrand) {
        self.brand = brand
        
        brandImageView.image = brand.getLogoImage()
        
        brandLabel.text = brand.rawValue
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        containerView.layer.borderWidth = 1
        
        containerView.layer.shadowColor = Constants.Color.border.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowOpacity = 0.3
        
        brandImageContainerView.layer.cornerRadius = 10
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
