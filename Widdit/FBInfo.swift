//
//  FBInfo.swift
//  Widdit
//
//  Created by John McCants on 4/1/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

class FBInfo {
    
    let strFirstName: String
    let strEmail: String
    let strGender: String
    let avaImage: UIImage?
    
    
    init(image: UIImage?, firstName: String?, email: String?, gender: String?) {
       self.strFirstName = firstName!
       self.strEmail = email!
       self.strGender = gender!
       self.avaImage = image
    }

}
