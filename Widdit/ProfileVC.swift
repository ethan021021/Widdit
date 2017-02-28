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
import BetterSegmentedControl


class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, WDTLoad, NewPostVCDelegate {

    let banHandler = WDTBanHandler()
    var tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)
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
    var infoSelected = true
    var wdtHeader: WDTHeader!
    let settingsBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.user.username?.uppercaseString
        
        configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)

        
        tableView.registerClass(FeedFooter.self, forHeaderFooterViewReuseIdentifier: "FeedFooter")
        tableView.registerClass(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.registerClass(AboutCell.self, forCellReuseIdentifier: "AboutCell")
        tableView.registerClass(ProfileCell.self, forCellReuseIdentifier: "ProfileCell")
        
        tableView.backgroundColor = UIColor.wddSilverColor()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150.0;
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        
        headerHeight = 200
        
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 0, view.frame.width, headerHeight))
        scrollView.backgroundColor = UIColor.whiteColor()
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        
        wdtHeader = WDTHeader(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) + 50))
        wdtHeader.control.addTarget(self, action: #selector(wdtHeaderSegmentedControlTapped), forControlEvents: .ValueChanged)
        wdtHeader.setName(user["firstName"] as? String)
        WDTAvatar.countAvatars(user) { (num) in
            scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(num), self.headerHeight)
        }
        

        
        
        tableView.tableHeaderView = wdtHeader
        self.loadPosts()
        
        
        
        settingsBtn.setImage((UIImage(named: "ic_settings")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
        
        settingsBtn.addTarget(self, action: #selector(editButtonTapped), forControlEvents: .TouchUpInside)
        settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 50, 0)
        
        
        tableView.addSubview(settingsBtn)
        settingsBtn.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(view).offset(16.x2)
            make.right.equalTo(view).offset(-6.x2)
            make.width.equalTo(40.x2)
            make.height.equalTo(40.x2)
        })
        //settingsBtn.hidden = user.username != PFUser.currentUser()?.username

        
    }
    
    func loadAvatars() {
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
        
        
        
        wdtHeader.setImages(avatars)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadPosts()
        loadAvatars()
        
        if avatars.count == 0 {
            settingsBtn.imageView?.tintColor = UIColor.blackColor()
        } else {
            settingsBtn.imageView?.tintColor = UIColor.whiteColor()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! WDTHeader
        headerView.scrollViewDidScroll(scrollView)
    }
    
    
    func editButtonTapped() {
        let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)
        
        if user.username == PFUser.currentUser()?.username {
            
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
        } else {
            var banTitle = "Block"
            self.showHud()
            banHandler.isUserInBanList(PFUser.currentUser()!, banUser: user) { (banListObject) in
                self.hideHud()
                if let _ = banListObject {
                    banTitle = "Unblock"
                } else {
                    banTitle = "Block"
                }
                
                alert.addAction(SimpleAlert.Action(title: banTitle, style: .Default) { action in
                    self.showHud()
                    self.banHandler.addOrRemove(self.user) { (added) in
                        self.hideHud()
                    }
                })
                
                alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func wdtHeaderSegmentedControlTapped(sender: BetterSegmentedControl) {
        if sender.index == 0 {
            infoSelected = false
        } else {
            infoSelected = true
        }
        tableView.reloadData()
    }

    func loadPosts() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
        wdtPost.postsOfUser = self.user
        wdtPost.requestPosts(nil, world: nil, category: nil, excludeCategory: nil) { (success) in
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if infoSelected == true {
            if section == 0 {
                return 1
            } else {
                return 3
            }
        }
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if infoSelected == true {
            return 3
        } else {
            return self.wdtPost.collectionOfAllPosts.count
        }
    }
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        if infoSelected == true {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("AboutCell", forIndexPath: indexPath) as! AboutCell
                if let about = user["about"] as? String {
                    cell.vc = self
                    cell.fillCell(about)
                }
                
                return cell

            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
                cell.tag = indexPath.row
                if indexPath.row == 0 {
                    cell.fillCellSituation(.School, user: user)
                } else if indexPath.row == 1 {
                    cell.fillCellSituation(.Working, user: user)
                } else if indexPath.row == 2 {
                    cell.fillCellSituation(.Opportunity, user: user)
                }
                
                return cell
                
            } else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
                cell.tag = indexPath.row
                if indexPath.row == 0 {
                    cell.fillCellVerification(.Phone, user: user)
                } else if indexPath.row == 1 {
                    cell.fillCellVerification(.Email, user: user)
                } else if indexPath.row == 2 {
                    cell.fillCellVerification(.Facebook, user: user)
                }
                
                return cell
                
            }

            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
            let post = wdtPost.collectionOfAllPosts[indexPath.section]
            cell.moreBtn.tag = indexPath.section
            cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), forControlEvents: .TouchUpInside)
            cell.geoPoint = self.geoPoint
            cell.fillCell(post)
            cell.moreBtn.hidden = true
            cell.vc = self
            cell.wdtFeed = self
            cell.newPostDelegate = self
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if infoSelected == false {
        
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! PostCell
            
            if let img = currentCell.postPhoto.image {
                
                imageProvider.image = img
                let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: currentCell.postPhoto)
                
                presentImageViewer(imageViewer)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if infoSelected == true {
            return 0
        } else {
            let post = self.wdtPost.collectionOfAllPosts[section]
            let user = post["user"] as! PFUser
            
            if PFUser.currentUser()?.username == user.username {
                return 0
            } else {
                return 55
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if infoSelected == true {
            return nil
        } else {
            let footer = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("FeedFooter")
            let footerView = footer as! FeedFooter
            let post = self.wdtPost.collectionOfAllPosts[section]
            let user = post["user"] as! PFUser
            
            if PFUser.currentUser()?.username == user.username {
                return nil
            } else {
                footerView.setDown(user, post: post)
            }
            
            return footerView
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if infoSelected == true {
            return 20
        } else {
            return 1
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if infoSelected == true {
            let headerView = UIView()
            let headerLbl = UILabel()
            headerView.addSubview(headerLbl)
            headerLbl.font = UIFont.wddMicrotealFont()
            headerLbl.textColor = UIColor.wddTealColor()
            headerLbl.snp_makeConstraints { (make) in
                make.left.equalTo(headerView).offset(6.x2)
                make.bottom.equalTo(headerView).offset(-6.x2)
            }
            
            if section == 0 {
                headerLbl.text = "ABOUT"
            } else if section == 1 {
                headerLbl.text = "SITUATION"
            } else if section == 2 {
                headerLbl.text = "VERIFICATION"
            }
            
            return headerView
        }
        
        return nil
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
        showHud()
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            self.hideHud()
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
                
                AppDelegate.appDelegate.window?.rootViewController = UINavigationController(rootViewController: WelcomeVC())
            
                
            }
        }
    }
}
