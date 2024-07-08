//
//  ContactsModel.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 05/07/2024.
//

import Foundation

class ContactsModel: NSObject, Codable {
    
    var id : Int!
    var contactTypeId : Int!
    var contactType : String!
    var isShared : Bool!
    var value : String!
    
    
    override init() {
        
        id = 0
        contactTypeId = 0
        contactType = ""
        isShared = false
        value = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case contactTypeId = "contactTypeId"
        case contactType = "contactType"
        case isShared = "isShared"
        case value = "value"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id  = try values.decodeIfPresent(Int.self, forKey: .id)
        contactTypeId  = try values.decodeIfPresent(Int.self, forKey: .contactTypeId)
        contactType  = try values.decodeIfPresent(String.self, forKey: .contactType)
        isShared  = try values.decodeIfPresent(Bool.self, forKey: .isShared)
        value  = try values.decodeIfPresent(String.self, forKey: .value)
    }
}
