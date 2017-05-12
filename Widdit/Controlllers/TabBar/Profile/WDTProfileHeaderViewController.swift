//
//  WDTProfileHeaderViewController.swift
//  Widdit
//
//  Created by JH Lee on 17/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import Kingfisher

class WDTProfileHeaderViewController: UIViewController {

    var m_objUser: PFUser?
    var m_parentVC: UIViewController?
    
    @IBOutlet weak var m_imageViewAvatar: UIImageView!
    @IBOutlet weak var m_imageViewCover: UIImageView!
    @IBOutlet weak var m_btnBack: WDTBackButton!
    @IBOutlet weak var m_btnSettings: UIButton!
    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_btnFollow: UIButton!
    @IBOutlet weak var m_buttonNewPost: UIButton!
    
    
    fileprivate var aryAvatars = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        m_imageViewAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WDTProfileHeaderViewController.onTapToAvatar)))
        m_imageViewCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WDTProfileHeaderViewController.onTapToCover)))
        
        let isCurrentUser = m_objUser?.objectId == PFUser.current()?.objectId
        m_btnSettings.isHidden = !isCurrentUser
        m_btnBack.isHidden = isCurrentUser
        m_buttonNewPost.isHidden = !isCurrentUser
        
        m_btnBack.onTouchUp = {
            self.onClickBtnBack(self.m_btnBack)
        }
        
        m_btnFollow.isHidden = true
        updateFollowingStatus()
        
        if let userName = m_objUser?["name"] as? String {
            m_lblName.text = userName
        } else {
            m_lblName.text = m_objUser?.username
        }
        
        updateAvatar()
        updateCover()
    }
    
    public func updateAvatar() {
        aryAvatars = [String]()
        
        if let ava = m_objUser?["ava"] as? PFFile {
            if let url = ava.url {
                aryAvatars.append(url)
            }
        }
        
        if let ava = m_objUser?["ava2"] as? PFFile {
            if let url = ava.url {
                aryAvatars.append(url)
            }
        }
        
        if let ava = m_objUser?["ava3"] as? PFFile {
            if let url = ava.url {
                aryAvatars.append(url)
            }
        }
        
        if let path = aryAvatars.first {
            if let url = URL(string: path) {
                m_imageViewAvatar.kf.setImage(with: url)
            }
        }
    }
    
    func updateCover() {
        if let coverFile = m_objUser?["cover"] as? PFFile {
            if let path = coverFile.url {
                if let url = URL(string: path) {
                    m_imageViewCover.kf.setImage(with: url)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        m_imageViewAvatar.layer.cornerRadius = m_imageViewAvatar.frame.width * 0.5
    }
    
    
    fileprivate func updateFollowingStatus() {
        if let user = m_objUser, user.objectId != PFUser.current()?.objectId {
            FollowersManager.isFollow(user: user, completion: { [weak self] isFollow in
                if isFollow {
                    self?.m_btnFollow.setImage(UIImage(named: "profile_button_following"), for: .normal)
                    self?.m_btnFollow.setTitle("Following", for: .normal)
                } else {
                    self?.m_btnFollow.setImage(UIImage(named: "profile_button_follow"), for: .normal)
                    self?.m_btnFollow.setTitle("Follow", for: .normal)
                }
                self?.m_btnFollow.isHidden = false
            })
        } else {
            m_btnFollow.isHidden = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBtnBack(_ sender: Any) {
        if let navigationController = m_parentVC?.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func onClickBtnSettings(_ sender: Any) {
        let alert = UIAlertController(title: Constants.String.APP_NAME, message: "", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit Profile", style: .default) { (_) in
            let editProfileNC = self.storyboard?.instantiateViewController(withIdentifier: "WDTEditProfileNavigationController")
            self.m_parentVC?.present(editProfileNC!, animated: true, completion: nil)
        }
        alert.addAction(editAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            PFUser.logOut()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootNC = appDelegate.window?.rootViewController as! UINavigationController
            rootNC.popToRootViewController(animated: false)
        }
        alert.addAction(logoutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        m_parentVC?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnFollow(_ sender: Any) {
        if let user = m_objUser, user.objectId != PFUser.current()?.objectId {
            FollowersManager.isFollow(user: user, completion: { isFollow in
                if isFollow {
                    FollowersManager.unfollow(user: user, completion: { [weak self] in
                        self?.updateFollowingStatus()
                    })
                } else {
                    FollowersManager.follow(user: user, completion: { [weak self] in
                        self?.updateFollowingStatus()
                    })
                }
            })
        }
    }
    
    @IBAction func onClickButtonNewPost(_ sender: Any) {
        let addPostNC = m_parentVC?.storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
        m_parentVC?.present(addPostNC, animated: true, completion: nil)
    }
    
    func onTapToCover() {
        if let coverFile = m_objUser?["cover"] as? PFFile {
            if let path = coverFile.url {
                let photoURLs = [path]
                let photos = photoURLs.map { _ in NYTPhotoObject() }
                let controller = PhotosViewController(photos: photos)
                controller.rightBarButtonItem = nil
                
                m_parentVC?.present(controller, animated: true, completion: nil)
                
                loadPhotos(for: photoURLs,
                           loaded:
                    { image, index in
                        photos[index].image = image
                        controller.updateImage(for: photos[index])
                })
            }
        }
    }
    
    func onTapToAvatar() {
        let photos = aryAvatars.map { _ in NYTPhotoObject() }
        let controller = PhotosViewController(photos: photos)
        controller.rightBarButtonItem = nil
        
        m_parentVC?.present(controller, animated: true, completion: nil)
        
        loadPhotos(for: aryAvatars,
                   loaded:
            { image, index in
                photos[index].image = image
                controller.updateImage(for: photos[index])
        })
    }
    
    
    fileprivate func loadPhotos(for photoURLs: [String],
                                loaded: @escaping (UIImage?, Int) -> Void,
                                completion: (() -> Void)? = nil) {
        if photoURLs.count > 0 {
            var photosLoaded = 0
            for (index, path) in photoURLs.enumerated() {
                guard let url = URL(string: path) else {
                    photosLoaded += 1
                    
                    if photosLoaded >= photoURLs.count {
                        completion?()
                    }
                    return
                }
                
                KingfisherManager.shared.retrieveImage(with: url,
                                                       options: nil,
                                                       progressBlock: nil,
                                                       completionHandler:
                    { (image, _, _, _) in
                        loaded(image, index)
                        
                        photosLoaded += 1
                        if photosLoaded >= photoURLs.count {
                            completion?()
                        }
                })
            }
        } else {
            completion?()
        }
    }
    
}

