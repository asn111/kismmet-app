//
//  GeneralResponse.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Tuesday15/12/2020.
//

import Foundation

class GeneralResponse : NSObject, Codable {
    var statusCode : Int!
    var status : String!
    var message : String!
    var errorMessage : String!
    var body : Body!
    
    override init() {
        statusCode = 0
        status = ""
        message = ""
        errorMessage = ""
        body = Body()
    }
    private enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case status = "status"
        case message = "message"
        case errorMessage = "errorMessage"
        case body = "body"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode  = try values.decodeIfPresent(Int.self, forKey: .statusCode)
        status  = try values.decodeIfPresent(String.self, forKey: .status)
        message  = try values.decodeIfPresent(String.self, forKey: .message)
        errorMessage  = try values.decodeIfPresent(String.self, forKey: .errorMessage)
        body  = try values.decodeIfPresent(Body.self, forKey: .body)
    }
}

class Body : NSObject, Codable {
    var token : String!

    override init() {
        token = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case token = "token"

    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token  = try values.decodeIfPresent(String.self, forKey: .token)

    }
}
