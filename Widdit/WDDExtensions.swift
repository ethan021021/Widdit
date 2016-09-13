//
//  WDDExtensions.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 09.09.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    var x2: Double { return self * 2 }
}

extension Int {
    var x2: Int { return self * 2 }
}

extension CGFloat {
    var CGX2: CGFloat { return self * 2 }
}

extension UIViewController {
    
    func setTealBG() {
        view.backgroundColor = UIColor.wddTealColor()
    }
    
    func addBackButton() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "ic_navbar_back"), forState: .Normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        backButton.snp_makeConstraints { (make) in
            make.left.equalTo(6.x2)
            make.top.equalTo(14.x2)
        }
    }
    
    func backButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
}

extension UIColor {
    class func wddTealColor() -> UIColor {
        return UIColor(red: 62.0 / 255.0, green: 203.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    }
    
    class func wddGreenColor() -> UIColor {
        return UIColor(red: 119.0 / 255.0, green: 224.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }
    
    class func wddRubyColor() -> UIColor {
        return UIColor(red: 212.0 / 255.0, green: 0.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
    }
    
    class func wddSilverColor() -> UIColor {
        return UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
    }
    
    class func wddCloudyBlueColor() -> UIColor {
        return UIColor(red: 177.0 / 255.0, green: 215.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0)
    }
}

// Text styles

extension UIFont {
    class func wddHtwoinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(10.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddHthreeinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(9.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddBodyinvertFont() -> UIFont {
        return UIFont.systemFontOfSize(8.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddBodylightinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(8.0 * 2, weight: UIFontWeightLight)
    }
    
    class func wddBodylightinvertFont() -> UIFont {
        return UIFont.systemFontOfSize(8.0 * 2, weight: UIFontWeightLight)
    }
    
    class func wddMiniinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(7.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMiniteal10centerFont() -> UIFont {
        return UIFont.systemFontOfSize(7.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMinigreyRegularFont() -> UIFont {
        return UIFont.systemFontOfSize(7.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMinirubyFont() -> UIFont {
        return UIFont.systemFontOfSize(7.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMinigreyLightFont() -> UIFont {
        return UIFont.systemFontOfSize(7.0 * 2, weight: UIFontWeightLight)
    }
    
    class func wddSmallmediumFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightMedium)
    }
    
    class func wddSmallinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddSmallFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddSmallgreencenterFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddSmallgreenFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddSmallgreycenterFont() -> UIFont {
        return UIFont.systemFontOfSize(6.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMicrotealFont() -> UIFont {
        return UIFont.systemFontOfSize(5.0 * 2, weight: UIFontWeightSemibold)
    }
    
    class func wddMicroinvertcenterFont() -> UIFont {
        return UIFont.systemFontOfSize(5.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMicrogreyFont() -> UIFont {
        return UIFont.systemFontOfSize(5.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMicrorubyrightFont() -> UIFont { 
        return UIFont.systemFontOfSize(5.0 * 2, weight: UIFontWeightRegular)
    }
    
    class func wddMicrogreyrightFont() -> UIFont { 
        return UIFont.systemFontOfSize(5.0 * 2, weight: UIFontWeightRegular)
    }
}