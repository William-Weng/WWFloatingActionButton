//
//  Constant.swift
//  WWFloatingActionButton
//
//  Created by William.Weng on 2022/12/15.
//

import UIKit

public extension WWFloatingActionButton {
    
    // MARK: - 執行在哪個類型的View上
    enum AnimationViewType {
        case viewController(_ target: UIViewController)
        case navigationController(_ target: UIViewController)
        case tabBarController(_ target: UIViewController)
    }
    
    // MARK: - 動畫類型
    enum AnimationType {
        
        case up
        case down
        case left
        case right
        case circleArc(startAngle: CGFloat, endAngle: CGFloat, distance: CGFloat)
        
        /// 產生動畫的frame
        /// - Parameters:
        ///   - index: Int
        ///   - baseFrame: 為基準的Frame
        ///   - itemGap: ItemButton間的間隔
        /// - Returns: CGRect
        func frame(with index: Int, baseFrame: CGRect, itemGap: CGFloat, total: Int) -> CGRect {
            
            let offset = (index + 1)._CGFloat() * (baseFrame.size.height + itemGap)
            var coordinates = CGPoint()
            
            switch self {
            case .up: coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y - offset)
            case .down: coordinates = CGPoint(x: baseFrame.origin.x, y: baseFrame.origin.y + offset)
            case .left: coordinates = CGPoint(x: baseFrame.origin.x - offset, y: baseFrame.origin.y)
            case .right: coordinates = CGPoint(x: baseFrame.origin.x + offset, y: baseFrame.origin.y)
            case .circleArc(let startAngle, let endAngle, let distance): coordinates = circleArcFrame(with: index, baseFrame: baseFrame, startAngle: startAngle, endAngle: endAngle, distance: distance, total: total)
            }
            
            return CGRect(origin: coordinates, size: baseFrame.size)
        }
        
        func labelCenter(for button: UIButton, textGap: CGFloat) -> CGPoint {
            
            let offset = (button.bounds.width * 0.5 + textGap)
            let center: CGPoint
            
            switch self {
            case .up, .down: center = CGPoint(x: button.center.x - offset, y: button.center.y)
            case .left, .right: center = CGPoint(x: button.center.x, y: button.center.y - offset)
            case .circleArc(_, _, _): center = CGPoint(x: button.center.x - offset, y: button.center.y)
            }
            
            return center
        }
        
        /// 圓弧的frame
        /// - Parameters:
        ///   - index: Int
        ///   - baseFrame: 為基準的Frame
        ///   - startAngle: 起始的角度
        ///   - endAngle: 結束的角度
        ///   - distance: 間隔
        ///   - total: ItemButton數量
        /// - Returns: CGPoint
        private func circleArcFrame(with index: Int, baseFrame: CGRect, startAngle: CGFloat, endAngle: CGFloat, distance: CGFloat, total: Int) -> CGPoint {
            
            if total < 2 { return .zero }
            
            var coordinates = CGPoint()
            
            let gap = total - 1
            let angleGap = (startAngle - endAngle) / gap._CGFloat()
            let angle = angleGap * (gap - index)._CGFloat() + endAngle
            
            coordinates = CGPoint(x: baseFrame.origin.x + distance * cos(angle._radian()), y: baseFrame.origin.y - distance * sin(angle._radian()))
            
            return coordinates
        }
    }
}
