//
//  StartupModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 20/04/2023.
//

import Foundation

class StartupModel: NSObject, Codable {
    
    var subscription : String!
    var subscriptionPlatform : String!
    var iosVersion : String!
    var accountStatusId : Int!
    var profileCountForSubscription : Int!
    var isEmailVarified : Bool!
    var isProfileVisible : Bool!
    var shadowMode : Bool!
    var isProfilePictureUpdated : Bool!
    var isIOSVersionMandatory : Bool!
    
    
    override init() {
        
        subscription = ""
        subscriptionPlatform = ""
        iosVersion = ""
        accountStatusId = 0
        profileCountForSubscription = 0
        isEmailVarified = false
        isProfileVisible = false
        shadowMode = false
        isProfilePictureUpdated = false
        isIOSVersionMandatory = false
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case subscription = "subscription"
        case subscriptionPlatform = "subscriptionPlatform"
        case iosVersion = "iosVersion"
        case accountStatusId = "accountStatusId"
        case profileCountForSubscription = "profileCountForSubscription"
        case isEmailVarified = "isEmailVerified"
        case isProfileVisible = "isProfileVisible"
        case shadowMode = "shadowMode"
        case isProfilePictureUpdated = "isProfilePictureUpdated"
        case isIOSVersionMandatory = "isIOSVersionMandatory"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        subscription  = try values.decodeIfPresent(String.self, forKey: .subscription)
        subscriptionPlatform  = try values.decodeIfPresent(String.self, forKey: .subscriptionPlatform)
        iosVersion  = try values.decodeIfPresent(String.self, forKey: .iosVersion)
        accountStatusId  = try values.decodeIfPresent(Int.self, forKey: .accountStatusId)
        profileCountForSubscription  = try values.decodeIfPresent(Int.self, forKey: .profileCountForSubscription)
        isEmailVarified  = try values.decodeIfPresent(Bool.self, forKey: .isEmailVarified)
        isProfileVisible  = try values.decodeIfPresent(Bool.self, forKey: .isProfileVisible)
        shadowMode  = try values.decodeIfPresent(Bool.self, forKey: .shadowMode)
        isProfilePictureUpdated  = try values.decodeIfPresent(Bool.self, forKey: .isProfilePictureUpdated)
        isIOSVersionMandatory  = try values.decodeIfPresent(Bool.self, forKey: .isIOSVersionMandatory)
    }
}
