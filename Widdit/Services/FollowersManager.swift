//
//  FollowersManager.swift
//  Widdit
//
//  Created by Ilya Kharabet on 08.05.17.
//  Copyright © 2017 Widdit. All rights reserved.
//

import Parse


final class Follow {

    var follower: PFUser
    var user: PFUser
    var date: Date
    var watched: Bool
    
    init?(pfObject: PFObject) {
        if let follower = pfObject["follower"] as? PFUser,
            let user = pfObject["user"] as? PFUser,
            let date = pfObject["date"] as? Date,
            let watched = pfObject["watched"] as? Bool {
            
            self.follower = follower
            self.user = user
            self.date = date
            self.watched = watched
        } else {
            return nil
        }
    }
    
    init(follower: PFUser, user: PFUser, date: Date, watched: Bool) {
        self.follower = follower
        self.user = user
        self.date = date
        self.watched = watched
    }
    
    
    var pfObject: PFObject {
        let object = PFObject(className: "Follow")
        object["follower"] = follower
        object["user"] = user
        object["date"] = date
        object["watched"] = watched
        return object
    }

}


final class FollowersManager {
    
    /// Gets all users that follow me
    class func getFollows(completion: @escaping ([Follow]) -> Void) {
        if let me = PFUser.current() {
            let query = PFQuery(className: "Follow")
            query.includeKey("follower")
            query.includeKey("user")
            query.whereKey("user", equalTo: me)
            query.findObjectsInBackground(block: { (follows, error) in
                if let follows = (follows?.flatMap { Follow(pfObject: $0) }) {
                    completion(follows)
                }
            })
        } else {
            completion([])
        }
    }
    
    class func getWatchedFollows(completion: @escaping ([Follow]) -> Void) {
        FollowersManager.getFollowing { follows in
            let watched = follows.filter { $0.watched }
            completion(watched)
        }
    }
    
    class func getUnwatchedFollows(completion: @escaping ([Follow]) -> Void) {
        FollowersManager.getFollowing { follows in
            let watched = follows.filter { $0.watched }
            completion(watched)
        }
    }
    
    /// Gets all of users I follow
    class func getFollowing(completion: @escaping ([Follow]) -> Void) {
        if let me = PFUser.current() {
            let query = PFQuery(className: "Follow")
            query.includeKey("follower")
            query.includeKey("user")
            query.whereKey("follower", equalTo: me)
            query.findObjectsInBackground(block: { (follows, error) in
                if let follows = (follows?.flatMap { Follow(pfObject: $0) }) {
                    completion(follows)
                }
            })
        } else {
            completion([])
        }
    }
    
    class func follow(user: PFUser, completion: @escaping () -> Void) {
        if let me = PFUser.current() {
            let followObject = Follow(follower: me, user: user, date: Date(), watched: false)
            followObject.pfObject.saveInBackground(block: { (success, error) in
                completion()
                
                if let username = user.username {
                    WDTPush.sendPushAfterFollowing(to: username)
                }
            })
        } else {
            completion()
        }
    }
    
    class func unfollow(user: PFUser, completion: @escaping() -> Void) {
        if let me = PFUser.current() {
            let query = PFQuery(className: "Follow")
            query.includeKey("follower")
            query.includeKey("user")
            query.whereKey("follower", equalTo: me)
            query.whereKey("user", equalTo: user)
            query.getFirstObjectInBackground(block: { (object, _) in
                object?.deleteInBackground(block: { (_, _) in
                    completion()
                })
            })
        } else {
            completion()
        }
    }
    
    /// Returns true if you have follow the user
    class func isFollow(user: PFUser, completion: @escaping (Bool) -> Void) {
        FollowersManager.getFollowing { followers in
            let isFollow = followers.contains(where: { $0.user.objectId == user.objectId })
            completion(isFollow)
        }
    }
    
    class func setAllFollowsWatched() {
        FollowersManager.getUnwatchedFollows { follows in
            follows
            .map { f -> Follow in
                let rf = f
                rf.watched = true
                return rf
            }
            .forEach { f in
                f.pfObject.saveInBackground()
            }
        }
    }
    
}
