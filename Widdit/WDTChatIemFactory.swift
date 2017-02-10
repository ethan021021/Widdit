
import Foundation
import NoChat
import NoChatTG
import Parse



typealias TGMessage = NoChatTG.Message
typealias TGMessageType = NoChatTG.MessageType

struct WDTMessageFactory {
    static func createMessage(senderId: String, isIncoming: Bool, msgType: String) -> TGMessage {
        let message = TGMessage(
            msgId: NSUUID().UUIDString,
            msgType: msgType,
            senderId: senderId,
            isIncoming: isIncoming,
            date: NSDate(),
            deliveryStatus: .Delivering,
            attachments: [],
            content: ""
        )
        
        return message
    }
    
    static func createTextMessage(text text: String, senderId: String, isIncoming: Bool) -> TGMessage {
        let message = createMessage(senderId, isIncoming: isIncoming, msgType: TGMessageType.Text.rawValue)
        message.content = text
        return message
    }
}

class WDTChatItemFactory {
    
    static func createChatItemsTG(toUser: PFUser, usersPost: PFObject, completion: (messages: [ChatItemProtocol]) -> Void) {
        var result = [ChatItemProtocol]()
        
        
        WDTActivity.isDownAndReverseDown(toUser, post: usersPost) { (down) in
            if let down = down  {
                let relation = down.relationForKey("replies")
                let query = relation.query()
                query.addAscendingOrder("createdAt")
                query.includeKey("by")
                query.findObjectsInBackgroundWithBlock({ (replies: [PFObject]?, err) in
                    if err == nil {
                        if replies?.count > 0 {
                            down["replyRead"] = true
                            down.saveInBackground()
                            
                            replies!.forEach({ (reply) in
                                let sender = reply["by"] as! PFUser
                                var name = ""
                                var text = ""
                                if let firstName = sender["firstName"]  {
                                    name = firstName as! String
                                } else {
                                    name = "No name"
                                }
                                
                                if let body = reply["body"] {
                                    text = body as! String
                                }
                                
                                
                                
                                let message = WDTMessageFactory.createTextMessage(text: text, senderId: name, isIncoming: sender.username != PFUser.currentUser()?.username)
                                
                                if let createdAt = reply.createdAt {
                                    message.date = createdAt
                                }
                                
                                result.insert(message, atIndex: 0)
                            })
                            
                            print(result.count)
                            print(result)
                            completion(messages: result)
                        } else {
                            print("No objects")
                            completion(messages: [])
                        }
                    } else {
                        print(err)
                        completion(messages: [])
                    }
                })
            } else {
                completion(messages: [])
            }
        }
    }
}
