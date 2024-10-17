//
//  ChatUsersModel.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 12/09/2024.
//

import Foundation

class ChatUsersModel: NSObject, Codable {
    
    var chatId : Int!
    var userId : String!
    var userName : String!
    var userProfilePicture : String!
    var userWorkTitle : String!
    var lastLoginTime : String!
    var unReadCount : Int!
    var isOnline : Bool!
    var lastMessage : LastMessageModel!
    
    
    override init() {
        
        chatId = 0
        userId = ""
        userName = ""
        userProfilePicture = ""
        lastLoginTime = ""
        userWorkTitle = ""
        unReadCount = 0
        isOnline = false
        lastMessage = LastMessageModel()
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case chatId = "chatId"
        case userId = "userId"
        case userName = "userName"
        case userProfilePicture = "userProfilePicture"
        case userWorkTitle = "userWorkTitle"
        case lastLoginTime = "lastLoginTime"
        case unReadCount = "unReadCount"
        case isOnline = "isOnline"
        case lastMessage = "lastMessage"
        
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        chatId  = try values.decodeIfPresent(Int.self, forKey: .chatId)
        userId  = try values.decodeIfPresent(String.self, forKey: .userId)
        userName  = try values.decodeIfPresent(String.self, forKey: .userName)
        userProfilePicture  = try values.decodeIfPresent(String.self, forKey: .userProfilePicture)
        userWorkTitle  = try values.decodeIfPresent(String.self, forKey: .userWorkTitle)
        lastLoginTime  = try values.decodeIfPresent(String.self, forKey: .lastLoginTime)
        isOnline  = try values.decodeIfPresent(Bool.self, forKey: .isOnline)
        unReadCount  = try values.decodeIfPresent(Int.self, forKey: .unReadCount)
        lastMessage  = try values.decodeIfPresent(LastMessageModel.self, forKey: .lastMessage)
        
    }
}

class LastMessageModel: NSObject, Codable {
    
    var messageld : Int!
    var chatMessage : String!
    var isLastMessageByMe : Bool!
    
    
}
