//
//  WWFloatingActionButton.swift
//  WWFloatingActionButton
//
//  Created by William.Weng on 2022/12/21.
//

import UIKit

// MARK: - 使用的協定
public protocol WWFloatingActionButtonDelegate {
    
    func currentViewType(with tag: Int) -> WWFloatingActionButton.AnimationViewType         // 取得該ViewController要彈出的底View
    func mainButtonStatus(isTouched: Bool, with tag: Int)                                   // 主按鈕的開關狀態
    func itemButton(with tag: Int, didTouched index: Int)                                   // 哪一個按鈕被按到，從0開始
    func itemButtonImages(with tag: Int) -> [UIImage]                                       // 子按鈕的圖片
    func itemButtonTexts(with tag: Int) -> [String]                                         // 子按鈕的文字
    func itemButtonTextsFont(with tag: Int) -> UIFont                                       // 子按鈕的文字字型
    func itemButtonTextsColor(with tag: Int) -> UIColor                                     // 子按鈕的文字顏色
    func itemButtonAnimationType(with tag: Int) -> WWFloatingActionButton.AnimationType     // 動畫的型式
}

// MARK: - WWFloatingActionButton
open class WWFloatingActionButton: UIView {
    
    @IBInspectable var itemButtonCount: Int = 1                                             // 子按鍵的數量
    @IBInspectable var itemGap: CGFloat = 8                                                 // 子按鍵的間隔
    @IBInspectable var labelGap: CGFloat = 8                                                // 子文字標籤的間隔
    @IBInspectable var animationDuration: CGFloat = 0.5                                     // 子按鍵的動畫時間
    @IBInspectable var itemBackgroundColor: UIColor = .gray.withAlphaComponent(0.3)         // 背景圖的顏色
    @IBInspectable var touchedImage: UIImage = UIImage()                                    // 開啟時的圖片
    @IBInspectable var disableImage: UIImage = UIImage()                                    // 關閉時的圖片

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
    public var myDelegate: WWFloatingActionButtonDelegate?
    
    private var isInitSettting = false
    private var floatingButtonMainView: UIView = UIView()
    private var itemButtons: [UIButton] = []
    private var itemButtonLabels: [UILabel] = []

    private var itemImages: [UIImage]? { get { myDelegate?.itemButtonImages(with: tag) }}
    private var itemTexts: [String]? { get { myDelegate?.itemButtonTexts(with: tag) }}

    private var currentView: UIView? {
        
        get {
            guard let viewType = myDelegate?.currentViewType(with: tag) else { return nil }
            
            switch viewType {
            case .viewController(let viewController): return viewController.view
            case .navigationController(let viewController): return viewController.navigationController?.view
            case .tabBarController(let viewController): return viewController.tabBarController?.view
        }
    }}
    
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
        
        guard let currentView = self.currentView else { return }
        
        translatesAutoresizingMaskIntoConstraints = true
        currentView.addSubview(self)
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
        floatingButtonMainView.backgroundColor = .clear
        
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
            let _label = itemButtonLabelMaker(for: _button, text: itemTexts?[safe: index])
            
            _button.alpha = 0.0
            _label.alpha = 0.0
            
            itemButtons.append(_button)
            itemButtonLabels.append(_label)
            
            floatingButtonMainView.addSubview(_button)
            floatingButtonMainView.addSubview(_label)
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
    
    /// 建立文字ItemLabel
    /// - Parameters:
    ///   - button: UIButton
    ///   - text: String?
    /// - Returns: UILabel
    func itemButtonLabelMaker(for button: UIButton, text: String?) -> UILabel {
        
        let label = UILabel(frame: .zero)
        let animationType = myDelegate?.itemButtonAnimationType(with: tag) ?? .up(isTextMirror: false)
        let font = myDelegate?.itemButtonTextsFont(with: tag) ?? UIFont.systemFont(ofSize: 12.0)
        let textColor = myDelegate?.itemButtonTextsColor(with: tag) ?? .black
        
        switch animationType {
        case .up(let isTextMirror), .down(let isTextMirror): label.layer.anchorPoint = !isTextMirror ? CGPoint(x: 1.0, y: 0.5) : CGPoint(x: 0.0, y: 0.5)
        case .left(let isTextMirror), .right(let isTextMirror): label.layer.anchorPoint = !isTextMirror ? CGPoint(x: 0.5, y: 0.5) : CGPoint(x: 0.5, y: 0.5)
        case .circleArc(_, _, _): break
        }
        
        label.text = text
        label.font = font
        label.textColor = textColor
        label.sizeToFit()
        label.center = animationType.labelCenter(for: button, textGap: labelGap)
        
        return label
    }
    
    /// 切換Button能不能被按
    /// - Parameter isEnabled: Bool
    func userInteractionEnabled(_ isEnabled: Bool) {
        
        mainButton.isUserInteractionEnabled = isEnabled
        floatingButtonMainView.isUserInteractionEnabled = isEnabled
        itemButtons.forEach { $0.isUserInteractionEnabled = isEnabled }
    }
    
    /// 切換開關
    /// - Parameter action: (() -> Void)?
    func toggleFloatButton(action: (() -> Void)?) {
        
        isTouched.toggle()
        
        myDelegate?.mainButtonStatus(isTouched: isTouched, with: tag)
        itemButtonAnimation(for: itemButtons, andLabels: itemButtonLabels, isTouched: isTouched, finished: { _ in action?() })
    }
    
    /// 主按鍵被點到的動畫 => 彈出畫面的動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - labels: [UILabel]
    ///   - currentView: UIView?
    ///   - finished: (Bool) -> Void
    func mainButtonTouchedAnimation(for buttons: [UIButton], labels: [UILabel], onView currentView: UIView?, finished: @escaping (Bool) -> Void) {
        
        guard let currentView = self.currentView else { return }
        
        let animationType = myDelegate?.itemButtonAnimationType(with: tag) ?? .up(isTextMirror: false)
        currentView.bringSubviewToFront(floatingButtonMainView)
        currentView.bringSubviewToFront(self)
        
        itemTransparency(alpha: 0.0, itemButtons: buttons, itemLabels: labels)
        floatingButtonMainView.backgroundColor = itemBackgroundColor
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            let alpha = 1.0
            
            for (index, button) in buttons.enumerated() {
                
                button.frame = animationType.frame(with: index, baseFrame: self.frame, itemGap: self.itemGap, total: self.itemButtonCount)
                button.alpha = alpha
                
                if let label = labels[safe: index] {
                    label.center = animationType.labelCenter(for: button, textGap: self.labelGap)
                    label.alpha = alpha
                }
            }
            
        }, completion: { _ in
            self.userInteractionEnabled(true)
            finished(true)
        })
    }
    
    /// 主按鍵Close的動畫 => 回到原點Button的位置
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - labels: [UILabel]
    ///   - currentView: UIView?
    ///   - finished: (Bool) -> Void
    func mainButtonDisableAnimation(for buttons: [UIButton], labels: [UILabel], onView currentView: UIView?, finished: @escaping (Bool) -> Void) {
        
        guard let currentView = self.currentView else { return }
        
        let animationType = myDelegate?.itemButtonAnimationType(with: tag) ?? .up(isTextMirror: false)
        
        itemTransparency(alpha: 1.0, itemButtons: buttons, itemLabels: labels)
        floatingButtonMainView.backgroundColor = .clear
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            let alpha = 0.0
            
            for (index, button) in buttons.enumerated() {
                
                button.center = self.center
                button.alpha = alpha
                
                if let label = labels[safe: index] {
                    label.center = animationType.labelCenter(for: button, textGap: self.labelGap)
                    label.alpha = alpha
                }
            }
                        
        }, completion: { _ in
            
            currentView.sendSubviewToBack(self.floatingButtonMainView)
            currentView.bringSubviewToFront(self)
            self.mainButton.isUserInteractionEnabled = true
            finished(true)
        })
    }
    
    /// 開關動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - isTouched: Bool
    ///   - finished: (Bool) -> Void
    func itemButtonAnimation(for buttons: [UIButton], andLabels labels: [UILabel], isTouched: Bool, finished: @escaping (Bool) -> Void) {
        
        self.userInteractionEnabled(false)
        
        if (!isTouched) { mainButtonDisableAnimation(for: buttons, labels: labels, onView: currentView) { finished($0) }; return }
        mainButtonTouchedAnimation(for: buttons, labels: labels, onView: currentView, finished: { finished($0) })
    }
    
    /// 項目按扭的位置 / 大小
    /// - Parameters:
    ///   - index: Int
    ///   - baseFrame: CGRect
    ///   - itemGap: CGFloat
    /// - Returns: CGRect
    func itemButtonFrame(with index: Int, baseFrame: CGRect, itemGap: CGFloat) -> CGRect {
        let coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y + ((index + 1)._CGFloat() * (baseFrame.size.height + itemGap)))
        return CGRect(origin: coordinates, size: baseFrame.size)
    }
    
    /// 設定項目透明度
    /// - Parameters:
    ///   - alpha: CGFloat
    ///   - itemButtons: [UIButton]
    ///   - itemLabels: [UILabel]
    func itemTransparency(alpha: CGFloat, itemButtons: [UIButton], itemLabels: [UILabel]) {
        itemButtons.forEach { $0.alpha = alpha }
        itemLabels.forEach { $0.alpha = alpha }
    }
}

