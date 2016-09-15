//
//  WDTHeader.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 04.07.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import Kingfisher

class WDTHeader: UIView, UIScrollViewDelegate {

    var scrollView = UIScrollView()
    var containerView = UIView()
    let firstNameLbl = UILabel()
    
    let segmentedControl = UISegmentedControl()

    
    
    var pageControl: UIPageControl = UIPageControl()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = UIColor.clearColor()
        addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.whiteColor()
        scrollView.addSubview(containerView)
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.tag = 1
        scrollView.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.height.equalTo(self.snp_width)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        
        containerView.snp_makeConstraints { (make) in
            make.edges.equalTo(scrollView)
        }
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.6).CGColor as CGColorRef
        gradientLayer.colors = [color3, color4]
        gradientLayer.locations = [0.2, 1.0]
        self.layer.addSublayer(gradientLayer)


        
        addSubview(firstNameLbl)
        firstNameLbl.font = UIFont.wddHtwoinvertcenterFont()
        firstNameLbl.textColor = UIColor.whiteColor()
        firstNameLbl.snp_makeConstraints { (make) in
            make.centerX.equalTo(scrollView)
            make.bottom.equalTo(scrollView).offset(-13.5.x2)
        }
        
        addSubview(pageControl)
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.alpha = 1.0
        
        pageControl.snp_makeConstraints { (make) in
            make.centerX.equalTo(scrollView)
            make.bottom.equalTo(scrollView)
        }
        // Set the initial page.
        pageControl.currentPage = 0
        

        
        segmentedControl.tintColor = UIColor.wddGreenColor()
        
        segmentedControl.insertSegmentWithTitle("ABOUT", atIndex: 0, animated: true)
        segmentedControl.insertSegmentWithTitle("FEED", atIndex: 0, animated: true)
        
        addSubview(segmentedControl)
        segmentedControl.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(scrollView.snp_bottom)
            make.right.equalTo(self)
            make.height.equalTo(50)
        }
        
//        let verifiedLbl = UILabel()
//        addSubview(verifiedLbl)
//        verifiedLbl.font = UIFont.WDTAgoraRegular(16)
//        verifiedLbl.text = "VERIFIED"
//        verifiedLbl.snp_makeConstraints { (make) in
//            make.left.equalTo(self).offset(50)
//            make.top.equalTo(scrollView.snp_bottom).offset(20)
//        }
//        
        
//        var emailVerifiedImage = UIImage(named: "email")
       // emailVerifiedImage = (emailVerifiedImage!.imageWithRenderingMode(.AlwaysTemplate))
//        emailVerified.tintColor = UIColor.darkGrayColor()
//        emailVerified.setImage(emailVerifiedImage, forState: .Normal)
//        emailVerified.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        emailVerified.layer.cornerRadius = heightOfButton / 2
//        emailVerified.clipsToBounds = true
//        emailVerified.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//        
//        
//        addSubview(emailVerified)
//        emailVerified.snp_makeConstraints { (make) in
//            make.top.equalTo(verifiedLbl).offset(25)
//            make.centerX.equalTo(verifiedLbl).offset(-30)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        
//        var phoneVerifiedImage = UIImage(named: "cellphone")
//     //   phoneVerifiedImage = (phoneVerifiedImage!.imageWithRenderingMode(.AlwaysTemplate))
//        phoneVerified.tintColor = UIColor.darkGrayColor()
//        
//        phoneVerified.setImage(phoneVerifiedImage, forState: .Normal)
//        phoneVerified.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        phoneVerified.layer.cornerRadius = heightOfButton / 2
//        phoneVerified.clipsToBounds = true
//        phoneVerified.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//        
//        addSubview(phoneVerified)
//        phoneVerified.snp_makeConstraints { (make) in
//            make.top.equalTo(verifiedLbl).offset(25)
//            make.centerX.equalTo(verifiedLbl)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        
//        var facebookVerifiedImage = UIImage(named: "facebook")
//       // facebookVerifiedImage = (facebookVerifiedImage!.imageWithRenderingMode(.AlwaysTemplate))
//        facebookVerified.tintColor = UIColor.darkGrayColor()
//        
//        facebookVerified.setImage(facebookVerifiedImage, forState: .Normal)
//        facebookVerified.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        facebookVerified.layer.cornerRadius = heightOfButton / 2
//        facebookVerified.clipsToBounds = true
//        facebookVerified.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//        
//        addSubview(facebookVerified)
//        facebookVerified.snp_makeConstraints { (make) in
//            make.top.equalTo(verifiedLbl).offset(25)
//            make.centerX.equalTo(verifiedLbl).offset(30)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        let situationLbl = UILabel()
//        addSubview(situationLbl)
//        situationLbl.font = UIFont.WDTAgoraRegular(16)
//        situationLbl.text = "SITUATION"
//        situationLbl.snp_makeConstraints { (make) in
//            make.right.equalTo(self).offset(-50)
//            make.top.equalTo(scrollView.snp_bottom).offset(20)
//        }
//        
//
//        var schoolSituationImage = UIImage(named: "situation-school")
//       // schoolSituationImage = (schoolSituationImage!.imageWithRenderingMode(.AlwaysTemplate))
//        schoolSituation.tintColor = UIColor.darkGrayColor()
//        
//        schoolSituation.setImage(schoolSituationImage, forState: .Normal)
//        schoolSituation.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        schoolSituation.layer.cornerRadius = heightOfButton / 2
//        schoolSituation.clipsToBounds = true
//        schoolSituation.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//
//        
//        addSubview(schoolSituation)
//        schoolSituation.snp_makeConstraints { (make) in
//            make.top.equalTo(situationLbl).offset(25)
//            make.centerX.equalTo(situationLbl).offset(-30)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        var workingSituationImage = UIImage(named: "situation-working")
//       // workingSituationImage = (workingSituationImage!.imageWithRenderingMode(.AlwaysTemplate))
//        workingSituation.tintColor = UIColor.darkGrayColor()
//        
//        workingSituation.setImage(workingSituationImage, forState: .Normal)
//        workingSituation.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        workingSituation.layer.cornerRadius = heightOfButton / 2
//        workingSituation.clipsToBounds = true
//        workingSituation.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//        
//        addSubview(workingSituation)
//        workingSituation.snp_makeConstraints { (make) in
//            make.top.equalTo(situationLbl).offset(25)
//            make.centerX.equalTo(situationLbl)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        
//        var opportunitySituationImage = UIImage(named: "situation-opportunity")
//      //  opportunitySituationImage = (opportunitySituationImage!.imageWithRenderingMode(.AlwaysTemplate))
//        opportunitySituation.tintColor = UIColor.darkGrayColor()
//        
//        opportunitySituation.setImage(opportunitySituationImage, forState: .Normal)
//        opportunitySituation.setBackgroundColor(UIColor.WDTBlueColor(), forUIControlState: .Selected)
//        opportunitySituation.layer.cornerRadius = heightOfButton / 2
//        opportunitySituation.clipsToBounds = true
//        opportunitySituation.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
//    
//        
//        addSubview(opportunitySituation)
//        opportunitySituation.snp_makeConstraints { (make) in
//            make.top.equalTo(situationLbl).offset(25)
//            make.centerX.equalTo(situationLbl).offset(30)
//            make.height.equalTo(heightOfButton)
//            make.width.equalTo(heightOfButton)
//        }
//        
//        
//        line.backgroundColor = UIColor.blackColor()
//        line.alpha = 0.5
//        addSubview(line)
//        line.hidden = true
//        line.snp_makeConstraints { (make) in
//            make.left.equalTo(self)
//            make.right.equalTo(self)
//            make.top.equalTo(scrollView.snp_bottom).offset(85)
//            make.height.equalTo(1)
//        }
//
//        
//        
//        
//        aboutLbl.editable = false
//        aboutLbl.scrollEnabled = false
//        aboutLbl.userInteractionEnabled = true;
//        aboutLbl.dataDetectorTypes = [.Link, .PhoneNumber]
//        aboutLbl.textAlignment = .Center
//        aboutLbl.font = UIFont.WDTAgoraRegular(16)
//        aboutLbl.backgroundColor = UIColor.clearColor()
//        addSubview(aboutLbl)
//        aboutLbl.snp_makeConstraints { (make) in
//            make.left.equalTo(self).offset(10)
//            make.right.equalTo(self).offset(-10)
//            make.top.equalTo(line).offset(15)
//        }
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let placeholderImage = UIImage(color: UIColor.WDTGrayBlueColor(), size: CGSizeMake(CGFloat(320), CGFloat(320)))
    
    func setImages(files: [PFFile]) {
        pageControl.numberOfPages = files.count
        
        var lastView: UIImageView?
        
        for (index, file) in files.enumerate() {
            let imageView: UIImageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = UIColor.whiteColor()
            imageView.clipsToBounds = true
            imageView.contentMode = .ScaleAspectFill
            imageView.kf_setImageWithURL(NSURL(string: file.url!)!, placeholderImage: placeholderImage, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
            })
            
            
            if index == 0 {
                containerView.addSubview(imageView)
                
                imageView.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(containerView)
                    make.top.equalTo(self).offset(-5)
                    make.height.equalTo(imageView.snp_width).offset(10)
                    make.width.equalTo(self)
                })
            } else {
                if let lastView = lastView {
                    containerView.addSubview(imageView)
                    imageView.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(lastView.snp_right)
                        make.top.equalTo(self).offset(-5)
                        make.height.equalTo(imageView.snp_width).offset(10)
                        make.width.equalTo(self)
                        make.right.equalTo(containerView).priority(751 + index)
                        
                    })
                }
            }
            
            lastView = imageView
        }
    }
    
    func setName(name: String?) {
        if let name = name {
            firstNameLbl.text = name
        }
    }
    
    
    func setAbout(about: String?) {
//        if let about = about {
//            aboutLbl.text = about
//            line.hidden = false
//        }
    }
    
    func setVerified(email: Bool, facebook: Bool, phone: Bool) {
        
        if email == true {
            
        }
        
        if facebook == true {
            
        }
        
        if phone == true {
            
        }

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
            pageControl.currentPage = Int(currentPage)
        }
    }
}
