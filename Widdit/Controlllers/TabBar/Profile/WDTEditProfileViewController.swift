//
//  WDTEditProfileViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class WDTEditProfileViewController: UITableViewController {

    @IBOutlet weak var m_btnLinkFacebook: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_btnLinkFacebook.isSelected = PFFacebookUtils.isLinked(with: PFUser.current()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 3 {
            return 3
        } else if section == 0 {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = Bundle.main.loadNibNamed(String(describing: WDTAvatarTableViewCell.self), owner: nil, options: [:])?.first as! WDTAvatarTableViewCell
                cell.setView(self)
                
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed(String(describing: WDTCoverTableViewCell.self), owner: nil, options: [:])?.first as! WDTCoverTableViewCell
                
                cell.m_parentVC = self
                
                cell.deleteButton.isHidden = true
                
                if let objUser = PFUser.current() {
                    if let cover = objUser["cover"] as? PFFile {
                        if let path = cover.url {
                            cell.coverView.kf.setImage(with: URL(string: path))
                            cell.deleteButton.isHidden = false
                        }
                    }
                }
                
                return cell
            }
        } else  if indexPath.section == 1 {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileTextTableViewCell.self), owner: nil, options: [:])?.first as! WDTProfileTextTableViewCell
            
            if indexPath.row == 0 {
                cell.setView(.Username)
            } else if indexPath.row == 1 {
                cell.setView(.Name)
            } else {
                cell.setView(.Email)
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WDTProfileAboutTableViewCell", for: indexPath)
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileSituationTableViewCell.self), owner: nil, options: [:])?.first as! WDTProfileSituationTableViewCell
            
            if indexPath.row == 0 {
                cell.setView(.School)
            } else if indexPath.row == 1 {
                cell.setView(.Job)
            } else {
                cell.setView(.Open)
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 2
        } else {
            return 52
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 114
        } else {
            return 64
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 52))
        
        let lblTitle = UILabel()
        lblTitle.font = UIFont.WDTMedium(size: 14)
        lblTitle.textColor = UIColor(r: 71, g: 211, b: 214, a: 1)
        headerView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalTo(12)
        }
        
        if section == 0 {
            lblTitle.text = "PHOTOS"
        } else if section == 1{
            lblTitle.text = "PERSONAL DATA"
        } else if section == 3 {
            lblTitle.text = "SITUATION"
        } else {
            return nil
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let profileAboutVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileAboutViewController.self)) as! WDTProfileAboutViewController
            navigationController?.pushViewController(profileAboutVC, animated: true)
        }
    }

    @IBAction func onClickBtnDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnLinkFacebook(_ sender: Any) {
        let btnLinkFacebook = sender as! UIButton
        btnLinkFacebook.isSelected = !btnLinkFacebook.isSelected
        
        let objUser = PFUser.current()!
        
        if btnLinkFacebook.isSelected {
            PFFacebookUtils.linkUser(inBackground: objUser, withReadPermissions: nil, block: { (success, error) in
                if error == nil {
                    objUser["facebookVerified"] = true
                    objUser.saveInBackground()
                }
            })
        } else {
            PFFacebookUtils.unlinkUser(inBackground: objUser, block: { (success, error) in
                if error == nil {
                    objUser["facebookVerified"] = false
                    objUser.saveInBackground()
                }
            })
        }
    }
    
}
