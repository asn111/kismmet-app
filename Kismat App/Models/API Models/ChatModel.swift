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
        
        // Decode `messageId` as String or Int and convert to Int
        if let messageIdString = try? values.decode(String.self, forKey: .messageId),
           let messageIdInt = Int(messageIdString) {
            self.messageId = messageIdInt
        } else if let messageIdInt = try? values.decode(Int.self, forKey: .messageId) {
            self.messageId = messageIdInt
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(
                    codingPath: values.codingPath + [CodingKeys.messageId],
                    debugDescription: "Expected to decode Int or String for messageId."
                )
            )
        }
        
        // Decode `chatId` as String or Int and convert to Int
        if let chatIdString = try? values.decode(String.self, forKey: .chatId),
           let chatIdInt = Int(chatIdString) {
            self.chatId = chatIdInt
        } else if let chatIdInt = try? values.decode(Int.self, forKey: .chatId) {
            self.chatId = chatIdInt
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(
                    codingPath: values.codingPath + [CodingKeys.chatId],
                    debugDescription: "Expected to decode Int or String for chatId."
                )
            )
        }
        
        // Decode `isDelivered` as String or Bool and convert to Bool
        if let isDeliveredString = try? values.decode(String.self, forKey: .isDelivered) {
            self.isDelivered = isDeliveredString.lowercased() == "true"
        } else if let isDeliveredBool = try? values.decode(Bool.self, forKey: .isDelivered) {
            self.isDelivered = isDeliveredBool
        } else {
            throw DecodingError.typeMismatch(
                Bool.self,
                DecodingError.Context(
                    codingPath: values.codingPath + [CodingKeys.isDelivered],
                    debugDescription: "Expected to decode Bool or String for isDelivered."
                )
            )
        }
        
        // Decode `isRead` as String or Bool and convert to Bool
        if let isReadString = try? values.decode(String.self, forKey: .isRead) {
            self.isRead = isReadString.lowercased() == "true"
        } else if let isReadBool = try? values.decode(Bool.self, forKey: .isRead) {
            self.isRead = isReadBool
        } else {
            throw DecodingError.typeMismatch(
                Bool.self,
                DecodingError.Context(
                    codingPath: values.codingPath + [CodingKeys.isRead],
                    debugDescription: "Expected to decode Bool or String for isRead."
                )
            )
        }
        
        // Decode remaining properties
        self.message = try values.decodeIfPresent(String.self, forKey: .message)
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        self.senderId = try values.decodeIfPresent(String.self, forKey: .senderId)
        self.senderUserName = try values.decodeIfPresent(String.self, forKey: .senderUserName)
        self.senderProfilePicture = try values.decodeIfPresent(String.self, forKey: .senderProfilePicture)
        //self.deliveredAt = try values.decodeIfPresent(String.self, forKey: .deliveredAt)
        //self.readAt = try values.decodeIfPresent(String.self, forKey: .readAt)
    }

}
