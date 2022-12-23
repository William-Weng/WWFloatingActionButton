//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/12/15.
///  ~/Library/Caches/org.swift.swiftpm/
///  file:///Users/william/Desktop/WWFloatingActionButton
/// [ICON來源](https://www.flaticon.com/)
/// [圖片來源](https://www.san-x.co.jp/d_present/)

import UIKit
import WWFloatingActionButton

final class ViewController: UIViewController {

    @IBOutlet weak var myFloatingActionButton: WWFloatingActionButton!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WWFloatingActionButton"
        myFloatingActionButton.myDelegate = self
        myFloatingActionButton.backgroundColor = .clear
    }
}

// MARK: - WWFloatButtonDelegate
extension ViewController: WWFloatingActionButtonDelegate {
    
    func currentViewType(with tag: Int) -> WWFloatingButtonAnimationViewType {
        return .tabBarController(self)
    }
    
    func itemButtonAnimationType(with tag: Int) -> WWFloatingButtonAnimationType {
        return .circleArc(startAngle: 90, endAngle: 180, distance: 200, count: 5)
    }

    func itemButtonImages(with tag: Int) -> [UIImage] {
        let images = [#imageLiteral(resourceName: "plus"), #imageLiteral(resourceName: "power"), #imageLiteral(resourceName: "refresh"), #imageLiteral(resourceName: "play"), #imageLiteral(resourceName: "chart")]
        return images
    }
    
    func itemButton(with tag: Int, didTouched index: Int) {
        let images = [#imageLiteral(resourceName: "desktop_1"), #imageLiteral(resourceName: "desktop_2"), #imageLiteral(resourceName: "desktop_5"), #imageLiteral(resourceName: "desktop_3"), #imageLiteral(resourceName: "desktop_4")]
        myImageView.image = images[index]
    }
    
    func mainButtonStatus(isTouched: Bool, with tag: Int) {
        titleLabel.text = isTouched ? "Touched" : "Closed"
    }
}
