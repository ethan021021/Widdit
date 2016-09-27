//
//  ActivityCell.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import Presentr

class ActivityCell: UITableViewCell {
    var avaImg: UIImageView = UIImageView()
    var username: UILabel = UILabel()
    var title: UILabel = UILabel()
    var postText: UILabel = UILabel()
    var activityVC: UITableViewController!
    var replyButton: UIButton = UIButton(type: .Custom)
    var downCell: Bool = false
    var toUser: PFUser!
    var byUser: PFUser!
    var whoRepliedLast: PFUser!
    var post: PFObject!
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureSubviews() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(avaImgTapped(_:)))
        avaImg.userInteractionEnabled = true
        avaImg.addGestureRecognizer(tapGestureRecognizer)
        
        
        backgroundColor = UIColor.WDTGrayBlueColor()
        selectionStyle = .None
        contentView.addSubview(avaImg)

        contentView.addSubview(username)
        username.font = UIFont.WDTAgoraMedium(16)

        
        contentView.addSubview(title)
        title.font = UIFont.wddMicrogreyFont()
        title.textColor = UIColor.lightGrayColor()

        contentView.addSubview(postText)
        postText.numberOfLines = 2
        postText.font = UIFont.WDTAgoraRegular(14)
        postText.textColor = UIColor.grayColor()
        
        
        contentView.addSubview(replyButton)
        replyButton.setTitle("Reply", forState: .Normal)
        replyButton.setImage(UIImage(named: "ic_reply"), forState: .Normal)
        replyButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        replyButton.titleLabel?.font = UIFont.wddSmallFont()
        replyButton.selected = true
        replyButton.addTarget(self, action: #selector(replyButtonTapped), forControlEvents: .TouchUpInside)
    }
    
    func fillCell(activityObject: PFObject) {
        print(activityObject)
        let postText = activityObject["postText"] as! String
        byUser = activityObject["by"] as! PFUser
        toUser = activityObject["to"] as! PFUser
        
        post = activityObject["post"] as! PFObject
        
        if byUser.username == PFUser.currentUser()!.username {
            if let avaFile = toUser["ava"] as? PFFile {
                avaFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }
            }
        } else {
            if let avaFile = byUser["ava"] as? PFFile {
                avaFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }
            }
        }
        
        self.postText.text = postText
        replyButton.hidden = false
        
        if downCell == true {
            if byUser.username == PFUser.currentUser()!.username {
                username.text = "You"
                title.text = " down for this post"
                replyButton.hidden = true
                
            } else {
                username.text = byUser.username
                title.text = " is down for your post"
            }
        } else {
            if let whoRepliedLast = activityObject["whoRepliedLast"] as? PFUser {
                if let firstMessage = activityObject["comeFromTheFeed"] as? Bool {
                    if firstMessage {
                        username.text = whoRepliedLast.username
                        title.text = " replied to your post"
                    } else {
                        if PFUser.currentUser()!.username == byUser.username {
                            username.text = toUser.username
                        } else {
                            username.text = byUser.username
                        }
                        
                        title.text = " replied back"
                    }
                }
            }
        }
    }
    
    
    override func updateConstraints() {
        
        avaImg.snp_remakeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(7)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        username.snp_remakeConstraints { (make) in
            make.left.equalTo(avaImg.snp_right).offset(10)
            make.top.equalTo(contentView).offset(7)
        }
        
        title.snp_remakeConstraints { (make) in
            make.left.equalTo(username.snp_right)
            make.top.equalTo(contentView).offset(7)
        }
        
        postText.snp_remakeConstraints { (make) in
            make.left.equalTo(avaImg.snp_right).offset(10)
            make.top.equalTo(title.snp_bottom).offset(5)
            make.right.equalTo(replyButton.snp_left).offset(-10)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
//        downed.snp_remakeConstraints { (make) in
//            make.left.equalTo(avaImg.snp_right).offset(10)
//            make.top.equalTo(postText.snp_bottom).offset(5)
//            make.bottom.equalTo(contentView).offset(-5).priority(750)
//        }
        
        replyButton.snp_remakeConstraints { (make) in
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.right.equalTo(contentView).offset(-10)

        }
        
        super.updateConstraints()
    }
    
    func replyButtonTapped(sender: AnyObject?) {
        
        let destVC = ReplyViewController()

        if byUser.username == PFUser.currentUser()!.username {
            destVC.toUser = toUser
        } else {
            destVC.toUser = byUser
        }
        
        destVC.usersPost = post
        destVC.comeFromTheFeed = false

        activityVC.customPresentViewController(presenter, viewController: destVC, animated: true, completion: nil)
        
    }
    
    func avaImgTapped(sender: AnyObject) {
        let destVC = ProfileVC()
        if byUser.username == PFUser.currentUser()!.username {
            destVC.user = toUser
        } else {
            destVC.user = byUser
        }
        
        activityVC.navigationController?.pushViewController(destVC, animated: true)
    }
}


