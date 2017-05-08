//
//  WDTPhotoCell.swift
//  Widdit
//
//  Created by Ilya Kharabet on 07.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit


final class WDTPhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isPlaceholder = false {
        didSet {
            deleteButton.isHidden = isPlaceholder
        }
    }
    
    var onDelete: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
    
    
    @IBAction func delete() {
        onDelete?()
    }

}
