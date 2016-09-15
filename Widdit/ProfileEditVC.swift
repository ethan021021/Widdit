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
        
//        
//        view.addSubview(scrollView)
//        scrollView.snp_makeConstraints { (make) in
//            make.edges.equalTo(view)
//        }
//        
        if signUpMode == true {
            navigationItem.title = "Sign Up"
        } else {
            navigationItem.title = "Settings"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(doneButtonTapped))
        
//        
//        scrollView.addSubview(addAvatar1)
//        addAvatar1.layer.cornerRadius = 10
//        addAvatar1.backgroundColor = UIColor.WDTGrayBlueColor()
//        addAvatar1.tag = 1
//        addAvatar1.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
//        addAvatar1.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.top.equalTo(scrollView).offset(50)
//            make.width.equalTo(view.snp_width).multipliedBy(0.4)
//            make.height.equalTo(view.snp_width).multipliedBy(0.4)
//        }
//        
//        
//        scrollView.addSubview(addAvatar2)
//        addAvatar2.layer.cornerRadius = 10
//        addAvatar2.backgroundColor = UIColor.WDTGrayBlueColor()
//        addAvatar2.tag = 2
//        addAvatar2.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
//        addAvatar2.snp_makeConstraints { (make) in
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(scrollView).offset(50)
//            make.width.equalTo(view.snp_width).multipliedBy(0.4)
//            make.height.equalTo(view.snp_width).multipliedBy(0.4)
//        }
//        
//        addAvatar2.addSubview(deleteAvatar2)
//        deleteAvatar2.hidden = true
//        deleteAvatar2.tag = 2
//        deleteAvatar2.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
//        deleteAvatar2.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
//        deleteAvatar2.snp_makeConstraints { (make) in
//            make.right.equalTo(addAvatar2).offset(5)
//            make.bottom.equalTo(addAvatar2).offset(5)
//            make.width.equalTo(18)
//            make.height.equalTo(18)
//        }
//        
//        
//        scrollView.addSubview(addAvatar3)
//        addAvatar3.layer.cornerRadius = 10
//        addAvatar3.backgroundColor = UIColor.WDTGrayBlueColor()
//        addAvatar3.tag = 3
//        addAvatar3.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
//        addAvatar3.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.top.equalTo(addAvatar1.snp_bottom).offset(30)
//            make.width.equalTo(view.snp_width).multipliedBy(0.4)
//            make.height.equalTo(view.snp_width).multipliedBy(0.4)
//        }
//        
//        addAvatar3.addSubview(deleteAvatar3)
//        deleteAvatar3.hidden = true
//        deleteAvatar3.tag = 3
//        deleteAvatar3.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
//        deleteAvatar3.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
//        deleteAvatar3.snp_makeConstraints { (make) in
//            make.right.equalTo(addAvatar3).offset(5)
//            make.bottom.equalTo(addAvatar3).offset(5)
//            make.width.equalTo(18)
//            make.height.equalTo(18)
//        }
//        
//        scrollView.addSubview(addAvatar4)
//        addAvatar4.layer.cornerRadius = 10
//        addAvatar4.backgroundColor = UIColor.WDTGrayBlueColor()
//        addAvatar4.tag = 4
//        addAvatar4.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
//        addAvatar4.snp_makeConstraints { (make) in
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(addAvatar2.snp_bottom).offset(30)
//            make.width.equalTo(view.snp_width).multipliedBy(0.4)
//            make.height.equalTo(view.snp_width).multipliedBy(0.4)
//        }
//        
//        addAvatar4.addSubview(deleteAvatar4)
//        deleteAvatar4.hidden = true
//        deleteAvatar4.tag = 4
//        deleteAvatar4.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
//        deleteAvatar4.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
//        deleteAvatar4.snp_makeConstraints { (make) in
//            make.right.equalTo(addAvatar4).offset(5)
//            make.bottom.equalTo(addAvatar4).offset(5)
//            make.width.equalTo(18)
//            make.height.equalTo(18)
//        }
//        
//        firstNameTxt.placeholder = "Enter Name"
//        firstNameTxt.font = UIFont.WDTAgoraRegular(16)
//        scrollView.addSubview(firstNameTxt)
//        firstNameTxt.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(addAvatar4.snp_bottom).offset(20)
//        }
//        
//        usernameTxt.placeholder = "Enter Username"
//        usernameTxt.font = UIFont.WDTAgoraRegular(16)
//        scrollView.addSubview(usernameTxt)
//        usernameTxt.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(firstNameTxt.snp_bottom).offset(20)
//        }
//    
//        
//        emailTxt.placeholder = "Enter Email"
//        emailTxt.font = UIFont.WDTAgoraRegular(16)
//        scrollView.addSubview(emailTxt)
//        emailTxt.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(usernameTxt.snp_bottom).offset(20)
//        }
//        
//
//        scrollView.addSubview(aboutTxt)
//        aboutTxt.placeholder = "Enter About Text"
//        aboutTxt.delegate = self
//        aboutTxt.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.top.equalTo(emailTxt.snp_bottom).offset(20)
//            make.height.equalTo(80)
//        }
//        
////        if signUpMode == false {
//            facebookLinkingBtn.backgroundColor = UIColor.WDTBlueColor()
//            facebookLinkingBtn.addTarget(self, action: #selector(facebookLinkingBtnTapped), forControlEvents: .TouchUpInside)
//            facebookLinkingBtn.layer.cornerRadius = 4
//            facebookLinkingBtn.clipsToBounds = true
//            scrollView.addSubview(facebookLinkingBtn)
//        
//        
//        
//            
//            if PFFacebookUtils.isLinkedWithUser(user!) == true {
//                facebookLinkingBtn.setTitle("Unlink Facebook", forState: .Normal)
//            } else {
//                facebookLinkingBtn.setTitle("Link Facebook", forState: .Normal)
//            }
//            
//            
//            
//            facebookLinkingBtn.snp_makeConstraints { (make) in
//                make.left.equalTo(view).offset(20)
//                make.right.equalTo(view).offset(-20)
//                make.top.equalTo(aboutTxt.snp_bottom).offset(20)
//                make.height.equalTo(40)
//            }
////        }
//        
//        
//        scrollView.addSubview(genderSgmtCtrl)
//        genderSgmtCtrl.tintColor = UIColor.WDTBlueColor()
//        genderSgmtCtrl.snp_makeConstraints { (make) in
//            make.top.equalTo(facebookLinkingBtn.snp_bottom).offset(20)
//            make.left.equalTo(view).offset(20)
//            make.right.equalTo(view).offset(-20)
//            make.height.equalTo(40)
//        }
//        
//        
//        
//        let schoolLbl = UILabel()
//        schoolLbl.font = UIFont.WDTAgoraRegular(18)
//        schoolLbl.text = "Currently in school"
//        schoolLbl.textColor = UIColor.blackColor()
//        scrollView.addSubview(schoolLbl)
//        schoolLbl.snp_makeConstraints { (make) in
//            make.top.equalTo(genderSgmtCtrl.snp_bottom).offset(40)
//            make.left.equalTo(view).offset(40)
//        }
//        
//        let workLbl = UILabel()
//        workLbl.font = UIFont.WDTAgoraRegular(18)
//        workLbl.text = "You have a job"
//        workLbl.textColor = UIColor.blackColor()
//        scrollView.addSubview(workLbl)
//        workLbl.snp_makeConstraints { (make) in
//            make.top.equalTo(schoolLbl.snp_bottom).offset(40)
//            make.left.equalTo(view).offset(40)
//        }
//        
//        let opportunityLbl = UILabel()
//        opportunityLbl.font = UIFont.WDTAgoraRegular(18)
//        opportunityLbl.text = "Open to new things"
//        opportunityLbl.textColor = UIColor.blackColor()
//        scrollView.addSubview(opportunityLbl)
//        opportunityLbl.snp_makeConstraints { (make) in
//            make.top.equalTo(workLbl.snp_bottom).offset(40)
//            make.left.equalTo(view).offset(40)
//        }
//        
//        
//        schoolSwitch.tintColor = UIColor.WDTGrayBlueColor()
//        scrollView.addSubview(schoolSwitch)
//        schoolSwitch.snp_makeConstraints { (make) in
//            make.centerY.equalTo(schoolLbl.snp_centerY)
//            make.left.equalTo(schoolLbl).offset(180)
//        }
//        
//        
//        workSwitch.tintColor = UIColor.WDTGrayBlueColor()
//        scrollView.addSubview(workSwitch)
//        workSwitch.snp_makeConstraints { (make) in
//            make.centerY.equalTo(workLbl.snp_centerY)
//            make.left.equalTo(workLbl).offset(180)
//        }
//        
//        
//        opportunitySwitch.tintColor = UIColor.WDTGrayBlueColor()
//        scrollView.addSubview(opportunitySwitch)
//        opportunitySwitch.snp_makeConstraints { (make) in
//            make.centerY.equalTo(opportunityLbl.snp_centerY)
//            make.left.equalTo(opportunityLbl).offset(180)
//        }
//
//        
//        
//        
//        let vvv = UIView()
//        scrollView.addSubview(vvv)
//        vvv.snp_makeConstraints { (make) in
//            make.left.equalTo(view)
//            make.right.equalTo(view)
//            make.top.equalTo(opportunityLbl.snp_bottom)
//            make.bottom.equalTo(scrollView).offset(-30).priority(751)
//        }
//        
//        
//        information()

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
            
            if section == 1 {
                if row == 0 {
                    cell.fillSettings(.Username(user!.username!))
                } else if row == 1 {
                    cell.fillSettings(.Name((user!.objectForKey("firstName") as? String)!))
                } else if row == 2 {
                    cell.fillSettings(.Email((user!.objectForKey("email") as? String)!))
                }
            } else if section == 2 {
                cell.fillSettings(.About(""))
            } else if section == 3 {
                let genderInt = user!.objectForKey("gender") as? Int
                if let genderInt = genderInt {
                    cell.fillSettings(.Gender(genderInt))
                }
                
            } else if section == 4 {
                if row == 0 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationSchool") as? Bool {
                        cell.fillSettings(.School(situation))
                    }
                } else if row == 1 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationWork") as? Bool {
                        cell.fillSettings(.Working(situation))
                    }
                    
                } else if row == 2 {
                    if let situation = PFUser.currentUser()!.objectForKey("situationOpportunity") as? Bool {
                        cell.fillSettings(.Opportunity(situation))
                    }
                }
            }
            
            
            return cell
        }
        

        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! ProfileSettingsCell
        
        currentCell.cellSelected()
        
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
    

    
    
    func information() {
        
        guard let user = user else {
            return
        }
        
        WDTAvatar.getAvatar(user, avaNum: 1) { (ava) in
            if let ava = ava {
                //                self.deleteAvatar1.hidden = false
                self.addAvatar1.setImage(ava, forState: .Normal)
            }
        }
        
        WDTAvatar.getAvatar(user, avaNum: 2) { (ava) in
            if let ava = ava {
                self.deleteAvatar2.hidden = false
                self.addAvatar2.setImage(ava, forState: .Normal)
            }
        }
        
        WDTAvatar.getAvatar(user, avaNum: 3) { (ava) in
            if let ava = ava {
                self.deleteAvatar3.hidden = false
                self.addAvatar3.setImage(ava, forState: .Normal)
            }
        }
        
        WDTAvatar.getAvatar(user, avaNum: 4) { (ava) in
            if let ava = ava {
                self.deleteAvatar4.hidden = false
                self.addAvatar4.setImage(ava, forState: .Normal)
            }
        }
        
        // receive text information
        if facebookMode == false {
            usernameTxt.text = user.username    
        }
        
        
        
        firstNameTxt.text = user.objectForKey("firstName") as? String
        aboutTxt.text = user.objectForKey("about") as? String
        emailTxt.text = user.objectForKey("email") as? String
        
        
    
        if let situation = user.objectForKey("situationSchool") as? Bool {
            schoolSwitch.on = situation
        }
        
        if let situation = user.objectForKey("situationWork") as? Bool {
            workSwitch.on = situation
        }
        
        if let situation = user.objectForKey("situationOpportunity") as? Bool {
            opportunitySwitch.on = situation
        }
        
        let genderInt = user.objectForKey("gender") as? Int
        if let genderInt = genderInt {
            genderSgmtCtrl.selectedSegmentIndex = genderInt
        }
        
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
