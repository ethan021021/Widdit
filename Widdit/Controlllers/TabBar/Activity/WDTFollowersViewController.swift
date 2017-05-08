//
//  WDTFollowersViewController.swift
//  Widdit
//
//  Created by Ilya Kharabet on 08.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse


final class WDTFollowersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var followers: (all: [PFUser], unwatched: [PFUser]) = ([], []) {
        didSet {
            tableView.reloadData()
            
            FollowersManager.addWatchedFollowers(followers.unwatched, completion: {})
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showHud()
        FollowersManager.getFollowers { [weak self] allFollowers in
            FollowersManager.getUnwatchedFollowers(completion: { [weak self] unwatchedFollowers in
                self?.hideHud()
                self?.followers = (all: allFollowers, unwatched: unwatchedFollowers)
            })
        }
    }

}

extension WDTFollowersViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath) as! WDTFollowerCell
        
        let user = self.followers.all[indexPath.row]
        let isNew = followers.unwatched.contains(where: { $0.objectId == user.objectId })
        
        cell.setUser(user, isNew: isNew)
        
        return cell
    }

}

extension WDTFollowersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = followers.all[indexPath.row]
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = user
        
        navigationController?.pushViewController(profileVC, animated: true)
    }

}
