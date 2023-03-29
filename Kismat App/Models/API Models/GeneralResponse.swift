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
    var users : [UserModel]!
    var profileViewer : [UserModel]!
    var socialLinkTypes : [SocialAccTypeModel]!
    var socialAccounts : [SocialAccModel]!

    override init() {
        token = ""
        user = UserModel()
        users = [UserModel]()
        profileViewer = [UserModel]()
        socialLinkTypes = [SocialAccTypeModel]()
        socialAccounts = [SocialAccModel]()
    }
    
    private enum CodingKeys: String, CodingKey {
        case token = "token"
        case user = "user"
        case users = "users"
        case profileViewer = "profileViewer"
        case socialLinkTypes = "socialLinkTypes"
        case socialAccounts = "socialAccounts"

    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token  = try values.decodeIfPresent(String.self, forKey: .token)
        user  = try values.decodeIfPresent(UserModel.self, forKey: .user)
        users  = try values.decodeIfPresent([UserModel].self, forKey: .users)
        profileViewer  = try values.decodeIfPresent([UserModel].self, forKey: .profileViewer)
        socialLinkTypes  = try values.decodeIfPresent([SocialAccTypeModel].self, forKey: .socialLinkTypes)
        socialAccounts  = try values.decodeIfPresent([SocialAccModel].self, forKey: .socialAccounts)

    }
}
