//
//  WDTPush.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPush {
    
    private class func sendPush(toUsername: String, var data: [String: AnyObject]) {
        
        print(data)
        
        
        
        //let push = PFPush()
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: toUsername)
        userQuery!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, err) in
            
            
            if err == nil {
                if let receiver = objects!.first {
                    
                    data["receiver"] = receiver.objectId!

                    PFCloud.callFunctionInBackground("sendPush", withParameters: data) {
                        (response: AnyObject?, error: NSError?) -> Void in
                        
                        
                        let resp = response as? [String: AnyObject?]
                        print(resp)
                        let resp2 = response as? String
                        print(resp2)
                        
                    }
                }
            }
        })
        
//        let pushQuery = PFInstallation.query()
//        pushQuery?.whereKey("user", matchesQuery: userQuery!)
//        
//        push.setData(data)
//        push.setQuery(pushQuery)
//        push.sendPushInBackground()
    }
    
    class func sendPushAfterDownTapped(toUsername: String, postId: String) {
        
        guard let username = PFUser.currentUser()?.username else {
            print("username is not set")
            return
        }
        
        guard let userObjectId = PFUser.currentUser()?.objectId! else {
            return
        }
        
        let data = ["alert": "\(username) is down for your post", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId, "type": "down"]
        WDTPush.sendPush(toUsername, data: data)
    }
    
    class func sendPushAfterReply(toUsername: String, msg: String, postId: String, comeFromTheFeed: Bool) {
        guard let username = PFUser.currentUser()?.username else {
            print("username is not set")
            return
        }
        
        guard let userObjectId = PFUser.currentUser()?.objectId! else {
            return
        }
        
        var message: String = ""
        
        if comeFromTheFeed {
            message = "replied to your post"
        } else {
            message = "replied back"
        }
        
        let data = ["alert": "\(username) \(message)", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId, "type": "reply"]
        WDTPush.sendPush(toUsername, data: data)
    }
}
