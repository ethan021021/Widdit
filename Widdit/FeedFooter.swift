//
//  FeedFooter.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 21.06.16.
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
            shadowLayer!.fillColor = UIColor.WDTGrayBlueColor().CGColor
            
            shadowLayer!.shadowColor = UIColor.darkGrayColor().CGColor
            shadowLayer!.shadowPath = shadowLayer!.path
            shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer!.shadowOpacity = 0.5
            shadowLayer!.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer!, atIndex: 0)
        }
        
        
        
    }
}

class FeedFooter: UITableViewHeaderFooterView {


    var replyBtn: UIButton = UIButton(type: .Custom)
    var imDownBtn: UIButton = UIButton(type: .Custom)
    var cardView: WDTFooterCardView = WDTFooterCardView()
    var feed: WDTFeed!
    var post: PFObject!
    var user: PFUser!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        contentView.addSubview(cardView)
        cardView.addSubview(imDownBtn)
        cardView.addSubview(replyBtn)
        cardSetup()
        

        replyBtn.backgroundColor = UIColor.WDTGrayBlueColor()
        replyBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        replyBtn.setTitle("Reply", forState: .Normal)
        replyBtn.titleLabel?.font = UIFont.WDTAgoraRegular(14)
        replyBtn.addTarget(self, action: #selector(replyBtnTapped), forControlEvents: .TouchUpInside)
        
        imDownBtn.backgroundColor = UIColor.WDTGrayBlueColor()
        imDownBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        imDownBtn.titleLabel?.font = UIFont.WDTAgoraRegular(14)
        imDownBtn.setTitleColor(UIColor.WDTBlueColor(), forState: .Selected)
        imDownBtn.setTitle("I'm Down", forState: .Normal)
        imDownBtn.addTarget(self, action: #selector(downBtnTapped), forControlEvents: .TouchUpInside)
        
        replyBtn.snp_remakeConstraints { (make) in
            make.top.equalTo(cardView).offset(10)
            make.left.equalTo(cardView).offset(10)
            make.right.equalTo(cardView.snp_centerX)
            make.bottom.equalTo(cardView)
        }
        
        imDownBtn.snp_remakeConstraints { (make) in
            make.top.equalTo(cardView).offset(10)
            make.left.equalTo(cardView.snp_centerX)
            make.right.equalTo(cardView).offset(-10)
            make.bottom.equalTo(cardView)
            
        }
        
    }
    
    func setDown(user: PFUser, post: PFObject) {
        self.user = user
        self.post = post
        WDTActivity.isDown(user, post: post) { (down) in
            if let down = down {
                let type = down["type"] as! String
                if type == WDTActivity.WDTActivityType.Down.rawValue {
                    self.imDownBtn.selected = true
                } else {
                    self.imDownBtn.selected = false
                }
            } else {
                self.imDownBtn.selected = false
            }
        }
    }
    
    func cardSetup() {
        cardView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(10)
            make.right.equalTo(self.contentView).offset(-10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        
        cardView.backgroundColor = UIColor.clearColor()
    }
    
    
    func downBtnTapped(sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        
        if button.selected == true {
            print("UnDown")
            button.selected = false
            WDTActivity.deleteActivity(user, post: post)
        } else {
            print("Downed")
            button.selected = true
            WDTActivity.addActivity(user, post: post, type: .Down, completion: { _ in })
        }
    }
    
    func replyBtnTapped(sender: AnyObject) {
        let destVC = ReplyViewController()
        destVC.toUser = user
        destVC.usersPost = post
        destVC.comeFromTheFeed = true
        feed!.navigationController!.pushViewController(destVC, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
