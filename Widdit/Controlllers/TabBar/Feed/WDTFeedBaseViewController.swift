//
//  WDTFeedBaseViewController.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import CPImageViewer

class WDTFeedBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPImageControllerProtocol, WDTFeedTableViewCellDelegate {
    
    @IBOutlet weak var m_tblFeeds: UITableView!
    
    var animationImageView: UIImageView!
    var animator = CPImageViewerAnimator()
    var m_aryPosts = [PFObject]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_tblFeeds.rowHeight = UITableViewAutomaticDimension
        m_tblFeeds.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickBtnAddPost(_ sender: Any) {
        let addPostVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTAddPostViewController.self)) as! WDTAddPostViewController
        present(addPostVC, animated: true, completion: nil)
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: WDTFeedTableViewCell.self), owner: nil, options: nil)?.first as! WDTFeedTableViewCell
        cell.setViewWithPFObject(m_aryPosts[indexPath.row])
        cell.hideMorePosts(self.hideMorePosts(indexPath.row))
        
        cell.m_lblPhotoText.enabledTypes = [.hashtag, .url]
        cell.m_lblPhotoText.hashtagColor = UIColor.WDTActivityColor()
        cell.m_lblPhotoText.handleHashtagTap { (hashtag) in
            let morePostsVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
            morePostsVC.category = hashtag
            self.navigationController?.pushViewController(morePostsVC, animated: true)
        }
        cell.m_lblPhotoText.handleURLTap { (url) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func hideMorePosts(_ index: Int) -> Bool {
        return true
    }
    
    //WDTFeedTableViewCellDelegate
    func onClickBtnMore(_ objPost: PFObject) {
        let alert = UIAlertController(title: "", message: Constants.String.APP_NAME, preferredStyle: .actionSheet)
        
        if (objPost["user"] as? PFUser)?.objectId == PFUser.current()?.objectId {
            let actionEdit = UIAlertAction(title: "Edit", style: .default) { (_) in
                let addPostVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTAddPostViewController.self)) as! WDTAddPostViewController
                addPostVC.m_objPost = objPost
                self.navigationController?.pushViewController(addPostVC, animated: true)
            }
            alert.addAction(actionEdit)
            
            let actionDelete = UIAlertAction(title: "Delete", style: .default) { (_) in
                let confirmAlert = UIAlertController(title: Constants.String.APP_NAME, message: "Are you sure to remove this post?", preferredStyle: .alert)
                
                let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    WDTPost.deletePost(post: objPost, completion: { (success) in
                        if success {
                            let index = self.m_aryPosts.index(where: { (post) -> Bool in
                                return post.objectId == objPost.objectId
                            })
                            self.m_tblFeeds.deleteRows(at: [IndexPath.init(row: index!, section: 0)], with: .automatic)
                        }
                    })
                })
                confirmAlert.addAction(actionYes)
                
                let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
                confirmAlert.addAction(actionNo)
                
                self.present(confirmAlert, animated: true, completion: nil)
            }
            alert.addAction(actionDelete)
        } else {
            let actionReport = UIAlertAction(title: "Report", style: .default) { (_) in
                self.showInfoAlert("Post reported. We’ll take a look at it. Thanks!")
            }
            alert.addAction(actionReport)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func onClickBtnMorePosts(_ objUser: PFUser?) {
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.user = objUser
        navigationController?.pushViewController(morePostsVC, animated: true)
    }
    
    func onTapPostPhoto(_ objPost: PFObject) {
        let index = self.m_aryPosts.index(where: { (post) -> Bool in
            return post.objectId == objPost.objectId
        })
        
        let cell = m_tblFeeds.cellForRow(at: IndexPath(row: index!, section: 0)) as! WDTFeedTableViewCell
        animationImageView = cell.m_imgPhoto
        
        let controller = CPImageViewerViewController()
        controller.transitioningDelegate = animator
        controller.image = animationImageView.image
        present(controller, animated: true, completion: nil)
    }
    
    func onTapUserAvatar(_ objUser: PFUser?) {
        
    }
    
    func onUpdateObject(_ objPost: PFObject) {
        let index = self.m_aryPosts.index(where: { (post) -> Bool in
            return post.objectId == objPost.objectId
        })
        
        m_tblFeeds.reloadRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
    }

}
