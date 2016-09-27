//
//  PostCell.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import SimpleAlert

class WDTCAShapeLayer: CAShapeLayer {
    var tag: Int?
}

//class WDTCellCardView: UIView {
//    
//    var shadowLayer:WDTCAShapeLayer? = nil
//    
//    override func layoutSubviews()
//    {
//        super.layoutSubviews()
//        
//        
//        if self.shadowLayer == nil {
//            let maskPath = UIBezierPath(roundedRect: bounds,
//                                        byRoundingCorners: [.TopLeft, .TopRight, .BottomLeft, .BottomRight],
//                                        cornerRadii: CGSize(width: 4.0, height: 4.0))
//            
//            self.shadowLayer = WDTCAShapeLayer()
//            self.shadowLayer!.tag = 1
//            self.shadowLayer!.path = maskPath.CGPath
//            self.shadowLayer!.fillColor = UIColor.whiteColor().CGColor
//            
//            self.shadowLayer!.shadowColor = UIColor.darkGrayColor().CGColor
//            self.shadowLayer!.shadowPath = self.shadowLayer!.path
//            self.shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 2.0)
//            self.shadowLayer!.shadowOpacity = 0.5
//            self.shadowLayer!.shadowRadius = 2
//            
//            layer.insertSublayer(self.shadowLayer!, atIndex: 0)
//        }
//    }
//    
//    func updateLayer() {
//        layer.sublayers?.forEach {
//            if let layer = $0 as? WDTCAShapeLayer {
//                if layer.tag == 1 {
//                    layer.removeFromSuperlayer()
//                    self.shadowLayer = nil
//                }
//            }
//        }
//    }
//}

import Kingfisher
import AFImageHelper

class PostCell: UITableViewCell {
    
    var avaImage: UIImageView = UIImageView()
    var postPhoto: UIImageView = UIImageView()
    
    var postText: UITextView = UITextView()
    var moreBtn: UIButton = UIButton(type: .Custom)
    var timeLbl: UILabel = UILabel()
//    var firstNameLbl: UILabel = UILabel()
    var userNameLbl: UILabel = UILabel()
    var settings: UIButton = UIButton()
//    var cardView: WDTCellCardView = WDTCellCardView()
    var cardView: UIView = UIView()
    var morePostsButton: UIButton = UIButton(type: .Custom)
    var distanceLbl: UILabel = UILabel()
    
    var vertLineView = UIView()
    var geoPoint: PFGeoPoint?
    
    var user: PFUser!
    var post: PFObject!
    
    var vc: UIViewController!
    var wdtFeed: WDTLoad!
    var tableView: UITableView!
    let bottomView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureSubviews() {
        backgroundColor = UIColor.wddSilverColor()
        cardView.backgroundColor = UIColor.whiteColor()
        
        self.contentView.addSubview(cardView)

        cardView.addSubview(avaImage)
        cardView.addSubview(postPhoto)
        cardView.addSubview(postText)
        cardView.addSubview(timeLbl)
//        cardView.addSubview(firstNameLbl)
        cardView.addSubview(userNameLbl)
        cardView.addSubview(moreBtn)
        cardView.addSubview(settings)

        cardView.addSubview(vertLineView)
        cardView.addSubview(distanceLbl)
        
        
        settings.setImage(UIImage(named: "ic_more"), forState: .Normal)
        settings.addTarget(self, action: #selector(settingsButtonTapped), forControlEvents: .TouchUpInside)
        
        vertLineView.backgroundColor = UIColor.grayColor()
        vertLineView.alpha = 0.5
        
        
        postPhoto.contentMode = .ScaleAspectFit
//        postPhoto.layer.cornerRadius = 4
//        postPhoto.clipsToBounds = true
        
        postText.backgroundColor = UIColor.whiteColor()
        postText.textColor = UIColor.blackColor()
        postText.editable = false
        postText.scrollEnabled = false
        postText.userInteractionEnabled = true;
        postText.dataDetectorTypes = [.Link, .PhoneNumber]
        
        // Rounded Square Image
        avaImage.layer.cornerRadius = 8.0
        avaImage.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(avaImageTapped(_:)))
        avaImage.userInteractionEnabled = true
        avaImage.addGestureRecognizer(tapGestureRecognizer)
        
        userNameLbl.font = UIFont.WDTAgoraRegular(12)
        userNameLbl.textColor = UIColor.blackColor()
        
        moreBtn.setImage(UIImage(named: "ic_more_posts"), forState: .Normal)
        moreBtn.titleLabel?.font = UIFont.wddSmallgreenFont()
        moreBtn.setTitleColor(UIColor.wddGreenColor(), forState: .Normal)
        moreBtn.setTitle("More posts...", forState: .Normal)
        
        
        cardView.addSubview(bottomView)
        
        
        
//        firstNameLbl.textColor = UIColor.grayColor()
//        firstNameLbl.font = UIFont.WDTAgoraRegular(12)
        
        timeLbl.textColor = UIColor.grayColor()
        timeLbl.font = UIFont.WDTAgoraRegular(12)
        
        distanceLbl.textColor = UIColor.grayColor()
        distanceLbl.font = UIFont.WDTAgoraRegular(12)
        
    }
    
    func settingsButtonTapped() {
        //let alert = SimpleAlert.Controller(title: "", message: "", style: .ActionSheet)
        let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)
        
        
        
        
        if user.username == PFUser.currentUser()?.username {
            alert.addAction(SimpleAlert.Action(title: "Edit", style: .Default) { action in
                
                let newPostVC = NewPostVC()
                
                let nc = UINavigationController(rootViewController: newPostVC)
                
                self.vc.presentViewController(nc, animated: true, completion:  {
                    newPostVC.editMode(self.post, postPhoto: self.postPhoto.image)    
                })
            
            })
            
            alert.addAction(SimpleAlert.Action(title: "Delete", style: .Destructive) { action in
                WDTPost.deletePost(self.post, completion: { (success) in
                    self.wdtFeed.loadPosts()
                })
            })
            
        } else {
            alert.addAction(SimpleAlert.Action(title: "Report", style: .Default) { action in
                let reportAlert = SimpleAlert.Controller(title: "Report", message: "Successfully reported", style: .Alert)
                reportAlert.addAction(SimpleAlert.Action(title: "OK", style: .OK))
                self.vc.presentViewController(reportAlert, animated: true, completion: nil)
            })
        }
        

        
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        
        vc.presentViewController(alert, animated: true, completion: nil)
        

    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var isHeightCalculated: Bool = false
    
    override func updateConstraints() {
        

        postText.snp_remakeConstraints(closure: { (make) in
            if let _ = self.postPhoto.image {
                make.top.equalTo(postPhoto.snp_bottom).offset(10)
            } else {
                make.top.equalTo(avaImage.snp_bottom).offset(10)
            }
            make.left.equalTo(cardView).offset(6.x2)
            make.right.equalTo(cardView).offset(-6.x2)
            make.bottom.equalTo(cardView).offset(-30)
            
        })



//        if isHeightCalculated == false {
        
            postPhoto.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(cardView).offset(28.x2)
                make.left.equalTo(cardView).offset(6.x2)
                make.right.equalTo(cardView).offset(-6.x2)
                make.height.equalTo(postPhoto.snp_width)
            })


            cardView.snp_remakeConstraints { (make) in
                make.top.equalTo(contentView).offset(10)
                make.left.equalTo(contentView).offset(6.x2)
                make.right.equalTo(contentView).offset(-6.x2)
                make.bottom.equalTo(contentView).priority(751)
            }
            
            avaImage.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(cardView).offset(6.x2)
                make.left.equalTo(cardView).offset(6.x2)
                make.width.equalTo(16.x2)
                make.height.equalTo(16.x2)
            })
            
            userNameLbl.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(avaImage.snp_right).offset(6.x2)
                make.top.equalTo(cardView).offset(6.5.x2)
            })
            
            timeLbl.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(avaImage.snp_right).offset(6.x2)
                make.top.equalTo(userNameLbl.snp_bottom).offset(1.5.x2)
            })
        
//            firstNameLbl.snp_remakeConstraints(closure: { (make) in
//                make.left.equalTo(avaImage.snp_right).offset(7)
//                make.top.equalTo(userNameLbl.snp_bottom).offset(3)
//            })
            
            settings.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(cardView).offset(-6.x2)
                make.top.equalTo(cardView).offset(2.x2)
                make.width.equalTo(25)
                make.height.equalTo(25)
            })

            
        
            distanceLbl.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(cardView).offset(-6.x2)
                make.top.equalTo(settings.snp_bottom).offset(1.x2)
            })
        

            moreBtn.snp_remakeConstraints { (make) in
                make.top.equalTo(postText.snp_bottom).offset(5.5)
                make.left.equalTo(cardView).offset(6.x2)
                make.height.equalTo(12.x2)
            }

        

//        }
            isHeightCalculated = true
        
        
        
        super.updateConstraints()
    }

    
    
    func fillCell(post: PFObject) {
        let user = post["user"] as! PFUser
        
        let username = user.username
        userNameLbl.text = username
        self.post = post
        self.user = user
        
        postText.text = post["postText"] as! String
//        firstNameLbl.text = user["firstName"] as? String
        userNameLbl.hidden = false
        moreBtn.hidden = false
        
        // Place Profile Picture
        if let avaFile = user["ava"] as? PFFile {
            avaImage.kf_setImageWithURL(NSURL(string: avaFile.url!)!)
        }
        
        if let photoFile = post["photoFile"] as? PFFile  {
            
            let placeholderImage = UIImage(color: UIColor.WDTGrayBlueColor(), size: CGSizeMake(CGFloat(320), CGFloat(320)))
            postPhoto.kf_setImageWithURL(NSURL(string: photoFile.url!)!, placeholderImage: placeholderImage, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
            })
        } else {
            postPhoto.image = nil
        }
        self.updateConstraints()

        let hoursexpired = post["hoursexpired"] as! NSDate
        let timeLeft = hoursexpired.timeIntervalSince1970 - NSDate().timeIntervalSince1970
        
        timeLbl.text = NSDateComponentsFormatter.wdtLeftTime(Int(timeLeft)) + " left"
        
        if let postGeoPoint = post["geoPoint"] {
            let distance = postGeoPoint.distanceInMilesTo(geoPoint)
            if distance >= 25 {
                distanceLbl.text = String(format: "Greater than 25 miles ")
            } else {
                distanceLbl.text = String(format: "%.1f mi", distance)
            }
            
        } else {
            distanceLbl.text = ""
        }
    }
    
    func avaImageTapped(sender: AnyObject) {
        let destVC = ProfileVC()
        destVC.user = user
        vc.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @IBAction func morePostsButtonPressed(sender: UIButton) {

    }
    

}
