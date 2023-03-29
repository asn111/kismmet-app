//
//  SocialAccType.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 26/03/2023.
//

import Foundation

class SocialAccTypeModel: NSObject, Codable {
    
    var socialLinkTypeId : String!
    var linkType : String!
    
    
    override init() {
        
        socialLinkTypeId = ""
        linkType = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case socialLinkTypeId = "socialLinkTypeId"
        case linkType = "linkType"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        socialLinkTypeId  = try values.decodeIfPresent(String.self, forKey: .socialLinkTypeId)
        linkType  = try values.decodeIfPresent(String.self, forKey: .linkType)
    }
}
