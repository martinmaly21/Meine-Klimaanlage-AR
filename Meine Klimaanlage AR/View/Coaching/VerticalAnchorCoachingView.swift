//
//  VerticalAnchorCoachingView.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-14.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class VerticalAnchorCoachingView: UIView {
    private let instructions = [
        "Walk towards the wall where you'd like to place your unit",
        "Hold the top of your device to the wall",
        "Tap the 'Place Unit' button below"
    ]
    
    let videoTutorialScrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        isUserInteractionEnabled = true
        
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.clipsToBounds = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        
        
        videoTutorialScrollView.clipsToBounds = true
        videoTutorialScrollView.isScrollEnabled = true
        videoTutorialScrollView.isPagingEnabled = true
        videoTutorialScrollView.showsHorizontalScrollIndicator = false
        
        videoTutorialScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(videoTutorialScrollView)
        videoTutorialScrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        videoTutorialScrollView.heightAnchor.constraint(equalTo: videoTutorialScrollView.widthAnchor).isActive = true
        
        //add content into scroll view
        addViewsToScrollView()
        
        let showNextStepButton = UIButton()
        showNextStepButton.translatesAutoresizingMaskIntoConstraints = false
        showNextStepButton.setTitle("Show next step", for: .normal)
        showNextStepButton.setTitleColor(Constants.Color.primaryTextDark, for: .normal)
        showNextStepButton.addTarget(self, action: #selector(userPressedShowNextStep), for: .touchUpInside)
        
        stackView.addArrangedSubview(showNextStepButton)
        
        let skipTutorialButton = UIButton()
        skipTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        skipTutorialButton.setTitle("Skip tutorial", for: .normal)
        skipTutorialButton.setTitleColor(Constants.Color.primaryTextDark, for: .normal)
        skipTutorialButton.addTarget(self, action: #selector(userPressedSkipTutorial), for: .touchUpInside)
        
        stackView.addArrangedSubview(skipTutorialButton)
    }
    
    private func addViewsToScrollView() {
        var previousView: UIView?
        
        for instruction in instructions {
            let image = UIImage(named: "AppIcon")
            let imageView = UIImageView(image: image)
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            videoTutorialScrollView.addSubview(imageView)
            imageView.heightAnchor.constraint(equalTo: videoTutorialScrollView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: videoTutorialScrollView.widthAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: videoTutorialScrollView.centerYAnchor).isActive = true
            
            if let previousView = previousView {
                imageView.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
                
                if instruction == instructions.last {
                    imageView.trailingAnchor.constraint(equalTo: videoTutorialScrollView.trailingAnchor).isActive = true
                }
            } else {
                imageView.leadingAnchor.constraint(equalTo: videoTutorialScrollView.leadingAnchor).isActive = true
            }
            
            previousView = imageView
        }
    }
    
    @objc func userPressedShowNextStep() {
    }
    
    @objc func userPressedSkipTutorial() {
    }
}
