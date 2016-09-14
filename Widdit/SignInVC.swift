//
//  SignInVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


enum VerificationMode {
    case SignIn
    case SignUp
}

class SignInVC: UIViewController {
    let usernameTF = UITextField()
    let passwordTF = UITextField()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wddTealColor()
        
        
        usernameTF.font = UIFont.wddHtwoinvertcenterFont()
        usernameTF.textColor = UIColor.whiteColor()
        usernameTF.placeholder = "Enter Username"
        usernameTF.becomeFirstResponder()
        usernameTF.autocapitalizationType = .None
        usernameTF.textAlignment = .Center
        usernameTF.autocapitalizationType = .None
        
        view.addSubview(usernameTF)
        usernameTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(100.5.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
        }
        
        
        passwordTF.font = UIFont.wddHtwoinvertcenterFont()
        passwordTF.textColor = UIColor.whiteColor()
        passwordTF.textAlignment = .Center
        passwordTF.placeholder = "Enter Password"
        passwordTF.autocapitalizationType = .None
        passwordTF.secureTextEntry = true
        view.addSubview(passwordTF)
        passwordTF.snp_makeConstraints { (make) in
            make.top.equalTo(usernameTF.snp_bottom).offset(12.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
        }
        
        let signUpBtn: UIButton = UIButton(type: .Custom)
        signUpBtn.titleLabel?.font = UIFont.WDTAgoraRegular(10.5 * 2)
        signUpBtn.setTitle("Sign up", forState: .Normal)
        signUpBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpBtn.addTarget(self, action: #selector(signInBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signUpBtn)
        signUpBtn.snp_makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp_bottom).offset(12.x2 * 2)
            make.centerX.equalTo(view)
        }
        
        
    }
    
    func signInBtnTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if usernameTF.text!.isEmpty {
            
            let alert = UIAlertController(title: "Please", message: "Fill in login field", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if passwordTF.text!.isEmpty {
            
            let alert = UIAlertController(title: "Please", message: "Fill in password field", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        showHud()
        PFUser.logInWithUsernameInBackground(usernameTF.text!.lowercaseString, password: passwordTF.text!.lowercaseString) { (user: PFUser?, error: NSError?) -> Void in
            self.hideHud()
            if error == nil {
                
                // Remember user or save in App Memory did the user login or not
                NSUserDefaults.standardUserDefaults().setObject(user!.username?.lowercaseString, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Call Login Function from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                let ok = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }

}

class WelcomeVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wddTealColor()
        navigationController?.navigationBarHidden = true
        let logo = UIImageView(image: UIImage(named: "logo_splash"))
        logo.contentMode = .ScaleAspectFit
        view.addSubview(logo)
        logo.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(47.5)
            make.left.equalTo(view).offset(63 * 2)
            make.right.equalTo(view).offset(-63 * 2)
            
            
        }
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        
        let signUpBtn: UIButton = UIButton(type: .Custom)
        signUpBtn.titleLabel?.font = UIFont.WDTAgoraRegular(10.5 * 2)
        signUpBtn.setTitle("Sign up", forState: .Normal)
        signUpBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signUpBtn)
        signUpBtn.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(99.5 * 2)
            make.centerX.equalTo(view)
        }
        
        let orLbl = UILabel()
        orLbl.text = "or"
        orLbl.font = UIFont.WDTAgoraRegular(7 * 2)
        orLbl.textColor = UIColor.whiteColor()
        view.addSubview(orLbl)
        orLbl.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(126.5 * 2)
            make.centerX.equalTo(view)
        }
        
        let leftLine = UIView()
        leftLine.backgroundColor = UIColor.whiteColor()
        view.addSubview(leftLine)
        leftLine.snp_makeConstraints { (make) in
            make.left.equalTo(view).offset(58 * 2)
            make.right.equalTo(orLbl.snp_left).offset(-4.5 * 2)
            make.centerY.equalTo(orLbl)
            make.height.equalTo(0.5 * 2)
        }
        
        let rightLine = UIView()
        rightLine.backgroundColor = UIColor.whiteColor()
        view.addSubview(rightLine)
        rightLine.snp_makeConstraints { (make) in
            make.right.equalTo(view).offset(-58 * 2)
            make.left.equalTo(orLbl.snp_right).offset(4.5 * 2)
            make.centerY.equalTo(orLbl)
            make.height.equalTo(0.5 * 2)
        }

        let facebookBtn : UIButton = UIButton()
        view.addSubview(facebookBtn)
        facebookBtn.titleLabel?.font = UIFont.WDTAgoraRegular(10.5 * 2)
        facebookBtn.setTitle("Login with Facebook", forState: .Normal)
        facebookBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        facebookBtn.addTarget(self, action: #selector(loginToFacebook), forControlEvents: .TouchUpInside)
        facebookBtn.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(view).offset(147.5 * 2)
            make.centerX.equalTo(view)
        })
        
        
//        let signUpBtn: UIButton = UIButton(type: .Custom)
//        signUpBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Sign Up")
//        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), forControlEvents: .TouchUpInside)
//        view.addSubview(signUpBtn)
//        signUpBtn.snp_makeConstraints { (make) in
//            make.bottom.equalTo(view).offset(-25)
//            make.left.equalTo(usernameTF)
//            make.right.equalTo(usernameTF)
//            make.height.equalTo(50)
//        }
        
        
        let alreadyHaveAnAccount: UIButton = UIButton(type: .Custom)
        alreadyHaveAnAccount.titleLabel?.font = UIFont.WDTAgoraRegular(7 * 2)
        alreadyHaveAnAccount.setTitle("Already have an account?", forState: .Normal)
        alreadyHaveAnAccount.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        alreadyHaveAnAccount.addTarget(self, action: #selector(alreadyHaveAnAccountTapped), forControlEvents: .TouchUpInside)
        view.addSubview(alreadyHaveAnAccount)
        alreadyHaveAnAccount.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-30.5 * 2)
            make.centerX.equalTo(view)
        }
        
        let turmOfUse: UIButton = UIButton(type: .Custom)
        turmOfUse.titleLabel?.font = UIFont.WDTAgoraRegular(6 * 2)
        turmOfUse.setTitle("Using the Widdit app you agree with out Terms of Use", forState: .Normal)
        turmOfUse.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        turmOfUse.addTarget(self, action: #selector(signInBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(turmOfUse)
        turmOfUse.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-11 * 2)
            make.centerX.equalTo(view)
        }


    }
    
    func alreadyHaveAnAccountTapped() {
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    func signUpBtnTapped(sender: AnyObject) {
                
        let signUpMainStep1 = SignUpPhone()
        signUpMainStep1.user = PFUser()
        navigationController?.pushViewController(signUpMainStep1, animated: true)

    }
    
    

    func loginToFacebook(sender: AnyObject?) {
        showHud()
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["email"], block: { (user, err) in
            self.hideHud()
            if err == nil {
                if let user = user {
                    if let signUpFinished = user["signUpFinished"] as? Bool where signUpFinished == true {
                        
                        NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        // Call Login Function from AppDelegate.swift class
                        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.login()
                        
                    } else {
                        
                    
                        self.showHud()
                        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, birthday, gender, age_range"]).startWithCompletionHandler { (connection, result, error) -> Void in
                            self.hideHud()
                            
                            guard let result = result else {
                                return
                                
                            }
                            
                            if let firstName = result.objectForKey("first_name") as? String {
                                user["firstName"] = firstName.lowercaseString
                            }
                            
                            if let gender = result.objectForKey("gender") as? String {
                                if gender == "male" {
                                    user["gender"] = 0
                                } else if gender == "female" {
                                    user["gender"] = 1
                                } else {
                                    user["gender"] = 2
                                }
                            } else {
                                user["gender"] = -1
                            }
                            
                            if let age_range = result.objectForKey("age_range") {
                                if let min = age_range.objectForKey("min") as? Int {
                                    user["minAge"] = min
                                } else {
                                    self.showAlert("You must be over the age of 18")
                                    return
                                }
                            }
                            
                            if let email = result.objectForKey("email") as? String {
                                user["email"] = email.lowercaseString
                            }
                            
                            
                            if let userID = result.valueForKey("id") as? String {
                                if let avaImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")!)!) {
                                    
                                    let avaData = UIImageJPEGRepresentation(avaImage, 0.5)
                                    let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                                    user["ava"] = avaFile
                                }
                                
                            }
                            
                            let signUpMainStep1 = SignUpMainStep1()
                            signUpMainStep1.user = user
                            signUpMainStep1.facebookMode = true
                            self.navigationController?.pushViewController(signUpMainStep1, animated: true)
                            
                        }
                    }
                }
            }
        })
    }
}
