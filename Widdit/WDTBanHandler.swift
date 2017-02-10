//
//  WDTBanHandler.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 27.12.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTBanHandler {
    
    
    func isUserInBanList(owner: PFUser, banUser: PFUser, completion:(banListObject: PFObject?) -> Void) {
        let banListQuery = PFQuery(className: "banList")
        banListQuery.whereKey("owner", equalTo: owner)
        banListQuery.whereKey("banUser", equalTo: banUser)
        banListQuery.getFirstObjectInBackgroundWithBlock { (obj, error) in
            if let _ = obj {
                completion(banListObject: obj)
            } else {
                completion(banListObject: nil)
            }
        }
    }
    
    
    func addOrRemove(banUser: PFUser, completion: (added: Bool) -> Void) {
        isUserInBanList(PFUser.currentUser()!, banUser: banUser) { (banListObject) in
            
            if let banListObject = banListObject {
                banListObject.deleteInBackground()
                completion(added: false)
            } else {
                let banList = PFObject(className: "banList")
                banList["owner"] = PFUser.currentUser()
                banList["banUser"] = banUser
                banList.saveInBackground()
                completion(added: true)
            }
        }
    }
}
