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
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    /// The `CAShapeLayer` that will contain the animated path

    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layer.addSublayer(shapeLayer)
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
    }
    
    /// Start the display link

    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        self.displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    /// Stop the display link

    private func stopDisplayLink() {
        displayLink?.invalidate()
    }
    
    
    /// Handle the display link timer.
    ///
    /// - Parameter displayLink: The display link.

    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        shapeLayer.path = wave(at: elapsed).cgPath
        shapeLayer.strokeColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = .round
    }

    /// Create the wave at a given elapsed time.
    ///
    /// You should customize this as you see fit.
    ///
    /// - Parameter elapsed: How many seconds have elapsed.
    /// - Returns: The `UIBezierPath` for a particular point of time.

    private func wave(at elapsed: Double) -> UIBezierPath {
        let elapsed = CGFloat(elapsed)
        let centerY = view.bounds.midY
        let amplitude = 50 - abs(elapsed.remainder(dividingBy: 3)) * 40

        func f(_ x: CGFloat) -> CGFloat {
            return sin((x + elapsed) * 4 * .pi) * amplitude + centerY
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
