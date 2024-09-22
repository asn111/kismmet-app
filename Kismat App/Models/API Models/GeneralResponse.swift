//
//  GeneralResponse.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Tuesday15/12/2020.
//

import Foundation

class GeneralResponse : NSObject, Codable {
    var statusCode : Int!
    var status : String!
    var message : String!
    var errorMessage : String!
    var body : Body!
    
    override init() {
        statusCode = 0
        status = ""
        message = ""
        errorMessage = ""
        body = Body()
    }
    private enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case status = "status"
        case message = "message"
        case errorMessage = "errorMessage"
        case body = "body"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode  = try values.decodeIfPresent(Int.self, forKey: .statusCode)
        status  = try values.decodeIfPresent(String.self, forKey: .status)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        errorMessage  = try values.decodeIfPresent(String.self, forKey: .errorMessage)
        body  = try values.decodeIfPresent(Body.self, forKey: .body)
    }
}

class Body : NSObject, Codable {
    var token : String!
    var user : UserModel!
    var proximityUsers : ProximityUsersModel!
    var users : [UserModel]!
    var profileViewer : [UserModel]!
    var deactivatedUsers : [UserModel]!
    var socialLinkTypes : [SocialAccTypeModel]!
    var socialAccounts : [SocialAccModel]!
    var startUp : StartupModel!
    var userNotifications : [NotificationModel]!
    var reportReasons : [ReportReasonsModel]!
    var contactUsers : [UserModel]!
    var requestUsers : [UserModel]!
    var contactTypes : [ContactTypesModel]!
    var contactAccounts : [ContactsModel]!
    var userChats : [ChatUsersModel]!
    var chatMessages : [ChatModel]!

    override init() {
        token = ""
        user = UserModel()
        proximityUsers = ProximityUsersModel()
        users = [UserModel]()
        profileViewer = [UserModel]()
        deactivatedUsers = [UserModel]()
        socialLinkTypes = [SocialAccTypeModel]()
        socialAccounts = [SocialAccModel]()
        startUp = StartupModel()
        userNotifications = [NotificationModel]()
        reportReasons = [ReportReasonsModel]()
        contactUsers = [UserModel]()
        requestUsers = [UserModel]()
        contactTypes = [ContactTypesModel]()
        contactAccounts = [ContactsModel]()
        userChats = [ChatUsersModel]()
        chatMessages = [ChatModel]()
    }
    
    private enum CodingKeys: String, CodingKey {
        case token = "token"
        case user = "user"
        case proximityUsers = "proximityUsers"
        case users = "users"
        case profileViewer = "profileViewer"
        case deactivatedUsers = "deactivatedUsers"
        case socialLinkTypes = "socialLinkTypes"
        case socialAccounts = "socialAccounts"
        case startUp = "startUp"
        case userNotifications = "userNotifications"
        case reportReasons = "reportReasons"
        case contactUsers = "userContacts"
        case contactTypes = "contactTypes"
        case contactAccounts = "userContactInformations"
        case userChats = "userChats"
        case chatMessages = "chatMessages"
        //case requestUsers = "reportReasons"

    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token  = try values.decodeIfPresent(String.self, forKey: .token)
        user  = try values.decodeIfPresent(UserModel.self, forKey: .user)
        proximityUsers  = try values.decodeIfPresent(ProximityUsersModel.self, forKey: .proximityUsers)
        users  = try values.decodeIfPresent([UserModel].self, forKey: .users)
        profileViewer  = try values.decodeIfPresent([UserModel].self, forKey: .profileViewer)
        deactivatedUsers  = try values.decodeIfPresent([UserModel].self, forKey: .deactivatedUsers)
        socialLinkTypes  = try values.decodeIfPresent([SocialAccTypeModel].self, forKey: .socialLinkTypes)
        socialAccounts  = try values.decodeIfPresent([SocialAccModel].self, forKey: .socialAccounts)
        startUp  = try values.decodeIfPresent(StartupModel.self, forKey: .startUp)
        userNotifications  = try values.decodeIfPresent([NotificationModel].self, forKey: .userNotifications)
        reportReasons  = try values.decodeIfPresent([ReportReasonsModel].self, forKey: .reportReasons)
        contactUsers  = try values.decodeIfPresent([UserModel].self, forKey: .contactUsers)
        contactTypes  = try values.decodeIfPresent([ContactTypesModel].self, forKey: .contactTypes)
        contactAccounts  = try values.decodeIfPresent([ContactsModel].self, forKey: .contactAccounts)
        userChats  = try values.decodeIfPresent([ChatUsersModel].self, forKey: .userChats)
        chatMessages  = try values.decodeIfPresent([ChatModel].self, forKey: .chatMessages)
        //requestUsers  = try values.decodeIfPresent([UserModel].self, forKey: .requestUsers)

    }
}
