//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import UserInterface

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Hello World!"
        label.textColor = .black
        label.textAlignment = .center
        
        view.addSubview(label)
        label.constrainToEdgesOfSuperview()
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = DraggableSplitViewController.init(direction: .vertical, leadingViewController: MyViewController(), trailingViewController: MyViewController())
