//
//  NewPostVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse


import MBProgressHUD
import CircleSlider

import ALCameraViewController


class NewPostVC: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    var deletePhotoButton: UIButton = UIButton()
    var addPhotoButton: UIButton = UIButton()
    var postTxt: WDTPlaceholderTextView = WDTPlaceholderTextView()
    var remainingLabel: UILabel = UILabel()
    var postDurationLabel: UILabel = UILabel()
    var sliderView: UIView = UIView()
    var wdtSlider = WDTCircleSlider()
    
    var photoImage: UIImage?
    var geoPoint: PFGeoPoint?

    var postBtn:UIBarButtonItem!
    private var editPost: PFObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postBtn = UIBarButtonItem(title: "Post", style: .Done, target: self, action: #selector(postBtnTapped))
        postBtn.enabled = false
        navigationItem.rightBarButtonItem = postBtn
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: #selector(cancelBtnTapped))
        

        view.backgroundColor = UIColor.WDTGrayBlueColor()
        
        view.addSubview(postDurationLabel)
        view.addSubview(postTxt)
        view.addSubview(addPhotoButton)
        view.addSubview(remainingLabel)
        view.addSubview(postDurationLabel)
        view.addSubview(sliderView)
        view.addSubview(deletePhotoButton)
        
        
        postTxt.font = UIFont.WDTAgoraRegular(18)
        postTxt.placeholder = "What do you feel like doing?"
        postTxt.backgroundColor = UIColor.WDTGrayBlueColor()
        postTxt.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(5)
            make.left.equalTo(view).offset(5)
            make.right.equalTo(view).offset(-5)
            make.height.equalTo(150)
        }
        addPhotoButton.setImage(UIImage(named: "AddPhotoButton"), forState: .Normal)
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), forControlEvents: .TouchUpInside)
        addPhotoButton.snp_makeConstraints { (make) in
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(postTxt.snp_bottom).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        deletePhotoButton.hidden = true
        deletePhotoButton.setImage(UIImage(named: "DeletePhotoButton"), forState: .Normal)
        deletePhotoButton.addTarget(self, action: #selector(deletePhotoButtonTapped), forControlEvents: .TouchUpInside)
        deletePhotoButton.snp_makeConstraints { (make) in
            make.right.equalTo(view).offset(-11)
            make.top.equalTo(postTxt.snp_bottom).offset(11)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        let line = UIView()
        line.alpha = 0.6
        self.view.addSubview(line)
        line.backgroundColor = UIColor.grayColor()
        line.snp_makeConstraints { (make) in
            make.top.equalTo(addPhotoButton.snp_bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.9)
            make.height.equalTo(1)
        }

        
        sliderView.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-50)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        
        postDurationLabel.font = UIFont.WDTAgoraRegular(16)
        postDurationLabel.snp_makeConstraints { (make) in
            make.bottom.equalTo(sliderView.snp_top).offset(-25)
            make.centerX.equalTo(view)
        }
        
        postDurationLabel.text = "Use dial to set post expiration"
        
        
        

        // hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(NewPostVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        view.userInteractionEnabled = true
        view.addGestureRecognizer(hideTap)
        
        postTxt.delegate = self
        buildCircleSlider()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postTxt.becomeFirstResponder()
    }
    
    
    func editMode(post: PFObject, postPhoto: UIImage?) {
        editPost = post
        postBtn = UIBarButtonItem(title: "Save", style: .Done, target: self, action: #selector(postBtnTapped))
        postBtn.enabled = false
        navigationItem.rightBarButtonItem = postBtn
        
        if let text = post["postText"] as? String {
            postTxt.text = text
        }
        
        if let image = postPhoto {
            addPhotoButton.setImage(image, forState: .Normal)
            photoImage = image
            deletePhotoButton.hidden = false
        }
        postGuard()
    }

    func buildCircleSlider() {
        wdtSlider.addTarget(self, action: #selector(NewPostVC.valueChange(_:)), forControlEvents: .ValueChanged)
        sliderView.addSubview(self.wdtSlider)
        wdtSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(self.sliderView)
        }

        
    }
    
    
    
    func valueChange(sender: CircleSlider) {
        wdtSlider.roundControll()
        
        var s = ""
        if Int(sender.value) == 1 {
            s = ""
        } else {
            s = "s"
        }
        
        if wdtSlider.circle == .Hours {
            postDurationLabel.text = "Lasts for \(Int(sender.value)) hour" + s
        } else {
            postDurationLabel.text = "Lasts for \(Int(sender.value)) day" + s
        }
        
        postGuard()
    }
    
    func addPhotoButtonTapped(sender: AnyObject) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { image in
            if let image = image.0 {
                let resizedImage = UIImage.resizeImage(image, newWidth: 1080)
                self.addPhotoButton.setImage(resizedImage, forState: .Normal)
                self.photoImage = resizedImage
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            self.deletePhotoButton.hidden = false
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func deletePhotoButtonTapped(sender: AnyObject) {
        deletePhotoButton.hidden = true
        addPhotoButton.setImage(UIImage(named: "AddPhotoButton"), forState: .Normal)
        photoImage = nil
    }
    
    
    // Text Changing in TextView
    
    func textView(textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String) -> Bool{
        
            let currentLength:Int = (textView.text as NSString).length
            let newLength:Int = (textView.text as NSString).length + (text as NSString).length - (range.length)
            let remainingChar:Int = 140 - currentLength
        
            self.postTxt.textColor = UIColor .blackColor()
            remainingLabel.text = "\(remainingChar)"
            self.postGuard()
            return (newLength > 140) ? false : true
    }
    
    func postGuard() {
        print(wdtSlider.value)
        if postTxt.text.characters.count > 0 && self.wdtSlider.value > 1 {
            postBtn.enabled = true
        } else {
            postBtn.enabled = false
        }
    }

    // hide keyboard function
    func hideKeyboardTap() {
        view.endEditing(true)
    }
    
    // Cancel button tapped
    func cancelBtnTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postBtnTapped(sender: AnyObject) {
        
        // dismiss keyboard
        view.endEditing(true)
        
        
        
        
        
        
        // send data to server to "posts" class in Parse
        var object = PFObject(className: "posts")
        
        
        if let editPost = editPost {
            object = editPost
            object.removeObjectForKey("photoFile")
        }
        
        object["postText"] = postTxt.text
        object["user"] = PFUser.currentUser()!

        if let geoPoint = self.geoPoint {
            object["geoPoint"] = geoPoint
        }
        
        var calendarUnit: NSCalendarUnit!
        if wdtSlider.circle == .Hours {
            calendarUnit = .Hour
        } else {
            calendarUnit = .Day
        }

        let tomorrow = NSCalendar.currentCalendar().dateByAddingUnit(calendarUnit, value: Int(self.wdtSlider.value), toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
        print(tomorrow!)
        object["hoursexpired"] = tomorrow
    

        let uuid = NSUUID().UUIDString
        object["uuid"] = "\(PFUser.currentUser()?.username) \(uuid)"

        if let image = self.photoImage {
            let photoData = UIImageJPEGRepresentation(image, 0.5)
            let photoFile = PFFile(name: "postPhoto.jpg", data: photoData!)
            object["photoFile"] = photoFile

        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        // Save Information
        object.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error == nil {
                // send notification with name "uploaded"
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                // dismiss editVC
                self.dismissViewControllerAnimated(true, completion: nil)
                // Reset Everything
                self.viewDidLoad()

            }
        }
    }
}
