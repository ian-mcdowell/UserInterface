//
//  UIViewController+Custom.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

extension UIViewController {
    
    public func removeFromParent() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    public func addChild(_ vc: UIViewController) {
        addChild(vc, toSubview: self.view)
    }
    public func addChild(_ vc: UIViewController, toSubview view: UIView) {
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }

    @objc open func close() {
        self.closeWithAnimation(true)
    }

    public func closeWithAnimation(_ animated: Bool) {
        self.closeWithAnimationAndCompletion(animated, nil)
    }

    public func closeWithAnimationAndCompletion(_ animated: Bool, _ completion: (() -> Swift.Void)?) {
        if self.presentingViewController == nil {
            completion?()
            return
        }
        self.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
    
    public func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    public func closeOrGoBack() {
        if let navigationController = self.navigationController, navigationController.viewControllers.first != self {
            self.goBack()
        } else {
            self.close()
        }
    }

    public func addCancelButtonIfNeeded() {
        if self.navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(UIViewController.close)
            )
        }
    }

    public func addCloseButtonIfNeeded() {
        if self.navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "Close", in: Bundle.init(for: SOViewController.self), compatibleWith: nil)?.scaled(toSize: CGSize(width: 25, height: 25)),
                style: .plain,
                target: self,
                action: #selector(UIViewController.close)
            )
        }
    }

    public func showYesNoAlert(_ title: String?, text: String?, destructive: Bool = false, completion: ((_ approved: Bool) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "No",
                style: .cancel,
                handler: { _ in
                    completion?(false)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Yes",
                style: destructive ? .destructive : .default,
                handler: { _ in
                    completion?(true)
                }
            )
        )

        self.present(alert, animated: true, completion: nil)
    }

    public func showAlert(_ title: String?, text: String?, destructive: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: destructive ? .destructive : .default,
                handler: { _ in
                    completion?()
                }
            )
        )

        self.present(alert, animated: true, completion: nil)
    }

    public func showCancelableAlert(_ title: String?, text: String?, destructive: Bool = false, completion: ((_ cancelled: Bool) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    completion?(true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: destructive ? .destructive : .default,
                handler: { _ in
                    completion?(false)
                }
            )
        )

        self.present(alert, animated: true, completion: nil)
    }
    
    public func showTextEntryAlert(_ title: String?, message: String?, actionButton: String = "OK", placeholder: String? = nil, existingText: String? = nil, keyboardType: UIKeyboardType = .default, destructive: Bool = false, completion: ((_ enteredText: String?) -> Void)? = nil) {
        
        var text: UITextField!
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addTextField(configurationHandler: { textField in
            text = textField
            textField.placeholder = placeholder
            textField.text = existingText
            textField.keyboardType = keyboardType
        })
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    completion?(nil)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: actionButton,
                style: destructive ? .destructive : .default,
                handler: { _ in
                    completion?(text.text)
                }
            )
        )
        
        self.present(alert, animated: true, completion: nil)
    }

    public func showNotImplementedAlert() {
        self.showAlert("Not implemented", text: "This feature has not been implemented yet.")
    }
}
