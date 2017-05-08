//
//  WDTFollowerCell.swift
//  Widdit
//
//  Created by Ilya Kharabet on 08.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import MTDates


final class WDTFollowerCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newFollowerIndicatorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatarView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userAvatarView.layer.cornerRadius = userAvatarView.frame.width * 0.5
        newFollowerIndicatorView.layer.cornerRadius = userAvatarView.frame.width * 0.5
    }

    
    func setUser(_ user: PFUser, date: Date, isNew: Bool) {
        usernameLabel.text =  user["name"] as? String ?? user.username
        
        if let avaFile = user["ava"] as? PFFile, let url = avaFile.url {
            self.userAvatarView.kf.setImage(with: URL(string: url))
        }
        
        let minutes = (date as NSDate).mt_minutes(until: Date())
        dateLabel.text = "\(date)" // TODO: Date difference
        
        newFollowerIndicatorView.isHidden = !isNew
    }
    
    
}
