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
    
    
    @IBOutlet weak var label: UILabel!
    
    let usernameTF = UITextField()
    let passwordTF = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.WDTBlueColor()
        navigationController?.navigationBarHidden = true
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        usernameTF.WDTRoundedWhite(nil, height: 50)
        usernameTF.WDTFontSettings("Enter Username")
        usernameTF.autocapitalizationType = .None
        
        view.addSubview(usernameTF)
        usernameTF.snp_makeConstraints { (make) in
            make.top.equalTo(label.snp_bottom).offset(20)
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
            make.top.equalTo(usernameTF.snp_bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.7)
            make.height.equalTo(50)
        }

        
        
        let signInBtn: UIButton = UIButton(type: .Custom)
        signInBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Sign In")
        signInBtn.addTarget(self, action: #selector(signInBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signInBtn)
        signInBtn.snp_makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp_bottom).offset(25)
            make.left.equalTo(usernameTF)
            make.right.equalTo(usernameTF)
            make.height.equalTo(50)
        }
        
//        let facebookBtn : FBSDKLoginButton = FBSDKLoginButton()
        let facebookBtn : UIButton = UIButton()
        view.addSubview(facebookBtn)
        facebookBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Log in with Facebook")
        facebookBtn.addTarget(self, action: #selector(loginToFacebook), forControlEvents: .TouchUpInside)
//        facebookBtn.readPermissions = ["public_profile", "email", "user_friends"]
//        facebookBtn.delegate = self
        facebookBtn.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(signInBtn.snp_bottom).offset(20)
            make.left.equalTo(usernameTF)
            make.right.equalTo(usernameTF)
            make.height.equalTo(50)
        })
        
        
        let signUpBtn: UIButton = UIButton(type: .Custom)
        signUpBtn.WDTButtonStyle(UIColor.whiteColor(), title: "Sign Up")
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signUpBtn)
        signUpBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-25)
            make.left.equalTo(usernameTF)
            make.right.equalTo(usernameTF)
            make.height.equalTo(50)
        }
        
        
//        let resetPswdBtn: UIButton = UIButton(type: .Custom)
//        resetPswdBtn.setTitle("Forgot Password", forState: .Normal)
//        resetPswdBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        resetPswdBtn.titleLabel?.font = UIFont.WDTAgoraRegular(16)
//        resetPswdBtn.addTarget(self, action: #selector(resetPswdBtnTapped), forControlEvents: .TouchUpInside)
//        view.addSubview(resetPswdBtn)
//        resetPswdBtn.snp_makeConstraints { (make) in
//            make.bottom.equalTo(view).offset(-20)
//            make.centerX.equalTo(view)
//            make.width.equalTo(view).multipliedBy(0.7)
//            make.height.equalTo(50)
//        }
        
        // Font of Label
        label.font = UIFont(name: "Pacifico", size: 35)
        
        
//        configureFacebook()

    }
    
    func signUpBtnTapped(sender: AnyObject) {
                
        let signUpMainStep1 = SignUpMainStep1()
        signUpMainStep1.user = PFUser()
        navigationController?.pushViewController(signUpMainStep1, animated: true)

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
    
    //    MARK: FBSDKLoginButtonDelegate Methods

    //WE NEED TO USE THIS BUTTON OR A CUSTOM IMAGE FOR IT
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
//    {
//        print("User Logged In")
//        if ((error) != nil)
//        {
//            // Process error
//            print(error)
//        } else if result.isCancelled {
//            // Handle cancellations
//            print("User cancelled")
//        } else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            if result.grantedPermissions.contains("email")
//            {
//                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).startWithCompletionHandler { (connection, result, error) -> Void in
//
//                    if result.count > 0 {
//
//                        let userQuery = PFQuery(className: "_User")
//
//                        userQuery.whereKey("email", equalTo: result.valueForKey("email") as! String)
//
//                        userQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
//                            if err == nil {
//                                if let object = objects!.first {
//                                    print("User is in our DB")
//                                    let user = object as! PFUser
//                                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//                                    PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken(), block: { (success, error) in
//                                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                                        // Remember user or save in App Memory did the user login or not
//                                        NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
//                                        NSUserDefaults.standardUserDefaults().synchronize()
//                                        
//                                        // Call Login Function from AppDelegate.swift class
//                                        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                                        appDelegate.login()
//                                    })
//                                    
//                                } else {
//                                    let strFirstName: String? = result.objectForKey("first_name") as? String
////                                    let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//                                    let strEmail: String? = result.objectForKey("email") as? String
////                                    let strGender: String = (result.objectForKey("gender") as? String)!
//                                    let userID = result.valueForKey("id") as! String
//                                    let avaImage: UIImage? = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")!)!)
//
//                                    
//                                    let user = PFUser()
//                                    if let strEmail = strEmail {
//                                        user["email"] = strEmail.lowercaseString
//                                    }
//                                    
//                                    if let strFirstName = strFirstName {
//                                        user["firstName"] = strFirstName.lowercaseString
//                                    }
//                                    
//                                    if let avaImage = avaImage {
//                                        let avaData = UIImageJPEGRepresentation(avaImage, 0.5)
//                                        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
//                                        user["ava"] = avaFile
//                                    }
//                                    
//                                    let editVC = ProfileEditVC()
//                                    editVC.signUpMode = true
//                                    editVC.facebookMode = true
//                                    self.navigationController?.pushViewController(editVC, animated: true)
//                                    
//                                    
//                                }
//                            } else {
//                                print(err)
//                            }
//                        })
//                    } else {
//                        print("Error completing facebook signup")
//                    }
//                    
//                }
//            }
//        }
//    }
//
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
//    {
//        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
//        loginManager.logOut()
//        
// 
//    }
}
