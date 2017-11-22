//
//  Themes.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit
    
/// Protocol defining something that can receive a theme update.
public protocol Themeable {
    func applyTheme(_ theme: Theme)
}

public extension Themeable {
    func applyCurrentTheme() {
        if let theme = Theme.current {
            self.applyTheme(theme)
        }
    }
}

/// Consists of various color values which are themed throughout the app.
public class Theme {
    
    public enum ThemeStyle {
        case light, dark
    }
    
    public static let DidChangeNotification = NSNotification.Name(rawValue: "ThemeDidChange")
    
    public private(set) static var current: Theme?
    
    fileprivate let bundle: Bundle
    public let style: ThemeStyle
    public init(bundle: Bundle, style: ThemeStyle) {
        self.bundle = bundle
        self.style = style
    }
    
    /// Applies the current theme to a running app. This should be called on launch.
    public func apply(toApplication application: UIApplication?) {
        let theme = self
        
        Theme.current = self
        
        // UINavigationBar
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().barTintColor = theme.barTintColor
        UINavigationBar.appearance().tintColor = theme.barButtonColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        UINavigationBar.appearance().isTranslucent = false
        
        // UIToolbar
        UIToolbar.appearance().barStyle = theme.barStyle
        UIToolbar.appearance().barTintColor = theme.barTintColor
        UIToolbar.appearance().tintColor = theme.barButtonColor
        UIToolbar.appearance().isTranslucent = false
        
        // UITabBar
        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().barTintColor = theme.barTintColor
        UITabBar.appearance().tintColor = theme.barButtonColor
        UITabBar.appearance().unselectedItemTintColor = theme.barButtonDisabledColor
        UITabBar.appearance().isTranslucent = false
        
        // UITableView
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UITableView.appearance().separatorColor = theme.separatorColor
        
        // UITableViewCell
        UITableViewCell.appearance().backgroundColor = theme.tableCellBackgroundColor
        UITableViewCell.appearance().tintColor = theme.tableCellTextColor
        
        // UITableView header
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.tableHeaderTextColor
        
        // UISearchBar
        UISearchBar.appearance().barTintColor = theme.backgroundColor
        UISearchBar.appearance().tintColor = theme.barButtonColor
        
        // Hacky way to reload everything
        if let app = application {
            for window in app.windows {
                window.tintColor = theme.mainColor
                
                for view in window.subviews {
                    view.removeFromSuperview()
                    window.addSubview(view)
                }
            }
        }
        
        NotificationCenter.default.post(name: Theme.DidChangeNotification, object: nil)
    }
    
    private var colorCache: [String: UIColor] = [:]
    private func color(_ name: String) -> UIColor {
        if let cached = colorCache[name] {
            return cached
        }
        guard let color = UIColor(named: name, in: self.bundle, compatibleWith: nil) else {
            assertionFailure("Theme: No color found in theme bundle with the name \(name)")
            return UIColor.white
        }
        colorCache[name] = color
        return color
    }
    private func optionalColor(_ name: String) -> UIColor? {
        if let cached = colorCache[name] {
            return cached
        }
        if let color = UIColor(named: name, in: self.bundle, compatibleWith: UITraitCollection()) {
            colorCache[name] = color
            return color
        }
        return nil
    }

    public var mainColor: UIColor { return color("primary") }
    
    // MARK: Bars
    public var barTextColor: UIColor { return color("barText") }
    public var barButtonColor: UIColor { return color("barButton") }
    public var barButtonDisabledColor: UIColor { return color("barButtonDisabled") }
    public var barTintColor: UIColor { return color("barTint") }
    
    // MARK: Background
    public var darkBackgroundColor: UIColor { return color("backgroundDark") }
    public var backgroundColor: UIColor { return color("background") }
    public var dimmedBackgroundColor: UIColor { return color("backgroundDimmed") }
    
    // MARK: UITableViewCell
    public var tableCellBackgroundColor: UIColor { return color("tableCellBackground") }
    public var tableCellBackgroundSelectedColor: UIColor { return color("tableCellSelectedBackground") }
    public var tableCellTextColor: UIColor { return color("tableCellText") }
    public var tableCellSecondaryTextColor: UIColor { return color("tableCellTextSecondary") }
    public var tableHeaderTextColor: UIColor { return color("tableHeaderText") }
    
    // MARK: Text
    public var placeholderTextColor: UIColor { return color("placeholderText") }
    public var emptyTextColor: UIColor { return color("emptyText") }
    
    // MARK: Borders
    public var borderSelectedColor: UIColor { return color("borderSelected") }
    public var borderColor: UIColor { return color("border") }
    public var separatorColor: UIColor { return color("separator") }
    
    // MARK: Tabs
    public var tabBackgroundSelectedColor: UIColor { return color("tabBackgroundSelected") }
    public var tabCloseButtonColor: UIColor { return color("tabCloseButton") }
    public var tabCloseButtonBackgroundColor: UIColor { return color("tabCloseButtonBackground") }

    public var barStyle: UIBarStyle {
        switch self.style {
        case .light:
            return .default
        case .dark:
            return .black
        }
    }
    
    public var statusBarStyle: UIStatusBarStyle {
        switch self.style {
        case .light:
            return UIStatusBarStyle.default
        case .dark:
            return UIStatusBarStyle.lightContent
        }
    }
}

extension Theme: Equatable {
    public static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.bundle == rhs.bundle && lhs.style == lhs.style
    }
}
