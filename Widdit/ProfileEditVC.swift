//
//  EditVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse



class ProfileEditVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    var firstNameTxt: UITextField = UITextField()
    var usernameTxt: UITextField = UITextField()
    var emailTxt: UITextField = UITextField()
    var aboutTxt: WDTPlaceholderTextView = WDTPlaceholderTextView()
    var genderSgmtCtrl = UISegmentedControl(items: ["Male", "Female", "Other"])
    
    
    
    let addAvatar1 = UIButton()
    let addAvatar2 = UIButton()
    let addAvatar3 = UIButton()
    let addAvatar4 = UIButton()
    let deleteAvatar2 = UIButton()
    let deleteAvatar3 = UIButton()
    let deleteAvatar4 = UIButton()
    let schoolSwitch = UISwitch()
    let workSwitch = UISwitch()
    let opportunitySwitch = UISwitch()
    
    var user: PFUser? = nil
    var signUpMode = false
    var facebookMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = PFUser.currentUser()
        
        navigationController?.navigationBarHidden = false
        
        view.addSubview(tableView)
        tableView.registerClass(ProfileSettingsCell.self, forCellReuseIdentifier: "ProfileSettingsCell")
        tableView.registerClass(ProfileSettingAvatarsCell.self, forCellReuseIdentifier: "ProfileSettingAvatarsCell")
        tableView.registerClass(ProfileFacebookCell.self, forCellReuseIdentifier: "ProfileFacebookCell")
        
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150.0;
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(-20)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(doneButtonTapped))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        } else if section == 4 {
            return 3
        }
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 6
        
    }
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingAvatarsCell", forIndexPath: indexPath) as! ProfileSettingAvatarsCell
            cell.vc = self
            return cell
            
            
        } else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFacebookCell", forIndexPath: indexPath) as! ProfileFacebookCell
            cell.vc = self
            return cell
          
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
            let section = indexPath.section
            let row = indexPath.row
            cell.vc = self
            cell.accessoryType = .None
            
            if section == 1 {
                if row == 0 {
                    cell.fillSettings(.Username(user!.username!))
                } else if row == 1 {
                    cell.fillSettings(.Name((user!.objectForKey("firstName") as? String)!))
                } else if row == 2 {
                    cell.fillSettings(.Email((user!.objectForKey("email") as? String)!))
                }
            } else if section == 2 {
                if let a = user!.objectForKey("about") as? String {
                    cell.fillSettings(.About(a))
                } else {
                    cell.fillSettings(.About(""))
                }
                cell.accessoryType = .DisclosureIndicator
                
            } else if section == 3 {
                let genderInt = user!.objectForKey("gender") as? Int
                if let genderInt = genderInt {
                    cell.fillSettings(.Gender(genderInt))
                } else {
                    cell.fillSettings(.Gender(-1))
                }
                
            } else if section == 4 {
                if row == 0 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationSchool") as? Bool {
                        cell.fillSettings(.School(situation))
                    } else {
                        cell.fillSettings(.School(false))
                    }
                } else if row == 1 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationWork") as? Bool {
                        cell.fillSettings(.Working(situation))
                    } else {
                        cell.fillSettings(.Working(false))
                    }
                    
                } else if row == 2 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationOpportunity") as? Bool {
                        cell.fillSettings(.Opportunity(situation))
                    } else {
                        cell.fillSettings(.Opportunity(false))
                    }
                }
            }
            
            
            return cell
        }
        

        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            navigationController?.pushViewController(ProfileEditAboutVC(), animated: true)
            
        } else {
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! ProfileSettingsCell
            currentCell.cellSelected()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let headerLbl = UILabel()
        headerView.addSubview(headerLbl)
        headerLbl.font = UIFont.wddMicrotealFont()
        headerLbl.textColor = UIColor.wddTealColor()
        headerLbl.snp_makeConstraints { (make) in
            make.left.equalTo(headerView).offset(6.x2)
            make.bottom.equalTo(headerView).offset(-6.x2)
        }
        
        if section == 1 {
            headerLbl.text = "PERSONAL DATA"
        } else if section == 4 {
            headerLbl.text = "SITUATION"
        } else {
            headerLbl.text = ""
        }
        
        return headerView
        
    }
    
    func doneButtonTapped() {
        
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
        
    }
//    
//    func textView(textView: UITextView,
//                  shouldChangeTextInRange range: NSRange,
//                                          replacementText text: String) -> Bool{
//        
//        let currentLength:Int = (textView.text as NSString).length
//        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - (range.length)
////        let remainingChar:Int = 140 - currentLength
//        
//        aboutTxt.textColor = UIColor .blackColor()
//        if text != "" {
//            return (newLength > 140) ? false : true
//        } else {
//            return true
//        }
//        
//    }



}
