//
//  ProfileEditAboutVC.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 21.09.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse

class ProfileEditAboutVC: UIViewController, UITextViewDelegate {
    
    var tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)
    let aboutTxt = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wddSilverColor()
        
        
        if let about = PFUser.currentUser()!["about"] as? String {
            aboutTxt.text = about
        }
        aboutTxt.becomeFirstResponder()
        aboutTxt.delegate = self
        aboutTxt.font = UIFont.wddHtwoinvertcenterFont()
        view.addSubview(aboutTxt)
        aboutTxt.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.6)
        }
        
        navigationItem.title = "About"
        
        
        let saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveButtonTapped() {
        PFUser.currentUser()!["about"] = aboutTxt.text
        showHud()
        PFUser.currentUser()!.saveInBackgroundWithBlock { (_, _) in
            self.hideHud()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    //func textViewDidEndEditing(textView: UITextView) {
        
    //}


}
