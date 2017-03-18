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

    var m_objUser: PFUser?
    var m_strCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = m_objUser {
            if let name = user["name"] as? String {
                title = name
            } else {
                title = user.username
            }
        } else {
            title = "#\(m_strCategory!)"
        }
        
        m_aryPosts = WDTPost.sharedInstance().getPosts(user: m_objUser, category: m_strCategory)
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
