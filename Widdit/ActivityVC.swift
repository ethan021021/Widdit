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
import Presentr
import Instabug

class ActivityVC: UIViewController, StatefulViewController, UITableViewDelegate, UITableViewDataSource, ActivityVCDelegate {
    
    let activity = WDTActivity()
    var chatsAndDowns: [PFObject] = []
    var tableView: UITableView!
    let segmentedControl = UISegmentedControl(items: ["REPLIES", "DOWNS"])
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        if AppDelegate.appDelegate.activitySegmentLeft == true {
            segmentedControl.selectedSegmentIndex = 0
            isDownSelected = false
        } else {
            segmentedControl.selectedSegmentIndex = 1
            isDownSelected = true
        }
    }

    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .Alert)
        presenter.transitionType = .CoverHorizontalFromRight // Optional
        return presenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Activity"
        
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(controlValueChanged(_:)), forControlEvents: .ValueChanged)
        navigationItem.titleView = segmentedControl
        
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.registerClass(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 60;
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        
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
    
    var isDownSelected: Bool = false
    
    func controlValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isDownSelected = false
        } else {
            isDownSelected = true
        }
        makeRequest()
    }
    
    func hasContent() -> Bool {
        return self.activity.chats.count > 0 || self.activity.downs.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.isFirstStart() == true {
            Instabug.showIntroMessage()
        }
        super.viewDidAppear(animated)
        
        makeRequest()
    }
    
    func makeRequest() {
        if self.activity.downs.count == 0 {
            showHud()
        }
        
        if isDownSelected == true {
            activity.requestDowns { (success) in
                self.setupInitialViewState()
                self.hideHud()
                self.tableView.reloadData()
            }
        } else {
            self.activity.requestChats { (success) in
                self.hideHud()
                self.setupInitialViewState()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDownSelected == true {
            return self.activity.downs.count
        } else {
            return self.activity.chats.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = self.tableView!.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath) as! ActivityCell
        cell.replyButton.tag = indexPath.row
        cell.activityVC = self
        cell.tableView = tableView
        cell.downCell = isDownSelected
        if isDownSelected == true {
            let obj = self.activity.downs[indexPath.row]
            if obj["downSeen"] as? Bool == true {
                cell.backgroundColor = UIColor.whiteColor()
            } else {
                cell.backgroundColor = UIColor.WDTTealLight()
                obj["downSeen"] = true
                obj.saveInBackground()
            }
            
            cell.fillCell(obj)
        } else {
            
            
            let obj = self.activity.chats[indexPath.row]
            
            if let whoRepliedLast = obj["whoRepliedLast"] as? PFUser {
                if PFUser.currentUser()!.username != whoRepliedLast.username {
                    if obj["repliesSeen"] as? Bool == true {
                        cell.backgroundColor = UIColor.whiteColor()
                    } else {
                        cell.backgroundColor = UIColor.WDTTealLight()
                        obj["repliesSeen"] = true
                        obj.saveInBackground()
                    }
                } else {
                    cell.backgroundColor = UIColor.whiteColor()
                }
            }
            
            
            cell.fillCell(obj)
        }
        
        
        
        cell.selectionStyle = .Gray
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let activityObj: PFObject!
        
        if isDownSelected == true {
            activityObj = self.activity.downs[indexPath.row]
        } else {
            activityObj = self.activity.chats[indexPath.row]
        }
        
        let post = activityObj["post"] as! PFObject
        let guest = MorePostsVC()
        guest.collectionOfPosts = [post]
//        guest.user = activityObj[""]
        self.navigationController?.pushViewController(guest, animated: true)
        
    }

}
