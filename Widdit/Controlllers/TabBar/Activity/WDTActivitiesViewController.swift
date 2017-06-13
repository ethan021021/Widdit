//
//  WDTActivitiesViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import DZNEmptyDataSet


class WDTActivitiesViewController: UITableViewController, WDTActivityTableViewCellDelegate {
    
    fileprivate var unwatchedFollows: [Follow] = []
    fileprivate var activities: [Activity] = []
    
    fileprivate var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 24))
        label.text = "ACTIVITY"
        label.textAlignment = .center
        label.textColor = .white
        navigationItem.titleView = label
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestUnwatchedFollows()
        makeRequest()
    }
    
    func makeRequest() {
        if activities.count == 0 {
            showHud()
        }
        
        activities = WDTActivity.sharedInstance().chats
        tableView.reloadData()
        
        WDTActivity.sharedInstance().requestChats { [weak self] (success) in
            self?.hideHud()
            
            self?.isFirstLoad = false
            
            self?.activities = WDTActivity.sharedInstance().chats
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func requestUnwatchedFollows() {
        FollowersManager.getUnwatchedFollows { [weak self] follows in
            self?.unwatchedFollows = follows
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return unwatchedFollows.count > 0 ? 1 : 0
        } else {
            return activities.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WDTNewFollowersCell", for: indexPath) as! WDTNewFollowersCell
            
            let followersCount = unwatchedFollows.count
            let end = followersCount == 1 ? "" : "s"
            cell.followersCountLabel.text = "\(followersCount) new follower\(end)"
            
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTActivityTableViewCell.self), owner: nil, options: [:])?.first as! WDTActivityTableViewCell
            
            let activity = activities[indexPath.row]
            cell.setViewWithActivity(activity)
            
            cell.delegate = self
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "WDTFollowersViewController") {
                navigationController?.pushViewController(controller,
                                                         animated: true)
            }
        } else {
//            let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
//            morePostsVC.m_objPost = activities[indexPath.row].post
//            navigationController?.pushViewController(morePostsVC, animated: true)
            let activity = activities[indexPath.row]
            let byUser = activity.by
            let toUser = activity.to
            
            var objUser: PFUser?
            if byUser.objectId == PFUser.current()?.objectId {
                objUser = toUser
            } else {
                objUser = byUser
            }
            
            activity.post.fetchIfNeededInBackground(block: { [weak self] (post, error) in
                let replyVC = self?.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTReplyViewController.self)) as! WDTReplyViewController
                replyVC.m_objPost = post
                replyVC.m_objUser = objUser
                self?.navigationController?.pushViewController(replyVC, animated: true)
            })
            
            activity.lastMessageRead = true
            activity.object.saveInBackground()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 110
        }
    }

    // MARK: - WDTActivityTableViewCellDelegate
    func onTapUserAvatar(_ objUser: PFUser?) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = objUser
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func onClickBtnReply(_ objPost: PFObject, objUser: PFUser) {
        let replyVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTReplyViewController.self)) as! WDTReplyViewController
        replyVC.m_objPost = objPost
        replyVC.m_objUser = objUser
        navigationController?.pushViewController(replyVC, animated: true)
    }
}


extension WDTActivitiesViewController: DZNEmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if isFirstLoad {
            return nil
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return NSAttributedString(string: "No activities", attributes: [
            NSForegroundColorAttributeName: UIColor.gray,
            NSFontAttributeName: UIFont.WDTRegular(size: 12),
            NSParagraphStyleAttributeName: paragraph
        ])
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        if isFirstLoad {
            return nil
        }
        return UIImage(named: "common_reload")!
    }

}

extension WDTActivitiesViewController: DZNEmptyDataSetDelegate {

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        requestUnwatchedFollows()
        makeRequest()
    }

}
