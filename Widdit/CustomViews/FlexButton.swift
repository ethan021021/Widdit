//
//  FlexButton.swift
//  Widdit
//
//  Created by Ilya Kharabet on 08.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

enum FlexButtonLayoutStyle {
    case defaultLayout
    case horizonLayoutTitleLeftImageRight
    case verticalLayoutTitleDownImageUp
    case verticalLayoutTitleUpImageDown
}

class FlexButton: UIButton {
    
    var layoutStyle:FlexButtonLayoutStyle = .verticalLayoutTitleDownImageUp
    fileprivate var boundsCenter: CGPoint {
        return CGPoint(x: self.bounds.origin.x + self.bounds.size.width/2,
                       y: self.bounds.origin.y + self.bounds.size.height/2)
    }
    
    override convenience init(frame: CGRect){
        self.init(layoutStyle:.defaultLayout, frame: frame)
    }
    
    
    init(layoutStyle style:FlexButtonLayoutStyle, frame: CGRect = CGRect.zero){
        self.layoutStyle = style
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = self.imageView, let label = self.titleLabel else { return }
        
        imageView.contentMode = .scaleAspectFit
        
        switch layoutStyle {
        case .defaultLayout:
            return
        case .horizonLayoutTitleLeftImageRight:
            
            let totalWidth = label.frame.width + imageView.frame.width
            
            label.frame.origin.x = self.boundsCenter.x - totalWidth/2
            imageView.frame.origin.x = label.frame.origin.x + label.frame.width
            
        case .verticalLayoutTitleDownImageUp:
            
            adjustSubviewSizeForVerticalLayoutStyle(label: label, imageView: imageView)
            
            let totalHeight = label.frame.height + imageView.frame.height
            
            /* adjust position */
            imageView.frame.origin.y = self.boundsCenter.y - totalHeight/2
            imageView.center.x = self.boundsCenter.x
            
            /* adjust position */
            label.frame.origin.y = imageView.frame.origin.y + imageView.frame.height
            label.center.x = self.boundsCenter.x
            
        case .verticalLayoutTitleUpImageDown:
            
            adjustSubviewSizeForVerticalLayoutStyle(label: label, imageView: imageView)
            let totalHeight = label.frame.height + imageView.frame.height
            
            /*  adjust position */
            label.frame.origin.y = self.boundsCenter.y - totalHeight/2
            label.center.x = self.boundsCenter.x
            
            /* adjust position */
            imageView.frame.origin.y = label.frame.origin.y + label.frame.height
            imageView.center.x = self.boundsCenter.x
        }
        
    }
    
    fileprivate func adjustSubviewSizeForVerticalLayoutStyle(label: UILabel, imageView: UIImageView) {
        /* adjust label  size */
        label.sizeToFit()
        if label.frame.size.width > self.bounds.size.width {
            label.frame.size.width = self.bounds.size.width
        }
        
        /* adjust imageView size */
        if imageView.frame.size.height > self.bounds.size.height - label.frame.size.height {
            imageView.frame.size.height = self.bounds.size.height - label.frame.size.height
        }
        if imageView.frame.size.width > self.bounds.size.width {
            imageView.frame.size.width = self.bounds.size.width
        }
        
    }
}
