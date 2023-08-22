//
//  ReportReasons.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 22/08/2023.
//

import Foundation

class ReportReasonsModel: NSObject, Codable {
    
    var reasonId : Int!
    var reason : String!
    
    
    override init() {
        
        reasonId = 0
        reason = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case reasonId = "reasonId"
        case reason = "reason"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        reasonId  = try values.decodeIfPresent(Int.self, forKey: .reasonId)
        reason  = try values.decodeIfPresent(String.self, forKey: .reason)
    }
}
