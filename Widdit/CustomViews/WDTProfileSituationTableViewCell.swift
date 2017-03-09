//
//  WDTProfileSituationTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTProfileSituationTableViewCell: UITableViewCell {

    @IBOutlet weak var m_txtTitle: UILabel!
    
    var parseKey = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onChangedSwitch(_ sender: Any) {
        let swtSituation = sender as! UISwitch
        
        let user = PFUser.current()
        user?[parseKey] = swtSituation.isOn
        user?.saveInBackground()
    }
    
}
