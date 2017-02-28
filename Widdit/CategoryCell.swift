//
//  CategoryCell.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 03.01.17.
//  Copyright © 2017 John McCants. All rights reserved.
//

import UIKit
import Parse
import DGActivityIndicatorView
class CategoryCell: UITableViewCell {

    var categoryTitleLbl: UILabel = UILabel()
    var numOfPostsLbl: UILabel = UILabel()
    var activityIndicator: DGActivityIndicatorView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureSubviews() {
        contentView.addSubview(categoryTitleLbl)
        contentView.addSubview(numOfPostsLbl)
        
        
        categoryTitleLbl.font = UIFont.WDTAgoraMedium(18)
        categoryTitleLbl.textColor = UIColor.blackColor()
        categoryTitleLbl.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(contentView).offset(6.x2)
            make.centerY.equalTo(contentView)
        })
        
        
        numOfPostsLbl.font = UIFont.WDTAgoraMedium(14)
        numOfPostsLbl.textColor = UIColor.blackColor()
        numOfPostsLbl.snp_remakeConstraints(closure: { (make) in
            make.right.equalTo(contentView).offset(-6.x2)
            make.centerY.equalTo(contentView)
        })
        
        activityIndicator = DGActivityIndicatorView(type: .BallScale, tintColor: UIColor.WDTTeal())
        activityIndicator.frame = CGRectMake(contentView.frame.width - 30, contentView.frame.height / 2 - 10, 20, 20)
        activityIndicator.size = 15
        contentView.addSubview(activityIndicator)
//        activityIndicator.tintColor = UIColor.wddTealColor()
//        activityIndicator.snp_makeConstraints { (make) in
//            make.right.equalTo(contentView).offset(-6.x2)
//            make.centerY.equalTo(contentView)
//            make.height.equalTo(20)
//            make.width.equalTo(20)
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fillCell(category: String, selectingCategoryForNewPost: Bool) {
        categoryTitleLbl.text = "#" + category
        numOfPostsLbl.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        
        
        if selectingCategoryForNewPost == false {
            let countCategoryQuery = PFQuery(className: "posts")
            
            countCategoryQuery.whereKey("hashtags", containedIn: [category])
//            countCategoryQuery.cachePolicy = .CacheThenNetwork
            countCategoryQuery.countObjectsInBackgroundWithBlock { (num, err) in
                self.numOfPostsLbl.text = "+" + String(num)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.numOfPostsLbl.hidden = false
                
                if num == 0 {
                    self.numOfPostsLbl.textColor = UIColor.lightGrayColor()
                    self.categoryTitleLbl.textColor = UIColor.lightGrayColor()
                    let categoryQuery = PFQuery(className: "categories")
                    categoryQuery.whereKey("title", equalTo: category)
                    categoryQuery.getFirstObjectInBackgroundWithBlock({ (obj, err) in
                        if let obj = obj {
                            obj.deleteInBackground()
                        }
                    })
                } else {
                    self.numOfPostsLbl.textColor = UIColor.blackColor()
                    self.categoryTitleLbl.textColor = UIColor.blackColor()
                }
            }
        }
    }
}
