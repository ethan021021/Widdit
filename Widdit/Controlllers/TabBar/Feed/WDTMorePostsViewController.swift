//
//  WDTMorePostsViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTMorePostsViewController: WDTFeedBaseViewController {

    var m_objUser: PFUser?
    var m_strCategory: String?
    var m_objPost: PFObject?
    
    var shouldRequestMyDowns: Bool = false
    
    var morePostsButtonColorSaved: [Int: UIColor] = [:]
    
    var postsByUser: [String: Int] = [:]
    
    fileprivate var filteredByCategory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if shouldRequestMyDowns {
            navigationItem.rightBarButtonItem = nil
            
            showHud()
            WDTActivity.sharedInstance().requestMyDowns(completion: { [weak self] success in
                self?.hideHud()
                
                self?.m_aryPosts = WDTActivity.sharedInstance().myDowns.flatMap { down in
                    return down["post"] as? PFObject
                }
                
                self?.tableView.reloadData()
            })
        } else {
            if let objUser = m_objUser, let strCategory = m_strCategory {
                if let name = objUser["name"] as? String {
                    title = name
                } else {
                    title = objUser.username
                }
                
                m_aryPosts = WDTPost.sharedInstance().getPosts(user: objUser, category: strCategory)
            } else if let objUser = m_objUser {
                if let name = objUser["name"] as? String {
                    title = name
                } else {
                    title = objUser.username
                }
                
                m_aryPosts = WDTPost.sharedInstance().getPosts(user: objUser, category: nil)
            } else if let strCategory = m_strCategory {
                title = "#\(strCategory)"
                m_aryPosts = WDTPost.sharedInstance().getPosts(user: nil, category: strCategory)
                    .reduce([], { (acc, current) -> [PFObject] in
                        if acc.contains( where: {
                            if ($0["user"] as! PFUser).objectId == (current["user"] as! PFUser).objectId {
                                return true
                            } else {
                                return false
                            }
                        })
                        {
                            return acc
                        } else {
                            postsByUser[(current["user"] as! PFUser).objectId!] = 1
                            return acc + [current]
                        }
                    })
                filteredByCategory = true
            } else if let objPost = m_objPost {
                title = "Post"
                m_aryPosts = [objPost]
            }
        }
    }
    
    
    fileprivate func loadMorePosts(user: PFUser?) {
        if let key = user?.objectId {
            if let currentCount = postsByUser[key] {
                let userPosts = Array(WDTPost.sharedInstance()
                    .getPosts(user: user, category: m_strCategory)
                    .prefix(currentCount + 3))
                    .filter { post in
                    return !self.m_aryPosts.contains(post)
                }
                
                if let lastUserPost = m_aryPosts
                    .reversed()
                    .first(where: { ($0["user"] as? PFUser)?.objectId == user?.objectId }) {
                    
                    if let index = m_aryPosts.index(of: lastUserPost) {
                        m_aryPosts.insert(contentsOf: userPosts, at: index + 1)
                        
                        postsByUser[key] = (postsByUser[key] ?? 0) + userPosts.count
                        
                        
                        self.tableView.insertRows(at: (index + 1...index + userPosts.count)
                            .map { IndexPath(row: $0,
                                             section: self.shouldShowCategories ? 1 : 0) },
                                                  with: UITableViewRowAnimation.bottom)
                        self.tableView.reloadRows(at: (index - currentCount + 1...index)
                            .map { IndexPath(row: $0,
                                            section: self.shouldShowCategories ? 1 : 0) },
                                                  with: .none)
                    }
                    
                }
            }
        }
    }
    
    
    @IBAction override func onClickBtnAddPost(_ sender: Any) {
        if let strCategory = m_strCategory {
            let addPostNC = storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
            let addPostVC = addPostNC.viewControllers[0] as! WDTAddPostViewController
            addPostVC.m_hashtag = "#\(strCategory)"
            present(addPostNC, animated: true, completion: nil)
        } else {
            super.onClickBtnAddPost(sender)
        }
    }
    
    override func onClickBtnMorePosts(_ objUser: PFUser?) {
//        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
//        morePostsVC.m_objUser = objUser
//        morePostsVC.m_strCategory = m_strCategory
//        navigationController?.pushViewController(morePostsVC, animated: true)
        loadMorePosts(user: objUser)
    }
    
    override func setMorePosts(_ index: Int) -> Int {
        if let category = m_strCategory, filteredByCategory {
            let post = m_aryPosts[index]
            
            let lastSamePost = m_aryPosts
                .reversed()
                .first(where: { ($0["user"] as? PFUser)?.objectId == (post["user"] as? PFUser)?.objectId })
            
            // неправильная логика
            guard post.objectId == lastSamePost?.objectId else {
                return 1
            }
            
            let userPostCount = (self.postsByUser[(post["user"] as! PFUser).objectId!] ?? 1) - 1
            
            let allCategoryPostsCount = WDTPost.sharedInstance().m_aryAllPosts.filter { tmpPost -> Bool in
                if let categories = tmpPost["hashtags"] as? [String] {
                    return categories.contains(category) &&
                        (post["user"] as! PFUser).objectId == (tmpPost["user"] as! PFUser).objectId
                }
                return false
            }.count
            
            if allCategoryPostsCount == 0 {
                morePostsButtonColorSaved[index] = UIColor.WDTPrimaryColor()
                return WDTPost.sharedInstance().m_aryAllPosts.filter { (tmpPost) -> Bool in
                    return (post["user"] as! PFUser).objectId == (tmpPost["user"] as! PFUser).objectId
                }.count - userPostCount
            }
            
            morePostsButtonColorSaved[index] = UIColor.purple
            return allCategoryPostsCount - userPostCount
        } else {
            morePostsButtonColorSaved[index] = UIColor.WDTPrimaryColor()
            return super.setMorePosts(index)
        }
    }
    
    override func morePostsButtonColor(at index: Int) -> UIColor {
        return morePostsButtonColorSaved[index] ?? UIColor.WDTPrimaryColor()
    }

}
