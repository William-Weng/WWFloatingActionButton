# WWFloatingActionButton

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-13.0](https://img.shields.io/badge/iOS-13.0-pink.svg?style=flat)](https://developer.apple.com/swift/) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

Android-like FloatingActionButton. / 仿Android的FloatingActionButton.

![](./Example.gif)

### 版本更新說明
|版本號|說明|備註|
|-|-|-|
|1.2.3|修正主按鍵圖示過大的問題 for iOS 15以上|-|
|1.2.2|修正主按鍵圖示過大的問題|-|
|1.2.1|補下右的文字顯示功能|-|
|1.2.0|加上左的文字顯示功能|-|
|1.1.2|修正extension CGFloat|-|
|1.1.1|修改currentViewType(with tag: Int)|-|
|1.1.0|新增圓弧動畫效果|-|
|1.0.0|基本上下左右四個方向的動畫|-|

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWFloatingActionButton.git", .upToNextMajor(from: "1.2.3"))
]
```

![](./IBDesignable.png)

### Example
```swift
import UIKit
import WWFloatingActionButton

final class ViewController: UIViewController {
    
    enum FloatingActionButtonTag: Int {
        case left = 100
        case right = 101
    }
    
    @IBOutlet weak var leftFloatingActionButton: WWFloatingActionButton!
    @IBOutlet weak var rightFloatingActionButton: WWFloatingActionButton!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WWFloatingActionButton"
        
        leftFloatingActionButton.myDelegate = self
        rightFloatingActionButton.myDelegate = self
        leftFloatingActionButton.backgroundColor = .clear
        rightFloatingActionButton.backgroundColor = .clear
    }
}

// MARK: - WWFloatButtonDelegate
extension ViewController: WWFloatingActionButtonDelegate {
    
    func currentViewType(with tag: Int) -> WWFloatingActionButton.AnimationViewType {
        return .tabBarController(self)
    }
    
    func itemButtonAnimationType(with tag: Int) -> WWFloatingActionButton.AnimationType {
        
        guard let buttonType = FloatingActionButtonTag(rawValue: tag) else { return .up(isTextMirror: false) }
        
        switch buttonType {
        case .left: return .up(isTextMirror: true)
        case .right: return .down(isTextMirror: false)
        }
    }
    
    func itemButtonImages(with tag: Int) -> [UIImage] {
        let images = [#imageLiteral(resourceName: "plus"), #imageLiteral(resourceName: "power"), #imageLiteral(resourceName: "refresh"), #imageLiteral(resourceName: "play"), #imageLiteral(resourceName: "chart")]
        return images
    }
    
    func itemButtonTexts(with tag: Int) -> [String] {
        return ["OPEN", "SHARE", "INFO", "CLOSE", "ADD"]
    }
    
    func itemButtonTextsFont(with tag: Int) -> UIFont {
        return UIFont.systemFont(ofSize: 32)
    }
    
    func itemButtonTextsColor(with tag: Int) -> UIColor {
        return .red
    }
    
    func mainButtonStatus(isTouched: Bool, with tag: Int) {
        statusImageView.image = isTouched ? #imageLiteral(resourceName: "LightOn") : #imageLiteral(resourceName: "LightOff")
    }
    
    func itemButton(with tag: Int, didTouched index: Int) {
        let images = [#imageLiteral(resourceName: "desktop_1"), #imageLiteral(resourceName: "desktop_2"), #imageLiteral(resourceName: "desktop_5"), #imageLiteral(resourceName: "desktop_3"), #imageLiteral(resourceName: "desktop_4")]
        myImageView.image = images[index]
    }
}
```
