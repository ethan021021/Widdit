//
//  FeedCategoryCell.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 03.01.17.
//  Copyright © 2017 John McCants. All rights reserved.
//

import UIKit



import Parse
import SimpleAlert

class FeedCategoryCell: UITableViewCell {
    
    var categoryTitleLbl: UILabel = UILabel()
    var cardView: UIView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
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
        let placeholderView = UIView()
        cardView.addSubview(placeholderView)
        placeholderView.snp_makeConstraints { (make) in
            make.left.equalTo(cardView).offset(6.x2)
            make.right.equalTo(cardView).offset(6.x2)
            make.height.equalTo(60)
            make.top.equalTo(cardView)
            make.bottom.equalTo(cardView)
        }

        
        cardView.addSubview(categoryTitleLbl)
        categoryTitleLbl.font = UIFont.WDTAgoraMedium(16)
        categoryTitleLbl.backgroundColor = UIColor.whiteColor()
        categoryTitleLbl.textColor = UIColor.blackColor()
        categoryTitleLbl.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(cardView).offset(6.x2)
            make.right.equalTo(cardView).offset(-6.x2)
            make.centerY.equalTo(cardView)
            
        })
        
        cardView.snp_makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(5.x2)
            make.right.equalTo(self).offset(-5.x2)
            make.bottom.equalTo(contentView).offset(-10).priority(751)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fillCell(selectedCategory: String?) {
        if let selectedCategory = selectedCategory {
            categoryTitleLbl.text = "#" + selectedCategory
        } else {
            categoryTitleLbl.text = "#Categories"
        }
    }
}
