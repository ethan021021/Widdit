//
//  ActivityVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import StatefulViewController

class ActivityVC: UITableViewController, StatefulViewController {
    
    let activity = WDTActivity()
    var chatsAndDowns: [PFObject] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInitialViewState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Activity"
        
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.registerClass(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 60;
        
        let activityEmptyView = UIView(frame: view.frame)
        
        let emptyImage = UIImageView(image: UIImage(named: "empty_feed"))
        activityEmptyView.addSubview(emptyImage)
        emptyImage.center = CGPointMake(activityEmptyView.frame.size.width / 2 , UIScreen.mainScreen().bounds.size.height / 2 * 0.8)
        
        let noActivityYetLbl = UILabel()
        noActivityYetLbl.text = "No activity yet"
        noActivityYetLbl.textColor = UIColor.wddTealColor()
        noActivityYetLbl.font = UIFont.wddMiniteal10centerFont()
        activityEmptyView.addSubview(noActivityYetLbl)
        noActivityYetLbl.snp_makeConstraints { (make) in
            make.centerX.equalTo(emptyImage)
            make.top.equalTo(emptyImage.snp_bottom)
        }
        
        emptyView = activityEmptyView
        
        
        
    }
    
    func hasContent() -> Bool {
        return chatsAndDowns.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activity.requestDowns { (success) in
            self.tableView.reloadData()
            self.activity.requestChats { (success) in
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.activity.chats.count
        } else {
            return self.activity.downs.count
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = self.tableView!.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath) as! ActivityCell
        cell.replyButton.tag = indexPath.row
        cell.activityVC = self
        if indexPath.section == 0 {
            cell.downCell = false
            cell.fillCell(self.activity.chats[indexPath.row])
        } else {
            cell.downCell = true
            cell.fillCell(self.activity.downs[indexPath.row])
        }
        cell.selectionStyle = .Gray
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let activityObj: PFObject!
        if indexPath.section == 0 {
            activityObj = self.activity.chats[indexPath.row]
        } else {
            activityObj = self.activity.downs[indexPath.row]
        }
        
//        let user = activityObj["by"] as! PFUser
        let post = activityObj["post"] as! PFObject
        let guest = MorePostsVC()
//        guest.user = user
        guest.collectionOfPosts = [post]
        self.navigationController?.pushViewController(guest, animated: true)
        
        
        
    }

}
