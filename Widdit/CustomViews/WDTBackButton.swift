//
//  WDTBackButton.swift
//  Widdit
//
//  Created by Ilya Kharabet on 12.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit


@IBDesignable final class WDTBackButton: UIView {

    @IBInspectable dynamic var backColor: UIColor = .clear
    
    var onTouchUp: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WDTBackButton.onTap)))
    }
    
    func onTap() {
        onTouchUp?()
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(backColor.cgColor)
            let path = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: [UIRectCorner.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: rect.height * 0.5, height: rect.height * 0.5))
            path.fill()
            
            if let image = UIImage(named: "common_icon_arrow_left")?.overlayed(by: .white) {
                let imageRect = CGRect(x: rect.midX,
                                       y: rect.midY - 5,
                                       width: 15, height: 10)
                image.draw(in: imageRect)
            }
        }
    }

}


extension UIImage {
    
    func overlayed(by overlayColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        overlayColor.setFill()
        context.fill(rect)
        
        self.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        
        let overlayedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return overlayedImage
    }
}
