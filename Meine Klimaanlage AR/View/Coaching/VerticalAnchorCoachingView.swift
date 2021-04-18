//
//  VerticalAnchorCoachingView.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-14.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

protocol VerticalAnchorCoachingViewDelegate: class {
    func userPressedPlaceACUnit()
}

class VerticalAnchorCoachingView: UIView {
    private let instructions = [
        "Walk towards the wall where you'd like to place your unit",
        "Hold the top of your device to the wall",
        "Tap the 'Place AC Unit' button below"
    ]
    
    let videoTutorialScrollView = UIScrollView()
    let pageControl = UIPageControl()
    let skipTutorialButton = UIButton()
    let showNextStepButton = UIButton()
    
    private var lastPageNumber: Int {
        return instructions.count - 1
    }
    
    public weak var delegate: VerticalAnchorCoachingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimView)
        
        dimView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let stackViewContainerView = UIView()
        stackViewContainerView.backgroundColor = Constants.Color.primaryWhiteBackground
        stackViewContainerView.layer.cornerCurve = .continuous
        stackViewContainerView.layer.cornerRadius = 15
        stackViewContainerView.clipsToBounds = true
        stackViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackViewContainerView)
        
        
        stackViewContainerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackViewContainerView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        stackViewContainerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.clipsToBounds = true
        stackView.spacing = 10
        
        stackViewContainerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: stackViewContainerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: stackViewContainerView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: stackViewContainerView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: stackViewContainerView.bottomAnchor, constant: -20).isActive = true
        
        videoTutorialScrollView.clipsToBounds = true
        videoTutorialScrollView.isScrollEnabled = true
        videoTutorialScrollView.isPagingEnabled = true
        videoTutorialScrollView.showsHorizontalScrollIndicator = false
        videoTutorialScrollView.delegate = self
        
        videoTutorialScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(videoTutorialScrollView)
        videoTutorialScrollView.widthAnchor.constraint(equalTo: stackViewContainerView.widthAnchor).isActive = true
        videoTutorialScrollView.heightAnchor.constraint(equalTo: videoTutorialScrollView.widthAnchor).isActive = true
        
        //add content into scroll view
        addViewsToScrollView()
        
        let pageControlContainerView = UIView()
        pageControl.isUserInteractionEnabled = false
        pageControlContainerView.backgroundColor = .systemGray
        pageControlContainerView.translatesAutoresizingMaskIntoConstraints = false
        pageControlContainerView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        pageControlContainerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        pageControlContainerView.layer.cornerRadius = 10
        
        //set up page control
        pageControl.numberOfPages = instructions.count
        
        pageControlContainerView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.centerXAnchor.constraint(equalTo: pageControlContainerView.centerXAnchor).isActive = true
        pageControl.centerYAnchor.constraint(equalTo: pageControlContainerView.centerYAnchor).isActive = true 
        
        stackView.addArrangedSubview(pageControlContainerView)
        
        showNextStepButton.translatesAutoresizingMaskIntoConstraints = false
        showNextStepButton.setTitle("Show next step", for: .normal)
        showNextStepButton.setTitleColor(Constants.Color.primaryTextLight, for: .normal)
        showNextStepButton.backgroundColor = Constants.Color.primaryBlue
        showNextStepButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        showNextStepButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        showNextStepButton.layer.cornerRadius = 25
        showNextStepButton.addTarget(self, action: #selector(userPressedShowNextStep), for: .touchUpInside)
        
        stackView.addArrangedSubview(showNextStepButton)
        
        skipTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        skipTutorialButton.setTitle("Skip tutorial", for: .normal)
        skipTutorialButton.setTitleColor(Constants.Color.primaryBlue, for: .normal)
        skipTutorialButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        skipTutorialButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        skipTutorialButton.layer.cornerRadius = 20
        skipTutorialButton.addTarget(self, action: #selector(userPressedSkipTutorial), for: .touchUpInside)
        
        stackView.addArrangedSubview(skipTutorialButton)
        
        stackView.setCustomSpacing(20, after: pageControlContainerView)
    }
    
    private func addViewsToScrollView() {
        var previousView: UIView?
        
        for (index, instruction) in instructions.enumerated() {
            let instructionContainerView = UIView()
            
            instructionContainerView.backgroundColor = UIColor.lightGray
            
            let instructionNumberLabelContainerView = UIView()
            instructionNumberLabelContainerView.backgroundColor = Constants.Color.primaryWhiteBackground.withAlphaComponent(0.4)
            instructionNumberLabelContainerView.layer.cornerRadius = 10
            instructionNumberLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
            instructionContainerView.addSubview(instructionNumberLabelContainerView)
            instructionNumberLabelContainerView.topAnchor.constraint(equalTo: instructionContainerView.topAnchor, constant: 25).isActive = true
            instructionNumberLabelContainerView.leadingAnchor.constraint(equalTo: instructionContainerView.leadingAnchor, constant: 25).isActive = true
            
            let instructionNumberLabel = UILabel()
            instructionNumberLabel.textColor = Constants.Color.primaryTextLight
            instructionNumberLabel.numberOfLines = 0
            instructionNumberLabel.text = "Step \(index + 1) of \(instructions.count)"
            instructionNumberLabel.textAlignment = .center
            instructionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
            instructionNumberLabelContainerView.addSubview(instructionNumberLabel)
            
            instructionNumberLabel.leadingAnchor.constraint(equalTo: instructionNumberLabelContainerView.leadingAnchor, constant: 10).isActive = true
            instructionNumberLabel.trailingAnchor.constraint(equalTo: instructionNumberLabelContainerView.trailingAnchor, constant: -10).isActive = true
            instructionNumberLabel.topAnchor.constraint(equalTo: instructionNumberLabelContainerView.topAnchor, constant: 10).isActive = true
            instructionNumberLabel.bottomAnchor.constraint(equalTo: instructionNumberLabelContainerView.bottomAnchor, constant: -10).isActive = true
 
            let instructionLabelContainerView = UIView()
            instructionLabelContainerView.backgroundColor = Constants.Color.primaryWhiteBackground.withAlphaComponent(0.4)
            instructionLabelContainerView.layer.cornerRadius = 10
            instructionLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
            instructionContainerView.addSubview(instructionLabelContainerView)
            instructionLabelContainerView.bottomAnchor.constraint(equalTo: instructionContainerView.bottomAnchor, constant: -10).isActive = true
            instructionLabelContainerView.leadingAnchor.constraint(equalTo: instructionContainerView.leadingAnchor, constant: 25).isActive = true
            instructionLabelContainerView.trailingAnchor.constraint(equalTo: instructionContainerView.trailingAnchor, constant: -25).isActive = true
            
            let instructionLabel = UILabel()
            instructionLabel.textColor = Constants.Color.primaryTextLight
            instructionLabel.numberOfLines = 0
            instructionLabel.text = instruction
            instructionLabel.textAlignment = .center
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            
            instructionLabelContainerView.addSubview(instructionLabel)
            instructionLabel.bottomAnchor.constraint(equalTo: instructionLabelContainerView.bottomAnchor, constant: -10).isActive = true
            instructionLabel.leadingAnchor.constraint(equalTo: instructionLabelContainerView.leadingAnchor, constant: 10).isActive = true
            instructionLabel.trailingAnchor.constraint(equalTo: instructionLabelContainerView.trailingAnchor, constant: -10).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: instructionLabelContainerView.topAnchor, constant: 10).isActive = true
            
            instructionContainerView.clipsToBounds = true
            instructionContainerView.isUserInteractionEnabled = true
            instructionContainerView.translatesAutoresizingMaskIntoConstraints = false
            
            videoTutorialScrollView.addSubview(instructionContainerView)
            instructionContainerView.heightAnchor.constraint(equalTo: videoTutorialScrollView.heightAnchor).isActive = true
            instructionContainerView.widthAnchor.constraint(equalTo: videoTutorialScrollView.widthAnchor).isActive = true
            instructionContainerView.centerYAnchor.constraint(equalTo: videoTutorialScrollView.centerYAnchor).isActive = true
            
            if let previousView = previousView {
                instructionContainerView.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
                
                if instruction == instructions.last {
                    instructionContainerView.trailingAnchor.constraint(equalTo: videoTutorialScrollView.trailingAnchor).isActive = true
                }
            } else {
                instructionContainerView.leadingAnchor.constraint(equalTo: videoTutorialScrollView.leadingAnchor).isActive = true
            }
            
            previousView = instructionContainerView
        }
    }
    
    @objc func userPressedShowNextStep() {
        if pageControl.currentPage == lastPageNumber {
            delegate?.userPressedPlaceACUnit()
            
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.alpha = 0
                },
                completion: { _ in
                    self.removeFromSuperview()
                }
            )
        } else {
            let nextPageNumber: CGFloat = CGFloat(pageControl.currentPage) + 1
            let targetX = videoTutorialScrollView.frame.size.width * nextPageNumber
            videoTutorialScrollView.setContentOffset(.init(x: targetX, y: 0), animated: true)
        }
    }
    
    @objc func userPressedSkipTutorial() {
        let targetX = videoTutorialScrollView.frame.size.width * CGFloat(lastPageNumber)
        videoTutorialScrollView.setContentOffset(.init(x: targetX, y: 0), animated: true)
    }
}

extension VerticalAnchorCoachingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageNumber
        
        if pageNumber == lastPageNumber {
            //hide tutorial on last page
            skipTutorialButton.alpha = 0
            skipTutorialButton.isUserInteractionEnabled = false
            showNextStepButton.setTitle("Place AC Unit", for: .normal)
        } else {
            skipTutorialButton.alpha = 1
            skipTutorialButton.isUserInteractionEnabled = true
            showNextStepButton.setTitle("Show next step", for: .normal)
        }
    }
}
