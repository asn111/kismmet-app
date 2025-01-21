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
            if APIlist.firstName != nil {userDB.firstName = APIlist.firstName}
            if APIlist.lastName != nil {userDB.lastName = APIlist.lastName}
            if APIlist.profilePicture != nil {userDB.profilePicture = APIlist.profilePicture}
            if APIlist.email != nil {userDB.email = APIlist.email}
            if APIlist.publicEmail != nil {userDB.publicEmail = APIlist.publicEmail}
            if APIlist.countryCode != nil {userDB.countryCode = APIlist.countryCode}
            if APIlist.countryName != nil {userDB.countryName = APIlist.countryName}
            if APIlist.phone != nil {userDB.phone = APIlist.phone}
            if APIlist.dob != nil {userDB.dob = APIlist.dob}
            if APIlist.workAddress != nil {userDB.workAddress = APIlist.workAddress}
            if APIlist.workTitle != nil {userDB.workTitle = APIlist.workTitle}
            if APIlist.about != nil {userDB.about = APIlist.about}
            if APIlist.status != nil {userDB.status = APIlist.status}
            if APIlist.disappearingStatus != nil {userDB.disappearingStatus = APIlist.disappearingStatus}
            if APIlist.proximity != nil {userDB.proximity = APIlist.proximity}
            if APIlist.isStarred != nil {userDB.isStarred = APIlist.isStarred}
            if APIlist.tags != nil {userDB.tags = APIlist.tags}
            if APIlist.isActive != nil {userDB.isActive = APIlist.isActive}
            if APIlist.accountStatus != nil {userDB.isActive = APIlist.isActive}
            
            if APIlist.subscription != nil {
                userDB.subscription = APIlist.subscription
                if APIlist.subscription == "Premium Plan" {
                    AppFunctions.setIsPremiumUser(value: true)
                } else {
                    AppFunctions.setIsPremiumUser(value: false)
                }
            } else {
                AppFunctions.setIsPremiumUser(value: false)
            }
            if APIlist.shadowMode != nil {
                userDB.shadowMode = APIlist.shadowMode
                AppFunctions.setIsShadowMode(value: APIlist.shadowMode)
            } else {
                AppFunctions.setIsShadowMode(value: false)
            }
            
            if APIlist.isProfileVisible != nil {
                userDB.isProfileVisible = APIlist.isProfileVisible
                AppFunctions.setIsProfileVisble(value: APIlist.isProfileVisible)
            } else {
                AppFunctions.setIsProfileVisble(value: false)
            }
            
            if APIlist.isProfileUpdated != nil {
                userDB.isProfileUpdated = APIlist.isProfileUpdated
                AppFunctions.setIsProfileUpdated(value: APIlist.isProfileUpdated)
            } else {
                AppFunctions.setIsProfileUpdated(value: false)
            }
            
            realm.create(UserDBModel.self, value: userDB, update: .all)
        }
    }
    
    func createUserSocialAccDB(APIlist: [SocialAccModel]) {
        let realm = try! Realm()
        let socialDB = UserSocialAccDBModel()
        
        try! realm.write {
            for item in APIlist {
                if item.linkTitle != nil {socialDB.linkTitle = item.linkTitle}
                if item.linkUrl != nil {socialDB.linkUrl = item.linkUrl}
                if item.linkTypeId != nil {socialDB.linkTypeId = item.linkTypeId}
                if item.linkType != nil {socialDB.linkType = item.linkType}
                if item.socialAccountId != nil {socialDB.socialAccountId = item.socialAccountId}
                if item.linkImage != nil {socialDB.linkImage = item.linkImage}
                
                realm.create(UserSocialAccDBModel.self, value: socialDB, update: .all)
            }
        }
    }
    
    func createSocialAccDB(APIlist: [SocialAccTypeModel]) {
        let realm = try! Realm()
        let socialDB = SocialAccDBModel()
        
        try! realm.write {
            for item in APIlist {
                if item.socialLinkTypeId != nil {socialDB.linkTypeId = item.socialLinkTypeId}
                if item.linkType != nil {socialDB.linkType = item.linkType}
                if item.linkImage != nil {socialDB.linkImage = item.linkImage}
                
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
    
    func fetchUserSocialAccList() -> Results<UserSocialAccDBModel> {
        let realm = try! Realm()
        return realm.objects(UserSocialAccDBModel.self)
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
    
    
    
    func removeUserSocialAcc(){
        let realm = try! Realm()
        try! realm.write {
            let socialAcc = realm.objects(UserSocialAccDBModel.self)
            if socialAcc.count > 0 {
                realm.delete(socialAcc)
                Logs.show(message: "DELETED socialAcc")
            }
        }
    }
    
    func removeSocialAcc(){
        let realm = try! Realm()
        try! realm.write {
            let socialAcc = realm.objects(SocialAccDBModel.self)
            if socialAcc.count > 0 {
                realm.delete(socialAcc)
                Logs.show(message: "DELETED socialAcc")
            }
        }
    }
    
    
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

