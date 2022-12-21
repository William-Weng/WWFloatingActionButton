//
//  WWFloatingActionButton.swift
//  WWFloatingActionButton
//
//  Created by William.Weng on 2022/12/21.
//

import UIKit

// MARK: - 動畫類型
public enum WWFloatingButtonAnimationType {
    
    case up
    case down
    case left
    case right
    
    func frame(with index: Int, baseFrame: CGRect, itemGap: CGFloat) -> CGRect {
        
        let offset = (index + 1)._CGFloat() * (baseFrame.size.height + itemGap)
        var coordinates = CGPoint()
        
        switch self {
        case .up: coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y - offset)
        case .down: coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y + offset)
        case .left: coordinates = CGPoint(x: baseFrame.origin.x - offset, y: baseFrame.origin.y)
        case .right: coordinates = CGPoint(x: baseFrame.origin.x + offset, y: baseFrame.origin.y)
        }
        
        return CGRect(origin: coordinates, size: baseFrame.size)
    }
}

// MARK: - 使用的協定
public protocol WWFloatingActionButtonDelegate {
    
    func currentView(with tag: Int) -> UIView                                           // 取得該ViewController要彈出的底View
    func mainButtonStatus(isTouched: Bool, with tag: Int)                               // 主按鈕的開關狀態
    func itemButton(with tag: Int, didTouched index: Int)                               // 哪一個按鈕被按到，從0開始
    func itemButtonImages(with tag: Int) -> [UIImage]                                   // 子按鈕的圖片
    func itemButtonAnimationType(with tag: Int) -> WWFloatingButtonAnimationType        // 動畫的型式
}

open class WWFloatingActionButton: UIView {
    
    @IBInspectable var itemButtonCount: Int = 1                                         // 子按鍵的數量
    @IBInspectable var itemGap: CGFloat = 10                                            // 子按鍵的間隔
    @IBInspectable var animationDuration: CGFloat = 0.5                                 // 子按鍵的動畫時間
    @IBInspectable var itemBackgroundColor: UIColor = .gray.withAlphaComponent(0.3)     // 背景圖的顏色
    @IBInspectable var touchedImage: UIImage = UIImage()                                // 開啟時的圖片
    @IBInspectable var disableImage: UIImage = UIImage()                                // 關閉時的圖片
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
    public var myDelegate: WWFloatingActionButtonDelegate?
    
    private var isInitSettting = false
    private var floatingButtonMainView: UIView = UIView()
    private var itemButtons: [UIButton] = []
    
    private var currentView: UIView? { get { myDelegate?.currentView(with: tag) }}
    private var itemImages: [UIImage]? { get { myDelegate?.itemButtonImages(with: tag) }}
    private var isTouched: Bool = false {
        willSet {
            let image = (newValue) ? touchedImage : disableImage
            mainButton.setImage(image, for: .normal)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromXib()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromXib()
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        initSetting()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        mainButton.setImage(disableImage, for: .normal)
        contentView.prepareForInterfaceBuilder()
    }
    
    @objc func itemButtonAction(_ sender: UIButton) {
        toggleFloatButton { self.myDelegate?.itemButton(with: self.tag, didTouched: sender.tag) }
    }

    @IBAction func mainButtonAction(_ sender: UIButton) {
        
        translatesAutoresizingMaskIntoConstraints = true
        
        let currentView = myDelegate?.currentView(with: tag)
        currentView?.addSubview(self)
        toggleFloatButton(action: {})
    }
}

// MARK: - 小工具
private extension WWFloatingActionButton {
    
    /// 讀取Nib畫面 => 加到View上面
    func initViewFromXib() {

        let bundle = Bundle.module
        let name = String(describing: Self.self)
        bundle.loadNibNamed(name, owner: self, options: nil)
        
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    /// 切始化 (只會Run一次)
    func initSetting() {
        
        guard !isInitSettting else { return }
                
        initFloatingButtonMainView()
        initItemButton()
        
        isTouched = false
        isInitSettting = true
        
        myDelegate?.mainButtonStatus(isTouched: isTouched, with: tag)
    }
    
    /// 初始化ItemButton們的底View
    func initFloatingButtonMainView() {
        
        guard let currentView = currentView else { return }
        
        floatingButtonMainView = UIView(frame: currentView.frame)
        floatingButtonMainView.isUserInteractionEnabled = false
        floatingButtonMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.mainButtonAction(_:))))
        floatingButtonMainView.backgroundColor = itemBackgroundColor
        
        currentView.insertSubview(floatingButtonMainView, at: 0)
    }
    
    /// 切始化ItemButton
    func initItemButton() {
        
        guard itemButtons.isEmpty,
              let itemImages = itemImages
        else {
            return
        }
                
        for index in 0..<itemButtonCount {
            let _button = itemButtonMaker(with: index, image: itemImages[safe: index])
            itemButtons.append(_button)
            floatingButtonMainView.addSubview(_button)
        }
    }
    
    /// 建立ItemButton
    /// - Parameters:
    ///   - index: Int
    ///   - image:  UIImage?
    /// - Returns: UIButton
    func itemButtonMaker(with index: Int, image: UIImage?) -> UIButton {
        
        let button = UIButton(frame: CGRect(origin: .zero, size: bounds.size))
        
        button.backgroundColor = .clear
        button.layer._maskedCorners(radius: button.frame.height * 0.5)
        button.isUserInteractionEnabled = false
        button.tag = Int(index)
        button.setImage(image, for: .normal)
        button.center = self.center
        
        button.addTarget(self, action: #selector(Self.itemButtonAction(_:)), for: .touchUpInside)
        
        return button
    }
    
    /// 切換Button能不能被按
    /// - Parameter isEnabled: Bool
    func userInteractionEnabled(_ isEnabled: Bool) {

        mainButton.isUserInteractionEnabled = isEnabled
        floatingButtonMainView.isUserInteractionEnabled = isEnabled
        itemButtons.forEach { $0.isUserInteractionEnabled = isEnabled }
    }
    
    /// 開關動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - isTouched: Bool
    ///   - finished: (Bool) -> Void
    func itemButtonAnimation(for buttons: [UIButton], isTouched: Bool, finished: @escaping (Bool) -> Void) {
        
        self.userInteractionEnabled(false)
        
        if (!isTouched) { mainButtonDisableAnimation(for: buttons, onView: currentView) { finished($0) }; return }
        mainButtonTouchedAnimation(for: buttons, onView: currentView, finished: { finished($0) })
    }
    
    /// 切換開關
    /// - Parameter action: (() -> Void)?
    func toggleFloatButton(action: (() -> Void)?) {
        
        isTouched.toggle()
        
        myDelegate?.mainButtonStatus(isTouched: isTouched, with: tag)
        itemButtonAnimation(for: itemButtons, isTouched: isTouched, finished: { _ in action?() })
    }
    
    /// 主按鍵被點到的動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - currentView: UIView?
    ///   - finished: (Bool) -> Void
    func mainButtonTouchedAnimation(for buttons: [UIButton], onView currentView: UIView?, finished: @escaping (Bool) -> Void) {
        
        guard let currentView = self.currentView else { return }
        
        let animationType = myDelegate?.itemButtonAnimationType(with: tag) ?? .up
        currentView.bringSubviewToFront(floatingButtonMainView)
        currentView.bringSubviewToFront(self)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            for (index, button) in buttons.enumerated() {
                button.frame = animationType.frame(with: index, baseFrame: self.frame, itemGap: self.itemGap)
            }
            
        }, completion: { _ in
            self.userInteractionEnabled(true)
            finished(true)
        })
    }
    
    func coordinates(with index: Int, baseFrame: CGRect, itemGap: CGFloat) -> CGRect {
        let coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y + ((index + 1)._CGFloat() * (baseFrame.size.height + itemGap)))
        return CGRect(origin: coordinates, size: baseFrame.size)
    }
    
    /// 主按鍵Close的動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - currentView: UIView?
    ///   - finished: (Bool) -> Void
    func mainButtonDisableAnimation(for buttons: [UIButton], onView currentView: UIView?, finished: @escaping (Bool) -> Void) {
        
        guard let currentView = self.currentView else { return }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            buttons.forEach { $0.center = self.center }
            
        }, completion: { _ in
            
            currentView.sendSubviewToBack(self.floatingButtonMainView)
            currentView.bringSubviewToFront(self)
            self.mainButton.isUserInteractionEnabled = true
            finished(true)
        })
    }
}

