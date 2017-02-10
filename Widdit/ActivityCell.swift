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
import NoChat

class ActivityCell: UITableViewCell {
    var avaImg: UIImageView = UIImageView()
    var username: UILabel = UILabel()
    var title: UILabel = UILabel()
    var postText: UILabel = UILabel()
    var activityVC: ActivityVC!
    var tableView: UITableView!
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
        //replyButton.setTitle("Reply", forState: .Normal)
//        replyButton.setImage(UIImage(named: "ic_reply"), forState: .Normal)
        replyButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        replyButton.titleLabel?.font = UIFont.wddSmallFont()
        replyButton.selected = true
        replyButton.imageView?.contentMode = .ScaleAspectFit
        replyButton.addTarget(self, action: #selector(replyButtonTapped), forControlEvents: .TouchUpInside)
    }
    
    func fillCell(_activityObject: AnyObject) {
        let activityObject = _activityObject as! PFObject
        
        let postText = activityObject["postText"] as! String
        byUser = activityObject["by"] as! PFUser
        toUser = activityObject["to"] as! PFUser
        
        post = activityObject["post"] as! PFObject
        
        if byUser.username == PFUser.currentUser()!.username {
            if let avaFile = toUser["ava"] as? PFFile {
                avaFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }
            } else {
                self.avaImg.image = UIImage(named: "ic_blank_placeholder_square")
            }
        } else {
            if let avaFile = byUser["ava"] as? PFFile {
                avaFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }
            } else {
                self.avaImg.image = UIImage(named: "ic_blank_placeholder_square")
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
            
            if let whoRepliedLast = activityObject["whoRepliedLast"] as? PFUser {
                if let _ = activityObject["comeFromTheFeed"] as? Bool {
                    if PFUser.currentUser()!.username != whoRepliedLast.username {
                        if activityObject["replyRead"] as? Bool == true {
                            replyButton.setImage(UIImage(named: "ic_activity_read"), forState: .Normal)
                        } else {
                            replyButton.setImage(UIImage(named: "ic_activity_unread"), forState: .Normal)
                        }
                    } else {
                        replyButton.setImage(UIImage(named: "ic_activity_sent"), forState: .Normal)
                    }
                }
            } else {
                replyButton.setImage(UIImage(named: "ic_reply"), forState: .Normal)
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
                            if whoRepliedLast.username == byUser.username {
                                title.text = ""
                            } else {
                                title.text = " replied back"
                            }
                            
                        } else {
                            username.text = byUser.username
                            
                            if whoRepliedLast.username == byUser.username {
                                title.text = " replied back"
                            } else {
                                title.text = ""
                            }
                        }
                        
                        
                    }
                }
                
                if PFUser.currentUser()!.username != whoRepliedLast.username {
                    if activityObject["replyRead"] as? Bool == true {
                        replyButton.setImage(UIImage(named: "ic_activity_read"), forState: .Normal)
                    } else {
                        replyButton.setImage(UIImage(named: "ic_activity_unread"), forState: .Normal)
                    }
                } else {
                    replyButton.setImage(UIImage(named: "ic_activity_sent"), forState: .Normal)
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
            make.top.equalTo(username.snp_bottom).offset(5)
            make.right.equalTo(contentView).offset(-68)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
//        downed.snp_remakeConstraints { (make) in
//            make.left.equalTo(avaImg.snp_right).offset(10)
//            make.top.equalTo(postText.snp_bottom).offset(5)
//            make.bottom.equalTo(contentView).offset(-5).priority(750)
//        }
        
        replyButton.snp_remakeConstraints { (make) in
            
            make.right.equalTo(contentView).offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(40)
            make.centerY.equalTo(contentView)
            

        }
        
        super.updateConstraints()
    }
    
    func replyButtonTapped(sender: AnyObject?) {
        
        let chatItemsDecorator = WDTChatItemsDecorator()
        
        let demoDataSource = WDTChatDataSource()
        var user: PFUser!
        if byUser.username == PFUser.currentUser()!.username {
            user = toUser
        } else {
            user = byUser
        }
        activityVC.showHud()
        WDTChatItemFactory.createChatItemsTG(user, usersPost: post) { (messages) in
            self.activityVC.hideHud()
            demoDataSource.chatItems = messages
            
            let chatVC = ReplyViewController()
            chatVC.delegate = self.activityVC
            chatVC.tableView = self.tableView
            chatVC.toUser = user
            chatVC.usersPost = self.post
            chatVC.comeFromTheFeed = false
            chatVC.chatItemsDecorator = chatItemsDecorator
            chatVC.chatDataSource = demoDataSource
            chatVC.hidesBottomBarWhenPushed = true
            chatVC.fetchUsernameAndAvatar()
            self.activityVC.customPresentViewController(presenter, viewController: chatVC, animated: true, completion: {
                chatVC.inputController.growTextView.becomeFirstResponder()
                
            })
        }

        
        
    }
    
    func avaImgTapped(sender: AnyObject) {
        let destVC = ProfileVC()
        if byUser.username == PFUser.currentUser()!.username {
            destVC.user = toUser
        } else {
            destVC.user = byUser
        }
        
        destVC.addBackButton()
        activityVC.navigationController!.navigationBarHidden = true
        activityVC.navigationController?.pushViewController(destVC, animated: true)
    }
}


