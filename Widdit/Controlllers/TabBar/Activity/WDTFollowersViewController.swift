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
    
    
    var follows: [Follow] = [] {
        didSet {
            tableView.reloadData()
            
            FollowersManager.setAllFollowsWatched()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showHud()
        FollowersManager.getFollows { [weak self] allFollows in
            self?.hideHud()
            self?.follows = allFollows
        }
    }

}

extension WDTFollowersViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return follows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath) as! WDTFollowerCell
        
        let follow = self.follows[indexPath.row]
        
        cell.setUser(follow.follower, date: follow.date, isNew: !follow.watched)
        
        return cell
    }

}

extension WDTFollowersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let follow = follows[indexPath.row]
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = follow.follower
        
        navigationController?.pushViewController(profileVC, animated: true) ?? present(profileVC, animated: true, completion: nil)
    }

}
