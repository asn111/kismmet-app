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
    var profilePicture : String!
    var email : String!
    var publicEmail : String!
    var countryCode : String!
    var countryName : String!
    var phone : String!
    var dob : String!
    var workAddress : String!
    var workTitle : String!
    var about : String!
    var status : String!
    var proximity : Int!
    var isProfileVisible : Bool!
    var isProfileUpdated : Bool!
    var disappearingStatus : Bool!
    var isStarred : Bool!
    var tags : String!
    var isActive : Bool!
    var shadowMode : Bool!
    var accountStatus : String!
    var subscription : String!
    var socialAccounts : [SocialAccModel]!
    var userContacts : UserContacts!


    override init() {
        
        userId = ""
        userName = ""
        profilePicture = ""
        email = ""
        publicEmail = ""
        countryCode = ""
        countryName = ""
        phone = ""
        dob = ""
        workAddress = ""
        workTitle = ""
        about = ""
        status = ""
        proximity = 0
        isProfileVisible = false
        isProfileUpdated = false
        disappearingStatus = false
        isStarred = false
        tags = ""
        isActive = false
        shadowMode = false
        accountStatus = ""
        subscription = ""
        socialAccounts = [SocialAccModel]()
        userContacts = UserContacts()
        
    }
    
    init(fromDictionary dictionary: [String: Any]) {
        userName = dictionary["fullName"] as? String
        profilePicture = dictionary["profilePicture"] as? String
        publicEmail = dictionary["publicEmail"] as? String
        workAddress = dictionary["workAdress"] as? String
        workTitle = dictionary["workTitle"] as? String
        about = dictionary["about"] as? String
        status = dictionary["status"] as? String
        disappearingStatus = dictionary["disappearingStatus"] as? Bool
        tags = dictionary["tags"] as? String
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case userId = "userId"
        case userName = "userName"
        case profilePicture = "profilePicture"
        case email = "email"
        case publicEmail = "publicEmail"
        case countryCode = "countryCode"
        case countryName = "countryName"
        case phone = "phone"
        case dob = "dob"
        case workAddress = "workAddress"
        case workTitle = "workTitle"
        case about = "about"
        case status = "status"
        case proximity = "proximity"
        case isProfileVisible = "isProfileVisible"
        case isProfileUpdated = "isProfileUpdated"
        case disappearingStatus = "disappearingStatus"
        case isStarred = "isStarred"
        case tags = "tags"
        case isActive = "isActive"
        case shadowMode = "shadowMode"
        case accountStatus = "accountStatus"
        case subscription = "subscription"
        case socialAccounts = "socialAccounts"
        case userContacts = "userContacts"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        userId  = try values.decodeIfPresent(String.self, forKey: .userId)
        userName  = try values.decodeIfPresent(String.self, forKey: .userName)
        profilePicture  = try values.decodeIfPresent(String.self, forKey: .profilePicture)
        email  = try values.decodeIfPresent(String.self, forKey: .email)
        publicEmail  = try values.decodeIfPresent(String.self, forKey: .publicEmail)
        countryCode  = try values.decodeIfPresent(String.self, forKey: .countryCode)
        countryName  = try values.decodeIfPresent(String.self, forKey: .countryName)
        phone  = try values.decodeIfPresent(String.self, forKey: .phone)
        dob  = try values.decodeIfPresent(String.self, forKey: .dob)
        workAddress  = try values.decodeIfPresent(String.self, forKey: .workAddress)
        workTitle  = try values.decodeIfPresent(String.self, forKey: .workTitle)
        about  = try values.decodeIfPresent(String.self, forKey: .about)
        status  = try values.decodeIfPresent(String.self, forKey: .status)
        disappearingStatus  = try values.decodeIfPresent(Bool.self, forKey: .disappearingStatus)
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
        userContacts = try values.decodeIfPresent(UserContacts.self, forKey: .userContacts)
    }
}

class UserContacts: NSObject, Codable {
    
    var contactStatusId : Int!
    var contactStatus : String!
}
