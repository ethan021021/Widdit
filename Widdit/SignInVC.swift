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
import Onboard
import PermissionScope

enum VerificationMode {
    case SignIn
    case SignUp
}
import SkyFloatingLabelTextField
class SignInVC: UIViewController {
    let usernameTF = SkyFloatingLabelTextField()
    let passwordTF = SkyFloatingLabelTextField()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
        
        view.backgroundColor = UIColor.wddTealColor()
        
        usernameTF.textColor = UIColor.whiteColor()
        usernameTF.placeholder = "Enter Username"
        usernameTF.title = "Username"
        usernameTF.becomeFirstResponder()
        usernameTF.autocapitalizationType = .None
        usernameTF.textAlignment = .Left
        usernameTF.autocapitalizationType = .None
        usernameTF.lineHeight = 1
        usernameTF.selectedLineHeight = 1
        usernameTF.placeholderColor = UIColor.whiteColor()
        usernameTF.lineColor = UIColor.whiteColor()
        usernameTF.selectedLineColor = UIColor.whiteColor()
        usernameTF.selectedTitleColor = UIColor.whiteColor()
//        usernameTF.tintColor = UIColor.greenColor()
        
        view.addSubview(usernameTF)
        usernameTF.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(35.5.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.9)
        }
        

//        passwordTF.font = UIFont.wddHtwoinvertcenterFont()
        passwordTF.textColor = UIColor.whiteColor()
        passwordTF.textAlignment = .Left
        passwordTF.placeholder = "Enter Password"
        passwordTF.title = "Password"
        passwordTF.autocapitalizationType = .None
        passwordTF.secureTextEntry = true
        passwordTF.lineHeight = 1
        passwordTF.selectedLineHeight = 1
        passwordTF.placeholderColor = UIColor.whiteColor()
        passwordTF.lineColor = UIColor.whiteColor()
        passwordTF.selectedLineColor = UIColor.whiteColor()
        passwordTF.selectedTitleColor = UIColor.whiteColor()
//        passwordTF.tintColor = UIColor.greenColor()
        view.addSubview(passwordTF)
        passwordTF.snp_makeConstraints { (make) in
            make.top.equalTo(usernameTF.snp_bottom).offset(12.x2)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.9)
        }
        
        let signInBtn: UIButton = UIButton(type: .Custom)
        signInBtn.titleLabel?.font = UIFont.WDTAgoraRegular(10.5 * 2)
        signInBtn.setTitle("Sign in", forState: .Normal)
        signInBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signInBtn.addTarget(self, action: #selector(signInBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signInBtn)
        signInBtn.snp_makeConstraints { (make) in
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

                AppDelegate.appDelegate.login()
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
    
    let imDownBtn = UIButton()
    var onboardingVC: OnboardingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wddTealColor()
        navigationController?.navigationBarHidden = true
        let logo = UIImageView(image: UIImage(named: "logo_splash"))
        logo.contentMode = .ScaleAspectFit
        view.addSubview(logo)
        logo.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(47.5)
            make.centerX.equalTo(view)
        }
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let orLbl = UILabel()
        view.addSubview(orLbl)
        
        let signUpBtn: UIButton = UIButton(type: .Custom)
        signUpBtn.titleLabel?.font = UIFont.WDTAgoraRegular(10.5 * 2)
        signUpBtn.setTitle("Sign up", forState: .Normal)
        signUpBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), forControlEvents: .TouchUpInside)
        view.addSubview(signUpBtn)
        signUpBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(orLbl.snp_top).offset(-27)
            make.centerX.equalTo(view)
        }
        
        
        orLbl.text = "or"
        orLbl.font = UIFont.WDTAgoraRegular(7 * 2)
        orLbl.textColor = UIColor.whiteColor()
        
        orLbl.snp_makeConstraints { (make) in
            make.centerY.equalTo(view)
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
            make.top.equalTo(orLbl.snp_bottom).offset(27)
            make.centerX.equalTo(view)
        })
        
        
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

        
        let page1 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen1"), buttonText: "") { () -> Void in}
        
        let page2 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen2"), buttonText: "") { () -> Void in}
        
        let page3 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen3"), buttonText: "") { () -> Void in}
        
        let page4 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen4"), buttonText: "") { () -> Void in}
        
        let page5 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen5"), buttonText: "") { () -> Void in}
        
        let page6 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen6"), buttonText: "") { () -> Void in}
        
        let page7 = OnboardingContentViewController(title: "", body: "", image: UIImage(named: "ic_tutorial_screen7"), buttonText: "") { () -> Void in}
        
        
        page1.topPadding = 100
        page2.topPadding = 100
        page3.topPadding = 100
        page4.topPadding = 100
        page5.topPadding = 100
        page6.topPadding = 100
        page7.topPadding = 100
        
        
    
        
        
        imDownBtn.backgroundColor = UIColor.whiteColor()
        imDownBtn.setImage(UIImage(named: "ic_down"), forState: .Normal)
        imDownBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        imDownBtn.titleLabel?.font = UIFont.WDTAgoraRegular(14)
        imDownBtn.setTitle("I'm down", forState: .Normal)
        imDownBtn.addTarget(self, action: #selector(downBtnTapped), forControlEvents: .TouchUpInside)
        imDownBtn.layer.cornerRadius = 4
        imDownBtn.clipsToBounds = true
        imDownBtn.layer.shouldRasterize = true
        imDownBtn.layer.rasterizationScale = UIScreen.mainScreen().scale;
        
        
        page2.view.addSubview(imDownBtn)
        
        imDownBtn.snp_remakeConstraints { (make) in
            make.height.equalTo(40)
            //make.top.equalTo(cardView)
            make.left.equalTo(page2.iconImageView.snp_centerX)
            make.right.equalTo(page2.iconImageView).offset(-10)
            make.bottom.equalTo(page2.iconImageView).offset(-10)
        }
        

        
        onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "bgLogin"), contents: [page1, page6, page7, page2, page4, page5])
        onboardingVC.shouldBlurBackground = false
        onboardingVC.shouldMaskBackground = false
        onboardingVC.swipingEnabled = false
        onboardingVC.pageControl.backgroundColor = UIColor.whiteColor()
        onboardingVC.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        onboardingVC.pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        onboardingVC.pageControl.frame = CGRectMake(0, view.bounds.height - 200, view.bounds.width, 200)
        onboardingVC.shouldFadeTransitions = true
        //onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.allowSkipping = true
        onboardingVC.bodyLabel.font = UIFont.systemFontOfSize(22)
        onboardingVC.bodyLabel.numberOfLines = 0
        onboardingVC.bodyLabel.text = "Be down to collaborate"
        onboardingVC.skipButton.setTitleColor(UIColor.blackColor(), forState: .Normal)

        
        onboardingVC.notificationHandler = { [weak self] in
            //UIApplication.sharedApplication().registerForRemoteNotifications()
            PermissionScope().requestNotifications()
            self!.onboardingVC.moveNextPage()
            self!.onboardingVC.norificationBtn.hidden = true
            self!.onboardingVC.locationBtn.hidden = false
            self!.onboardingVC.bodyLabel.text = "We need your location to show you posts 🌎"
        }
        
        onboardingVC.locationHandler = { [weak self] in
            //UIApplication.sharedApplication().registerForRemoteNotifications()
            PermissionScope().requestLocationInUse()
            self!.onboardingVC.dismissViewControllerAnimated(true, completion: nil)

        }
        
        onboardingVC.skipHandler = { [weak self] in
            
            if self!.onboardingVC.pageControl.currentPage == 5 {
                self!.onboardingVC.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self!.onboardingVC.bodyLabel.font = UIFont.systemFontOfSize(18)
            self!.onboardingVC.skipButton.hidden = false
            self!.onboardingVC.moveNextPage()
            
            switch self!.onboardingVC.pageControl.currentPage {
            case 1:
                
                self!.onboardingVC.skipButton.setTitle("Next", forState: .Normal)
                self!.onboardingVC.makeSkipButtonRight()
                self!.onboardingVC.locationBtn.hidden = true
                self!.onboardingVC.bodyLabel.text = "Be down to buy/sell"
                
            case 2:
                
                self!.onboardingVC.bodyLabel.text = "Be down to do anything"
                
                
            case 3:
                
                self!.onboardingVC.skipButton.hidden = true
                self!.onboardingVC.bodyLabel.text = "Go ahead and tap the I'm down button"
                
            case 4:
                
                self!.onboardingVC.skipButton.setTitle("Skip", forState: .Normal)
                self!.onboardingVC.bodyLabel.text = "We want to notify you on downs, replies, and updates 💯"
                self!.onboardingVC.makeSkipButtonLeft()
                self!.onboardingVC.norificationBtn.hidden = false

            case 5:
                
                self!.onboardingVC.norificationBtn.hidden = true
                self!.onboardingVC.locationBtn.hidden = false
                self!.onboardingVC.bodyLabel.text = "We need your location to show you posts 🌎"
                
            default:
                print()
            }
        }
        
        if NSUserDefaults.isFirstStart() == true {
            onboardingVC.skipButton.setTitle("Next", forState: .Normal)
            presentViewController(onboardingVC, animated: true, completion: nil)
        }
        
    }
    
    
    func downBtnTapped() {
        imDownBtn.setTitleColor(UIColor.wddTealColor(), forState: .Normal)
        onboardingVC.bodyLabel.text = "How it works: Only the person who made the post knows you're down. No one else 😇"
        onboardingVC.bodyLabel.font = UIFont.systemFontOfSize(18)
        onboardingVC.skipButton.hidden = false
    }
    
    func alreadyHaveAnAccountTapped() {
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    func signUpBtnTapped(sender: AnyObject) {
        let signUpMainVC = SignUpMain()
        signUpMainVC.user = PFUser()
        signUpMainVC.facebookMode = false
        //let signUpMainStep1 = SignUpPhone()
        //signUpMainStep1.user = PFUser()
        navigationController?.pushViewController(signUpMainVC, animated: true)

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
                        
                        AppDelegate.appDelegate.login()
                        
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
                            
//                            if let gender = result.objectForKey("gender") as? String {
//                                if gender == "male" {
//                                    user["gender"] = 0
//                                } else if gender == "female" {
//                                    user["gender"] = 1
//                                } else {
//                                    user["gender"] = 2
//                                }
//                            } else {
//                                user["gender"] = -1
//                            }
//                            
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
                            
                            let signUpMainStep1 = SignUpMain()
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
