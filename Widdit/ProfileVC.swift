//
//  HomeVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import ImageViewer
import SimpleAlert
import Whisper

class ProfileVC: WDTFeed {

    
//    var tableView: UITableView!
    var configuration: ImageViewerConfiguration!
    let imageProvider = WDTImageProvider()
    // Page Size
    var page : Int = 10
    
    var geoPoint: PFGeoPoint?
    let wdtPost = WDTPost()
    
    var user: PFUser = PFUser.currentUser()!
    var headerHeight: CGFloat = 200.0
    var headerView: UIView!
    
    var avatars: [PFFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = self.user.username?.uppercaseString
        
        if user.username == PFUser.currentUser()?.username {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Done, target: self, action: #selector(editButtonTapped))
        }
        
        configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)

        
        tableView.registerClass(FeedFooter.self, forHeaderFooterViewReuseIdentifier: "FeedFooter")
        tableView.registerClass(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150.0;
        tableView.separatorStyle = .None
        
        
        
        headerHeight = 200
        
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 0, view.frame.width, headerHeight))
        scrollView.backgroundColor = UIColor.whiteColor()
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        
        let wdtHeader = WDTHeader(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) + 100));
        
        print(user["firstName"] as? String)
        wdtHeader.setName(user["firstName"] as? String)
        
        WDTAvatar.countAvatars(user) { (num) in
            scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(num), self.headerHeight)
        }
        avatars = []
        
        if let ava = user["ava"] as? PFFile {
            avatars.append(ava)
        }
        
        if let ava = user["ava2"] as? PFFile {
            avatars.append(ava)
        }
        
        if let ava = user["ava3"] as? PFFile {
            avatars.append(ava)
        }
        
        if let ava = user["ava4"] as? PFFile {
            avatars.append(ava)
        }
        wdtHeader.setImages(avatars)
        
        
        if let _ = user["phoneNumber"] {
            wdtHeader.phoneVerified.tintColor = UIColor.whiteColor()
            wdtHeader.phoneVerified.selected = true
            
        }
        
        if let _ = user["email"] {
            wdtHeader.emailVerified.tintColor = UIColor.whiteColor()
            wdtHeader.emailVerified.selected = true
        }
        
        if let facebookVerified = user["facebookVerified"] as? Bool where facebookVerified == true {
            wdtHeader.facebookVerified.tintColor = UIColor.whiteColor()
            wdtHeader.facebookVerified.selected = true
        }
        
        if let about = user["about"] as? String {
            if about.characters.count > 0 {
                wdtHeader.setAbout(about)
                wdtHeader.frame.size.height += 60
            }
        }
        
        if let situation = user["situationSchool"] as? Bool {
            wdtHeader.schoolSituation.tintColor = UIColor.whiteColor()
            wdtHeader.schoolSituation.selected = situation
        }
        
        if let situation = user["situationWork"] as? Bool {
            wdtHeader.workingSituation.tintColor = UIColor.whiteColor()
            wdtHeader.workingSituation.selected = situation
        }
        
        if let situation = user["situationOpportunity"] as? Bool {
            wdtHeader.opportunitySituation.tintColor = UIColor.whiteColor()
            wdtHeader.opportunitySituation.selected = situation
        }
        
        tableView.tableHeaderView = wdtHeader
        self.loadPosts()
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! WDTHeader
        headerView.scrollViewDidScroll(scrollView)
    }
    
    
    func editButtonTapped() {
        
        
        let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)
        alert.addAction(SimpleAlert.Action(title: "Edit", style: .Default) { action in
            let destVC = ProfileEditVC()
            destVC.view.backgroundColor = UIColor.whiteColor()
            let nc = UINavigationController(rootViewController: destVC)
            self.presentViewController(nc, animated: true, completion: nil)
        })
        
        alert.addAction(SimpleAlert.Action(title: "Logout", style: .Destructive) { action in
            self.logout()
        })
        
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    

    override func loadPosts() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
        wdtPost.postsOfUser = self.user
        wdtPost.requestPosts { (success) in
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillAppear(animated: Bool) {
        self.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.wdtPost.collectionOfAllPosts.count
    }
    
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = wdtPost.collectionOfAllPosts[indexPath.section]
        cell.feed = self
        cell.moreBtn.tag = indexPath.section
        cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), forControlEvents: .TouchUpInside)
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
        let post = self.wdtPost.collectionOfAllPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return 0
        } else {
            return 55
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("FeedFooter")
        let footerView = footer as! FeedFooter
        let post = self.wdtPost.collectionOfAllPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return nil
        } else {
            footerView.feed = self
            footerView.setDown(user, post: post)
        }
        
        return footerView
        
    }

    func moreBtnTapped(sender: AnyObject) {
        let post = self.wdtPost.collectionOfAllPosts[sender.tag]
        let user = post["user"] as! PFUser
        let guest = MorePostsVC()
        guest.user = user
        guest.geoPoint = self.geoPoint
        self.navigationController?.pushViewController(guest, animated: true)
    }
    
    
    func logout() {
        
        // implement log out
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if error == nil {
                
                // remove logged in user from App memory
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()

                FBSDKLoginManager().logOut()
                PFUser.logOut()

                let storage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in storage.cookies! {
                    storage.deleteCookie(cookie)
                }
                NSUserDefaults.standardUserDefaults().synchronize()

                FBSDKAccessToken.setCurrentAccessToken(nil)
                FBSDKProfile.setCurrentProfile(nil)

                let signIn = self.storyboard?.instantiateViewControllerWithIdentifier("SignInVC") as! SignInVC
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = signIn
                
            }
        }
    }
}
