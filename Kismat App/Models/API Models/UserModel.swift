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
    
    var contactId : Int!
    var userId : String!
    var firstName : String!
    var lastName : String!
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
    var contactStatus : String!
    var proximity : Int!
    var isProfileVisible : Bool!
    var isProfileUpdated : Bool!
    var disappearingStatus : Bool!
    var isStarred : Bool!
    var tags : String!
    var isActive : Bool!
    var isRead : Bool!
    var shadowMode : Bool!
    var accountStatus : String!
    var message : String!
    var subscription : String!
    var socialAccounts : [SocialAccModel]!
    var contactInformationsSharedByUser : [ContactInformations]!
    var contactInformationsSharedByOther : [ContactInformations]!
    var contactInformationsShared : [ContactInformations]!
    var userContacts : UserContacts!


    override init() {
        
        contactId = 0
        userId = ""
        firstName = ""
        lastName = ""
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
        contactStatus = ""
        proximity = 0
        isProfileVisible = false
        isProfileUpdated = false
        disappearingStatus = false
        isStarred = false
        isRead = false
        tags = ""
        isActive = false
        shadowMode = false
        accountStatus = ""
        message = ""
        subscription = ""
        socialAccounts = [SocialAccModel]()
        contactInformationsSharedByUser = [ContactInformations]()
        contactInformationsSharedByOther = [ContactInformations]()
        contactInformationsShared = [ContactInformations]()
        userContacts = UserContacts()
        
    }
    
    init(fromDictionary dictionary: [String: Any]) {
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
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
        
        case contactId = "contactId"
        case userId = "userId"
        case firstName = "firstName"
        case lastName = "lastName"
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
        case contactStatus = "contactStatus"
        case proximity = "proximity"
        case isProfileVisible = "isProfileVisible"
        case isProfileUpdated = "isProfileUpdated"
        case disappearingStatus = "disappearingStatus"
        case isStarred = "isStarred"
        case isRead = "isRead"
        case tags = "tags"
        case isActive = "isActive"
        case shadowMode = "shadowMode"
        case accountStatus = "accountStatus"
        case message = "message"
        case subscription = "subscription"
        case socialAccounts = "socialAccounts"
        case userContacts = "userContacts"
        case contactInformationsSharedByUser = "contactInformationsSharedByUser"
        case contactInformationsSharedByOther = "contactInformationsSharedByOther"
        case contactInformationsShared = "contactInformationsShared"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        contactId  = try values.decodeIfPresent(Int.self, forKey: .contactId)
        userId  = try values.decodeIfPresent(String.self, forKey: .userId)
        firstName  = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName  = try values.decodeIfPresent(String.self, forKey: .lastName)
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
        contactStatus  = try values.decodeIfPresent(String.self, forKey: .contactStatus)
        disappearingStatus  = try values.decodeIfPresent(Bool.self, forKey: .disappearingStatus)
        proximity  = try values.decodeIfPresent(Int.self, forKey: .proximity)
        isProfileVisible  = try values.decodeIfPresent(Bool.self, forKey: .isProfileVisible)
        isProfileUpdated  = try values.decodeIfPresent(Bool.self, forKey: .isProfileUpdated)
        isStarred  = try values.decodeIfPresent(Bool.self, forKey: .isStarred)
        isRead  = try values.decodeIfPresent(Bool.self, forKey: .isRead)
        tags  = try values.decodeIfPresent(String.self, forKey: .tags)
        isActive  = try values.decodeIfPresent(Bool.self, forKey: .isActive)
        shadowMode  = try values.decodeIfPresent(Bool.self, forKey: .shadowMode)
        accountStatus  = try values.decodeIfPresent(String.self, forKey: .accountStatus)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        subscription  = try values.decodeIfPresent(String.self, forKey: .subscription)
        socialAccounts  = try values.decodeIfPresent([SocialAccModel].self, forKey: .socialAccounts)
        contactInformationsSharedByUser  = try values.decodeIfPresent([ContactInformations].self, forKey: .contactInformationsSharedByUser)
        contactInformationsSharedByOther  = try values.decodeIfPresent([ContactInformations].self, forKey: .contactInformationsSharedByOther)
        contactInformationsShared  = try values.decodeIfPresent([ContactInformations].self, forKey: .contactInformationsShared)
        userContacts = try values.decodeIfPresent(UserContacts.self, forKey: .userContacts)
    }
}

class UserContacts: NSObject, Codable {
    
    var id : Int!
    var contactStatusId : Int!
    var contactStatus : String!
    var message : String!
    var isSentByCurrentUsers : Bool!
    var isRead : Bool!
    var contactInformationsSharedByUser : [ContactInformations]!
    var contactInformationsSharedByOther : [ContactInformations]!

}

class ContactInformations: NSObject, Codable {
    
    var contactTypeId : Int!
    var contactType : String!
    var value : String!
}
