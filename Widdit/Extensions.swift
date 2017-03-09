//
//  Extensions.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

extension UserDefaults {
    class func isFirstStart() -> Bool {
        let isFirstStart = UserDefaults.standard.bool(forKey: Constants.UserDefaults.FIRST_START)
        if isFirstStart {
            UserDefaults.standard.set(false, forKey: Constants.UserDefaults.FIRST_START)
        }
        
        return isFirstStart
    }
}

extension UIColor {
    convenience init(r: Float, g: Float, b: Float, a: Float) {
        self.init(colorLiteralRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    class func WDTPrimaryColor() -> UIColor {
        return UIColor(r: 62, g: 203, b: 204, a: 1)
    }
    
    class func WDTActivityColor() -> UIColor {
        return UIColor(r: 119, g: 224, b: 179, a: 1)
    }
}

extension UIFont {
    class func WDTRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func WDTLight(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func WDTMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

extension UIImage {
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension Date {
    func timeLeft() -> String {
        let leftSec = timeIntervalSince(Date())
        var strTimeLeft = ""
        
        if leftSec / 60 < 60 {
            strTimeLeft = "\(Int(leftSec / 60)) minutes left"
        } else if leftSec / 3600 < 24 {
            strTimeLeft = "\(Int(leftSec / 3600)) hours left"
        } else {
            strTimeLeft = "\(Int(leftSec / 3600 / 24)) days left"
        }
        
        return strTimeLeft
    }
}

import MBProgressHUD
import DGActivityIndicatorView
import PermissionScope
import Parse
import SCLAlertView

extension UIViewController {
    
    func showInfoAlert(_ message: String) {
        SCLAlertView().showInfo("", subTitle: message)
    }
    
    func showErrorAlert(_ message: String) {
        SCLAlertView().showError(Constants.String.APP_NAME, subTitle: message)
    }
    
    func showHud() {
        let viewActivity = DGActivityIndicatorView(type: .ballRotate, tintColor: UIColor.WDTActivityColor(), size: 70)
        viewActivity?.startAnimating()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.customView = viewActivity
        hud?.mode = .customView
        hud?.color = UIColor.clear
    }
    
    func hideHudWithError(_ error: String) {
        MBProgressHUD.hide(for: view, animated: true)
        showErrorAlert(error)
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func showPermissionScope() {
        let scope = PermissionScope()
        
        scope.addPermission(NotificationsPermission(notificationCategories: nil),
                             message: "Get notified on downs and replies")
        scope.addPermission(LocationWhileInUsePermission(),
                             message: "Doing this lets you see peoples posts")
        
        scope.show({ finished, results in
            print("got results \(results)")
            for result in results {
                if result.type == .notifications && result.status == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                if result.type == .locationInUse && result.status == .authorized {
                    PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) in
                        if error == nil {
                            let user = PFUser.current()
                            user!["geoPoint"] = geoPoint
                            user!.saveInBackground()
                        }
                    })
                }
            }
            
        }, cancelled: { (results) -> Void in
            print("thing was cancelled")
        })
    }
}
