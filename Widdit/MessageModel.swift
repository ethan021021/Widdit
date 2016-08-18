//
//  Message.swift
//  Widdit
//
//  Created by Ethan Thomas on 4/20/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

struct MessageModel {
  var name: String
  var body: String
  var createdAt: NSDate

  init(name: String, body: String, createdAt: NSDate) {
    self.name = name
    self.body = body
    self.createdAt = createdAt
  }
}
