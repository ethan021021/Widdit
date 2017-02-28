//
//  FeedVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import ImageViewer
import SimpleAlert
import Device


protocol WDTLoad {
    func loadPosts()
}


class FeedVC: UITableViewController, WDTLoad, NewPostVCDelegate {
    
    // UI Objects
    @IBOutlet weak var ivarcator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // Page Size
    var page : Int = 10
    var geoPoint: PFGeoPoint?
    let wdtPost = WDTPost()
    var worldSelected = true
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPermissionScope()
        
        navigationController?.navigationBar.setBottomBorderColor()
        countUsers()
        configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)
        refresher.addTarget(self, action: #selector(loadPosts), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.refresh), name: "downed", object: nil)
        
        tableView.registerClass(FeedFooter.self, forHeaderFooterViewReuseIdentifier: "FeedFooter")
        tableView.registerClass(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.registerClass(FeedCategoryCell.self, forCellReuseIdentifier: "FeedCategoryCell")
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150.0;
        tableView.separatorStyle = .None
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let logoNC = UIImageView(image: UIImage(named: "logo_splash"))
        
//        let NCbtn = UIButton()
//        NCbtn.addTarget(self, action: #selector(NCbtnTapped), forControlEvents: .TouchUpInside)
//        NCbtn.setImage(UIImage(named: "icon_world"), forState: .Normal)
//        NCbtn.setImage(UIImage(named: "icon_local"), forState: .Selected)
//        NCbtn.imageView!.contentMode = .ScaleAspectFit
        
        //if Device.isEqualToScreenSize(Size.Screen4Inch) {
        //    NCbtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40)
        //}

        
        if let selectedCategory = selectedCategory {
            
            let closeFeedBtn = UIBarButtonItem(image: UIImage(named: "ic_navbar_back"), style: .Done, target: self, action: #selector(closeFeedBtnTapped))
            closeFeedBtn.tintColor = UIColor.whiteColor()
            navigationItem.leftBarButtonItem = closeFeedBtn
            title = "#" + selectedCategory
            
        } else {
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            logoNC.frame = titleView.bounds
            titleView.addSubview(logoNC)
            navigationItem.titleView = titleView
        }
    }
    
//        removed feature
//    func NCbtnTapped(sender: UIButton) {
//        if sender.selected == true {
//            sender.selected = false
//        } else {
//            sender.selected = true
//        }
//        wdtPost.collectionOfPosts = []
//        tableView.reloadData()
//        worldSelected = !sender.selected
//        loadPosts()
//        countUsers()
//    }
    
    func closeFeedBtnTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func countUsers() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_navbar_add"), style: .Done, target: self, action: #selector(newPostButtonTapped))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem

//        removed feature
//        let queryOfAllUsers = PFUser.query()
//        if worldSelected == false {
//            if let geoPoint = PFUser.currentUser()!["geoPoint"] as? PFGeoPoint {
//                queryOfAllUsers!.whereKey("geoPoint", nearGeoPoint: geoPoint, withinMiles: 25)
//            }
//        }
//        if self.allUsers == 0 {
//            self.putLeftBarButtonItem(0)    
//        }
//        
//        queryOfAllUsers?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
//            if let objects = objects {
//                //
//                self.allUsers = objects.count
//                self.putLeftBarButtonItem(objects.count)
//            }
//        })
    }
    
    
    func selectedCategory(category: String) {
        selectedCategory = category
        loadPosts()
        
    }
    
    
    func putLeftBarButtonItem(users: Int) {
        let button =  UIButton(type: .Custom)
        button.setImage(UIImage(named: "ic_navbar_users_new"), forState: .Normal)
        button.setTitle(String(users), forState: .Normal)
        button.titleLabel?.font = UIFont.wddSmallFont()
        button.addTarget(self, action: #selector(self.allUsersButtonTapped), forControlEvents: .TouchUpInside)
        button.frame = CGRectMake(0, 0, 100, 40)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 16 - 15, 18, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake(11, 0 - 15, 0, 0)
        button.contentHorizontalAlignment = .Left
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func newPostButtonTapped() {
        let newPostVC = NewPostVC()
        newPostVC.delegate = self
        if let selectedCategory = selectedCategory {
            newPostVC.postTxt.text = "#" + selectedCategory
        }
        let nc = UINavigationController(rootViewController: newPostVC)
        presentViewController(nc, animated: true, completion: nil)
    }
    
    var allUsers: Int = 0
    
    func allUsersButtonTapped() {
        if worldSelected == false {
            let alert = SimpleAlert.Controller(title: "Local Users", message: "There are currently \(allUsers) people around you on this app. New Features Coming Soon 😎", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Fasho", style: .Default, handler: { (action) in
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = SimpleAlert.Controller(title: "Total Users", message: "There are currently \(allUsers) people total on Widdit. New Features Coming Soon", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Fasho", style: .Default, handler: { (action) in
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    func refresh() {
        self.tableView.reloadData()
    }

    var requesting = false
    
    func loadPosts() {
        requesting = true
        if self.wdtPost.collectionOfPosts.count == 0 {
            showHud()
        }
        
        sharedActivity.requestMyDowns { (success) in
            self.tableView.reloadData()
        }

        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if error == nil {
                self.geoPoint = geoPoint
                PFUser.currentUser()!["geoPoint"] = self.geoPoint
                PFUser.currentUser()!.saveInBackground()
                
                self.wdtPost.requestPosts(geoPoint, world: self.worldSelected, category: self.selectedCategory, excludeCategory: false) { (success) in
                    self.hideHud()
                    self.refresher.endRefreshing()
                    self.tableView.reloadData()
                    self.requesting = false
                }
                if let selectedCategory = self.selectedCategory {
                    self.wdtPost.requestPosts(selectedCategory, completion: { (posts) in
                        if let posts = posts {
                            self.wdtPost.collectionOfAllPosts.appendContentsOf(posts)
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            } else {
                self.hideHud()
                self.requesting = false
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
//            loadMore()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = selectedCategory {
            if section == 0 {
                return 0
            }
        }
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.wdtPost.collectionOfPosts.count + 1
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        
        if indexPath.section == 0 {
            let cell = self.tableView!.dequeueReusableCellWithIdentifier("FeedCategoryCell", forIndexPath: indexPath) as! FeedCategoryCell
            cell.fillCell(selectedCategory)
            cell.accessoryType = .DisclosureIndicator
            return cell
        } else {
            let cell = self.tableView!.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
            let post = self.wdtPost.collectionOfPosts[indexPath.section - 1]
            print(post)
            let postsCount = self.wdtPost.collectionOfAllPosts.filter({
                let user1 = post["user"] as! PFUser
                return user1.username == ($0["user"] as! PFUser).username
            }).count
            if postsCount >= 11 {
                cell.moreBtn.setTitle("++", forState: .Normal)
            } else {
                cell.moreBtn.setTitle("+" + String(postsCount - 1), forState: .Normal)
            }
            cell.newPostDelegate = self
            cell.moreBtn.hidden = postsCount == 1
            cell.moreBtn.tag = indexPath.section - 1
            cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), forControlEvents: .TouchUpInside)
            cell.geoPoint = self.geoPoint
            cell.vc = self
            cell.wdtFeed = self
            cell.fillCell(post)
            cell.worldSelected = worldSelected
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            return cell
        
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let categoriesVC = SelectCategoryVC()
            categoriesVC.delegate = self
            navigationController?.pushViewController(categoriesVC, animated: true)
        } else {
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! PostCell
            
            if let img = currentCell.postPhoto.image {
                
                imageProvider.image = img
                let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: currentCell.postPhoto)
                
                self.presentImageViewer(imageViewer)
            }
        }
        
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 55
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section > 0 {
            let footer = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("FeedFooter")
            let footerView = footer as! FeedFooter
            let post = self.wdtPost.collectionOfPosts[section - 1]
            let user = post["user"] as! PFUser
            footerView.vc = self
            footerView.setDown(user, post: post)
            return footerView
        } else {
            return nil
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    func moreBtnTapped(sender: AnyObject) {
        let post = self.wdtPost.collectionOfPosts[sender.tag]
        let user = post["user"] as! PFUser
            let morePosts = MorePostsVC(style: .Grouped)
            morePosts.user = user
            morePosts.geoPoint = self.geoPoint
            morePosts.selectedCategory = selectedCategory
            morePosts.loadPosts()
            self.navigationController?.pushViewController(morePosts, animated: true)
    }
    
}

