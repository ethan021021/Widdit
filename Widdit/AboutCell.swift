//
//  AboutCell.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 15.09.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell {

    let aboutTxt = UITextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        contentView.addSubview(aboutTxt)
        aboutTxt.editable = false
        aboutTxt.scrollEnabled = false
        aboutTxt.userInteractionEnabled = true;
        aboutTxt.dataDetectorTypes = [.Link, .PhoneNumber]
        aboutTxt.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(6.x2)
            make.right.equalTo(contentView).offset(-6.x2)
            make.top.equalTo(contentView).offset(4.5.x2)
            make.bottom.equalTo(contentView).offset(-5.5.x2)
        }
        
    }
    

    func fillCell(aboutText: String) {
        aboutTxt.text = aboutText
        
    }

}

enum WDTSituation: Int {
    case School
    case Working
    case Opportunity
    
    
    func getDescription() -> (String, String) {
        switch self {
        case .School:
            return ("At school", "ic_school")
        case .Working:
            return ("Working", "ic_job")
        case .Opportunity:
            return ("Opportunity", "ic_open")
        }
    }
}

enum WDTVerification: Int {
    case Phone
    case Email
    case Facebook
    
    func getDescription() -> (String, String) {
        switch self {
        case .Phone:
            return ("Phone", "ic_phone")
        case .Email:
            return ("E-mail", "ic_mail")
        case .Facebook:
            return ("Facebook", "ic_fb")
        }
    }
}

import Parse

enum WDTSettings {
    case Username(String)
    case Name(String)
    case Email(String)
    case About(String)
    case Gender(Int)
    case School(Bool)
    case Working(Bool)
    case Opportunity(Bool)
    
    func getDescription() -> String {
        switch self {
        case .Username:
            return "Username"
        case .Name:
            return "Name"
        case .Email:
            return "Email"
        case .About:
            return "About"
        case .Gender:
            return "Gender"
        case .School:
            return "Currently at school"
        case .Working:
            return "Have a job"
        case .Opportunity:
            return "Open to new things"
        }
    }
}

import ParseFacebookUtilsV4

class ProfileFacebookCell: UITableViewCell {
    
    let facebookLinkingBtn = UIButton(type: .Custom)
    var vc: UIViewController!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        backgroundColor = UIColor.clearColor()
        facebookLinkingBtn.backgroundColor = UIColor.WDTBlueColor()
        facebookLinkingBtn.addTarget(self, action: #selector(facebookLinkingBtnTapped), forControlEvents: .TouchUpInside)
        facebookLinkingBtn.layer.cornerRadius = 26
        facebookLinkingBtn.clipsToBounds = true
        contentView.addSubview(facebookLinkingBtn)
        
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) == true {
            facebookLinkingBtn.setTitle("Unlink Facebook", forState: .Normal)
        } else {
            facebookLinkingBtn.setTitle("Link Facebook", forState: .Normal)
        }

        
        facebookLinkingBtn.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(26.x2)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
        }
        
    }
    
    func facebookLinkingBtnTapped() {
        let user = PFUser.currentUser()!
        
        if PFFacebookUtils.isLinkedWithUser(user) == true {
            
            PFFacebookUtils.unlinkUserInBackground(user, block: { (succeeded: Bool?, error: NSError?) in
                user["facebookVerified"] = false
                user.saveInBackground()
                self.facebookLinkingBtn.setTitle("Link Facebook", forState: .Normal)
            })
            
        } else {
            facebookLinkingBtn.setTitle("Link Facebook", forState: .Normal)
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if error == nil {
                    self.facebookLinkingBtn.setTitle("Unlink Facebook", forState: .Normal)
                    user["facebookVerified"] = true
                    user.saveInBackground()
                } else {
                    self.vc.showAlert((error?.localizedDescription)!)
                }
            })
        }
    }
}

class ProfileCell: UITableViewCell {
    
    let titleLbl = UILabel()
    let iconImg = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        
        contentView.addSubview(iconImg)
        iconImg.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(6.x2)
            make.top.equalTo(contentView).offset(4.x2)
            make.bottom.equalTo(contentView).offset(-4.x2)
        }
        
        contentView.addSubview(titleLbl)
        titleLbl.numberOfLines = 1
        titleLbl.snp_makeConstraints { (make) in
            make.left.equalTo(iconImg.snp_right).offset(6.x2)
            make.top.equalTo(contentView).offset(6.x2)
            make.bottom.equalTo(contentView).offset(-8.x2)
        }
        
    }
    
    func fillCellSituation(situation: WDTSituation, user: PFUser) {
        
        let (title, imgname) = situation.getDescription()
        iconImg.image = UIImage(named: imgname)
        titleLbl.text = title
        
        switch situation {
        case .School:
            if let sit = user["situationSchool"] as? Bool where sit == true {
                accessoryType = .Checkmark
            } else {
                accessoryType = .None
            }
        case .Working:
            if let sit = user["situationWork"] as? Bool where sit == true {
                accessoryType = .Checkmark
            } else {
                accessoryType = .None
            }
        case .Opportunity:
            if let sit = user["situationOpportunity"] as? Bool where sit == true {
                accessoryType = .Checkmark
            } else {
                accessoryType = .None
            }
        }
    }
    
    func fillCellVerification(verification: WDTVerification, user: PFUser) {
        let (title, imgname) = verification.getDescription()
        iconImg.image = UIImage(named: imgname)
        titleLbl.text = title
        
        if let _ = user["phoneNumber"] {
            accessoryType = .Checkmark
            
        }
        
        if let _ = user["email"] {
            accessoryType = .Checkmark
        }
        
        if let facebookVerified = user["facebookVerified"] as? Bool where facebookVerified == true {
            accessoryType = .Checkmark
        }
    }

}

import SimpleAlert
import ALCameraViewController
//import ImagePicker

class ProfileSettingAvatarsCell: UITableViewCell {
    
    let addAvatar1 = UIButton()
    let addAvatar2 = UIButton()
    let addAvatar3 = UIButton()
    let deleteAvatar2 = UIButton()
    let deleteAvatar3 = UIButton()
    var vc: UIViewController!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        fillCell()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        backgroundColor = UIColor.clearColor()
        contentView.addSubview(addAvatar1)
        contentView.addSubview(addAvatar2)
        contentView.addSubview(addAvatar3)
        
        addAvatar1.layer.cornerRadius = 10
        addAvatar1.setImage(UIImage(named: "add_photo"), forState: .Normal)
        addAvatar1.tag = 1
        addAvatar1.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
        addAvatar1.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(6.x2)
            make.top.equalTo(contentView)
            make.width.equalTo(44.x2)
            make.height.equalTo(44.x2)
        }
        

        
        addAvatar2.layer.cornerRadius = 10
        addAvatar2.setImage(UIImage(named: "add_photo"), forState: .Normal)
        addAvatar2.tag = 2
        addAvatar2.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
        addAvatar2.snp_makeConstraints { (make) in
            make.left.equalTo(addAvatar1.snp_right).offset(8.x2)
            make.top.equalTo(contentView)
            make.width.equalTo(44.x2)
            make.height.equalTo(44.x2)
        }
        
        addAvatar2.addSubview(deleteAvatar2)
        deleteAvatar2.hidden = true
        deleteAvatar2.tag = 2
        deleteAvatar2.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
        deleteAvatar2.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
        deleteAvatar2.snp_makeConstraints { (make) in
            make.right.equalTo(addAvatar2).offset(5)
            make.bottom.equalTo(addAvatar2).offset(5)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        
        addAvatar3.layer.cornerRadius = 10
        addAvatar3.setImage(UIImage(named: "add_photo"), forState: .Normal)
        addAvatar3.tag = 3
        addAvatar3.addTarget(self, action: #selector(addAvatarButtonTapped), forControlEvents: .TouchUpInside)
        addAvatar3.snp_makeConstraints { (make) in
            make.left.equalTo(addAvatar2.snp_right).offset(8.x2)
            make.top.equalTo(contentView)
            make.width.equalTo(44.x2)
            make.height.equalTo(44.x2)
        }
        
        addAvatar3.addSubview(deleteAvatar3)
        deleteAvatar3.hidden = true
        deleteAvatar3.tag = 3
        deleteAvatar3.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
        deleteAvatar3.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
        deleteAvatar3.snp_makeConstraints { (make) in
            make.right.equalTo(addAvatar3).offset(5)
            make.bottom.equalTo(addAvatar3).offset(5)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        
        let bottomView = UIView()
        contentView.addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) in
            make.top.equalTo(addAvatar1.snp_bottom).offset(5)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.bottom.equalTo(contentView).priority(751)
        }
    }
    
    func fillCell() {
        WDTAvatar.getAvatar(PFUser.currentUser()!, avaNum: 1) { (ava) in
            if let ava = ava {
                //                self.deleteAvatar1.hidden = false
                self.addAvatar1.setImage(ava, forState: .Normal)
            }
        }
        
        WDTAvatar.getAvatar(PFUser.currentUser()!, avaNum: 2) { (ava) in
            if let ava = ava {
                self.deleteAvatar2.hidden = false
                self.addAvatar2.setImage(ava, forState: .Normal)
            }
        }
        
        WDTAvatar.getAvatar(PFUser.currentUser()!, avaNum: 3) { (ava) in
            if let ava = ava {
                self.deleteAvatar3.hidden = false
                self.addAvatar3.setImage(ava, forState: .Normal)
            }
        }
    }
    
    func deletePhotoButtonTapped(sender: AnyObject) {
        if sender.tag! == 1 {
            addAvatar1.setImage(UIImage(named: "add_photo"), forState: .Normal)
            PFUser.currentUser()!.removeObjectForKey("ava")
            
        } else if sender.tag! == 2 {
            addAvatar2.setImage(UIImage(named: "add_photo"), forState: .Normal)
            deleteAvatar2.hidden = true
            PFUser.currentUser()!.removeObjectForKey("ava2")
            
        } else if sender.tag! == 3 {
            addAvatar3.setImage(UIImage(named: "add_photo"), forState: .Normal)
            deleteAvatar3.hidden = true
            PFUser.currentUser()!.removeObjectForKey("ava3")
            
        }
        
        PFUser.currentUser()!.saveInBackground()
        
    }
    
    func addAvatarButtonTapped(sender: AnyObject) {
        
        let cameraViewController = CameraViewController(croppingEnabled: true) { image in
            if let image = image.0 {
                var resizedImage: UIImage!
                let user = PFUser.currentUser()!
                
                resizedImage = UIImage.resizeImage(image, newWidth: 400)
                resizedImage = resizedImage.roundCorners(20)
                let avaData = UIImageJPEGRepresentation(resizedImage, 0.5)
                let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                
                if sender.tag == 1 {
                    self.addAvatar1.setImage(resizedImage, forState: .Normal)
                    user["ava"] = avaFile
                    
                } else if sender.tag == 2 {
                    self.addAvatar2.setImage(resizedImage, forState: .Normal)
                    user["ava2"] = avaFile
                    self.deleteAvatar2.hidden = false
                    
                } else if sender.tag == 3 {
                    self.addAvatar3.setImage(resizedImage, forState: .Normal)
                    user["ava3"] = avaFile
                    self.deleteAvatar3.hidden = false
                    
                }
                
                user.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        
                    }
                })
            }
            self.vc.dismissViewControllerAnimated(true, completion: nil)
        }
        
        vc.presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    
}

import SevenSwitch

class ProfileSettingsCell: UITableViewCell, UITextFieldDelegate {
    
    let titleLbl = UILabel()
    let textField = UITextField()
    let uiswitch = SevenSwitch()
    var settingsCell: WDTSettings?
    var vc: UIViewController!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        
        contentView.addSubview(titleLbl)
        titleLbl.numberOfLines = 1
        titleLbl.textColor = UIColor.lightGrayColor()
        titleLbl.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(6.x2)
            make.top.equalTo(contentView).offset(6.x2)
            make.bottom.equalTo(contentView).offset(-8.x2)
        }
        
        contentView.addSubview(textField)
        textField.delegate = self
        textField.textAlignment = .Right
        textField.hidden = true
        textField.snp_makeConstraints { (make) in
            make.width.equalTo(contentView).dividedBy(2)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.right.equalTo(contentView).offset(-7.x2)
        }
        
        contentView.addSubview(uiswitch)
        
        uiswitch.thumbTintColor = UIColor.whiteColor()
        uiswitch.onThumbTintColor = UIColor.wddTealColor()
        uiswitch.borderColor = UIColor.wddSilverColor()
        uiswitch.activeColor =  UIColor.wddSilverColor()
        uiswitch.inactiveColor = UIColor.wddSilverColor()
        uiswitch.onTintColor = UIColor.wddSilverColor()
        
        uiswitch.hidden = true
        uiswitch.addTarget(self, action: #selector(uiswitchTapped), forControlEvents: .ValueChanged)
        uiswitch.snp_makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-4.x2)
            make.top.equalTo(contentView).offset(4.x2)
            make.bottom.equalTo(contentView).offset(-4.x2)
            make.width.equalTo(30.x2)
        }
        
        
    }

    func activateTextField() {
        textField.hidden = false
    }
    
    func deactivateTextField() {
        textField.hidden = true
    }
    
    func activateSwitch() {
        uiswitch.hidden = false
    }
    
    func deactivateSwitch() {
        uiswitch.hidden = true
    }
    
    
    func fillSettings(settings: WDTSettings) {
        settingsCell = settings
        titleLbl.text = settings.getDescription()
        deactivateSwitch()
        deactivateTextField()
        
        switch settings {
        case .Username(let value):
            activateTextField()
            textField.text = value
        case .Name(let value):
            activateTextField()
            textField.text = value
        case .Email(let value):
            activateTextField()
            textField.text = value
        
        case .School(let value):
            activateSwitch()
            uiswitch.on = value
        case .Working(let value):
            activateSwitch()
            uiswitch.on = value
        case .Opportunity(let value):
            activateSwitch()
            uiswitch.on = value
            
        case .Gender(let value):
            activateTextField()
            textField.enabled = false
            if value == 0 {
                textField.text = "Male"
            } else if value == 1 {
                textField.text = "Female"
            } else if value == 2 {
                textField.text = "Other"
            } else if value == -1 {
                textField.text = "Unknown"
            }
        case .About(let value):
            activateTextField()
            textField.enabled = false
            textField.text = value
            
        default:
            break
        }
    }
    
    func uiswitchTapped(sender: UISwitch) {
        if let settingsCell = settingsCell {
            
            switch settingsCell {
            case .School:
                PFUser.currentUser()!["situationSchool"] = sender.on
            case .Working:
                PFUser.currentUser()!["situationWork"] = sender.on
            case .Opportunity:
                PFUser.currentUser()!["situationOpportunity"] = sender.on
            default:
                break
            }
            PFUser.currentUser()?.saveInBackground()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let settingsCell = settingsCell {
            
            switch settingsCell {
            case .Username:
                PFUser.currentUser()!.username = textField.text?.lowercaseString
            case .Name:
                PFUser.currentUser()!["firstName"] = textField.text?.lowercaseString
            case .Email:
                if !(textField.text!.validateEmail())  {
                    vc.showAlert("Please provide correct email address")
                    textField.text = PFUser.currentUser()!.email
                } else {
                    PFUser.currentUser()!.email = textField.text?.lowercaseString
                }
                
            default:
                break
            }
            
            PFUser.currentUser()?.saveInBackground()
        }
    }
    
    func cellSelected() {
        if let settingsCell = settingsCell {
            switch settingsCell {
            case .About:
                break
            case .Gender:
                let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)
                alert.addAction(SimpleAlert.Action(title: "Male", style: .Default) { action in
                    PFUser.currentUser()!["gender"] = 0
                    PFUser.currentUser()?.saveInBackground()
                    self.textField.text = "Male"
                    })
                alert.addAction(SimpleAlert.Action(title: "Female", style: .Default) { action in
                    PFUser.currentUser()!["gender"] = 1
                    PFUser.currentUser()?.saveInBackground()
                    self.textField.text = "Female"
                    })
                alert.addAction(SimpleAlert.Action(title: "Other", style: .Default) { action in
                    PFUser.currentUser()!["gender"] = 2
                    PFUser.currentUser()?.saveInBackground()
                    self.textField.text = "Other"
                    })
                
                alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
                
                vc.presentViewController(alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    
}
