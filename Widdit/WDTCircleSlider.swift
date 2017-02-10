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
            .ThumbWidth(30),
            .TrackingColor(UIColor.wddGreenColor()),
            .BarWidth(12),
            .StartAngle(270),
            .MaxValue(24),
            .MinValue(1),
            .ThumbOffset(25)
        ]
    }
    
    class var sliderOptionsDays: [CircleSliderOption] {
        return [
            .BarColor(UIColor.wddGreenColor()),
            .ThumbImage(UIImage(named: "knob_button")!),
            .ThumbWidth(CGFloat(30)),
            .TrackingColor(UIColor.wddTealColor()),
            .BarWidth(12),
            .StartAngle(270),
            .MaxValue(31),
            .MinValue(1),
            .ThumbOffset(25)
            
        ]
    }
    
    var timer: NSTimer!
    
    init() {
        super.init(frame: CGRectZero, options: WDTCircleSlider.sliderOptionsHours)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(setDefaultValue), userInfo: nil, repeats: true)
    }
    
    func setDefaultValue() {
        
        value += 0.1
        
        if value >= 12 {
            timer.invalidate()
        }
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
    var stack: [Int] = []
    
    func roundControll() {
        let value = Int(self.value)
        if value != lastValue {
            stack.append(value)
            
            if (value >= 1 && value <= 4) && (lastValue >= 22 && lastValue <= 24) && circle == .Hours {
                changeOptionsFromHoursToDays()
            } else if (value >= 27 && value <= 31) && (lastValue >= 1 && lastValue <= 3) && circle == .Days {
                changeOptionsFromDaysToHours()
            }
            lastValue = value
        }
        
        
    }
    
    func isStackRise() -> Bool? {
        let stackCount = stack.count
        if stackCount > 1 {
            if (stack[stackCount - 1] > stack[stackCount - 2]) || (stack[stackCount - 2] == 24 && stack[stackCount - 1] == 1) {
                return true
            } else if (stack[stackCount - 1] < stack[stackCount - 2]) || (stack[stackCount - 2] == 1 && stack[stackCount - 1] == 30) {
                return false
            }
        }
        
        return nil
    }
    
    
}
