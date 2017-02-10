//
//  WDTActivity.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

protocol WDTActivityProtocol {}


let sharedActivity = WDTActivity()


class WDTActivity {
    
    enum WDTActivityType: String {
        case Down = "down"
        case Undown = "undown"
    }

    let currentUser = PFUser.currentUser()!
    var chats: [PFObject] = []
    var downs: [PFObject] = []
    var myDowns: [PFObject] = []
    var chatsAndDowns: [PFObject] = []
    
    class func isDown(user: PFUser, post: PFObject, completion: (down: PFObject?) -> Void) {
        let didDown = PFQuery(className: "Activity")
        didDown.whereKey("by", equalTo: PFUser.currentUser()!)
        didDown.whereKey("to", equalTo: user)
        didDown.whereKey("post", equalTo: post)
        
        didDown.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if let object = objects?.first {
                completion(down: object)
            } else {
                completion(down: nil)
            }
        }
    }
    
    class func isDownAndReverseDown(user: PFUser, post: PFObject, completion: (down: PFObject?) -> Void) {
        let didDown = PFQuery(className: "Activity")
        didDown.whereKey("by", equalTo: PFUser.currentUser()!)
        didDown.whereKey("to", equalTo: user)
        didDown.whereKey("post", equalTo: post)
        
        let reverseDidDown = PFQuery(className: "Activity")
        reverseDidDown.whereKey("by", equalTo: user)
        reverseDidDown.whereKey("to", equalTo: PFUser.currentUser()!)
        reverseDidDown.whereKey("post", equalTo: post)
        
        let allQueries = PFQuery.orQueryWithSubqueries([didDown, reverseDidDown])
        
        allQueries.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if let object = objects?.first {
                completion(down: object)
            } else {
                completion(down: nil)
            }
        }
    }
    

    
    class func addActivity(user: PFUser, post: PFObject, type: WDTActivityType, completion:(activityObj: PFObject)->Void) {
        WDTPush.sendPushAfterDownTapped(user.username!, postId: post.objectId!)
        
        WDTActivity.isDown(user, post: post) { (down) in
            if let down = down {
                down["type"] = type.rawValue
                down.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
                    completion(activityObj: down)
                    sharedActivity.requestMyDowns({ (success) in})
                }
            } else {
                let activityObj = PFObject(className: "Activity")
                activityObj["by"] = PFUser.currentUser()
                activityObj["to"] = user
                activityObj["post"] = post
                activityObj["postText"] = post["postText"]
                activityObj["type"] = type.rawValue
                
                activityObj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
                    completion(activityObj: activityObj)
                    sharedActivity.requestMyDowns({ (success) in})
                }
            }
        }
    }
    
    class func deleteActivity(user: PFUser, post: PFObject) {
    
        WDTActivity.isDown(user, post: post) { (down) in
            if let down = down {
                down["type"] = WDTActivityType.Undown.rawValue
                down.saveInBackgroundWithBlock({ (success, error) in
                    sharedActivity.requestMyDowns({ (success) in})
                })
            }
        }
    }
    
    func requestMyDowns(completion: (success: Bool) -> Void) {
        
        let activitiesQuery = PFQuery(className: "Activity")
        activitiesQuery.whereKey("by", equalTo: currentUser)
        activitiesQuery.whereKey("type", equalTo: "down")
        activitiesQuery.includeKey("post")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackgroundWithBlock { (myDowns: [PFObject]?, error: NSError?) in
            if let myDowns = myDowns {
                self.myDowns = myDowns.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })
                
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    
    func requestDowns(completion: (success: Bool) -> Void) {
                
        let activitiesQuery = PFQuery(className: "Activity")
        activitiesQuery.whereKey("to", equalTo: currentUser)
        activitiesQuery.whereKey("type", equalTo: "down")
        activitiesQuery.includeKey("post")
        activitiesQuery.includeKey("by")
        activitiesQuery.includeKey("to")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackgroundWithBlock { (downs: [PFObject]?, error: NSError?) in
            if let downs = downs {
                self.downs = downs.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })

                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    func requestChats(completion: (success: Bool) -> Void) {
        
        let activitiesToMeQuery = PFQuery(className: "Activity")
        activitiesToMeQuery.whereKey("by", equalTo: currentUser)
//        activitiesToMeQuery.whereKey("whoRepliedLast", notEqualTo: currentUser)
        activitiesToMeQuery.whereKey("comeFromTheFeed", equalTo: false)
        activitiesToMeQuery.whereKeyExists("whoRepliedLast")
        
        
        let activitiesFromMeQuery = PFQuery(className: "Activity")
        activitiesFromMeQuery.whereKey("to", equalTo: currentUser)
        activitiesFromMeQuery.whereKeyExists("whoRepliedLast")
        
        let activitiesQuery = PFQuery.orQueryWithSubqueries([activitiesToMeQuery, activitiesFromMeQuery])
        activitiesQuery.includeKey("post")
        activitiesQuery.includeKey("by")
        activitiesQuery.includeKey("to")
        activitiesQuery.includeKey("whoRepliedLast")
        //activitiesQuery.addDescendingOrder("replyDate")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackgroundWithBlock { (chats: [PFObject]?, error: NSError?) in
            if let chats = chats {
                
                self.chats = chats.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })
                
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
}
