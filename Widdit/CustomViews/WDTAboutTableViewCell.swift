//
//  WDTAboutTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ActiveLabel

class WDTAboutTableViewCell: UITableViewCell {

    @IBOutlet weak var m_lblAbout: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        m_lblAbout.enabledTypes = [.url]
        m_lblAbout.hashtagColor = UIColor.WDTTealColor()
        m_lblAbout.handleURLTap { (url) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
