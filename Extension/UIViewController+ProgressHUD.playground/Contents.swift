//: Playground - noun: a place where people can play

import PlaygroundSupport
import UIKit

let width = 350
let height = 600
let controlsHeight = 50

let rootView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))

// Create view controller to display HUD
let displayVC = UIViewController()
displayVC.title = "Progress HUD Demo"
let nav = UINavigationController(rootViewController: displayVC)
let view = displayVC.view!
view.backgroundColor = .white
nav.view.frame = CGRect(x: 0, y: 0, width: width, height: height - controlsHeight)
rootView.addSubview(nav.view)

// Add image to view
let imageView = UIImageView(image: UIImage(named: "landscape.jpg"))
view.addSubview(imageView)
imageView.constrainToEdgesOfSuperview()

// Target of the control buttons.
class Controller: NSObject {
    func show() {
        displayVC.progressHUD.show(animated: false)
    }
    func remove() {
        displayVC.progressHUD.remove()
    }
    func incProgress() {
        displayVC.progressHUD.progress = displayVC.progressHUD.progress + 0.1
    }
}

let controller = Controller()

// Add controls
let controlView = UIView()
rootView.addSubview(controlView)
controlView.frame = CGRect(x: 0, y: height - controlsHeight, width: width, height: controlsHeight)
controlView.backgroundColor = UIColor(white: 0.8, alpha: 1)


let showButton = UIButton(type: .system)
showButton.setTitle("Show", for: .normal)
showButton.addTarget(controller, action: #selector(Controller.show), for: .touchUpInside)

let removeButton = UIButton(type: .system)
removeButton.setTitle("Remove", for: .normal)
removeButton.addTarget(controller, action: #selector(Controller.remove), for: .touchUpInside)

let incProgressButton = UIButton(type: .system)
incProgressButton.setTitle("Progress++", for: .normal)
incProgressButton.addTarget(controller, action: #selector(Controller.incProgress), for: .touchUpInside)


let stackView = UIStackView(
    arrangedSubviews: [
        showButton,
        removeButton,
        incProgressButton
    ]
)
stackView.alignment = .fill
stackView.distribution = .fillProportionally
controlView.addSubview(stackView)
stackView.constrainToEdgesOfSuperview()

PlaygroundPage.current.liveView = rootView
