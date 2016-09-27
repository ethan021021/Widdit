//
//  WDTCircleSlider.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 24.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import CircleSlider

class WDTCircleSlider: CircleSlider {
    
    enum WDTCircle {
        case Hours
        case Days
    }
    var circle: WDTCircle = .Hours
    
    class var sliderOptionsHours: [CircleSliderOption] {
        return [
            .BarColor(UIColor.clearColor()),
            .ThumbImage(UIImage(named: "knob_button")!),
            .ThumbWidth(25),
            .TrackingColor(UIColor.wddGreenColor()),
            .BarWidth(12),
            .StartAngle(270),
            .MaxValue(23),
            .MinValue(1),
            .ThumbOffset(20)
        ]
    }
    
    class var sliderOptionsDays: [CircleSliderOption] {
        return [
            .BarColor(UIColor.wddGreenColor()),
            .ThumbImage(UIImage(named: "knob_button")!),
            .ThumbWidth(CGFloat(25)),
            .TrackingColor(UIColor.wddTealColor()),
            .BarWidth(12),
            .StartAngle(270),
            .MaxValue(30),
            .MinValue(1),
            .ThumbOffset(20)
        ]
    }
    
    init() {
        super.init(frame: CGRectZero, options: WDTCircleSlider.sliderOptionsHours)
        
        
        
        UIView.animateWithDuration(1.1, delay: 0.5, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            
            }, completion: { (finished: Bool) -> Void in
                self.value = 12
        })

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func changeOptionsFromHoursToDays() {
        if circle == .Hours {
            circle = .Days
            self.changeOptions(WDTCircleSlider.sliderOptionsDays)
        }
    }
    
    func changeOptionsFromDaysToHours() {
        if circle == .Days {
            circle = .Hours
            self.changeOptions(WDTCircleSlider.sliderOptionsHours)
        }
    }
    
    
    var lastValue: Int = 0
    
    func roundControll() {
        let value = Int(self.value)
        
        if lastValue == 23 && circle == .Hours {
            if value == 24 || value == 1 || value == 2 || value == 3 {
                self.changeOptionsFromHoursToDays()
            }
        } else if lastValue == 1 && circle == .Days {
            if value == 31 || value == 30 || value == 29 {
                self.changeOptionsFromDaysToHours()
            }
        }
        
        lastValue = value
    }
}
