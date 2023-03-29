//
//  Database.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday05/06/2021.
//


import Foundation
import RealmSwift
import RxSwift
import SwiftDate

class Database {
    
    static let singleton = Database()
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: create
    
    func createUserDB(APIlist: UserModel) {
        let realm = try! Realm()
        let userDB = UserDBModel()
        
        try! realm.write {
            if APIlist.userId != nil {userDB.userId = APIlist.userId}
            if APIlist.userName != nil {userDB.userName = APIlist.userName}
            if APIlist.email != nil {userDB.email = APIlist.email}
            if APIlist.publicEmail != nil {userDB.publicEmail = APIlist.publicEmail}
            if APIlist.countryCode != nil {userDB.countryCode = APIlist.countryCode}
            if APIlist.phone != nil {userDB.phone = APIlist.phone}
            if APIlist.dob != nil {userDB.dob = APIlist.dob}
            if APIlist.workAddress != nil {userDB.workAddress = APIlist.workAddress}
            if APIlist.workTitle != nil {userDB.workTitle = APIlist.workTitle}
            if APIlist.about != nil {userDB.about = APIlist.about}
            if APIlist.proximity != nil {userDB.proximity = APIlist.proximity}
            if APIlist.isProfileVisible != nil {userDB.isProfileVisible = APIlist.isProfileVisible}
            if APIlist.isProfileUpdated != nil {userDB.isProfileUpdated = APIlist.isProfileUpdated}
            if APIlist.isStarred != nil {userDB.isStarred = APIlist.isStarred}
            if APIlist.tags != nil {userDB.tags = APIlist.tags}
            if APIlist.isActive != nil {userDB.isActive = APIlist.isActive}
            
            realm.create(UserDBModel.self, value: userDB, update: .all)
        }
    }
    
    func createSocialAccDB(APIlist: [SocialAccModel]) {
        let realm = try! Realm()
        let socialDB = SocialAccDBModel()
        
        try! realm.write {
            for item in APIlist {
                if item.linkTitle != nil {socialDB.linkTitle = item.linkTitle}
                if item.linkUrl != nil {socialDB.linkUrl = item.linkUrl}
                if item.linkTypeId != nil {socialDB.linkTypeId = item.linkTypeId}
                if item.linkType != nil {socialDB.linkType = item.linkType}
                if item.socialAccountId != nil {socialDB.socialAccountId = item.socialAccountId}
                
                realm.create(SocialAccDBModel.self, value: socialDB, update: .all)
            }
        }
    }
    
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    // MARK: Fetch Records
    
    func fetchloggedInUser() -> Results<UserDBModel> {
        let realm = try! Realm()
        return realm.objects(UserDBModel.self).filter(NSPredicate(format: "userId = %@", "\(AppFunctions.getUserId())"))
    }
    
    func fetchSocialAccList() -> Results<SocialAccDBModel> {
        let realm = try! Realm()
        return realm.objects(SocialAccDBModel.self)
    }
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: update records
    
    
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: delete records
    
    func removeCompletedDB() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }

    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    func getImageData(imgStr: String) -> Data {
        var imgData = Data()
        APIService
            .singelton
            .getImageData(imgStr: imgStr)
            .subscribe({ model in
                switch model {
                    case .next(let val):
                        if !val.isEmpty {
                            Logs.show(message: "\(val)")
                            imgData = val
                        } else {
                            
                        }
                    case .error(let error):
                        print(error)
                    case .completed:
                        print("completed")
                }
            })
            .disposed(by: dispose_Bag)
        return imgData
    }
    
}

