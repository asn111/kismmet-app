//
//  SocialAccModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 26/03/2023.
//

import Foundation

class SocialAccModel: NSObject, Codable {
    
    var socialAccountId : Int!
    var linkTitle : String!
    var linkUrl : String!
    var linkTypeId : Int!
    var linkType : String!
    var linkImage : String!
    
    override init() {
        
        socialAccountId = 0
        linkTitle = ""
        linkUrl = ""
        linkTypeId = 0
        linkType = ""
        linkImage = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case socialAccountId = "socialAccountId"
        case linkTitle = "linkTitle"
        case linkUrl = "linkUrl"
        case linkTypeId = "linkTypeId"
        case linkType = "linkType"
        case linkImage = "linkImage"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        socialAccountId  = try values.decodeIfPresent(Int.self, forKey: .socialAccountId)
        linkTitle  = try values.decodeIfPresent(String.self, forKey: .linkTitle)
        linkUrl  = try values.decodeIfPresent(String.self, forKey: .linkUrl)
        linkTypeId  = try values.decodeIfPresent(Int.self, forKey: .linkTypeId)
        linkType  = try values.decodeIfPresent(String.self, forKey: .linkType)
        linkImage  = try values.decodeIfPresent(String.self, forKey: .linkImage)
    }
}
