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

class WDTCellCardView: UIView {
    
    var shadowLayer:WDTCAShapeLayer? = nil
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        
        if self.shadowLayer == nil {
            let maskPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: [.TopLeft, .TopRight],
                                        cornerRadii: CGSize(width: 8.0, height: 8.0))
            
            self.shadowLayer = WDTCAShapeLayer()
            self.shadowLayer!.tag = 1
            self.shadowLayer!.path = maskPath.CGPath
            self.shadowLayer!.shouldRasterize = true
            self.shadowLayer!.rasterizationScale = UIScreen.mainScreen().scale;
            self.shadowLayer!.fillColor = UIColor.whiteColor().CGColor
//            self.shadowLayer!.shadowColor = UIColor.darkGrayColor().CGColor
//            self.shadowLayer!.shadowPath = self.shadowLayer!.path
//            self.shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 2.0)
//            self.shadowLayer!.shadowOpacity = 0.5
//            self.shadowLayer!.shadowRadius = 2
            
            layer.insertSublayer(self.shadowLayer!, atIndex: 0)
        }
    }

}

import Kingfisher
import AFImageHelper
import ActiveLabel
class PostCell: UITableViewCell {
    
    var avaImage: UIImageView = UIImageView()
    var postPhoto: UIImageView = UIImageView()
    
    var postText: ActiveLabel = ActiveLabel()
    var moreBtn: UIButton = UIButton(type: .Custom)
    var timeLbl: UILabel = UILabel()
    var userNameLbl: UILabel = UILabel()
    var settings: UIButton = UIButton()
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
    var newPostDelegate: NewPostVCDelegate!
    
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
        
        cardView.layer.cornerRadius = 4
        cardView.clipsToBounds = true
        cardView.layer.shouldRasterize = true
        cardView.layer.rasterizationScale = UIScreen.mainScreen().scale;
        
        self.contentView.addSubview(cardView)

        cardView.addSubview(avaImage)
        cardView.addSubview(postPhoto)
        cardView.addSubview(postText)
        cardView.addSubview(timeLbl)
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
        postText.numberOfLines = 0
        postText.backgroundColor = UIColor.whiteColor()
        postText.textColor = UIColor.blackColor()
        postText.userInteractionEnabled = true;
        postText.font = UIFont.systemFontOfSize(14)
        postText.enabledTypes = [.Hashtag, .URL]
        postText.hashtagColor = UIColor.wddTealColor()
        postText.handleHashtagTap { (hashtag) in
            
            let feedVC = FeedVC(style: .Grouped)
            feedVC.selectedCategory(hashtag)
            self.vc.navigationController?.pushViewController(feedVC, animated: true)
        }
        
        postText.handleURLTap { (url) in
            
            let webVC = WebViewController()
            webVC.makeRequest(url)
            let nc = UINavigationController(rootViewController: webVC)
            self.vc.presentViewController(nc, animated: true, completion: nil)
            
        }
        

        avaImage.layer.shouldRasterize = true
        avaImage.layer.cornerRadius = 8.0
        avaImage.clipsToBounds = true
        avaImage.layer.rasterizationScale = UIScreen.mainScreen().scale;
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(avaImageTapped(_:)))
        avaImage.userInteractionEnabled = true
        avaImage.addGestureRecognizer(tapGestureRecognizer)
        
        userNameLbl.font = UIFont.WDTAgoraMedium(14)
        userNameLbl.textColor = UIColor.blackColor()
        
        
        
        
        moreBtn.setBackgroundImage(UIImage(named: "ic_rectangle"), forState: .Normal)
        moreBtn.titleLabel?.font = UIFont.wddSmallgreenFont()
        moreBtn.setTitleColor(UIColor.wddGreenColor(), forState: .Normal)
        moreBtn.setTitle("More posts...", forState: .Normal)
        
        
        cardView.addSubview(bottomView)

        
        timeLbl.textColor = UIColor.grayColor()
        timeLbl.font = UIFont.WDTAgoraRegular(12)
        
        distanceLbl.textColor = UIColor.grayColor()
        distanceLbl.font = UIFont.WDTAgoraRegular(12)
        
        
    
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
        
        /*

        */
    }
    
    
    
    func settingsButtonTapped() {
        let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)

        if user.username == PFUser.currentUser()?.username {
            alert.addAction(SimpleAlert.Action(title: "Edit", style: .Default) { action in
                
                let newPostVC = NewPostVC()
                newPostVC.delegate = self.newPostDelegate
                
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
                let reportAlert = SimpleAlert.Controller(title: "Success", message: "Post reported. We’ll take a look at it. Thanks!", style: .Alert)
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
            make.top.equalTo(avaImage.snp_bottom).offset(10)
            if let _ = self.postPhoto.image {
                make.bottom.equalTo(self.postPhoto.snp_top).offset(-20)
            } else {
                if moreBtn.hidden == true {
                    make.bottom.equalTo(cardView).offset(-28)
                } else {
                    let offset = UIScreen.mainScreen().bounds.width * 0.11
                    make.bottom.equalTo(-offset)
                }
            }

            make.left.equalTo(cardView).offset(6.x2)
            make.right.equalTo(cardView).offset(-6.x2)
            
        })

        postPhoto.snp_remakeConstraints(closure: { (make) in
            make.top.equalTo(postText.snp_bottom).offset(18)
            make.left.equalTo(cardView).offset(6.x2)
            make.right.equalTo(cardView).offset(-6.x2)
            make.height.equalTo(postPhoto.snp_width)
            
            
            if moreBtn.hidden == true {
                make.bottom.equalTo(-10)
            } else {
                let offset = UIScreen.mainScreen().bounds.width * 0.11
                make.bottom.equalTo(-offset)
            }
            
            
        })
        /*
        
            bottomView.snp_remakeConstraints { (make) in
                if let _ = postPhoto.image {
                    make.top.equalTo(postPhoto.snp_bottom)
                } else {
                    make.top.equalTo(postText.snp_bottom)
                }
                
                make.left.equalTo(cardView)
                make.right.equalTo(cardView)
                
                if moreBtn.hidden == true {
                    make.bottom.equalTo(cardView).offset(-2)
                } else {
                    let offset = self.frame.width * 0.12
                    make.bottom.equalTo(cardView).offset(-offset)
                }
                
            }
        */
        
        moreBtn.snp_remakeConstraints { (make) in
            
            make.width.equalTo(self.snp_width).multipliedBy(0.14)
            make.height.equalTo(moreBtn.snp_width).multipliedBy(0.56)
            make.right.equalTo(cardView).offset(-6.x2)
            make.bottom.equalTo(cardView).offset(-5)
            
        }
        
        
        super.updateConstraints()
    }

    let placeholderImage = UIImage(color: UIColor.WDTGrayBlueColor(), size: CGSizeMake(CGFloat(320), CGFloat(320)))
    var worldSelected: Bool = true
    func fillCell(post: PFObject) {
        
        let user = post["user"] as! PFUser
        user.fetchIfNeededInBackgroundWithBlock({ (_, _) in
            
            let username = user.username
            self.userNameLbl.text = username
            self.post = post
            self.user = user
            
            self.postText.text = post["postText"] as! String
            self.userNameLbl.hidden = false
            
            
            // Place Profile Picture
            if let avaFile = user["ava"] as? PFFile {
                self.avaImage.kf_setImageWithURL(NSURL(string: avaFile.url!)!)
            } else {
                self.avaImage.image = UIImage(named: "ic_blank_placeholder_square")
            }
            
            
            if let photoFile = post["photoFile"] as? PFFile  {
                
                self.postPhoto.kf_setImageWithURL(NSURL(string: photoFile.url!)!, placeholderImage: self.placeholderImage, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                })
            } else {
                self.postPhoto.image = nil
            }
            self.updateConstraints()
            
            let hoursexpired = post["hoursexpired"] as! NSDate
            let timeLeft = hoursexpired.timeIntervalSince1970 - NSDate().timeIntervalSince1970
            
            self.timeLbl.text = NSDateComponentsFormatter.wdtLeftTime(Int(timeLeft)) + " left"
            
            if let postGeoPoint = post["geoPoint"] as? PFGeoPoint {
                let distance = postGeoPoint.distanceInMilesTo(self.geoPoint)
                if distance >= 15 {
                    if self.worldSelected == true {
                        if let country = post["country"] as? String, let city = post["city"] as? String {
                            self.distanceLbl.text = country + ", " + city
                        }
                    } else {
                        if let city = post["city"] as? String {
                            self.distanceLbl.text = city
                        }
                    }
                    
                } else {
                    if let city = post["city"] as? String {
                        self.distanceLbl.text = city
                    }
                }
            } else {
                self.distanceLbl.text = ""
            }
        })
    }
    
    func avaImageTapped(sender: AnyObject) {
        let destVC = ProfileVC()
        destVC.user = user
        destVC.addBackButton()
        vc.navigationController!.navigationBarHidden = true
        vc.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @IBAction func morePostsButtonPressed(sender: UIButton) {

    }
    

}
