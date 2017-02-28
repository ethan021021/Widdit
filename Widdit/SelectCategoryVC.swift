//
//  SelectCategoryVC.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 03.01.17.
//  Copyright © 2017 John McCants. All rights reserved.
//

import UIKit
import Parse

class SelectCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NewPostVCDelegate {

    var tableView: UITableView = UITableView()
    var categories: [PFObject] = []
    var selectingCategoryForNewPost = false
    var delegate: NewPostVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        loadCategories()
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_navbar_add"), style: .Done, target: self, action: #selector(newPostButtonTapped))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func loadPosts() {
        delegate.loadPosts()
        loadCategories()
    }
    
    func loadCategories() {
        showHud()
        let categoryQuery = PFQuery(className: "categories")
        categoryQuery.orderByDescending("updatedAt")
        categoryQuery.findObjectsInBackgroundWithBlock { (cat, err) in
            self.hideHud()
            self.categories = cat!
            self.tableView.reloadData()
        }
    }
    
    func newPostButtonTapped() {
        let newPostVC = NewPostVC()
        newPostVC.delegate = self
        let nc = UINavigationController(rootViewController: newPostVC)
        presentViewController(nc, animated: true, completion: nil)
    }

    
    func cancelBtnTapped() {
        dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        let obj = categories[indexPath.row]
        let title = obj["title"] as! String
        cell.selectionStyle = .Gray
        
        cell.fillCell(title, selectingCategoryForNewPost: selectingCategoryForNewPost)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(false, animated: true)
        
        let feedVC = FeedVC(style: .Grouped)
        let obj = categories[indexPath.row]
        feedVC.selectedCategory(obj["title"] as! String)
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
