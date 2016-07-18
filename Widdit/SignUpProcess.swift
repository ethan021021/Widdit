//
//  SignUpStep1.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 14.07.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import SinchVerification
import ParseFacebookUtilsV4
import libPhoneNumber_iOS
import SimpleAlert
import SwiftDate

class SignUp: UIViewController {
    var user: PFUser! = nil
    var facebookMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.WDTBlueColor()
        navigationController?.navigationBarHidden = true
        
        let backBtn = UIButton(type: .Custom)
        backBtn.setImage(UIImage(named: "backbutton"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(backBtnTapped), forControlEvents: .TouchUpInside)
        backBtn.tintColor = UIColor.whiteColor()
        view.addSubview(backBtn)
        backBtn.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(10)
            make.top.equalTo(view).offset(30)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
    }
    
    func backBtnTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
}

class SignUpMainStep1: SignUp {
    let usernameTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.WDTBlueColor()
        
        usernameTF.WDTRoundedWhite(nil, height: 50)
        usernameTF.WDTFontSettings("Choose Username")
        usernameTF.autocapitalizationType = .None
        
        
        view.addSubview(usernameTF)
        usernameTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(60)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        let nextBtn: UIButton = UIButton(type: .Custom)
        nextBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Next")
        nextBtn.addTarget(self, action: #selector(nextBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp_makeConstraints { (make) in
            make.top.equalTo(usernameTF.snp_bottom).offset(25)
            make.left.equalTo(usernameTF)
            make.right.equalTo(usernameTF)
            make.height.equalTo(50)
        }
    }
    
    func nextBtnTapped() {
        if usernameTF.text!.isEmpty {
            
            let alert = UIAlertController(title: "Please", message: "Fill in login field", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: usernameTF.text!)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if err == nil {
                if let _ = objects!.first {
                    let alert = UIAlertController(title: "Please", message: "Username already exists", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {

                    self.user.username = self.usernameTF.text!.lowercaseString
                    var nextVC: SignUp!
                    
                    if self.facebookMode {
                        nextVC = SignUpPhone()
                    } else {
                        nextVC = SignUpMainStep2()
                    }
                    nextVC.user = self.user
                    nextVC.facebookMode = self.facebookMode
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        })
    }
}











class SignUpMainStep2: SignUp {
    let firstNameTF = UITextField()
    let emailTF = UITextField()
    let passwordTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.WDTRoundedWhite(nil, height: 50)
        firstNameTF.WDTFontSettings("Enter First Name")
        firstNameTF.autocapitalizationType = .None
        
        view.addSubview(firstNameTF)
        firstNameTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(60)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        emailTF.WDTRoundedWhite(nil, height: 50)
        emailTF.WDTFontSettings("Enter Email")
        emailTF.autocapitalizationType = .None
        
        view.addSubview(emailTF)
        emailTF.snp_makeConstraints { (make) in
            make.top.equalTo(firstNameTF.snp_bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        passwordTF.WDTRoundedWhite(nil, height: 50)
        passwordTF.WDTFontSettings("Enter Password")
        passwordTF.autocapitalizationType = .None
        passwordTF.secureTextEntry = true
        
        view.addSubview(passwordTF)
        passwordTF.snp_makeConstraints { (make) in
            make.top.equalTo(emailTF.snp_bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        let nextBtn: UIButton = UIButton(type: .Custom)
        nextBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Next")
        nextBtn.addTarget(self, action: #selector(nextBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp_makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp_bottom).offset(25)
            make.left.equalTo(passwordTF)
            make.right.equalTo(passwordTF)
            make.height.equalTo(50)
        }
    }
    
    func nextBtnTapped() {
        if !emailTF.text!.validateEmail()  {
            let alert = SimpleAlert.Controller(view: nil, style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "OK", style: .Cancel))
            alert.title = "Please provide correct email address"
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let userQuery = PFUser.query()
        
        userQuery!.whereKey("email", equalTo: emailTF.text!)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if let _ = objects!.first {
                let alert = UIAlertController(title: "Please", message: "Email already exists", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let phoneVerifyVC = SignUpPhone()
                self.user["firstName"] = self.firstNameTF.text!
                self.user["email"] = self.emailTF.text!
                self.user.password = self.passwordTF.text!.lowercaseString
                
                phoneVerifyVC.user = self.user
                phoneVerifyVC.facebookMode = self.facebookMode
                self.navigationController?.pushViewController(phoneVerifyVC, animated: true)
            }
            
        })
    }
}













class SignUpPhone: SignUp, UITextFieldDelegate {
    
    //properties
    let regionCode = "US"
    var verification: Verification!
    var applicationKey = "50bd9bd8-7468-4484-8185-e53ee94e00c9"
    
    var phoneFormatter: NBAsYouTypeFormatter!
    let phoneUtil = NBPhoneNumberUtil()
    
    let phoneTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneFormatter = NBAsYouTypeFormatter(regionCode: regionCode)
        
        
        phoneTF.WDTRoundedWhite(nil, height: 50)
        phoneTF.WDTFontSettings("Enter Phone")
        phoneTF.delegate = self
        phoneTF.autocapitalizationType = .None
        phoneTF.becomeFirstResponder()
        phoneTF.keyboardType = .PhonePad
        view.addSubview(phoneTF)
        phoneTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(60)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        let verifyBtn: UIButton = UIButton(type: .Custom)
        verifyBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Verify")
        verifyBtn.addTarget(self, action: #selector(verifyBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(verifyBtn)
        verifyBtn.snp_makeConstraints { (make) in
            make.top.equalTo(phoneTF.snp_bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
    }

    
    func verifyBtnTapped() {
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneTF.text, defaultRegion: regionCode)
            let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            
            NSLog("[%@]", formattedString)
            
            verification = SMSVerification(applicationKey: applicationKey, phoneNumber: formattedString)
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//            verification.initiate { (success, err) in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                if success {
            
                    let pinVerify = SignUpPinVerification()
                    self.user["phoneNumber"] = formattedString
                    pinVerify.verification = self.verification
                    pinVerify.user = self.user
                    pinVerify.facebookMode = self.facebookMode
                    self.navigationController?.pushViewController(pinVerify, animated: true)
//                } else {
//                    print("Error sending sms: \(err)")
//                }
//            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if range.length == 0 {
            phoneTF.text = phoneFormatter.inputDigit(string)
        } else {
            phoneTF.text = phoneFormatter.removeLastDigit()
        }
        
        return false
    }
}











class SignUpPinVerification: SignUp {
    var verification: Verification!
    let pinTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinTF.WDTRoundedWhite(nil, height: 50)
        pinTF.WDTFontSettings("Enter Code")
        pinTF.autocapitalizationType = .None
        pinTF.keyboardType = .NumberPad
        view.addSubview(pinTF)
        pinTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(60)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
        let verifyBtn: UIButton = UIButton(type: .Custom)
        verifyBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Verify")
        verifyBtn.addTarget(self, action: #selector(verifyBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(verifyBtn)
        verifyBtn.snp_makeConstraints { (make) in
            make.top.equalTo(pinTF.snp_bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
    }
    
    func verifyBtnTapped() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        verification.verify(pinTF.text!) { (success, err) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//            if success {
        
                let situationVC = SignUpSituation()
                situationVC.user = self.user
                situationVC.facebookMode = self.facebookMode
                self.navigationController?.pushViewController(situationVC, animated: true)
                
                
//            } else {
//                print("Error authentication pin: \(err)")
//                self.navigationController?.popViewControllerAnimated(true)
//            }
//        }
    }
    
    
}







class SignUpSituation: SignUp {
    let schoolSwitch = UISwitch()
    let workSwitch = UISwitch()
    let opportunitySwitch = UISwitch()
    let ageBtn: UIButton = UIButton(type: .Custom)
    var genderSgmtCtrl = UISegmentedControl(items: ["Male", "Female", "Other"])
    
    var ageValidate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let whatIsYourSituation = UILabel()
        whatIsYourSituation.font = UIFont.WDTAgoraRegular(18)
        whatIsYourSituation.text = "What is your situation?"
        whatIsYourSituation.textColor = UIColor.whiteColor()
        view.addSubview(whatIsYourSituation)
        whatIsYourSituation.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(60)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        let schoolLbl = UILabel()
        schoolLbl.font = UIFont.WDTAgoraRegular(18)
        schoolLbl.text = "Currently in school"
        schoolLbl.textColor = UIColor.whiteColor()
        view.addSubview(schoolLbl)
        schoolLbl.snp_makeConstraints { (make) in
            make.top.equalTo(whatIsYourSituation.snp_bottom).offset(40)
            make.left.equalTo(view).offset(40)
        }
        
        let workLbl = UILabel()
        workLbl.font = UIFont.WDTAgoraRegular(18)
        workLbl.text = "You have a job"
        workLbl.textColor = UIColor.whiteColor()
        view.addSubview(workLbl)
        workLbl.snp_makeConstraints { (make) in
            make.top.equalTo(schoolLbl.snp_bottom).offset(40)
            make.left.equalTo(view).offset(40)
        }
        
        let opportunityLbl = UILabel()
        opportunityLbl.font = UIFont.WDTAgoraRegular(18)
        opportunityLbl.text = "Open to new things"
        opportunityLbl.textColor = UIColor.whiteColor()
        view.addSubview(opportunityLbl)
        opportunityLbl.snp_makeConstraints { (make) in
            make.top.equalTo(workLbl.snp_bottom).offset(40)
            make.left.equalTo(view).offset(40)
        }
        
        
        
        schoolSwitch.tintColor = UIColor.WDTGrayBlueColor()
        view.addSubview(schoolSwitch)
        schoolSwitch.snp_makeConstraints { (make) in
            make.centerY.equalTo(schoolLbl.snp_centerY)
            make.left.equalTo(schoolLbl).offset(180)
        }
        
        
        workSwitch.tintColor = UIColor.WDTGrayBlueColor()
        view.addSubview(workSwitch)
        workSwitch.snp_makeConstraints { (make) in
            make.centerY.equalTo(workLbl.snp_centerY)
            make.left.equalTo(workLbl).offset(180)
        }
        
        
        opportunitySwitch.tintColor = UIColor.WDTGrayBlueColor()
        view.addSubview(opportunitySwitch)
        opportunitySwitch.snp_makeConstraints { (make) in
            make.centerY.equalTo(opportunityLbl.snp_centerY)
            make.left.equalTo(opportunityLbl).offset(180)
        }
        
        
        ageBtn.titleLabel?.textColor = UIColor.whiteColor()
        ageBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Tap to select your birthday")
        ageBtn.addTarget(self, action: #selector(ageBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(ageBtn)
        ageBtn.snp_makeConstraints { (make) in
            make.top.equalTo(opportunityLbl.snp_bottom).offset(35)
            make.width.equalTo(view).multipliedBy(0.7)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
        }
        
        view.addSubview(genderSgmtCtrl)
        genderSgmtCtrl.tintColor = UIColor.WDTGrayBlueColor()
        genderSgmtCtrl.snp_makeConstraints { (make) in
            make.top.equalTo(ageBtn.snp_bottom).offset(25)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(40)
        }
        
        
        
        let nextBtn: UIButton = UIButton(type: .Custom)
        nextBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Next")
        nextBtn.addTarget(self, action: #selector(nextBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp_makeConstraints { (make) in
            make.top.equalTo(genderSgmtCtrl.snp_bottom).offset(45)
            make.width.equalTo(view).multipliedBy(0.7)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
        }
    }
    
    func nextBtnTapped() {
        
        guard ageValidate == true else {
            let alert = SimpleAlert.Controller(view: nil, style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "OK", style: .Cancel))
            alert.title = "You must be over the age of 18"
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        user["gender"] = genderSgmtCtrl.selectedSegmentIndex
        user["situationSchool"] = schoolSwitch.on
        user["situationWork"] = workSwitch.on
        user["situationOpportunity"] = opportunitySwitch.on
        
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
        
        if facebookMode {
            user.saveInBackgroundWithBlock({ (success, error) in
                appDelegate.login()
            })
        } else {
            user.signUpInBackgroundWithBlock { (success, error) in
                if error == nil {
                    appDelegate.login()
                }
            }
        }
    }
    
    func ageBtnTapped() {
        DatePickerDialog().show("Birth Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .NoStyle
            
            self.ageBtn.setTitle("\(formatter.stringFromDate(date))", forState: .Normal)
            let newDate = date.add(18, months: 0, days: 0, hours: 0)
            if newDate < NSDate() {
                self.ageValidate = true
            } else {
                self.ageValidate = false
            }
            
        }
    }
}


