//
//  APIService.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday05/06/2021.
//

import RxSwift
import Alamofire
import CoreData
import CoreLocation
import UIKit
import MaterialComponents.MaterialSnackbar

class APIService: NSObject {
    
    // MARK: - Properties
    var reachabilityManager = NetworkReachabilityManager()
    var baseUrl: String = ""

    // Singleton Instance
    static let singelton = APIService()
    
    // MARK: Initiate
    private override init() {
        super.init()
        
        baseUrl = "https://api.kismmet.com"
        Logs.show(message: "SERVER: \(baseUrl)")
        
        self.startMonitoring()
        Alamofire.Session.default.session.configuration.timeoutIntervalForRequest = 3000
    }
    
    // MARK: - Helper Functions
    func startMonitoring() {
        reachabilityManager?.startListening { status in
            switch status {
                case .notReachable :
                    print("not reachable")
                    generalPublisher.onNext("noInternet")
                case .reachable(.cellular) :
                    print("cellular")
                    generalPublisher.onNext("Internet")
                case .reachable(.ethernetOrWiFi) :
                    print("ethernetOrWiFi")
                    generalPublisher.onNext("Internet")
                default :
                    print("unknown")
                    generalPublisher.onNext("noInternet")
            }
        }
    }
    
    
    func isCheckReachable() -> Bool {
        return (reachabilityManager?.isReachable)!
    }
    
    private func getRequestHeader() -> HTTPHeaders {
        
        let token = AppFunctions.getToken()
        
        let headers: HTTPHeaders = ["Authorization":"Bearer "+token+"", "Content-Type" :"application/json"]
        Logs.show(message: "TOKEN: // \(headers)")
        return headers
    }
    
    
    func checkError(response: AFDataResponse<Any>) -> String {
        var errorMessage = "General error message"
        if let data = response.data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                if let error = json["error"]{
                    errorMessage = error
                }
                if let message = json["message"]{
                    errorMessage = message
                }
                print(json)
            }
        }
        return errorMessage
    }

    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    

    //MARK: GENERAL WEB CALLS
    
    
    func getImageData(imgStr: String) -> Observable<Data> {
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request( imgStr,method: .get).response { response in
                    
                    switch response.result {
                        case .success(let responseData):
                            observer.onNext(responseData!)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                            observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: POST CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////

    
    //MARK: Register Dev Token
    func registerDeviceToken(token: String) {
        if isCheckReachable() {
            let pram: Parameters = ["deviceTokenId": "\(token)"]
            print(pram)
            AF.request("\(self.baseUrl)/api/Notifications/RegDeviceToken", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            Logs.show(message: "SUCCESS IN RegDeviceToken")
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            }catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    //MARK: GET CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////

    //MARK: StartUp Call
    func startUpCall() -> Observable<StartupModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/StartUp", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN startUpCall")
                                    observer.onNext(genResponse.body.startUp)
                                    //DBService.createStartupDB(startup: genResponse.body.userPreferences)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(StartupModel())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get Genders
    func getGenders() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Configuration/GetGenders", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: USER SIDE CALLS

    
    //MARK: USER Login
    func userLogin(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Token", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: nil)
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    let jwtValue = try! AppFunctions.decode(jwtToken: genResponse.body.token)
                                    Logs.show(message: "TOKEN: \(genResponse.body.token ?? "")")
                                    Logs.show(message: "jwtValue: \(jwtValue)")
                                    let role = jwtValue["Role"]
                                    let userId = jwtValue["Id"]
                                    //let paymentInfo : String = jwtValue["IsPaymentInfoSaved"] as! String
                                    
                                    let isProfileUpdated : String = jwtValue["IsProfileUpdated"] as! String
                                    let isUserAgreement : String = jwtValue["IsUserAgreement"] as! String
                                    
                                    AppFunctions.saveToken(name: genResponse.body.token ?? "")
                                    AppFunctions.saveUserId(name: userId as! String)
                                    AppFunctions.saveRole(name: role as! String)
                                    AppFunctions.setIsLoggedIn(value: true)
                                    
                                    
                                    if isUserAgreement.contains("True") {
                                        AppFunctions.setIsTermsNCndCheck(value: true)
                                    }
                                    
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.errorMessage)
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                    
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: USER SignUp
    func userSignUp(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/CreateUser", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: nil)
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    let jwtValue = try! AppFunctions.decode(jwtToken: genResponse.body.token)
                                    Logs.show(message: "TOKEN: \(genResponse.body.token ?? "")")
                                    Logs.show(message: "jwtValue: \(jwtValue)")
                                    let role = jwtValue["Role"]
                                    let userId = jwtValue["Id"]
                                    //let paymentInfo : String = jwtValue["IsPaymentInfoSaved"] as! String
                                    
                                    let isProfileUpdated : String = jwtValue["IsProfileUpdated"] as! String
                                    let isUserAgreement : String = jwtValue["IsUserAgreement"] as! String
                                    
                                    AppFunctions.saveToken(name: genResponse.body.token ?? "")
                                    AppFunctions.saveUserId(name: userId as! String)
                                    AppFunctions.saveRole(name: role as! String)
                                    AppFunctions.setIsLoggedIn(value: true)

                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                    
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: USER profileUpadte
    func userProfileUpdate(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/UpdateUserProfile", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                    
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Change Password
    func changePassword(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/ChangePassword", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                    
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: USER Social Add
    func userSocialAdd(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/AddUserSocialAccount", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                    
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func updateSubscription(val: Int){
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["subscriptionId": val]
            
            AF.request("\(self.baseUrl)/api/Users/UpdateUserSubscription", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    func updateAccountStatus(val: Int) {
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["statusId": val]
            
            AF.request("\(self.baseUrl)/api/Users/UpdateUserAccountStatus", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    func deleteSocialLink(val: Int) {
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["linkId": val]
            
            AF.request("\(self.baseUrl)/api/Users/RemoveUserSocialAccount", method:.delete, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    
    func markStarUser(val: String){
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["userId": val]

            AF.request("\(self.baseUrl)/api/Users/StarUser", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    
    func markViewedUser(val: String){
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["userId": val]

            AF.request("\(self.baseUrl)/api/Users/UserProfileViewed", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    func markBlockUser(val: String){
        
        if (self.isCheckReachable()) {
            let pram: Parameters = ["userId": val]

            AF.request("\(self.baseUrl)/api/Users/BlockUser", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                //AppFunctions.showSnackBar(str: genResponse.message)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure( _):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                AppFunctions.showSnackBar(str: responce.message)
                            } catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    
    
       //MARK: GET CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////

    //MARK: Get Proximity Users
    func getproximityUsers(pram: Parameters) -> Observable<ProximityUsersModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/GetProximityUsers", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.proximityUsers)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(ProximityUsersModel())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get Starred Users
    func getStarredUsers(pram: Parameters) -> Observable<[UserModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/GetStarredUsers", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.users)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext([UserModel]())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get Blocked Users
    func getBlockUsers(pram: Parameters) -> Observable<[UserModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/GetBlockedUsers", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.users)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext([UserModel]())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get Viewed By Users
    func getViewedByUsers(pram: Parameters) -> Observable<[UserModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/WhoViewedMyProfile", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.profileViewer)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext([UserModel]())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: Get Viewed By Me
    func getViewedByMe(pram: Parameters) -> Observable<[UserModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/ProfilesViewed", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.profileViewer)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext([UserModel]())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    
    //MARK: Get User By ID
    func getUserById(userId: String, isOtherUser: Bool = false) -> Observable<UserModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request("\(self?.baseUrl ?? "")/api/Users/GetUserProfile?userId=\(userId)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    if !isOtherUser {
                                        DBService.createUserDB(APIlist: genResponse.body.user)
                                    }
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.user)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(UserModel())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get User By ID without callback
    func getUserProfile() {
        
            if (self.isCheckReachable()) {
                AF.request("\(self.baseUrl)/api/Users/GetUserProfile", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    DBService.createUserDB(APIlist: genResponse.body.user)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                } catch {
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(_):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
    }
    
    
    
    //MARK: Get User Social Accounts
    func getUserSocialAccounts() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Users/GetUserSocialAccounts", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    DBService.removeUserSocialAcc()
                                    DBService.createUserSocialAccDB(APIlist: genResponse.body.socialAccounts)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: Get Social Accounts List
    func getSocialAccounts() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Configuration/GetSocialLinkTypes", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    DBService.removeSocialAcc()
                                    DBService.createSocialAccDB(APIlist: genResponse.body.socialLinkTypes)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: Get Notif List
    func getNotif() -> Observable<[NotificationModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Notifications/GetUserNotifications", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    let notif = genResponse.body.userNotifications
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(notif!)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext([NotificationModel]())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    
    //MARK: POST CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    //MARK: Verify Email
    func sendEmailToVerify(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request("\(self?.baseUrl ?? "")/api/Users/ForgotPassword", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(isLogTrue: true, message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.errorMessage)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: Verify Code
    func codeVerificationNLogin(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request("\(self?.baseUrl ?? "")/api/Users/ValidateCode", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(isLogTrue: true, message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    let jwtValue = try! AppFunctions.decode(jwtToken: genResponse.body.token)
                                    Logs.show(message: "TOKEN: \(genResponse.body.token ?? "")")
                                    Logs.show(message: "jwtValue: \(jwtValue)")
                                    let role = jwtValue["Role"]
                                    let userId = jwtValue["Id"]
                                    //let paymentInfo : String = jwtValue["IsPaymentInfoSaved"] as! String
                                    
                                    let isProfileUpdated : String = jwtValue["IsProfileUpdated"] as! String
                                    let isUserAgreement : String = jwtValue["IsUserAgreement"] as! String
                                    
                                    AppFunctions.saveToken(name: genResponse.body.token ?? "")
                                    AppFunctions.saveUserId(name: userId as! String)
                                    AppFunctions.saveRole(name: role as! String)
                                    AppFunctions.setIsLoggedIn(value: true)
                                    
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.errorMessage)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    //MARK: ADD CARD
    
    func addCard(param: Parameters) -> Observable<Bool> {
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request("\(self?.baseUrl ?? "")/api/stripe/AddCard", method:.post, parameters: param, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN addCard")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func sendPayment(param: Parameters) -> Observable<Bool>  {
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                AF.request("\(self?.baseUrl ?? "")/api/stripe/ProcessStripePayment", method:.post, parameters: param, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN sendPayment")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                } catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    

    
    func getCardDetails() -> Observable<Bool> { //Observable<[CardInfo]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/stripe/GetPaymentCards", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN getCardDetails")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    Logs.show(message: "S:: \(responce.errorMessage ?? "")")
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
}

