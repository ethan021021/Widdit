//
//  ProfileEditAboutVC.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 21.09.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse

class ProfileEditAboutVC: UIViewController, UITextViewDelegate {
    
    var tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wddSilverColor()
        
        let aboutTxt = UITextView()
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
            make.height.equalTo(view).multipliedBy(0.45)
        }
        
        navigationItem.title = "About"
        
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        PFUser.currentUser()!["about"] = textView.text
        PFUser.currentUser()!.saveInBackground()
    }


}
