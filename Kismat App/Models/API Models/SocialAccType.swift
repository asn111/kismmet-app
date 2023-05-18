//
//  SocialAccType.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 26/03/2023.
//

import Foundation

class SocialAccTypeModel: NSObject, Codable {
    
    var socialLinkTypeId : Int!
    var linkType : String!
    var linkImage : String!
    
    
    override init() {
        
        socialLinkTypeId = 0
        linkType = ""
        linkImage = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case socialLinkTypeId = "socialLinkTypeId"
        case linkType = "linkType"
        case linkImage = "linkImage"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        socialLinkTypeId  = try values.decodeIfPresent(Int.self, forKey: .socialLinkTypeId)
        linkType  = try values.decodeIfPresent(String.self, forKey: .linkType)
        linkImage  = try values.decodeIfPresent(String.self, forKey: .linkImage)
    }
}
