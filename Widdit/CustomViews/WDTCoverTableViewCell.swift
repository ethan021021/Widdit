//
//  WDTCoverTableViewCell.swift
//  Widdit
//
//  Created by Ilya Kharabet on 11.05.2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ALCameraViewController
import Parse

class WDTCoverTableViewCell: UITableViewCell {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var m_parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapCover))
        coverView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverView.layer.cornerRadius = 2
    }
    
    
    @IBAction func onClickBtnDelete(_ sender: Any) {
        let btnDelete = sender as! UIButton
        btnDelete.isHidden = true
        
        coverView.image = nil
        
        if let objUser = PFUser.current() {
            objUser.remove(forKey: "cover")
            objUser.saveInBackground()
        }
    }
    
    @objc private func onTapCover(_ sender: Any) {
        let cameraVC = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { (image, asset) in
            if let image = image {
                self.coverView.image = image
                if let objUser = PFUser.current() {
                    let dataAvatar = UIImageJPEGRepresentation(image.resizeImage(CGFloat(Constants.Integer.AVATAR_SIZE)), 0.5)
                    let fileAvatar = PFFile(name: "cover.jpg", data: dataAvatar!)
                    objUser["cover"] = fileAvatar
                    objUser.saveInBackground()
                }
                
                self.deleteButton.isHidden = false
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
