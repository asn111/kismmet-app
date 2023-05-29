//
//  NotificationModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 29/05/2023.
//

import Foundation

class NotificationModel: NSObject, Codable {
    
    var notificationId : Int!
    var notifiedUserId : String!
    var userName : String!
    var profilePicture : String!
    var notificationMessage : String!
    var isRead : Bool!
    var createdAt : String!
    
    override init() {
        
        notificationId = 0
        notifiedUserId = ""
        userName = ""
        profilePicture = ""
        notificationMessage = ""
        isRead = false
        createdAt = ""
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case notificationId = "notificationId"
        case notifiedUserId = "notifiedUserId"
        case userName = "userName"
        case profilePicture = "profilePicture"
        case notificationMessage = "notificationMessage"
        case isRead = "isRead"
        case createdAt = "createdAt"
        
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        notificationId  = try values.decodeIfPresent(Int.self, forKey: .notificationId)
        notifiedUserId  = try values.decodeIfPresent(String.self, forKey: .notifiedUserId)
        userName  = try values.decodeIfPresent(String.self, forKey: .userName)
        profilePicture  = try values.decodeIfPresent(String.self, forKey: .profilePicture)
        notificationMessage  = try values.decodeIfPresent(String.self, forKey: .notificationMessage)
        isRead  = try values.decodeIfPresent(Bool.self, forKey: .isRead)
        createdAt  = try values.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
