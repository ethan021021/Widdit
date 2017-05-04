//
//  LinkPreviewView.swift
//  Widdit
//
//  Created by Ilya Kharabet on 04.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit


final class LinkPreviewView: JHView {
    
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    @IBOutlet weak var linkSiteLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }
    
}
