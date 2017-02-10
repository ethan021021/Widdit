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
import BetterSegmentedControl

class WDTHeader: UIView, UIScrollViewDelegate {

    var scrollView = UIScrollView()
    var containerView = UIView()
    let firstNameLbl = UILabel()
    
    var control: BetterSegmentedControl!

    
    
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
            make.height.equalTo(self.snp_width).offset(-15)
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
        
        
        control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 100.0, width: bounds.width, height: 44.0),
            titles: ["FEED", "ABOUT"],
            index: 1,
            backgroundColor: UIColor.whiteColor(),
            titleColor: UIColor(r: 177, g: 215, b: 215, a: 1),
            indicatorViewBackgroundColor: UIColor.clearColor(),
            selectedTitleColor: UIColor.wddGreenColor())
        
        addSubview(control)
        control.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(scrollView.snp_bottom)
            make.right.equalTo(self)
            make.height.equalTo(50)
        }

        
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
        
        if files.count == 0 {
            for v in containerView.subviews {
                v.removeFromSuperview()
            }

            let imageView: UIImageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = UIColor.whiteColor()
            imageView.clipsToBounds = true
            imageView.contentMode = .ScaleAspectFill
            imageView.image = UIImage(named: "ic_blank_placeholder")
            containerView.addSubview(imageView)
            imageView.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(containerView)
                make.top.equalTo(self).offset(-5)
                make.height.equalTo(imageView.snp_width).offset(10)
                make.width.equalTo(self)
            })
            
        }
    }
    
    func setName(name: String?) {
        if let name = name {
            firstNameLbl.text = name
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.tag == 1 {
        
            let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
            pageControl.currentPage = Int(currentPage)
        } else {
        
            
            print(scrollView.contentOffset.y)
            if scrollView.contentOffset.y < 0 {
                let offset = scrollView.contentOffset.y //+ 20
                var headerTransform = CATransform3DIdentity
                let headerScaleFactor: CGFloat = -(offset) / 320
                let headerSizevariation: CGFloat = ((320 * (1.0 + headerScaleFactor)) - 320)/2.0
                headerTransform = CATransform3DTranslate(headerTransform, 0, -headerSizevariation, 0)
                
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                self.scrollView.layer.transform = headerTransform
                
            } else {
                var headerTransform = CATransform3DIdentity
                headerTransform = CATransform3DTranslate(headerTransform, 0, 0, 0)
//                let headerScaleFactor: CGFloat = -(offset) / 320
//                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                self.scrollView.layer.transform = headerTransform
            }
        }
    }
}
