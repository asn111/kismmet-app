//
//  UserModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 26/03/2023.
//

import Foundation


class ProximityUsersModel: NSObject, Codable {
    
    var profilesViewed : Int!
    var users : [UserModel]!
    
    
    override init() {
        
        profilesViewed = 0
        users = [UserModel]()
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case profilesViewed = "profilesViewed"
        case users = "users"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        profilesViewed  = try values.decodeIfPresent(Int.self, forKey: .profilesViewed)
        users  = try values.decodeIfPresent([UserModel].self, forKey: .users)
    }
}


class UserModel: NSObject, Codable {
    
    var userId : String!
    var userName : String!
    var email : String!
    var publicEmail : String!
    var countryCode : String!
    var phone : String!
    var dob : String!
    var workAddress : String!
    var workTitle : String!
    var about : String!
    var proximity : Int!
    var isProfileVisible : Bool!
    var isProfileUpdated : Bool!
    var isStarred : Bool!
    var tags : String!
    var isActive : Bool!
    var shadowMode : Bool!
    var accountStatus : String!
    var subscription : String!
    var socialAccounts : [SocialAccModel]!


    override init() {
        
        userId = ""
        userName = ""
        email = ""
        publicEmail = ""
        countryCode = ""
        phone = ""
        dob = ""
        workAddress = ""
        workTitle = ""
        about = ""
        proximity = 0
        isProfileVisible = false
        isProfileUpdated = false
        isStarred = false
        tags = ""
        isActive = false
        shadowMode = false
        accountStatus = ""
        subscription = ""
        socialAccounts = [SocialAccModel]()
        
    }
    
    init(fromDictionary dictionary: [String: Any]) {
        userName = dictionary["fullName"] as? String
        workAddress = dictionary["workAdress"] as? String
        workTitle = dictionary["workTitle"] as? String
        about = dictionary["about"] as? String
        tags = dictionary["tags"] as? String
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case userId = "userId"
        case userName = "userName"
        case email = "email"
        case publicEmail = "publicEmail"
        case countryCode = "countryCode"
        case phone = "phone"
        case dob = "dob"
        case workAddress = "workAddress"
        case workTitle = "workTitle"
        case about = "about"
        case proximity = "proximity"
        case isProfileVisible = "isProfileVisible"
        case isProfileUpdated = "isProfileUpdated"
        case isStarred = "isStarred"
        case tags = "tags"
        case isActive = "isActive"
        case shadowMode = "shadowMode"
        case accountStatus = "accountStatus"
        case subscription = "subscription"
        case socialAccounts = "socialAccounts"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        userId  = try values.decodeIfPresent(String.self, forKey: .userId)
        userName  = try values.decodeIfPresent(String.self, forKey: .userName)
        email  = try values.decodeIfPresent(String.self, forKey: .email)
        publicEmail  = try values.decodeIfPresent(String.self, forKey: .publicEmail)
        countryCode  = try values.decodeIfPresent(String.self, forKey: .countryCode)
        phone  = try values.decodeIfPresent(String.self, forKey: .phone)
        dob  = try values.decodeIfPresent(String.self, forKey: .dob)
        workAddress  = try values.decodeIfPresent(String.self, forKey: .workAddress)
        workTitle  = try values.decodeIfPresent(String.self, forKey: .workTitle)
        about  = try values.decodeIfPresent(String.self, forKey: .about)
        proximity  = try values.decodeIfPresent(Int.self, forKey: .proximity)
        isProfileVisible  = try values.decodeIfPresent(Bool.self, forKey: .isProfileVisible)
        isProfileUpdated  = try values.decodeIfPresent(Bool.self, forKey: .isProfileUpdated)
        isStarred  = try values.decodeIfPresent(Bool.self, forKey: .isStarred)
        tags  = try values.decodeIfPresent(String.self, forKey: .tags)
        isActive  = try values.decodeIfPresent(Bool.self, forKey: .isActive)
        shadowMode  = try values.decodeIfPresent(Bool.self, forKey: .shadowMode)
        accountStatus  = try values.decodeIfPresent(String.self, forKey: .accountStatus)
        subscription  = try values.decodeIfPresent(String.self, forKey: .subscription)
        socialAccounts  = try values.decodeIfPresent([SocialAccModel].self, forKey: .socialAccounts)
    }
}
