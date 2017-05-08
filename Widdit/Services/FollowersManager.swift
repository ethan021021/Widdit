//
//  FollowersManager.swift
//  Widdit
//
//  Created by Ilya Kharabet on 08.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import Parse


final class FollowersManager {
    
    /// Gets all users that follow me
    class func getFollowers(completion: @escaping ([PFUser]) -> Void) {
        if let query = PFUser.query(), let me = PFUser.current() {
            query.includeKey("followers")
            query.whereKey("followers", equalTo: me)
            query.findObjectsInBackground(block: { (users, error) in
                if let users = users as? [PFUser] {
                    completion(users)
                } else {
                    completion([])
                }
            })
        } else {
            completion([])
        }
    }
    
    class func getWatchedFollowers(completion: @escaping ([PFUser]) -> Void) {
        if let me = PFUser.current() {
            me.fetchIfNeededInBackground { me, error in
                if let followers = me?["watchedFollowers"] as? [PFUser] {
                    completion(followers)
                } else {
                    completion([])
                }
            }
        } else {
            completion([])
        }
    }
    
    class func getUnwatchedFollowers(completion: @escaping ([PFUser]) -> Void) {
        FollowersManager.getFollowers { followers in
            FollowersManager.getWatchedFollowers(completion: { watchedFollowers in
                let unwatchedFollowers = followers.filter { follower in
                    return !watchedFollowers.contains(where: {
                        return $0.objectId == follower.objectId
                    })
                }
                completion(unwatchedFollowers)
            })
        }
    }
    
    /// Gets all of users I follow
    class func getFollowing(completion: @escaping ([PFUser]) -> Void) {
        if let me = PFUser.current() {
            me.fetchIfNeededInBackground { me, error in
                if let followers = me?["followers"] as? [PFUser] {
                    completion(followers)
                } else {
                    completion([])
                }
            }
        } else {
            completion([])
        }
    }
    
    class func follow(user: PFUser, completion: @escaping () -> Void) {
        FollowersManager.getFollowing { followers in
            if let me = PFUser.current() {
                let resultFollowers = followers + [user]
                me["followers"] = resultFollowers
                me.saveInBackground(block: { (success, error) in
                    completion()
                    
                    if let username = user.username {
                        WDTPush.sendPushAfterFollowing(to: username)
                    }
                })
            } else {
                completion()
            }
        }
    }
    
    class func unfollow(user: PFUser, completion: @escaping() -> Void) {
        FollowersManager.getFollowing { followers in
            if let me = PFUser.current() {
                let resultFollowers = followers.filter { $0.objectId != user.objectId }
                me["followers"] = resultFollowers
                me.saveInBackground(block: { (success, error) in
                    completion()
                })
            } else {
                completion()
            }
        }
    }
    
    /// Returns true if you have follow the user
    class func isFollow(user: PFUser, completion: @escaping (Bool) -> Void) {
        FollowersManager.getFollowing { followers in
            let isFollow = followers.contains(where: { $0.objectId == user.objectId })
            completion(isFollow)
        }
    }
    
    class func addWatchedFollowers(_ followers: [PFUser], completion: @escaping () -> Void) {
        FollowersManager.getWatchedFollowers { followers in
            if let me = PFUser.current() {
                let resultFollowers = followers + followers
                me["watchedFollowers"] = resultFollowers
                me.saveInBackground(block: { (success, error) in
                    completion()
                })
            } else {
                completion()
            }
        }
    }
    
}
