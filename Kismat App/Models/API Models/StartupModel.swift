//
//  StartupModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 20/04/2023.
//

import Foundation

class StartupModel: NSObject, Codable {
    
    var subscription : String!
    var accountStatusId : Int!
    var isProfileVisible : Bool!
    var shadowMode : Bool!
    
    
    override init() {
        
        subscription = ""
        accountStatusId = 0
        isProfileVisible = false
        shadowMode = false
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case subscription = "subscription"
        case accountStatusId = "accountStatusId"
        case isProfileVisible = "isProfileVisible"
        case shadowMode = "shadowMode"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        subscription  = try values.decodeIfPresent(String.self, forKey: .subscription)
        accountStatusId  = try values.decodeIfPresent(Int.self, forKey: .accountStatusId)
        isProfileVisible  = try values.decodeIfPresent(Bool.self, forKey: .isProfileVisible)
        shadowMode  = try values.decodeIfPresent(Bool.self, forKey: .shadowMode)
    }
}
