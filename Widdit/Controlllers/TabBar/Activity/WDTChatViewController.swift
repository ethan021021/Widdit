//
//  WDTChatViewController.swift
//  Widdit
//
//  Created by JH Lee on 20/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Parse

class WDTChatViewController: JSQMessagesViewController {

    var m_objPost: PFObject?
    var m_objUser: PFUser?
    var m_isFeedChat = false
    
    var outgoingBubbleImageData: JSQMessagesBubbleImage?
    var incomingBubbleImageData: JSQMessagesBubbleImage?
    
    var senderAvatar: UIImage?
    var recipientAvatar: UIImage?
    
    var m_aryMessages = [JSQMessageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()

        // Do any additional setup after loading the view.
        let objUser = PFUser.current()!
        
        senderId = objUser.objectId
        if let strName = objUser["Name"] as? String {
            senderDisplayName = strName
        } else {
            senderDisplayName = objUser.username
        }
        
        if let avatarFile = objUser["ava"] as? PFFile {
            if let data = try? avatarFile.getData() {
                senderAvatar = UIImage(data: data)
            }
        }
        
        if let avatarFile = m_objUser?["ava"] as? PFFile {
            if let data = try? avatarFile.getData() {
                recipientAvatar = UIImage(data: data)
            }
        }
        
        collectionView.collectionViewLayout.messageBubbleFont = UIFont.WDTRegular(size: 16)
        
        outgoingBubbleImageData = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(),
                                                                capInsets: .zero)?
            .outgoingMessagesBubbleImage(with: UIColor(r: 71, g: 211, b: 214, a: 1))
        incomingBubbleImageData = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(),
                                                                capInsets: .zero)?
            .incomingMessagesBubbleImage(with: UIColor(r: 249, g: 249, b: 249, a: 1))
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        showHud()
        getChatHistory()
    }
    
    fileprivate func setupToolbar() {
        self.inputToolbar.maximumHeight = 256
        self.inputToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.inputToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.inputToolbar.clipsToBounds = false
        self.inputToolbar.layer.shadowColor = UIColor(r: 206, g: 209, b: 210, a: 1).cgColor
        self.inputToolbar.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.inputToolbar.layer.shadowRadius = 3
        self.inputToolbar.layer.shadowOpacity = 0.5
        self.inputToolbar.contentView.backgroundColor = .white
        self.inputToolbar.contentView.textView.layer.borderWidth = 0
        self.inputToolbar.contentView.textView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func getChatHistory() {
        if let objPost = m_objPost {
            let objUser = objPost["user"] as! PFUser
            WDTActivity.isDownAndReverseDown(user: objUser, post: objPost) { (down) in
                if let down = down  {
                    let relation = down.relation(forKey: "replies")
                    let query = relation.query()
                    query.addAscendingOrder("createdAt")
                    query.includeKey("by")
                    query.findObjectsInBackground(block: { (replies, err) in
                        self.hideHud()
                        
                        if err == nil {
                            for objReply in replies! {
                                down["replyRead"] = true
                                down.saveInBackground()
                                
                                let sender = objReply["by"] as! PFUser
                                var senderName = ""
                                var text = ""
                                
                                if let strName = sender["name"] as? String {
                                    senderName = strName
                                } else {
                                    senderName = sender.username!
                                }
                                
                                if let body = objReply["body"] as? String {
                                    text = body
                                }
                                
                                self.m_aryMessages.append(JSQMessage(senderId: sender.objectId, displayName: senderName, text: text))
                            }
                            
                            self.finishReceivingMessage()
                        }
                    })
                } else {
                    self.hideHud()
                }
            }
        } else {
            self.hideHud()
        }
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

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        WDTActivity.isDownAndReverseDown(user: m_objUser!, post: m_objPost!) { (down) in
            if let down = down  {
                self.sendMessage(down, text: text)
            } else {
                WDTActivity.addActivity(user: self.m_objUser!, post: self.m_objPost!, type: .Undown, completion: { (activityObj) in
                    self.sendMessage(activityObj, text: text)
                })
            }
        }
        
        m_aryMessages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        finishSendingMessage()
    }
    
    func sendMessage(_ objActivity: PFObject, text: String) {
        
        let parseMessage = PFObject(className: "replies")
        
        parseMessage["by"] = PFUser.current()
        parseMessage["to"] = m_objUser
        parseMessage["body"] = text
        parseMessage["post"] = PFObject(withoutDataWithClassName: "posts", objectId: m_objPost?.objectId)
        
        WDTPush.sendPushAfterReply(toUsername: (m_objUser?.username!)!, msg: text, postId: (self.m_objUser?.objectId!)!, comeFromTheFeed: m_isFeedChat)
        
        parseMessage.saveInBackground { (bool, error) in
            let relation = objActivity.relation(forKey: "replies")
            relation.add(parseMessage)
            
            //sends message
            if PFUser.current()?.objectId != (self.m_objPost?["user"] as! PFUser).objectId {
                objActivity["replyDate"]  = parseMessage.updatedAt
            }
            
            objActivity["replyRead"] = false
            objActivity["repliesSeen"] = false
            objActivity["comeFromTheFeed"] = self.m_isFeedChat
            objActivity["whoRepliedLast"] = PFUser.current()
            objActivity.saveInBackground()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_aryMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return m_aryMessages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            return outgoingBubbleImageData
        } else {
            return incomingBubbleImageData
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImage(with: senderAvatar ?? UIImage(named: "common_avatar_placeholder"),
                                                             diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: recipientAvatar ?? UIImage(named: "common_avatar_placeholder"),
                                                             diameter: 30)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor(r: 68, g: 74, b: 89, a: 1)
        }
        
        return cell
    }
    
}
