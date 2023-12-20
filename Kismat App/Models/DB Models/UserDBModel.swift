//
//  UserDBModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 26/03/2023.
//

import Foundation
import RealmSwift

class UserDBModel: Object {
    
    @objc dynamic var userId : String = ""
    @objc dynamic var userName : String = ""
    @objc dynamic var profilePicture : String = ""
    @objc dynamic var email : String = ""
    @objc dynamic var publicEmail : String = ""
    @objc dynamic var countryCode : String = ""
    @objc dynamic var countryName : String = ""
    @objc dynamic var phone : String = ""
    @objc dynamic var dob : String = ""
    @objc dynamic var workAddress : String = ""
    @objc dynamic var workTitle : String = ""
    @objc dynamic var about : String = ""
    @objc dynamic var status : String = ""
    @objc dynamic var proximity : Int = 0
    @objc dynamic var isProfileVisible : Bool = false
    @objc dynamic var isProfileUpdated : Bool = false
    @objc dynamic var disappearingStatus : Bool = false
    @objc dynamic var isStarred : Bool = false
    @objc dynamic var tags : String = ""
    @objc dynamic var isActive : Bool = false
    @objc dynamic var shadowMode : Bool = false
    @objc dynamic var accountStatus : String = ""
    @objc dynamic var subscription : String = ""
    
    override class func primaryKey() -> String? {
        "userId"
    }
}
