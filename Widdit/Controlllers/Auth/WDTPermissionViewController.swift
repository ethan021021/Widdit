//
//  WDTPermissionViewController.swift
//  Widdit
//
//  Created by Ilya Kharabet on 15.06.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import PermissionScope


class WDTPermissionViewController: UIViewController {

    @IBOutlet weak var permissionTitleLabel: UILabel!
    @IBOutlet weak var permissionDescriptionLabel: UILabel!
    
    var permissionScope = PermissionScope()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        permissionScope.viewControllerForAlerts = self
        
        permissionScope.onAuthChange = { (finished, results) in
            self.checkPermissionStatus()
        }
    }
    
    
    @IBAction func onClickCancelButton() {}
    
    @IBAction func onClickAllowButton() {}
    
    
    func setupView() {}
    
    func checkPermissionStatus() {}
    
    func permissionAllowed() {}

}

final class WDTNotificationsPermissionViewController: WDTPermissionViewController {

    fileprivate func showNextViewController() {
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTLocationPermissionViewController.self)) {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    override func onClickCancelButton() {
        showNextViewController()
    }
    
    override func onClickAllowButton() {
        permissionScope.requestNotifications()
    }
    
    override func setupView() {
        permissionTitleLabel.text = "Notificaitons permission"
        permissionDescriptionLabel.text = Constants.Arrays.TUTORIAL_TITLES[4]
    }
    
    override func checkPermissionStatus() {
        if permissionScope.statusNotifications() == .authorized {
            permissionAllowed()
        }
    }
    
    override func permissionAllowed() {
        showNextViewController()
    }

}


final class WDTLocationPermissionViewController: WDTPermissionViewController {

    fileprivate func startApplication() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startApplication(true)
    }
    
    override func onClickCancelButton() {
        startApplication()
    }
    
    override func onClickAllowButton() {
        permissionScope.requestLocationInUse()
    }
    
    override func setupView() {
        permissionTitleLabel.text = "Location while use permission"
        permissionDescriptionLabel.text = Constants.Arrays.TUTORIAL_TITLES[5]
    }
    
    override func checkPermissionStatus() {
        if permissionScope.statusLocationInUse() == .authorized {
            permissionAllowed()
        }
    }
    
    override func permissionAllowed() {
        startApplication()
    }
    
}
