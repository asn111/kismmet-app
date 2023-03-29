//
//  SocialAccDBModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 27/03/2023.
//

import Foundation
import RealmSwift

class SocialAccDBModel: Object {
    
    @objc dynamic var socialAccountId : Int = 0
    @objc dynamic var linkTitle : String = ""
    @objc dynamic var linkUrl : String = ""
    @objc dynamic var linkTypeId : Int = 0
    @objc dynamic var linkType : String = ""
    
    override class func primaryKey() -> String? {
        "socialAccountId"
    }
}
