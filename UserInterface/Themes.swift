//
//  Themes.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
    
/// Protocol defining something that can receive a theme update.
public protocol Themeable {
    func applyTheme(_ theme: Theme)
}

private var _currentTheme: Theme!

/// Consists of various color values which are themed throughout the app.
public struct Theme {
    
    public enum ThemeStyle {
        case light, dark
    }
    
    public static let DidChangeNotification = NSNotification.Name(rawValue: "ThemeDidChange")
    
    public static var current: Theme {
        return _currentTheme
    }
    
    fileprivate let bundle: Bundle
    public let style: ThemeStyle
    public init(bundle: Bundle, style: ThemeStyle) {
        self.bundle = bundle
        self.style = style
    }
    
    /// Applies the current theme to a running app. This should be called on launch.
    public func apply(toApplication application: UIApplication?) {
        let theme = self
        
        _currentTheme = self
        
        // UINavigationBar
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().barTintColor = theme.barTintColor
        UINavigationBar.appearance().tintColor = theme.barButtonColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: theme.barTextColor
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSForegroundColorAttributeName: theme.barTextColor
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
    
    private func color(_ name: String) -> UIColor {
        guard let color = UIColor(named: name, in: self.bundle, compatibleWith: UITraitCollection()) else {
            assertionFailure("Theme: No color found in theme bundle with the name \(name).")
            return UIColor.white
        }
        return color
    }
    private func optionalColor(_ name: String) -> UIColor? {
        return UIColor(named: name, in: self.bundle, compatibleWith: UITraitCollection())
    }

    public var mainColor: UIColor { return color("primary") }
    public var barTextColor: UIColor { return color("barText") }
    public var barButtonColor: UIColor { return color("barButton") }
    public var barButtonDisabledColor: UIColor { return color("barButtonDisabled") }
    public var barTintColor: UIColor? { return optionalColor("barTint") }
    public var darkBackgroundColor: UIColor { return color("backgroundDark") }
    public var backgroundColor: UIColor { return color("background") }
    public var dimmedBackgroundColor: UIColor { return color("backgroundDimmed") }
    public var emptyTextColor: UIColor { return color("emptyText") }
    public var separatorColor: UIColor { return color("separator") }
    public var tableCellBackgroundColor: UIColor { return color("tableCellBackground") }
    public var tableCellBackgroundSelectedColor: UIColor { return color("tableCellSelectedBackground") }
    public var tableCellTextColor: UIColor { return color("tableCellText") }
    public var tableCellSecondaryTextColor: UIColor { return color("tableCellTextSecondary") }
    public var tableHeaderTextColor: UIColor { return color("tableHeaderText") }
    public var placeholderTextColor: UIColor { return color("placeholderText") }
    public var borderSelectedColor: UIColor { return color("borderSelected") }
    public var borderColor: UIColor { return color("border") }

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
