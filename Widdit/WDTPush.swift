//
//  WDTPush.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPush {
    
    private class func sendPush(toUsername: String, data: [String: AnyObject]) {
        
        let push = PFPush()
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: toUsername)
        
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("user", matchesQuery: userQuery!)
        
        push.setData(data)
        push.setQuery(pushQuery)
        push.sendPushInBackground()
    }
    
    class func sendPushAfterDownTapped(toUsername: String, postId: String) {
        
        guard let username = PFUser.currentUser()?.username else {
            print("username is not set")
            return
        }
        
        guard let userObjectId = PFUser.currentUser()?.objectId! else {
            return
        }
        
        let data = ["alert": "\(username) is down for your post", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId]
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
        
        let data = ["alert": "\(username) \(message)", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId]
        WDTPush.sendPush(toUsername, data: data)
    }
}
