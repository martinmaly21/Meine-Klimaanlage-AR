//
//  ViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class LogInOrCreateAccountViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    private var shapeLayers: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShapeLayers()
        setUpUI()
    }
    
    private func addShapeLayers() {
        //add 10 shape layers
        for _ in 0...9 {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = Constants.Color.primaryBlue.withAlphaComponent(0.25).cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 30
            shapeLayer.lineCap = .round
            
            shapeLayers.append(shapeLayer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startDisplayLink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopDisplayLink()
    }
    
    private func setUpUI() {
        //round corners of buttons
        signUpButton.layer.cornerRadius = signUpButton.frame.height / 2
        createAccountButton.layer.cornerRadius = createAccountButton.frame.height / 2
        
        //add wave animation
        
        for shapeLayer in shapeLayers {
            view.layer.addSublayer(shapeLayer)
        }
    }
    
    /// Start the display link
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    /// Stop the display link
    private func stopDisplayLink() {
        displayLink?.invalidate()
    }
    
    /// Handle the display link timer.
    /// - Parameter displayLink: The display link.
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        
        for (index, shapeLayer) in shapeLayers.enumerated() {
            shapeLayer.path = wave(at: elapsed, for: index).cgPath
        }
    }
    
    /// Create the wave at a given elapsed time.
    /// - Parameter elapsed: How many seconds have elapsed.
    /// - Returns: The `UIBezierPath` for a particular point of time.
    private func wave(at elapsed: Double, for shapeLayerWithIndex: Int) -> UIBezierPath {
        let elapsedTimeOffset: CGFloat = CGFloat(shapeLayerWithIndex) * 0.1
        let elapsed = CGFloat(elapsed) - elapsedTimeOffset
        
        let centerYOffset = CGFloat(shapeLayerWithIndex) * 8
        let centerY = (appTitleLabel.frame.maxY) + (appTitleLabel.frame.maxY) / 3.5 - (centerYOffset)
        
        
        let amplitude = 20 - abs(elapsed.remainder(dividingBy: 3)) * 50
        
        func f(_ x: CGFloat) -> CGFloat {
            return sin((x + elapsed) * 2 * .pi) * amplitude + centerY
        }
        
        let path = UIBezierPath()
        let steps = Int(view.bounds.width / 10)
        
        path.move(to: CGPoint(x: 0, y: f(0)))
        for step in 1 ... steps {
            let x = CGFloat(step) / CGFloat(steps)
            path.addLine(to: CGPoint(x: x * view.bounds.width, y: f(x)))
        }
        
        return path
    }
}
