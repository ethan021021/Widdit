//
//  WDTMorePostsViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTMorePostsViewController: WDTFeedBaseViewController {

    var user: PFUser?
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = user {
            if let name = user["name"] as? String {
                title = name
            } else {
                title = user.username
            }
        } else {
            title = "#\(category!)"
        }
        
        m_aryPosts = WDTPost.sharedInstance().getPosts(user: user, category: category)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
