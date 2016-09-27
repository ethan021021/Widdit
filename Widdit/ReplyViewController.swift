//
//  ViewController.swift
//  IPMQuickstart
//
//  Created by Brent Schooley on 12/8/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

import UIKit
import SlackTextViewController
import Parse

class ReplyViewController: SLKTextViewController {
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    

    var messages = [MessageModel]()
    var usersPost: PFObject!
    var userObjArray = [PFObject]()
    var avaImage: UIImageView = UIImageView()
    let userNameLbl = UILabel()
    
    var isDown = false
    var toUser: PFUser!
    var comeFromTheFeed = true
    var body: String = ""

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Associate the device with a user
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
        
        
        let titleView = UIView()
        titleView.backgroundColor = UIColor.whiteColor()
        view.addSubview(titleView)
        titleView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(24.x2)
        }
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor.lightGrayColor()
        titleView.addSubview(topLine)
        topLine.alpha = 0.5
        topLine.snp_makeConstraints { (make) in
            make.left.equalTo(titleView)
            make.right.equalTo(titleView)
            make.bottom.equalTo(titleView).offset(-0.5.x2)
            make.height.equalTo(0.5.x2)
        }
        
        
        avaImage.layer.cornerRadius = 8.0
        avaImage.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(avaImageTapped(_:)))
        avaImage.userInteractionEnabled = true
        avaImage.addGestureRecognizer(tapGestureRecognizer)
        titleView.addSubview(avaImage)
        avaImage.snp_remakeConstraints(closure: { (make) in
            make.top.equalTo(titleView).offset(6.x2)
            make.left.equalTo(titleView).offset(6.x2)
            make.width.equalTo(16.x2)
            make.height.equalTo(16.x2)
        })
        
        
        userNameLbl.font = UIFont.WDTAgoraRegular(12)
        userNameLbl.textColor = UIColor.blackColor()
        titleView.addSubview(userNameLbl)
        userNameLbl.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(avaImage.snp_right).offset(6.x2)
            make.top.equalTo(titleView).offset(9.5.x2)
        })
        
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "ic_reply_close"), forState: .Normal)
        closeBtn.addTarget(self, action: #selector(closeBtnTapped), forControlEvents: .TouchUpInside)
        titleView.addSubview(closeBtn)
        closeBtn.snp_makeConstraints { (make) in
            make.right.equalTo(titleView).offset(-6.x2)
            make.top.equalTo(titleView).offset(6.x2)
            make.width.equalTo(12.x2)
            make.height.equalTo(12.x2)
        }
        
        
        
        tableView!.registerClass(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        inverted = false
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 64.0
        tableView!.separatorStyle = .None
        tableView!.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        registerPrefixesForAutoCompletion(["@",  "#", ":", "+:", "/"])
        
        textView.placeholder = "Message";
        
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
        
        
        
        requestMessages()
    }
    
    func closeBtnTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func avaImageTapped(sender: AnyObject) {
//        let destVC = ProfileVC()
//        destVC.user = user
//        feed.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func requestMessages() {
        
        toUser.fetchInBackgroundWithBlock { (u, error) in
            let user: PFUser = u as! PFUser
            if let avaFile = user["ava"] as? PFFile {
                self.avaImage.kf_setImageWithURL(NSURL(string: avaFile.url!)!)
            }
            
            if let firstName = user["firstName"] as? String {
                self.userNameLbl.text = firstName
            }
            
            
        }
        
        
        WDTActivity.isDownAndReverseDown(toUser, post: usersPost) { (down) in
            if let down = down  {
                let relation = down.relationForKey("replies")
                let query = relation.query()
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (replies: [PFObject]?, err) in
                    if err == nil {
                        if replies?.count > 0 {
                            self.messages = replies!.map({ (reply) -> MessageModel in
                                
                                var message = MessageModel(name: "", body: "", createdAt: NSDate())
                                
                                let sender = reply["by"] as! PFUser
                                
                                if let firstName = sender["firstName"]  {
                                    message.name = firstName as! String
                                } else {
                                    message.name = "No name"
                                }
                                
                                if let body = reply["body"] {
                                    message.body = body as! String
                                }
                                
                                if let createdAt = reply.createdAt {
                                    message.createdAt = createdAt
                                }
                                
                                return message
                            })
                            self.tableView?.reloadData()
                            if self.messages.count > 0 {
                                let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                                let rowAnimation: UITableViewRowAnimation = .Bottom
                                let scrollPosition: UITableViewScrollPosition = .Bottom
                                self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
                            }
                            
                        } else {
                            print("No objects")
                        }
                    } else {
                        print(err)
                    }
                })
            }
        }
    }
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
            let message = messages[indexPath.row]
            
            // Set table cell values
            cell.nameLabel.text = message.name
            cell.bodyLabel.text = message.body
            cell.createdAtLabel.text = self.dateFormatter.stringFromDate(message.createdAt)
            cell.selectionStyle = .None
            
            return cell
    }
    
    // MARK: UITableViewDataSource Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension ReplyViewController {
    override func didPressRightButton(sender: AnyObject?) {
        let message = MessageModel(name: PFUser.currentUser()!["firstName"] as! String, body: self.textView.text, createdAt: NSDate())
        
        body = self.textView.text
        
        let indexPath = NSIndexPath(forRow: self.messages.count, inSection: 0)
        let rowAnimation: UITableViewRowAnimation = .Bottom
        let scrollPosition: UITableViewScrollPosition = .Bottom
        self.tableView!.beginUpdates()
        self.messages.append(message)
        self.tableView!.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
        self.tableView!.endUpdates()
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView!.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
        super.didPressRightButton(sender)
        
        
        WDTActivity.isDownAndReverseDown(toUser, post: usersPost) { (down) in
            if let down = down  {
                
                self.sendMessage(sender, activityObj: down)
            } else {
                WDTActivity.addActivity(self.toUser, post: self.usersPost, type: .Undown, completion: { (activityObj) in
                
                    self.sendMessage(sender, activityObj: activityObj)
                })
            }
        }
    }
    
    func sendMessage(sender: AnyObject?, activityObj: PFObject) {
        self.textView.refreshFirstResponder()
        
        
        
        let parseMessage = PFObject(className: "replies")
        
        parseMessage["by"] = PFUser.currentUser()
        parseMessage["to"] = self.toUser
        parseMessage["body"] = body
        parseMessage["postText"] = self.usersPost["postText"]
        parseMessage["post"] = PFObject(withoutDataWithClassName: "posts", objectId: self.usersPost.objectId)
        
        WDTPush.sendPushAfterReply(self.toUser.username!, msg: body, postId: self.usersPost.objectId!, comeFromTheFeed: comeFromTheFeed)
        
        
        parseMessage.saveInBackgroundWithBlock { (bool, error) in
            let relation = activityObj.relationForKey("replies")
            relation.addObject(parseMessage)
            
            
            //sends message
            activityObj["comeFromTheFeed"] = self.comeFromTheFeed
            activityObj["whoRepliedLast"] = PFUser.currentUser()
            activityObj.saveInBackground()
        }
    }
}
