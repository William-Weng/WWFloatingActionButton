# WWFloatingActionButton

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-13.0](https://img.shields.io/badge/iOS-13.0-pink.svg?style=flat)](https://developer.apple.com/swift/) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

Android-like FloatingActionButton.

仿Android的FloatingActionButton.

![](./Example.gif)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWFloatingActionButton.git", .upToNextMajor(from: "1.0.0"))
]
```

![](./IBDesignable.png)

### Example
```swift

import UIKit
import WWPrint
import WWFloatingActionButton

final class ViewController: UIViewController {

    @IBOutlet weak var myFloatingActionButton: WWFloatingActionButton!
    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WWFloatingActionButton"
        myFloatingActionButton.myDelegate = self
        myFloatingActionButton.backgroundColor = .clear
    }
}

// MARK: - WWFloatButtonDelegate
extension ViewController: WWFloatingActionButtonDelegate {
    
    func currentView(with tag: Int) -> UIView {
        if let tabBarView = tabBarController?.view { return tabBarView }
        if let navigationView = navigationController?.view { return navigationView  }
        return self.view
    }
    
    func itemButtonImages(with tag: Int) -> [UIImage] {
        let images = [#imageLiteral(resourceName: "plus"), #imageLiteral(resourceName: "power"), #imageLiteral(resourceName: "refresh"), #imageLiteral(resourceName: "play"), #imageLiteral(resourceName: "chart")]
        return images
    }
    
    func itemButton(with tag: Int, didTouched index: Int) {
        let images = [#imageLiteral(resourceName: "desktop_1"), #imageLiteral(resourceName: "desktop_2"), #imageLiteral(resourceName: "desktop_5"), #imageLiteral(resourceName: "desktop_3"), #imageLiteral(resourceName: "desktop_4")]
        myImageView.image = images[index]
    }
    
    func itemButtonAnimationType(with tag: Int) -> WWFloatingButtonAnimationType {
        return .up
    }
    
    func mainButtonStatus(isTouched: Bool, with tag: Int) {
        wwPrint(isTouched)
    }
}
```
