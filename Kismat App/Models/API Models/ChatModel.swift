//
//  ChatModel.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 13/09/2024.
//

import Foundation

class ChatModelArray: NSObject, Codable {
    var dayHeader : String!
    var messages : [ChatModel] = [ChatModel]()
}
class ChatModel: NSObject, Codable {
    
    var messageId : Int!
    var chatId : Int!
    var message : String!
    var createdAt : String!
    var senderId : String!
    var senderUserName : String!
    var senderProfilePicture : String!
    var isDelivered : Bool!
    var deliveredAt : String!
    var isRead : Bool!
    var readAt : String!
    
    
    override init() {
        
        messageId = 0
        chatId = 0
        message = ""
        createdAt = ""
        senderId = ""
        senderUserName = ""
        senderProfilePicture = ""
        isDelivered = false
        deliveredAt = ""
        isRead = false
        readAt = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case messageId = "messageId"
        case chatId = "chatId"
        case message = "chatMessage"
        case createdAt = "createdAt"
        case senderId = "senderId"
        case senderUserName = "senderUserName"
        case senderProfilePicture = "senderProfilePicture"
        case isDelivered = "isDelivered"
        case deliveredAt = "deliveredAt"
        case isRead = "isRead"
        case readAt = "readAt"
        
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        messageId  = try values.decodeIfPresent(Int.self, forKey: .messageId)
        chatId  = try values.decodeIfPresent(Int.self, forKey: .chatId)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        createdAt  = try values.decodeIfPresent(String.self, forKey: .createdAt)
        senderId  = try values.decodeIfPresent(String.self, forKey: .senderId)
        senderUserName  = try values.decodeIfPresent(String.self, forKey: .senderUserName)
        senderProfilePicture  = try values.decodeIfPresent(String.self, forKey: .senderProfilePicture)
        isDelivered  = try values.decodeIfPresent(Bool.self, forKey: .isDelivered)
        isRead  = try values.decodeIfPresent(Bool.self, forKey: .isRead)
        
    }
}
