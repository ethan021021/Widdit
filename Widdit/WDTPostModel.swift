//
//  WDTPostModel.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 07.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPostModel: PFObject, PFSubclassing {
    
    @NSManaged var user: PFUser
    @NSManaged var postText: String?
    @NSManaged var photoFile: PFFile?
    @NSManaged var ava: PFFile
    @NSManaged var hoursexpired: NSDate
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    

    static func parseClassName() -> String {
        return "WDTPostModel"
    }

}