//
//  GuestVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import ImageViewer

class MorePostsVC: WDTFeed {
    
//    var tableView: UITableView!
    
    // UI Objects
    var refresher : UIRefreshControl!
    var page : Int = 12

    var user: PFUser!
    let wdtPost = WDTPost()
    var collectionOfPosts = [PFObject]()
    var geoPoint: PFGeoPoint?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.registerClass(FeedFooter.self, forHeaderFooterViewReuseIdentifier: "FeedFooterMorePosts")
        tableView.registerClass(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150.0;
        tableView.separatorStyle = .None
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MorePostsVC.refresh), forControlEvents: UIControlEvents.ValueChanged)
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MorePostsVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(backSwipe)
        
        
        // Receive Notification from NewPostVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MorePostsVC.uploaded(_:)), name: "uploaded", object: nil)

    }
    
    // reloading func with posts after received notification
    func uploaded(notification: NSNotification) {
        loadPosts()
    }
    
    override func loadPosts() {
        
        wdtPost.requestPosts { (success) in
            self.tableView.reloadData()
            self.refresher.endRefreshing()
            
            self.collectionOfPosts = self.wdtPost.collectionOfAllPosts.filter({
                let u = $0["user"] as! PFUser
                if u.username == self.user.username {
                    return true
                } else {
                    return false
                }
                
            })
            self.tableView.reloadData()
        }
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = user {
            navigationItem.title = user.username?.uppercaseString
        }
    }

    func back(sender: UIBarButtonItem) {
        
        // Push Back
        navigationController?.popViewControllerAnimated(true)
    }
    
    func refresh() {
        refresher.endRefreshing()
    }
    
    
    // load more while scrolling down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - view.frame.size.height {
//            self.loadMore()
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collectionOfPosts.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = collectionOfPosts[indexPath.section]
        cell.feed = self
        cell.geoPoint = self.geoPoint
        cell.fillCell(post)
        cell.moreBtn.hidden = true
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! PostCell
        
        if let img = currentCell.postPhoto.image {
            
            imageProvider.image = img
            let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: currentCell.postPhoto)
            
            presentImageViewer(imageViewer)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let post = collectionOfPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return 0
        } else {
            return 55
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("FeedFooterMorePosts")
        let footerView = footer as! FeedFooter
        let post = collectionOfPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return nil
        } else {
            footerView.feed = self
            footerView.setDown(user, post: post)
        }
        
        return footerView
    }
}
