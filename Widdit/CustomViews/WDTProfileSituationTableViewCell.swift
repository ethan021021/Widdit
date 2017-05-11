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
    @IBOutlet weak var m_swtStatus: UISwitch!
    
    var m_situationType: WDTPersonalSituation?
    
    enum WDTPersonalSituation: Int {
        case School
        case Job
        case Open
        
        func getDescription() -> (String, Bool) {
            let objUser = PFUser.current()!
            
            switch self {
            case .School:
                return ("Currently in school", objUser["situationSchool"] as? Bool ?? false)
            case .Job:
                return ("Have a job", objUser["situationWork"] as? Bool ?? false)
            case .Open:
                return ("Open to new things", objUser["situationOpportunity"] as? Bool ?? false)
            }
        }
        
        func setDescription(_ value: Bool) {
            let objUser = PFUser.current()!
            
            switch self {
            case .School:
                objUser["situationSchool"] = value
                break
            case .Job:
                objUser["situationWork"] = value
                break;
            case .Open:
                objUser["situationOpportunity"] = value
                break;
            }
            
            objUser.saveInBackground()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(_ type: WDTPersonalSituation) {
        m_situationType = type
        
        let (title, value) = type.getDescription()
        m_txtTitle.text = title
        m_swtStatus.isOn = value
    }
    
    @IBAction func onChangedSwitch(_ sender: Any) {
        let swtSituation = sender as! UISwitch
        
        m_situationType?.setDescription(swtSituation.isOn)
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor(r: 249, g: 249, b: 249, a: 1).cgColor)
            context.setLineWidth(2)
            
            context.move(to: CGPoint(x: 0, y: 1))
            context.addLine(to: CGPoint(x: rect.width, y: 1))
            context.strokePath()
            
            context.move(to: CGPoint(x: 0, y: rect.height - 1))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height - 1))
            context.strokePath()
        }
    }
    
}
