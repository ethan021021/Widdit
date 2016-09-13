//
//  Extesions.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 18.07.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: Float, g: Float, b: Float, a: Float) {
        self.init(colorLiteralRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    class func WDTGrayBlueColor() -> UIColor {
        return UIColor(r: 249, g: 249, b: 249, a: 1)
    }
    
    class func WDTBlueColor() -> UIColor {
        return UIColor(r: 59, g: 122, b: 218, a: 1)
    }
    
    class func WDTTeal() -> UIColor {
        return UIColor(r: 62, g: 203, b: 204, a: 1)
    }
    
    
}


extension UIFont {
    class func WDTAgoraRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "PFAgoraSansPro-Regular", size: size)!
    }
    
    class func WDTAgoraMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "PFAgoraSansPro-Medium", size: size)!
    }
}


extension UIImage {
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension NSDateFormatter {
    class func wdtDateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
}

extension NSDateComponentsFormatter {
    class func wdtLeftTime(seconds: Int) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        let components = NSDateComponents()
        
        if seconds / 3600 > 24 {
            components.day = seconds / (3600 * 24)
        } else {
            let hours = seconds / 3600
            let minuts = (seconds - (3600 * hours)) / 60
            
            components.hour = hours
            components.minute = minuts
        }
        
        
        return formatter.stringFromDateComponents(components)!
    }
}


extension NSDate {
    func toLocalTime() -> NSDate {
        let tz = NSTimeZone.localTimeZone()
        let seconds = tz.secondsFromGMTForDate(self)
        return NSDate(timeInterval: NSTimeInterval(seconds), sinceDate: self)
    }
}



extension Array where Element: Equatable {
    
    public func uniq() -> [Element] {
        var arrayCopy = self
        arrayCopy.uniqInPlace()
        return arrayCopy
    }
    
    mutating public func uniqInPlace() {
        var seen = [Element]()
        var index = 0
        for element in self {
            if seen.contains(element) {
                removeAtIndex(index)
                print(seen.count)
            } else {
                seen.append(element)
                index += 1
            }
        }
    }
}



extension UINavigationBar {
    
    func setBottomBorderColor() {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: 0.5)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        
        let shadowPath = UIBezierPath(rect: bottomBorderView.bounds)
        bottomBorderView.layer.masksToBounds = false
        bottomBorderView.layer.shadowColor = UIColor.blackColor().CGColor
        bottomBorderView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        bottomBorderView.layer.shadowOpacity = 0.5
        bottomBorderView.layer.shadowPath = shadowPath.CGPath
        bottomBorderView.layer.cornerRadius = 4.0
        
        addSubview(bottomBorderView)
    }
}




extension UIButton {
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), forState: state)
    }
    
    
    func WDTButtonStyle(color: UIColor, title: String) {
        self.backgroundColor = color
        self.setTitle(NSLocalizedString(title, comment: ""), forState: .Normal)
        if color == UIColor.whiteColor() {
            self.setTitleColor(UIColor.WDTBlueColor(), forState: .Normal)
        } else {
            self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        self.setBackgroundColor(UIColor.lightGrayColor(), forUIControlState: .Highlighted)
        self.layer.cornerRadius = 4
        self.titleLabel?.font = UIFont.WDTAgoraRegular(17)
    }
}

extension UITextField {
    func WDTRoundedWhite(image: UIImage?, height: CGFloat) {
        
        let container: UIView = UIView()
        container.frame = CGRectMake(0, 0, 30, 30)
        
        let imgView = UIImageView(image: image)
        imgView.contentMode = .Right
        imgView.frame = CGRectMake(-13, 2.5, 20, 20)
        container.addSubview(imgView)
        
        self.leftView = container
        self.leftViewMode = .Always
        self.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0); // leftview indent
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = height / 2
    }
    
    func WDTRoundedDark(image: UIImage?, height: CGFloat) {
        let container: UIView = UIView()
        container.frame = CGRectMake(0, 0, 30, 30)
        
        let imgView = UIImageView(image: image)
        imgView.contentMode = .Right
        imgView.frame = CGRectMake(-13, 2.5, 20, 20)
        container.addSubview(imgView)
        
        self.leftView = container
        self.leftViewMode = .Always
        self.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0); // leftview indent
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = UIColor.WDTBlueColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = height / 2
    }
    
    func WDTFontSettings(placeholder: String) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.init(white: 1.0, alpha: 0.4), NSFontAttributeName: UIFont.WDTAgoraRegular(16)])
        self.textColor = UIColor.whiteColor()
        self.font = UIFont.WDTAgoraRegular(16)
        self.tintColor = UIColor.whiteColor()
        self.tintAdjustmentMode = .Normal
    }
}


extension String {
    func validateEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = self.rangeOfString(regex, options: .RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
}

import SimpleAlert
import MBProgressHUD

extension UIViewController {
    
    func showAlert(title: String) {
        let alert = SimpleAlert.Controller(view: nil, style: .Alert)
        alert.addAction(SimpleAlert.Action(title: "OK", style: .Cancel))
        alert.title = title
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showHud() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func hideHud() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
    
    
}
