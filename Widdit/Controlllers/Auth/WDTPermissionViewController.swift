//
//  WDTPermissionViewController.swift
//  Widdit
//
//  Created by Ilya Kharabet on 15.06.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import PermissionScope
import Parse


class WDTPermissionViewController: UIViewController {

    @IBOutlet weak var permissionTitleLabel: UILabel!
    @IBOutlet weak var permissionDescriptionLabel: UILabel!
    
    var permissionScope = PermissionScope()
    
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        permissionScope.viewControllerForAlerts = self
    }
    
    
    @IBAction func onClickCancelButton() {
        startApplication()
    }
    
    @IBAction func onClickAllowButton() {
        setupNotificationPermissionTimer()
        permissionScope.requestNotifications()
    }
    
    
    func notificationPermissionAllowed() {}
    
    
    
    fileprivate func startApplication() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startApplication(true)
    }
    
    
    func setupNotificationPermissionTimer() {
        NotificationCenter.default.addObserver(self, selector: #selector(WDTPermissionViewController.notificationPermissionAllowed), name: NSNotification.Name.UIDocumentStateChanged, object: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(WDTPermissionViewController.checkNotificationPermissionStatus), userInfo: nil, repeats: true)
        
        permissionScope.onAuthChange = { (finished, results) in
            self.checkNotificationPermissionStatus()
        }
    }
    
    func checkNotificationPermissionStatus() {
        if permissionScope.statusNotifications() == .authorized {
            timer.invalidate()
            
            UIApplication.shared.registerForRemoteNotifications()
            
            permissionScope.onAuthChange = { (finished, results) in
                self.checkLocationPermissionStatus()
            }
            
            permissionScope.requestLocationInUse()
        } else if permissionScope.statusLocationInUse() == .disabled || permissionScope.statusLocationInUse() == .unauthorized {
            timer.invalidate()
            
            permissionScope.onAuthChange = { (finished, results) in
                self.checkLocationPermissionStatus()
            }
            
            permissionScope.requestLocationInUse()
        }
    }
    
    func checkLocationPermissionStatus() {
        if permissionScope.statusLocationInUse() == .authorized {
            startApplication()
            PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) in
                if error == nil {
                    let user = PFUser.current()
                    user!["geoPoint"] = geoPoint
                    user!.saveInBackground()
                }
            })
        } else if permissionScope.statusLocationInUse() == .disabled || permissionScope.statusLocationInUse() == .unauthorized {
            startApplication()
        }
    }

}
