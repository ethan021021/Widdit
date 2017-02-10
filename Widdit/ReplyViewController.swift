//
//  ReplyViewController2.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 20.12.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import NoChat
import NoChatTG


protocol ActivityVCDelegate {
    func makeRequest()
}

class ReplyViewController: ChatViewController {
    
    
    let banHandler = WDTBanHandler()
    var tableView: UITableView?
    
    
    var delegate: ActivityVCDelegate?
    var usersPost: PFObject!
    var toUser: PFUser!
    var comeFromTheFeed = true
    let inputController = NoChatTG.ChatInputViewController()
    var avaImage: UIImageView = UIImageView()
    let userNameLbl = UILabel()
    
    let messageLayoutCache = NSCache()
    
    override func viewDidLoad() {
        inverted = true
        super.viewDidLoad()

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
            make.top.equalTo(titleView).offset(3.x2)
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
    }
    
    func fetchUsernameAndAvatar() {
        toUser.fetchInBackgroundWithBlock { (u, error) in
            
            let user: PFUser = u as! PFUser
            if let avaFile = user["ava"] as? PFFile {
                self.avaImage.kf_setImageWithURL(NSURL(string: avaFile.url!)!)
            }
            
            if let firstName = user["firstName"] as? String {
                self.userNameLbl.text = firstName
            }
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let tv = self.tableView {
            tv.reloadData()
            if let delegate = delegate {
                delegate.makeRequest()
            }
        }
    }
    
    func closeBtnTapped() {
        dismissViewControllerAnimated(true, completion: {
            if let tv = self.tableView {
                tv.reloadData()
            }
            
            if let delegate = self.delegate {
                delegate.makeRequest()
            }
        })
    }
    
    func avaImageTapped(sender: AnyObject) {
        //        let destVC = ProfileVC()
        //        destVC.user = user
        //        feed.navigationController?.pushViewController(destVC, animated: true)
    }
    
    // Setup chat items
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        return [
            DateItem.itemType : [
                DateItemPresenterBuider()
            ],
            MessageType.Text.rawValue : [
                MessagePresenterBuilder<TextBubbleView, TGTextMessageViewModelBuilder>(
                    viewModelBuilder: TGTextMessageViewModelBuilder(),
                    layoutCache: messageLayoutCache
                )
            ]
        ]
    }
    

    override func createChatInputViewController() -> UIViewController {
        
        
        inputController.onSendText = { [weak self] text in
            self?.sendText(text)
        }
        
        return inputController
    }
    
}

extension ReplyViewController {
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        messageLayoutCache.removeAllObjects()
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}

extension ReplyViewController {
    func sendText(text: String) {
        
        let message = WDTMessageFactory.createTextMessage(text: text, senderId: "outgoing", isIncoming: false)
        (self.chatDataSource as! WDTChatDataSource).addMessages([message])
        
        banHandler.isUserInBanList(toUser, banUser: PFUser.currentUser()!) { (banListObject) in
            
            if let _ = banListObject {
                self.showAlert("You are banned!")
                (self.chatDataSource as! WDTChatDataSource).removeLastMsg()
            } else {
                WDTActivity.isDownAndReverseDown(self.toUser, post: self.usersPost) { (down) in
                    if let down = down  {
                        
                        self.sendMessage(down, text: text)
                    } else {
                        WDTActivity.addActivity(self.toUser, post: self.usersPost, type: .Undown, completion: { (activityObj) in
                            
                            self.sendMessage(activityObj, text: text)
                        })
                    }
                }
            }
        }
 
    }
    
    func sendMessage(activityObj: PFObject, text: String) {

        let parseMessage = PFObject(className: "replies")
        
        parseMessage["by"] = PFUser.currentUser()
        parseMessage["to"] = self.toUser
        parseMessage["body"] = text
        parseMessage["postText"] = self.usersPost["postText"]
        parseMessage["post"] = PFObject(withoutDataWithClassName: "posts", objectId: self.usersPost.objectId)
        
        
        
        
        WDTPush.sendPushAfterReply(self.toUser.username!, msg: text, postId: self.usersPost.objectId!, comeFromTheFeed: comeFromTheFeed)
        
        
        parseMessage.saveInBackgroundWithBlock { (bool, error) in
            let relation = activityObj.relationForKey("replies")
            relation.addObject(parseMessage)
            
            //sends message
            
            if PFUser.currentUser()?.objectId != self.usersPost["user"].objectId {
                activityObj["replyDate"]  = parseMessage.updatedAt
            }
            
            activityObj["replyRead"] = false
            activityObj["repliesSeen"] = false
            activityObj["comeFromTheFeed"] = self.comeFromTheFeed
            activityObj["whoRepliedLast"] = PFUser.currentUser()
            activityObj.saveInBackground()
        }
    }
}


class TGTextMessageViewModel: TextMessageViewModel {
    
}

class TGTextMessageViewModelBuilder: MessageViewModelBuilderProtocol {
    
    private let messageViewModelBuilder = MessageViewModelBuilder()
    
    func createMessageViewModel(message message: MessageProtocol) -> MessageViewModelProtocol {
        let messageViewModel = messageViewModelBuilder.createMessageViewModel(message: message)
        messageViewModel.status.value = .Success
        let textMessageViewModel = TGTextMessageViewModel(text: message.content, messageViewModel: messageViewModel)
        return textMessageViewModel
    }
}

