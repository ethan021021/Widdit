//
//  WDTPost.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPost {
    var collectionOfPosts = [PFObject]()
    var collectionOfAllPosts = [PFObject]()
    
    var postsOfUser:PFUser?
    
    class func deletePost(post: PFObject, completion: (success: Bool) -> Void) {
        let query = PFQuery(className: "posts")
        query.getObjectInBackgroundWithId(post.objectId!) { (object, error) in
            object?.deleteInBackgroundWithBlock({ (success, error) in
                completion(success: success)
            })
        }
    }
    
    func requestPosts(completion: (success: Bool) -> Void) {
        let query = PFQuery(className: "posts")
        query.limit = 10
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        query.whereKeyExists("user")
        
        
        
        if let postsOfUser = self.postsOfUser {
            query.whereKey("user", equalTo: postsOfUser)
        }
        
        query.findObjectsInBackgroundWithBlock({ (posts: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let posts = posts {
                    self.collectionOfAllPosts = posts
                    
                    self.collectionOfAllPosts = self.collectionOfAllPosts.filter({
                        let parseDate = $0.objectForKey("hoursexpired") as! NSDate
                        if NSDate().timeIntervalSince1970 >= parseDate.timeIntervalSince1970 {
                            let delete = PFObject(withoutDataWithClassName: "posts", objectId: $0.objectId)
                            delete.deleteInBackgroundWithBlock({ (success, err) in
                                if success {
                                    print("Successfully deleted expired post")
                                    dispatch_async(dispatch_get_main_queue(), {
                                        
                                    })
                                } else {
                                    print("Failed to delete expired post: \(err)")
                                }
                            })
                            return false
                        } else {
                            return true
                        }
                    })
                    
                    self.collectionOfPosts = self.collectionOfAllPosts.reduce([], combine: { (acc: [PFObject], current: PFObject) -> [PFObject] in
                        if acc.contains( {
                            if $0["user"].objectId == current["user"].objectId {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            return acc
                        } else {
                            let allPostsOfUser = self.collectionOfAllPosts.filter({$0["user"].objectId == current["user"].objectId
                            })
                            if let newest = allPostsOfUser.first {
                                return acc + [newest]
                            } else {
                                return acc
                            }
                        }
                    })
                }
            }
            completion(success: true)
            
        })
    }
}