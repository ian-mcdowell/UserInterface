//
//  UIViewController+ProgressHUD.swift
//  Source
//
//  Created by Ian McDowell on 1/18/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

/// Since extensions can not officially have stored properties,
/// we use the objc_runtime to set and get associated objects.
/// This is the key used for storage and retrieval.
private var ProgressHUDAssociatedObjectKey: UInt8 = 0

/// This UIViewController extension allows you to display and update
/// a progress HUD by calling methods on any UIViewController.
public extension UIViewController {
    
    public var progressHUD: ProgressHUD {
        if let progressHUD = objc_getAssociatedObject(self, &ProgressHUDAssociatedObjectKey) as? ProgressHUD {
            return progressHUD
        } else {
            let progressHUD = ProgressHUD(self.navigationController ?? self)
            objc_setAssociatedObject(self, &ProgressHUDAssociatedObjectKey, progressHUD, .OBJC_ASSOCIATION_RETAIN)
            return progressHUD
        }
    }
    
    /// Removes the current HUD
    fileprivate func reset() {
        objc_setAssociatedObject(self, &ProgressHUDAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN)
    }
    
}

/// Property of a view controller that manages presenting, updating, and removing a progress HUD.
public class ProgressHUD {
    
    private var viewController: UIViewController
    
    private var dimmingView: UIView? = nil
    private var progressHUDView: ProgressHUDView? = nil
    
    fileprivate init(_ viewController: UIViewController) {
        self.viewController = viewController
        
    }
    
    deinit {
        // Make sure we don't leave the hud view behind when we get deallocated.
        progressHUDView?.removeFromSuperview()
    }
    
    
    /// Construct a new progress HUD view, and add it to the view controller's view.
    public func show(animated: Bool = true) {
        
        DispatchQueue.main.async {
            
            // Make sure there isn't already a progress view. If there is, this will remove it.
            self.progressHUDView?.removeFromSuperview()
            
            // Create the new view and add it to the view controller.
            self.progressHUDView = {
                let p = ProgressHUDView(blurStyle: self.blurStyle)
                self.viewController.view.addSubview(p)
                
                // Add constraints: center in view controller's view
                p.centerXAnchor.constraint(equalTo: self.viewController.view.centerXAnchor).isActive = true
                p.centerYAnchor.constraint(equalTo: self.viewController.view.centerYAnchor).isActive = true
                
                return p
            }()
            
            self.refreshAll()
            
            self.progressHUDView?.alpha = 0
            UIView.animate(withDuration: animated ? 0.25 : 0) {
                self.progressHUDView?.alpha = 1
            }
        
        }
    }
    
    /// Removes the progress view from the screen and resets all progress state.
    public func remove(animated: Bool = true, delay: Double = 0, _ completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { 
            UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                
                self.progressHUDView?.alpha = 0
                self.dimmingView?.alpha = 0
                
            }) { _ in
                // Remove the view from the screen
                self.progressHUDView?.removeFromSuperview()
                self.progressHUDView = nil
                
                if self.disablesUserInteraction {
                    self.viewController.view.isUserInteractionEnabled = true
                }
                
                if self.dimmingView != nil {
                    self.dimmingView?.removeFromSuperview()
                    self.dimmingView = nil
                }
                
                // Tell the view controller to remove ourself from its properties
                self.viewController.reset()
                
                completion?()
            }
        }
    }
    
    /// Applies the values of all properties to the view.
    private func refreshAll() {
        self.progressHUDView?.setProgress(self.progress, animated: false)
        self.progressHUDView?.setText(self.text, animated: false)
        self.progressHUDView?.setBackground(self.backgroundColor)
        self.progressHUDView?.setColor(self.color, animated: false)
        
        self.cornerRadius = self.cornerRadius + 0
        self.indeterminate = !(!self.indeterminate)
        self.disablesUserInteraction = !(!self.disablesUserInteraction)
        self.dimsBackground = !(!self.dimsBackground)
    }
    
    /// The current value of the progress indicator, between 0 and 1. Animates when set. Initially set to 0.
    /// If it is set to an invalid value, the indicator becomes indeterminate.
    public var progress: Float = 0 {
        didSet {
            self.indeterminate = !(progress >= 0 && progress <= 1)
            
            DispatchQueue.main.async {
                self.progressHUDView?.setProgress(self.progress, animated: true)
            }
        }
    }
    
    /// Changing this will change the style of the HUD.
    public var indeterminate: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.progressViewType = self.indeterminate ? .indeterminate : .determinate
            }
        }
    }
    
    public var text: String? = nil {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.setText(self.text, animated: true)
            }
        }
    }
    
    /// The style of blur to apply to the background of the HUD.
    public var blurStyle: UIBlurEffectStyle = .light {
        didSet {
            // If the HUD is already visible, re-add it to get the new blur style
            if self.progressHUDView?.superview != nil {
                self.show()
            }
        }
    }
    
    public var color: UIColor = .black {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.setColor(self.color, animated: true)
            }
        }
    }
    
    /// Sets a background color for the progress view. If set to a non-nil value, the `blurStyle` property will be ignored.
    public var backgroundColor: UIColor? = .white {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.setBackground(self.backgroundColor)
            }
        }
    }
    
    /// How rounded the corners of the HUD should be.
    public var cornerRadius: Float = 15 {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.layer.cornerRadius = CGFloat(self.cornerRadius)
            }
        }
    }
    
    /// Whether or not to disable the user interaction of the presenting view controller when the HUD appears. Defaults to true.
    public var disablesUserInteraction: Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.progressHUDView?.superview != nil {
                    self.viewController.view.isUserInteractionEnabled = !self.disablesUserInteraction
                }
            }
        }
    }
    
    public var dimsBackground: Bool = true {
        didSet {
            DispatchQueue.main.async {
                if let progressHUDView = self.progressHUDView {
                    if self.dimsBackground && self.dimmingView == nil {
                        let dimmingView = UIView()
                        dimmingView.backgroundColor = .black
                        dimmingView.alpha = 0.4
                        self.viewController.view.insertSubview(dimmingView, belowSubview: progressHUDView)
                        dimmingView.constrainToEdgesOfSuperview()
                        self.dimmingView = dimmingView
                    }
                }
                
                if !self.dimsBackground && self.dimmingView != nil {
                    self.dimmingView?.removeFromSuperview()
                    self.dimmingView = nil
                }
            }
        }
    }
}


/// The view that appears on screen.
private class ProgressHUDView: UIView {
    
    /// Blurred background.
    private var blurEffect: UIBlurEffect
    private var blurView: UIVisualEffectView
    
    /// Constraint between label and progress view
    private var labelProgressViewConstraint: NSLayoutConstraint? = nil
    
    private var color: UIColor = .black {
        didSet {
            self.labelView.textColor = color
            self.progressView?.color = color
        }
    }
    
    /// View for showing determinate progress
    private var progressView: ProgressHUDProgressView? = nil {
        didSet {
            if let progressView = progressView {
                progressView.color = self.color
                
                progressView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(progressView)
                progressView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                progressView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
                progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                self.labelProgressViewConstraint = progressView.bottomAnchor.constraint(equalTo: self.labelView.topAnchor, constant: -10)
                self.labelProgressViewConstraint?.isActive = true
            } else {
                labelProgressViewConstraint = nil
            }
        }
    }
    
    var progressViewType: ProgressHUDProgressViewType? = nil {
        didSet {
            // If we just set the type to something new, swap out the progress views if needed.
            if let type = progressViewType {
                let viewType = type.viewType()
                
                if Swift.type(of: progressView) != viewType {
                    self.progressView?.removeFromSuperview()
                    self.progressView = viewType.init()
                }
            } else {
                self.progressView?.removeFromSuperview()
                self.progressView = nil
            }
        }
    }
    
    private var labelView: UILabel!
    
    init(blurStyle: UIBlurEffectStyle) {
        blurEffect = UIBlurEffect(style: blurStyle)
        blurView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: .zero)
        
        // This view defines its own width and height
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Mask all sublayers to the corner radius
        self.layer.masksToBounds = true
        
        // Add blur view & vibrancy view
        self.addSubview(blurView)
        blurView.constrainToEdgesOfSuperview()

        // Set up label
        labelView = {
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = self.color
            self.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            
            return label
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: Float, animated: Bool) {
        self.progressView?.setProgress(progress, animated: animated)
    }
    
    func setText(_ text: String?, animated: Bool) {
        self.layoutIfNeeded()
        
        self.labelView.text = text
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                if text?.characters.count ?? 0 == 0 {
                    self.labelView.alpha = 0
                    self.labelProgressViewConstraint?.constant = 0
                } else {
                    self.labelView.alpha = 1
                    self.labelProgressViewConstraint?.constant = -10
                }
                
                self.layoutIfNeeded()
            }
        }
    }
    
    func setColor(_ color: UIColor, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) { 
            self.color = color
        }
    }
    
    func setBackground(_ backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        
        blurView.isHidden = backgroundColor != nil
    }
    
}

private enum ProgressHUDProgressViewType {
    case determinate, indeterminate
    
    func viewType() -> ProgressHUDProgressView.Type {
        switch self {
        case .determinate:
            return ProgressHUDDeterminateProgressView.self
        case .indeterminate:
            return ProgressHUDIndeterminateProgressView.self
        }
    }
}

private class ProgressHUDProgressView: UIView {
    
    var thickness: CGFloat = 2
    var color: UIColor = .black
    
    required init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {}
    
    func setProgress(_ progress: Float, animated: Bool) {}
}


private class ProgressHUDDeterminateProgressView: ProgressHUDProgressView {
    
    private var ringLayer: CAShapeLayer!
    
    override var thickness: CGFloat {
        didSet {
            ringLayer.lineWidth = thickness
            self.layoutSubviews()
        }
    }
    
    override var color: UIColor {
        didSet {
            ringLayer.strokeColor = color.cgColor
        }
    }
    
    override func setup() {
        
        ringLayer = {
            let layer = CAShapeLayer()

            layer.contentsScale = UIScreen.main.scale
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = self.color.cgColor
            layer.lineWidth = self.thickness
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinBevel
            layer.strokeEnd = 0
            
            self.layer.addSublayer(layer)
            
            return layer
        }()

    }

    override func setProgress(_ progress: Float, animated: Bool) {
        ringLayer.removeAllAnimations()
        let currentProgress = Float(ringLayer.strokeEnd)
        
        ringLayer.strokeEnd = CGFloat(progress)
        
        if animated {
            let animation = CABasicAnimation.init(keyPath: "strokeEnd")
            animation.duration = 0.1
            animation.fromValue = NSNumber(value: currentProgress)
            animation.toValue = NSNumber(value: progress)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            ringLayer.add(animation, forKey: "progressAnimation")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(self.bounds.width, self.bounds.height) / UIScreen.main.scale
        
        let arcCenter = CGPoint(
            x: radius + self.thickness / 2 + 5,
            y: radius + self.thickness / 2 + 5
        )
        let smoothedPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: -CGFloat(Double.pi / 2),
            endAngle: CGFloat(Double.pi + Double.pi / 2),
            clockwise: true
        )
        ringLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: arcCenter.x * 2,
            height: arcCenter.y * 2
        )
        ringLayer.path = smoothedPath.cgPath
        
        let width = self.bounds.width - ringLayer.bounds.width
        let height = self.bounds.width - ringLayer.bounds.width
        
        ringLayer.position = CGPoint(
            x: self.bounds.width - ringLayer.bounds.width / 2 - width / 2,
            y: self.bounds.height - ringLayer.bounds.height / 2 - height / 2
        )
    }
    

}

private class ProgressHUDIndeterminateProgressView: ProgressHUDProgressView {
    
    private var ringLayer: CAShapeLayer!
    
    override var thickness: CGFloat {
        didSet {
            ringLayer.lineWidth = thickness
            self.layoutSubviews()
        }
    }
    
    override var color: UIColor {
        didSet {
            ringLayer.strokeColor = color.cgColor
        }
    }
    
    override func setup() {
        ringLayer = {
            let layer = CAShapeLayer()
            
            layer.contentsScale = UIScreen.main.scale
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = self.color.cgColor
            layer.lineWidth = self.thickness
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinBevel
            layer.strokeEnd = 0.9
            
            self.layer.addSublayer(layer)
            
            return layer
        }()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = NSNumber(value: 0)
        animation.toValue = NSNumber(value:Double.pi * 2)
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = Float.infinity
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        ringLayer.add(animation, forKey: "rotation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(self.bounds.width, self.bounds.height) / UIScreen.main.scale
        
        let arcCenter = CGPoint(
            x: radius + self.thickness / 2 + 5,
            y: radius + self.thickness / 2 + 5
        )
        let smoothedPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: -CGFloat(Double.pi / 2),
            endAngle: CGFloat(Double.pi + Double.pi / 2),
            clockwise: true
        )
        ringLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: arcCenter.x * 2,
            height: arcCenter.y * 2
        )
        ringLayer.path = smoothedPath.cgPath
        
        let width = self.bounds.width - ringLayer.bounds.width
        let height = self.bounds.width - ringLayer.bounds.width
        
        ringLayer.position = CGPoint(
            x: self.bounds.width - ringLayer.bounds.width / 2 - width / 2,
            y: self.bounds.height - ringLayer.bounds.height / 2 - height / 2
        )
    }
    
}
