# UserInterface

This framework contains many helpful user interface components used throughout my apps. It acts as a layer on top of UIKit in many cases. Many of these components should be refactored out into separate libraries, but currently have dependencies on each other.

In this framework, you will find things like:
* `Theme` - apply colors and styles across an app, loaded from a bundle.
* `PropertiesViewController` - A layer on top of UITableViewController, which provides an easy way to display content in a table view.
* `Transition` - A few UIViewController transitions used throughout my apps, such as zoom or overlay.
* `FeatureRequest` - Provides UI for requesting features in an app
* `UIViewController+ProgressHUD` - Add a loading indicator to any UIViewController
* `UIViewController+CheckDeallocation` - When debugging, notify the developer if a view controller is not deallocated when it goes off screen
* `UIView+GestureRecognizer` - Block-based UITapGestureRecognizer

Additionally, there are a ton of extensions on UIKit types, which provide easier ways of doing things:
* `NSLayoutConstraint+Custom` - Easier methods for creating & enabling constraints
* `UICollectionView+Custom` and `UITableView+Custom` - Retrieve cells by class, without reuse identifiers, with generics
* `UIColor+Custom` - UIColor from hex, lighten, darken

Don't hesitate to use any of this code in your app. In the future, I plan to release these components as separate libraries with their dependencies fully defined.
