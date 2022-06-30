//
//  ViewController.swift
//  SwiftUIABC
//
//  Created by TrucPham on 10/06/2022.
//

import UIKit
import SwiftUI
import QuartzCore
class ViewController: UIViewController {
    private lazy var button : UIButton = {
        let v = UIButton()
        v.backgroundColor = .green
        v.setTitle("Navigate", for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonEnd), for: .touchUpInside)
        v.addTarget(self, action: #selector(buttonTap), for: .touchDown)
        return v
    }()
    fileprivate lazy var pulsator : Pulsator = {
        let pulsator = Pulsator()
        pulsator.numPulse = 5
        pulsator.radius = 200
        pulsator.animationDuration = 3
        pulsator.backgroundColor = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: 1).cgColor
        return pulsator
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        //        // Do any additional setup after loading the view.
        //        self.view.backgroundColor = .red
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let swiftUIView = ContentView() // swiftUIView is View
        let swiftUIControler = UIHostingController(rootView: swiftUIView)
        self.addChild(swiftUIControler)
        swiftUIControler.view.frame = view.bounds
        view.addSubview(swiftUIControler.view)
        swiftUIControler.didMove(toParent: self)
    }
    @objc private func buttonTap(){
        pulsator.position = self.button.center
        self.view.layer.addSublayer(pulsator)
        
        
        pulsator.start()
        
    }
    
    @objc func buttonEnd(){
        pulsator.removeFromSuperlayer()
    }
    
}

class Pulsator: CAReplicatorLayer {
    let kPulsatorAnimationKey = "pulsator"
    fileprivate let pulse = CALayer()
    fileprivate var animationGroup: CAAnimationGroup!
    
    
    var numPulse: Int = 1
    
    var radius: CGFloat = 200
    
    var animationDuration: TimeInterval = 3
    
    var fromValueForRadius: Float = 0.0
    
    var pulseInterval: TimeInterval = 0
    
    var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .default)
    
    /// private properties for resuming
    fileprivate weak var prevSuperlayer: CALayer?
    fileprivate var prevLayerIndex: Int?
    
    // MARK: - Initializer
    override init() {
        super.init()
        setupPulse()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(save),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resume),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupPulse() {
        repeatCount = MAXFLOAT
        instanceCount = self.numPulse
        instanceDelay = max((animationDuration + pulseInterval) / Double(numPulse), 1)
        pulse.contentsScale = UIScreen.main.scale
        pulse.opacity = 0
        addSublayer(pulse)
        updatePulse()
    }
    
    fileprivate func setupAnimationGroup() {
        animationGroup = CAAnimationGroup()
        animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
        animationGroup.duration = animationDuration + pulseInterval
        animationGroup.repeatCount = repeatCount
        if let timingFunction = timingFunction {
            animationGroup.timingFunction = timingFunction
        }
    }
    
    fileprivate func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = fromValueForRadius
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    fileprivate func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [1, 0.5, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.2, 1.0]
        return opacityAnimation
    }
    
    fileprivate func updatePulse() {
        let diameter: CGFloat = radius * 2
        pulse.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: diameter, height: diameter))
        pulse.cornerRadius = radius
        pulse.backgroundColor = backgroundColor
    }
    
    // MARK: - Internal Methods
    
    @objc internal func save() {
        prevSuperlayer = superlayer
        prevLayerIndex = prevSuperlayer?.sublayers?.firstIndex(where: {$0 === self})
    }
    
    @objc private func resume() {
        if let prevSuperlayer = prevSuperlayer, let prevLayerIndex = prevLayerIndex {
            prevSuperlayer.insertSublayer(self, at: UInt32(prevLayerIndex))
        }
        if pulse.superlayer == nil {
            addSublayer(pulse)
        }
        let isAnimating = pulse.animation(forKey: kPulsatorAnimationKey) != nil
        // if the animationGroup is not nil, it means the animation was not stopped
        if let animationGroup = animationGroup, !isAnimating {
            pulse.add(animationGroup, forKey: kPulsatorAnimationKey)
        }
    }
    func start() {
        setupPulse()
        setupAnimationGroup()
        pulse.add(animationGroup, forKey: kPulsatorAnimationKey)
    }
    
    func stop() {
        pulse.removeAllAnimations()
        animationGroup = nil
    }
    
}
