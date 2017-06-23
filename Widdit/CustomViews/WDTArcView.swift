//
//  WDTArcView.swift
//  Widdit
//
//  Created by Ilya Kharabet on 12.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit


@IBDesignable final class WDTArcView: UIView {

    @IBInspectable dynamic var backColor: UIColor = .white
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(backColor.cgColor)
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addPath(CGPath.arc(in: rect, withHeight: rect.height))
            path.closeSubpath()
            
            context.addPath(path)
            context.fillPath()
        }
    }

}

extension CGPath {
    
    class func arc(in rect: CGRect, withHeight height: CGFloat) -> CGPath {
        
        let arcRect = CGRect(x: rect.origin.x,
                             y: rect.origin.y + rect.size.height - height,
                             width: rect.size.width,
                             height: height)
        
        let radius = 0.5 * arcRect.size.height + pow(arcRect.size.width, 2) / (8 * arcRect.size.height)
        
        let center = CGPoint(x: arcRect.origin.x + 0.5 * arcRect.size.width,
                             y: arcRect.origin.y + radius)
        
        let angle = acos(arcRect.size.width / (2 * radius))
        
        let startAngle = .pi + angle
        
        let endAngle = .pi * 2 - angle
        
        let path = CGMutablePath()
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path
    }
    
}
