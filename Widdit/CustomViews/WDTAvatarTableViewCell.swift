//
//  WDTAvatarTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ALCameraViewController
import Parse

class WDTAvatarTableViewCell: UITableViewCell {

    var m_parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for tag in 100...102 {
            let imgAvatar = viewWithTag(tag) as! UIImageView
            let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar))
            imgAvatar.addGestureRecognizer(tap)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for tag in 100...102 {
            let imgAvatar = viewWithTag(tag) as! UIImageView
            imgAvatar.layer.cornerRadius = imgAvatar.frame.width * 0.5
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(_ parentVC: UIViewController) {
        m_parentVC = parentVC
        
        if let objUser = PFUser.current() {
            if let ava = objUser["ava"] as? PFFile {
                let imgAvatar = viewWithTag(100) as! UIImageView
                imgAvatar.kf.setImage(with: URL(string: ava.url!))
                
                let btnDelete = viewWithTag(200) as! UIButton
                btnDelete.isHidden = false
            }
            
            if let ava = objUser["ava2"] as? PFFile {
                let imgAvatar = viewWithTag(101) as! UIImageView
                imgAvatar.kf.setImage(with: URL(string: ava.url!))
                
                let btnDelete = viewWithTag(201) as! UIButton
                btnDelete.isHidden = false
            }
            
            if let ava = objUser["ava3"] as? PFFile {
                let imgAvatar = viewWithTag(102) as! UIImageView
                imgAvatar.kf.setImage(with: URL(string: ava.url!))
                
                let btnDelete = viewWithTag(202) as! UIButton
                btnDelete.isHidden = false
            }
        }
    }
    
    @IBAction func onClickBtnDelete(_ sender: Any) {
        let btnDelete = sender as! UIButton
        btnDelete.isHidden = true
        
        let index = btnDelete.tag - 200
        
        let imgAvatar = viewWithTag(100 + index) as! UIImageView
        imgAvatar.image = UIImage(named: "profile_icon_avatar_placeholder")
        
        if let objUser = PFUser.current() {
            objUser.remove(forKey: "ava" + (index == 0 ? "" : String(index + 1)))
            objUser.saveInBackground()
        }
    }
    
    @objc private func onTapAvatar(_ sender: Any) {
        let gesture = sender as! UITapGestureRecognizer
        let imgAvatar = gesture.view as! UIImageView
        
        let cameraVC = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { (image, asset) in
            if let image = image {
                imgAvatar.image = image
                let index = imgAvatar.tag - 100
                if let objUser = PFUser.current() {
                    let dataAvatar = UIImageJPEGRepresentation(image.resizeImage(CGFloat(Constants.Integer.AVATAR_SIZE)), 0.5)
                    let fileAvatar = PFFile(name: "ava.jpg", data: dataAvatar!)
                    objUser["ava" + (index == 0 ? "" : String(index + 1))] = fileAvatar
                    objUser.saveInBackground()
                }
                
                let btnDelete = self.viewWithTag(200 + index) as! UIButton
                btnDelete.isHidden = false
            }
            
            self.m_parentVC?.dismiss(animated: true, completion: nil)
        }
        
        m_parentVC?.present(cameraVC, animated: true, completion: nil)
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
