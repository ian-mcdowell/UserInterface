//
//  SOViewController.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

/// Base class for a view controller, which can respond to theme updates, among other things.
open class SOViewController: UIViewController, Themeable {

    public var transitionController: SOTransitionController? {
        didSet {
            self.transitioningDelegate = transitionController
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.definesPresentationContext = true
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.applyCurrentTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(SOViewController.applyCurrentTheme), name: Theme.DidChangeNotification, object: nil)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        #if DEBUG
        self.checkDeallocation()
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Theme.DidChangeNotification, object: nil)
    }

    private var lastTheme: Theme?
    @objc private func applyCurrentTheme() {
        let theme = Theme.current
        self.applyTheme(theme)
        if theme != lastTheme {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        lastTheme = theme
    }

    
    open func applyTheme(_ theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.navigationController?.view.backgroundColor = theme.backgroundColor
    }
}
