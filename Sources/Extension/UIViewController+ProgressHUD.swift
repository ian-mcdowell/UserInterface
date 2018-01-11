//
//  UIViewController+ProgressHUD.swift
//  Source
//
//  Created by Ian McDowell on 1/18/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

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
                p.progressHUD = self
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
        self.progressHUDView?.setProgress(self.percentCompleted)
        self.progressHUDView?.setText(self.text, self.detailText, animated: false)
        self.progressHUDView?.setBackground(self.backgroundColor)
        self.progressHUDView?.setColor(self.color, animated: false)
        self.progressHUDView?.setShowsCancelButton(self.progress?.isCancellable ?? false)
        
        self.cornerRadius = self.cornerRadius + 0
        self.indeterminate = !(!self.indeterminate)
        self.dimsBackground = !(!self.dimsBackground)
    }
    
    private var progressObservations: [NSKeyValueObservation] = []
    public var progress: Progress? = nil {
        didSet {
            if let progress = progress {
                self.indeterminate = progress.isIndeterminate
                self.text = progress.localizedDescription
                self.showsCancelButton = progress.isCancellable
                let percentObservation = progress.observe(\Progress.fractionCompleted, changeHandler: { progress, change in
                    self.percentCompleted = progress.fractionCompleted
                })
                let indeterminateObservation = progress.observe(\Progress.isIndeterminate, changeHandler: { progress, change in
                    self.indeterminate = progress.isIndeterminate
                })
                let localizedDescriptionObservation = progress.observe(\Progress.localizedDescription, changeHandler: { progress, change in
                    self.text = progress.localizedDescription
                })
                let localizedAdditionalDescriptionObservation = progress.observe(\Progress.localizedAdditionalDescription, changeHandler: { progress, change in
                    self.detailText = progress.localizedAdditionalDescription
                })
                progressObservations = [percentObservation, indeterminateObservation, localizedDescriptionObservation, localizedAdditionalDescriptionObservation]
            } else {
                self.showsCancelButton = false
                progressObservations = []
            }
        }
    }
    
    /// The current value of the progress indicator, between 0 and 1. Animates when set. Initially set to 0.
    /// If it is set to an invalid value, the indicator becomes indeterminate.
    public var percentCompleted: Double = 0 {
        didSet {
            if percentCompleted == -1 {
                self.indeterminate = true
            } else if !(percentCompleted >= 0 && percentCompleted <= 1) {
                return
            }
            
            DispatchQueue.main.async {
                self.progressHUDView?.setProgress(self.percentCompleted)
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
                self.progressHUDView?.setText(self.text, self.detailText, animated: true)
            }
        }
    }
    
    public var detailText: String? = nil {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.setText(self.text, self.detailText, animated: true)
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
    
    private var showsCancelButton: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.progressHUDView?.setShowsCancelButton(self.showsCancelButton)
            }
        }
    }
    
    fileprivate func cancelButtonTappedInView() {
        if let progress = self.progress, progress.isCancellable {
            self.progress?.cancel()
        }
    }
}


/// The view that appears on screen.
private class ProgressHUDView: UIView {
    
    weak var progressHUD: ProgressHUD?
    
    /// Blurred background.
    private var blurEffect: UIBlurEffect
    private var blurView: UIVisualEffectView
    
    private var color: UIColor = .black {
        didSet {
            self.labelView.textColor = color
            self.detailLabelView.textColor = color.withAlphaComponent(0.8)
            self.progressView?.color = color
        }
    }
    
    /// View for showing determinate progress
    private var progressView: ProgressHUDProgressView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let progressView = progressView {
                progressView.color = self.color
                progressView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                progressView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                stackView.insertArrangedSubview(progressView, at: 0)
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
    
    private var stackView: UIStackView
    private var labelView: UILabel
    private var detailLabelView: UILabel
    private var cancelButton: UIButton
    
    init(blurStyle: UIBlurEffectStyle) {
        blurEffect = UIBlurEffect(style: blurStyle)
        blurView = UIVisualEffectView(effect: blurEffect)
        stackView = UIStackView()
        labelView = UILabel()
        detailLabelView = UILabel()
        cancelButton = UIButton(type: .system)
        
        super.init(frame: .zero)
        
        // This view defines its own width and height
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Mask all sublayers to the corner radius
        self.layer.masksToBounds = true
        
        // Add blur view & vibrancy view
        self.addSubview(blurView)
        blurView.constrainToEdgesOfSuperview()
        
        // Set up stack view
        self.addSubview(stackView)
        stackView.constrainToEdgesOfSuperview(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center

        // Set up label
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.textColor = self.color
        labelView.font = UIFont.preferredFont(forTextStyle: .body)
        stackView.addArrangedSubview(labelView)
        
        // Set up detail label
        detailLabelView.textAlignment = .center
        detailLabelView.numberOfLines = 0
        detailLabelView.textColor = self.color.withAlphaComponent(0.8)
        detailLabelView.font = UIFont.preferredFont(forTextStyle: .caption2)
        
        // Set up cancel button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: Double) {
        self.progressView?.setProgress(progress)
    }
    
    func setText(_ text: String?, _ detailText: String?, animated: Bool) {
        self.layoutIfNeeded()
        
        self.labelView.text = text
        self.detailLabelView.text = detailText
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                if text?.isEmpty ?? true {
                    self.labelView.alpha = 0
                } else {
                    self.labelView.alpha = 1
                }
                if detailText?.isEmpty ?? true {
                    self.detailLabelView.removeFromSuperview()
                } else if self.detailLabelView.superview == nil {
                    let index = self.stackView.arrangedSubviews.index(of: self.labelView)!.advanced(by: 1)
                    self.stackView.insertArrangedSubview(self.detailLabelView, at: index)
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
    
    func setShowsCancelButton(_ showCancel: Bool) {
        if showCancel {
            stackView.addArrangedSubview(cancelButton)
        } else {
            cancelButton.removeFromSuperview()
        }
    }
    
    @objc private func cancelButtonTapped() {
        progressHUD?.cancelButtonTappedInView()
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
    
    func setProgress(_ progress: Double) {}
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

    override func setProgress(_ progress: Double) {
        ringLayer.strokeEnd = CGFloat(progress)
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
