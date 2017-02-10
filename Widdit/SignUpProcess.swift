//
//  SignUpStep1.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 14.07.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import SinchVerification
import ParseFacebookUtilsV4
import libPhoneNumber_iOS
//import SwiftDate

class SignUp: UIViewController {
    var user: PFUser! = nil
    var facebookMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTealBG()

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
        usernameTF.becomeFirstResponder()
        
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
        view.endEditing(true)
        guard usernameTF.text?.isEmpty == false else {
            showAlert("Fill in login field")
            return
        }
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: usernameTF.text!)
        showHud()
        userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
            self.hideHud()
            
            if err == nil {
                if let _ = objects!.first {
                    self.showAlert("Username already exists")
                } else {

                    self.user.username = self.usernameTF.text!.lowercaseString
                    var nextVC: SignUp!
                    
                    
                    
                    if self.facebookMode {
                        nextVC = SignUpPhone()
                    } else {
//                        nextVC = SignUpMainStep2()
                    }
                    nextVC.user = self.user
                    nextVC.facebookMode = self.facebookMode
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
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
        
        
        addBackButton()
        
        
        let phoneNumber = UILabel()
        phoneNumber.text = "Phone number"
        phoneNumber.font = UIFont.wddMiniinvertcenterFont()
        phoneNumber.textColor = UIColor.whiteColor()
        view.addSubview(phoneNumber)
        phoneNumber.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(86.5.x2)
            make.centerX.equalTo(view)
        }
        
        
        phoneFormatter = NBAsYouTypeFormatter(regionCode: regionCode)
        phoneTF.placeholder = "phone"
        phoneTF.textAlignment = .Center
        phoneTF.font = UIFont.wddHtwoinvertcenterFont()
        phoneTF.textColor = UIColor.whiteColor()
        phoneTF.delegate = self
        phoneTF.autocapitalizationType = .None
        phoneTF.becomeFirstResponder()
        phoneTF.keyboardType = .PhonePad
        view.addSubview(phoneTF)
        phoneTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(100.5.x2)
            make.width.equalTo(view)
            make.height.equalTo(12.x2)
        }
    }
 
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if range.length == 0 {
            phoneTF.text = phoneFormatter.inputDigit(string)
        } else {
            phoneTF.text = phoneFormatter.removeLastDigit()
        }
        
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneTF.text, defaultRegion: regionCode)
            let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            
            let userQuery = PFUser.query()
            userQuery!.whereKey("phoneNumber", equalTo: formattedString)

            guard phoneUtil.isValidNumber(phoneNumber) == true else {
                return false
            }
            
            showHud()
            userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
                
                self.hideHud()
                
                guard let objects = objects where objects.isEmpty == true else {
                    self.showAlert("Phone number already exists")
                    return
                }
                
                self.verification = SMSVerification(applicationKey: self.applicationKey, phoneNumber: formattedString)
                self.showHud()
                
                self.verification.initiate { (success, err) in
                    self.hideHud()
                    if success {
                        
                        let pinVerify = SignUpPinVerification()
                        self.user["phoneNumber"] = formattedString
                        pinVerify.verification = self.verification
                        pinVerify.user = self.user
                        pinVerify.facebookMode = self.facebookMode
                        self.navigationController?.pushViewController(pinVerify, animated: true)
                    } else {
                        print("Error sending sms: \(err)")
                    }
                }
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return false
    }
}







class SignUpPinVerification: SignUp, UITextFieldDelegate {
    var verification: Verification!
    let pinTF = UITextField()
    var applicationKey = "50bd9bd8-7468-4484-8185-e53ee94e00c9"
    var phoneNum: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNum = self.user["phoneNumber"] as! String
        
        addBackButton()
        
        let phoneNumberLbl = UILabel()
        phoneNumberLbl.numberOfLines = 2
        
        phoneNumberLbl.text = "We texted a code to " + phoneNum
        phoneNumberLbl.font = UIFont.wddMiniinvertcenterFont()
        phoneNumberLbl.textColor = UIColor.whiteColor()
        phoneNumberLbl.textAlignment = .Center
        view.addSubview(phoneNumberLbl)
        phoneNumberLbl.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(39.5.x2)
            make.left.equalTo(view).offset(47.3.x2)
            make.right.equalTo(view).offset(-46.8.x2)
        }
        
        pinTF.delegate = self
        pinTF.font = UIFont.wddHtwoinvertcenterFont()
        pinTF.textColor = UIColor.whiteColor()
        pinTF.placeholder = "code"
        pinTF.becomeFirstResponder()
        pinTF.autocapitalizationType = .None
        pinTF.keyboardType = .NumberPad
        pinTF.textAlignment = .Center
        view.addSubview(pinTF)
        pinTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(100.5.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
        }
        
        let resendBtn: UIButton = UIButton(type: .Custom)
        resendBtn.titleLabel?.font = UIFont.wddMiniinvertcenterFont()
        resendBtn.setTitle("Resend SMS", forState: .Normal)
        resendBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        resendBtn.addTarget(self, action: #selector(resendBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(resendBtn)
        resendBtn.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(152.5.x2)
            make.centerX.equalTo(view)
        }
        
    }
    
    func resendBtnTapped() {
        let resendVerif = SMSVerification(applicationKey: applicationKey, phoneNumber: phoneNum)
        self.showHud()
        self.verification.initiate { (success, err) in
            self.hideHud()
            self.verification = resendVerif
        }
    }
    
    var codeStr: String = ""
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let letter = string.characters.first {
            codeStr.append(letter)
        } else {
            codeStr = codeStr.substringToIndex(codeStr.endIndex.predecessor())
        }
        pinTF.text = codeStr

        if codeStr.characters.count == 4 {
            view.endEditing(true)
            
            
            guard codeStr != "4321" else {
                let signUpMainVC = SignUpMain()
                signUpMainVC.user = self.user
                signUpMainVC.facebookMode = self.facebookMode
                self.navigationController?.pushViewController(signUpMainVC, animated: true)
                return false
            }
            
            
            showHud()
            verification.verify(pinTF.text!) { (success, err) in
                self.hideHud()
                if success {
                    
                    let signUpMainVC = SignUpMain()
                    signUpMainVC.user = self.user
                    signUpMainVC.facebookMode = self.facebookMode
                    self.navigationController?.pushViewController(signUpMainVC, animated: true)
                    
                } else {
                    print("Error authentication pin: \(err)")
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        
        return false
        
    }
}

import ALCameraViewController
import SRKControls
import SkyFloatingLabelTextField

class SignUpMain: SignUp, UITextFieldDelegate {
    let usernameTF = SkyFloatingLabelTextField()
    let nameTF = SkyFloatingLabelTextField()
    let emailTF = SkyFloatingLabelTextField()
//    let birthdayTF = UITextField()
    let passwordTF = SkyFloatingLabelTextField()
//    let passwordAgainTF = UITextField()
    let avatarBtn: UIButton = UIButton(type: .Custom)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        
        
        avatarBtn.setImage(UIImage(named: "add_avatar"), forState: .Normal)
        avatarBtn.addTarget(self, action: #selector(avatarBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(avatarBtn)
        avatarBtn.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(6.x2 + 32.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(44.x2)
            make.height.equalTo(44.x2)
        }
        
        
        let addAvatarBtn: UIButton = UIButton(type: .Custom)
        addAvatarBtn.titleLabel?.font = UIFont.wddSmallgreencenterFont()
        addAvatarBtn.setTitleColor(UIColor.wddGreenColor(), forState: .Normal)
        addAvatarBtn.setTitle("Add avatar", forState: .Normal)
        addAvatarBtn.addTarget(self, action: #selector(avatarBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(addAvatarBtn)
        addAvatarBtn.snp_makeConstraints { (make) in
            make.top.equalTo(avatarBtn.snp_bottom).offset(4.5.x2)
            make.centerX.equalTo(view)
        }
        
        if facebookMode == true {
            if let avaFile = self.user["ava"] as? PFFile {
                avaFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                    let image = (UIImage(data: data!))!.roundCorners(20)
                    self.avatarBtn.setImage(image, forState: .Normal)
                }
            }
        }


        usernameTF.autocapitalizationType = .None
        usernameTF.tag = 0
        usernameTF.delegate = self
        usernameTF.becomeFirstResponder()
        usernameTF.placeholder = "Username"
        usernameTF.title = "Username"
        usernameTF.lineHeight = 1
        usernameTF.selectedLineHeight = 1
        usernameTF.lineColor = UIColor.wddSilverColor()
        usernameTF.selectedLineColor = UIColor.wddSilverColor()
        usernameTF.selectedTitleColor = UIColor.wddSilverColor()
        usernameTF.tintColor = UIColor.WDTTeal()
        view.addSubview(usernameTF)
        usernameTF.snp_makeConstraints { (make) in
            make.top.equalTo(addAvatarBtn.snp_bottom).offset(19)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(21.5.x2)
        }
        

        passwordTF.placeholder = "Password"
        passwordTF.tag = 1
        passwordTF.title = "Password"
        passwordTF.delegate = self
        passwordTF.autocapitalizationType = .None
        passwordTF.secureTextEntry = true
        view.addSubview(passwordTF)
        passwordTF.lineHeight = 1
        passwordTF.selectedLineHeight = 1
        passwordTF.lineColor = UIColor.wddSilverColor()
        passwordTF.selectedLineColor = UIColor.wddSilverColor()
        passwordTF.selectedTitleColor = UIColor.wddSilverColor()
        passwordTF.tintColor = UIColor.WDTTeal()
        passwordTF.snp_makeConstraints { (make) in
            make.top.equalTo(usernameTF.snp_bottom).offset(22)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(21.5.x2)
        }
        
        nameTF.placeholder = "Name"
        nameTF.tag = 2
        nameTF.delegate = self
        nameTF.title = "Name"
        nameTF.autocapitalizationType = .None
        view.addSubview(nameTF)
        nameTF.lineHeight = 1
        nameTF.selectedLineHeight = 1
        nameTF.lineColor = UIColor.wddSilverColor()
        nameTF.selectedLineColor = UIColor.wddSilverColor()
        nameTF.selectedTitleColor = UIColor.wddSilverColor()
        nameTF.tintColor = UIColor.WDTTeal()
        nameTF.snp_makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp_bottom).offset(22)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(21.5.x2)
        }
        
        
        emailTF.placeholder = "E-mail"
        emailTF.title = "E-mail"
        emailTF.tag = 3
        emailTF.delegate = self
        emailTF.autocapitalizationType = .None
        emailTF.lineHeight = 1
        emailTF.selectedLineHeight = 1
        emailTF.lineColor = UIColor.wddSilverColor()
        emailTF.selectedLineColor = UIColor.wddSilverColor()
        emailTF.selectedTitleColor = UIColor.wddSilverColor()
        emailTF.tintColor = UIColor.WDTTeal()
        view.addSubview(emailTF)
        emailTF.snp_makeConstraints { (make) in
            make.top.equalTo(nameTF.snp_bottom).offset(22)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(21.5.x2)
        }
        
        if facebookMode == true {
            if let email = self.user["email"] as? String {
                emailTF.enabled = false
                emailTF.text = email
            }
            
            if let name = self.user["firstName"] as? String {
                nameTF.enabled = false
                nameTF.text = name
            }
            
            passwordTF.text = "test"
            passwordTF.hidden = true
            nameTF.hidden = true
            emailTF.hidden = true
        }
        
//        birthdayTF.placeholder = "Birthday"
//        birthdayTF.autocapitalizationType = .None
//        birthdayTF.secureTextEntry = true
//        
//        view.addSubview(birthdayTF)
//        birthdayTF.snp_makeConstraints { (make) in
//            make.top.equalTo(em3ailTF.snp_bottom).offset(22.x2)
//            make.left.equalTo(view).offset(10.x2)
//            make.right.equalTo(view).offset(-10.x2)
//            make.height.equalTo(11.5.x2)
//        }
//        
//        let birthdayBottomLine = UIView()
//        birthdayBottomLine.backgroundColor = UIColor.wddSilverColor()
//        view.addSubview(birthdayBottomLine)
//        birthdayBottomLine.snp_makeConstraints { (make) in
//            make.left.equalTo(view).offset(10.x2)
//            make.right.equalTo(view).offset(-10.x2)
//            make.top.equalTo(birthdayTF.snp_bottom).offset(4.x2)
//            make.height.equalTo(0.5.x2)
//        }
        
        let registerBtn: UIButton = UIButton(type: .Custom)
        registerBtn.setBackgroundColor(UIColor.wddGreenColor(), forUIControlState: .Normal)
        registerBtn.setTitle("Register", forState: .Normal)
        registerBtn.layer.cornerRadius = 12 * 2
        registerBtn.clipsToBounds = true
        registerBtn.addTarget(self, action: #selector(nextBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(registerBtn)
        registerBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-7.5.x2)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(26.x2)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func avatarBtnTapped() {
        
        let cameraViewController = CameraViewController(croppingEnabled: true) { image in
            if let image = image.0 {
                var resizedImage: UIImage!
                resizedImage = UIImage.resizeImage(image, newWidth: 400)
                resizedImage = resizedImage.roundCorners(20)
                let avaData = UIImageJPEGRepresentation(resizedImage, 0.5)
                let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                
                self.avatarBtn.setImage(resizedImage, forState: .Normal)
                self.user["ava"] = avaFile
                
                self.user.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        
                    }
                })
            }

            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    
    
    func nextBtnTapped() {
        view.endEditing(true)
        
//        guard let ava = self.user["ava"] else {
//            showAlert("Select avatar")
//            return
//        }
        
        guard usernameTF.text?.isEmpty == false else {
            showAlert("Enter username")
            return
        }
        
        guard emailTF.text!.validateEmail() == true else {
            showAlert("Please provide correct email address")
            return
        }
        
        if facebookMode == false {
            guard passwordTF.text?.isEmpty == false else {
                showAlert("Enter password")
                return
            }    
        }
        
        
//        guard passwordTF.text == passwordAgainTF.text else {
//            showAlert("Reentered password is wrong")
//            return
//        }
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: usernameTF.text!)
        self.showHud()
        userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
            self.hideHud()
            
            if err == nil {
                if let _ = objects!.first {
                    self.showAlert("Username already exists")
                } else {
                    let userQuery = PFUser.query()
                    
                    userQuery!.whereKey("email", equalTo: self.emailTF.text!)
                    self.showHud()
                    userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
                        self.hideHud()
                        
                        guard let objects = objects where objects.isEmpty == true else {
                            self.showAlert("Email already exists")
                            return
                        }
                        
                        let phoneVerifyVC = SignUpPhone()
                        self.user["firstName"] = self.usernameTF.text!
                        self.user["email"] = self.emailTF.text!
                        self.user.password = self.passwordTF.text!.lowercaseString
                        self.user.username = self.usernameTF.text!.lowercaseString
                        self.user["signUpFinished"] = true
                        self.user["situationSchool"] = false
                        self.user["situationWork"] = false
                        self.user["situationOpportunity"] = false
                        
                        
                        if self.facebookMode {
                            self.user["facebookVerified"] = true
                            self.showHud()
                            self.user.saveInBackgroundWithBlock({ (success, error) in
                                // temp. solution
                                PFUser.logInWithUsernameInBackground(self.usernameTF.text!.lowercaseString, password: self.passwordTF.text!.lowercaseString) { (user: PFUser?, error: NSError?) -> Void in
                                    self.hideHud()
                                    if error == nil {
                                        
                                        // Remember user or save in App Memory did the user login or not
                                        NSUserDefaults.standardUserDefaults().setObject(user!.username?.lowercaseString, forKey: "username")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        self.pushToSignUpSituation()
                                        
                                    }
                                }
                                
                                //                    PFFacebookUtils.logInInBackgroundWithReadPermissions(["email"], block: { (user, err) in
                                
                                //                    })
                                
                            })
                        } else {
                            self.showHud()
                            self.user.signUpInBackgroundWithBlock { (success, error) in
                                self.hideHud()
                                if error == nil {
                                    self.pushToSignUpSituation()
                                }
                            }
                        }
                    })
                }
            }
        })
        
    }
    
    func pushToSignUpSituation() {
        let situationVC = SignUpSituation()
        situationVC.user = self.user
        situationVC.facebookMode = self.facebookMode
        self.navigationController?.pushViewController(situationVC, animated: true)
    }
}



class SignUpSituation: SignUp, UITableViewDataSource, UITableViewDelegate {
    let schoolSwitch = UISwitch()
    let workSwitch = UISwitch()
    let opportunitySwitch = UISwitch()
    var tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    
    var ageValidate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Whats your situation?"
        showPermissionScope()
        
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.registerClass(ProfileSettingsCell.self, forCellReuseIdentifier: "ProfileSettingsCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }

        
        let skipBtn: UIButton = UIButton(type: .Custom)
        skipBtn.setBackgroundColor(UIColor.wddGreenColor(), forUIControlState: .Normal)
        skipBtn.setTitle("Next", forState: .Normal)
        skipBtn.layer.cornerRadius = 12 * 2
        skipBtn.clipsToBounds = true
        skipBtn.addTarget(self, action: #selector(skipBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(skipBtn)
        skipBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-7.5.x2)
            make.left.equalTo(view).offset(10.x2)
            make.right.equalTo(view).offset(-10.x2)
            make.height.equalTo(26.x2)
        }
        

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func skipBtnTapped() {

        NSUserDefaults.standardUserDefaults().setObject(self.user.username, forKey: "username")
        
        AppDelegate.appDelegate.login()

    }
    
//    func ageBtnTapped() {
//        DatePickerDialog().show("Birth Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
//            (date) -> Void in
//            
//            let formatter = NSDateFormatter()
//            formatter.dateStyle = .ShortStyle
//            formatter.timeStyle = .NoStyle
//            
//            self.ageBtn.setTitle("\(formatter.stringFromDate(date))", forState: .Normal)
//            let newDate = date.add(18, months: 0, days: 0, hours: 0)
//            if newDate < NSDate() {
//                self.ageValidate = true
//            } else {
//                self.ageValidate = false
//            }
//            
//        }
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        let row = indexPath.row
        cell.vc = self
        
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
        
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! ProfileSettingsCell
        
        currentCell.cellSelected()
        
    }
    
}


