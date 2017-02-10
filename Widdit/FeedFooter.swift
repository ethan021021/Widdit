//
//  FeedFooter.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 21.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse

class WDTFooterCardView: UIView {
    
    var shadowLayer:CAShapeLayer? = nil
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        
        if self.shadowLayer == nil {
            let maskPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: [.BottomLeft, .BottomRight],
                                        cornerRadii: CGSize(width: 4.0, height: 4.0))
            
            shadowLayer = CAShapeLayer()
            shadowLayer!.path = maskPath.CGPath
            shadowLayer!.fillColor = UIColor.whiteColor().CGColor
            
            shadowLayer!.shadowColor = UIColor.darkGrayColor().CGColor
            shadowLayer!.shadowPath = shadowLayer!.path
            shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer!.shadowOpacity = 0.5
            shadowLayer!.shadowRadius = 2
            shadowLayer!.shouldRasterize = true
            shadowLayer!.rasterizationScale = UIScreen.mainScreen().scale;
            layer.insertSublayer(shadowLayer!, atIndex: 0)
        }
        
        
        func fillColor(color: UIColor) {
            shadowLayer!.fillColor = color.CGColor
        }
        
    }
}

class FeedFooter: UITableViewHeaderFooterView {


    var replyBtn: UIButton = UIButton(type: .Custom)
    var imDownBtn: UIButton = UIButton(type: .Custom)
//    var cardView: WDTFooterCardView = WDTFooterCardView()
    var cardView: UIView = UIView()
    var vc: UIViewController!
    var tableView: UITableView!
    var post: PFObject!
    var user: PFUser!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        contentView.addSubview(cardView)
        cardView.addSubview(imDownBtn)
        cardView.addSubview(replyBtn)
        cardSetup()
        

        replyBtn.backgroundColor = UIColor.whiteColor()
        replyBtn.setImage(UIImage(named: "ic_reply"), forState: .Normal)
        replyBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        replyBtn.setTitle("Reply", forState: .Normal)
        replyBtn.titleLabel?.font = UIFont.WDTAgoraRegular(14)
        replyBtn.addTarget(self, action: #selector(replyBtnTapped), forControlEvents: .TouchUpInside)
        
        replyBtn.layer.cornerRadius = 4
        replyBtn.clipsToBounds = true
        replyBtn.layer.shouldRasterize = true
        replyBtn.layer.rasterizationScale = UIScreen.mainScreen().scale;
        
        imDownBtn.backgroundColor = UIColor.whiteColor()
        imDownBtn.setImage(UIImage(named: "ic_down"), forState: .Normal)
        imDownBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        imDownBtn.titleLabel?.font = UIFont.WDTAgoraRegular(14)
//        imDownBtn.setTitleColor(UIColor.WDTBlueColor(), forState: .Selected)
        imDownBtn.setTitle("I'm down", forState: .Normal)
        imDownBtn.addTarget(self, action: #selector(downBtnTapped), forControlEvents: .TouchUpInside)
        imDownBtn.layer.cornerRadius = 4
        imDownBtn.clipsToBounds = true
        imDownBtn.layer.shouldRasterize = true
        imDownBtn.layer.rasterizationScale = UIScreen.mainScreen().scale;
        
        
        replyBtn.snp_remakeConstraints { (make) in
            make.top.equalTo(cardView)
            make.left.equalTo(cardView)
            make.right.equalTo(cardView.snp_centerX)
            make.bottom.equalTo(cardView)
        }
        
        imDownBtn.snp_remakeConstraints { (make) in
            make.top.equalTo(cardView)
            make.left.equalTo(cardView.snp_centerX)
            make.right.equalTo(cardView)
            make.bottom.equalTo(cardView)
            
        }
        
        let horLine = UIView()
        horLine.backgroundColor = UIColor(r: 216, g: 216, b: 216, a: 1)
        addSubview(horLine)
        horLine.snp_makeConstraints { (make) in
            make.left.equalTo(cardView)
            make.right.equalTo(cardView)
            make.top.equalTo(cardView)
            make.height.equalTo(0.3.x2)
        }
        
        let vertLine = UIView()
        vertLine.backgroundColor = UIColor(r: 216, g: 216, b: 216, a: 1)
        addSubview(vertLine)
        vertLine.snp_makeConstraints { (make) in
            make.width.equalTo(0.3.x2)
            make.height.equalTo(imDownBtn)
            make.centerX.equalTo(self)
        }
    }
    
    func isCurrentUser() -> Bool {
        if PFUser.currentUser()?.username == user.username {
            replyBtn.enabled = false
            imDownBtn.enabled = false
            imDownBtn.titleLabel!.alpha = 0.5
            replyBtn.titleLabel!.alpha = 0.5
            return true
        } else {
            replyBtn.enabled = true
            imDownBtn.enabled = true
            imDownBtn.titleLabel!.alpha = 1
            replyBtn.titleLabel!.alpha = 1
            return false
        }
    }
    
    func setDown(user: PFUser, post: PFObject) {
        user.fetchIfNeededInBackgroundWithBlock { (_, _) in
            self.user = user
            self.post = post
            if self.isCurrentUser() == false {
                if sharedActivity.myDowns.filter({ (down) -> Bool in
                    let localPost = down["post"] as! PFObject
                    return localPost.objectId == post.objectId
                }).count == 0 {
                    self.imDownBtn.selected = false
                    self.imDownBtn.backgroundColor = UIColor.whiteColor()
                } else {
                    self.imDownBtn.selected = true
                    self.imDownBtn.backgroundColor = UIColor.wddLightTeal24
                }
            } else {
                self.imDownBtn.selected = false
                self.imDownBtn.backgroundColor = UIColor.whiteColor()
            }
    
        }
    }
    
    func cardSetup() {
        cardView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(6.x2)
            make.right.equalTo(self.contentView).offset(-6.x2)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        cardView.backgroundColor = UIColor.clearColor()
    }
    
    
    func downBtnTapped(sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        
        if button.selected == true {
            button.selected = false
            self.imDownBtn.backgroundColor = UIColor.whiteColor()
            WDTActivity.deleteActivity(user, post: post)
        } else {
            button.selected = true
            self.imDownBtn.backgroundColor = UIColor.wddLightTeal24
            WDTActivity.addActivity(user, post: post, type: .Down, completion: { _ in })
        }
    }
    
    func replyBtnTapped(sender: AnyObject) {
        
        let chatItemsDecorator = WDTChatItemsDecorator()
        let demoDataSource = WDTChatDataSource()

        vc.showHud()
        WDTChatItemFactory.createChatItemsTG(user, usersPost: post) { (messages) in
            self.vc.hideHud()
            demoDataSource.chatItems = messages
            
            let chatVC = ReplyViewController()
            chatVC.toUser = self.user
            chatVC.usersPost = self.post
            chatVC.comeFromTheFeed = true
            chatVC.chatItemsDecorator = chatItemsDecorator
            chatVC.chatDataSource = demoDataSource
            chatVC.hidesBottomBarWhenPushed = true
            chatVC.fetchUsernameAndAvatar()
            self.vc.customPresentViewController(presenter, viewController: chatVC, animated: true, completion: {
                chatVC.inputController.growTextView.becomeFirstResponder()
            })
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
