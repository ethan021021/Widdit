//
//  ChatItemsDecorator.swift
//  Demo

import Foundation
import NoChat
import NoChatTG


typealias TGDateItem = NoChatTG.DateItem
typealias TGChatItemDecorationAttributes = NoChatTG.ChatItemDecorationAttributes

class WDTChatItemsDecorator: ChatItemsDecoratorProtocol {
    lazy var dateItem: TGDateItem = {
        let dateUid = NSUUID().UUIDString
        return TGDateItem(uid: dateUid, date: NSDate())
    }()
    
    func decorateItems(chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem] {
        let bottomMargin: CGFloat = 2
        
        var decoratedChatItems = [DecoratedChatItem]()
        
        for chatItem in chatItems {
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: TGChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: true)
                )
            )
        }
        
        if chatItems.isEmpty == false {
            let decoratedDateItem = DecoratedChatItem(
                chatItem: dateItem,
                decorationAttributes: TGChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: false)
            )
            decoratedChatItems.append(decoratedDateItem)
        }
        
        return decoratedChatItems
    }
}

