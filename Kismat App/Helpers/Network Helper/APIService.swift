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
        
        baseUrl = "https://dev-api-motiveapp.azurewebsites.net"
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
            AF.request("\(self.baseUrl)/api/Notification/RegDeviceToken", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self.getRequestHeader())
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
    func startUpCall() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/User/StartUp", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
                                    observer.onNext(true)
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
    
    
    //MARK: Get Cities
    func getCities() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Configuration/GetCities", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
    
    
    //MARK: Get Provinces
    func getProvinces() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/Configuration/GetProvinces", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
                                    let isPhoneVerifyed : String = jwtValue["IsPhoneVerified"] as! String
                                    let isEmailVerifyed : String = jwtValue["IsEmailVerified"] as! String
                                    
                                    AppFunctions.saveToken(name: genResponse.body.token ?? "")
                                    AppFunctions.saveUserId(name: userId as! String)
                                    AppFunctions.saveRole(name: role as! String)
                                    AppFunctions.setIsLoggedIn(value: true)
                                    
//                                    if paymentInfo.contains("True") {
//                                        AppFunctions.setIsPaymentInfoSaved(value: true)
//                                    }
                                    if isProfileUpdated.contains("True") {
                                        AppFunctions.setIsProfileUpdated(value: true)
                                    }
                                    if isUserAgreement.contains("True") {
                                        AppFunctions.setIsTermsNCndCheck(value: true)
                                    }
                                    if isPhoneVerifyed.contains("True") {
                                        AppFunctions.setIsNumberVerified(value: true)
                                    }
                                    if isEmailVerifyed.contains("True") {
                                        AppFunctions.setIsEmailVerified(value: true)
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
                
                AF.request("\(self?.baseUrl ?? "")/api/User/CreateUser", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: nil)
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
    
    
    //MARK: USER profileUpadte
    func userProfileUpdate(pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/MotiveUser/UpdateMotiveUserProfile", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
    
    
    
       //MARK: GET CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////


    //MARK: Get User By ID
    func getUserById(userId: String) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                //?userId=\(userId)
                AF.request("\(self?.baseUrl ?? "")/api/MotiveUser/GetMotiveUserById", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
                                    //DBService.createUserDB(APIlist: genResponse.body.motiveUser)
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
    
    
    //MARK: Get Locations
    func getLocations() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                AF.request("\(self?.baseUrl ?? "")/api/MotiveBusiness/GetLocations", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
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
                                    //DBService.createMotiveLocationDB(APIlist: genResponse.body.locations, userId: AppFunctions.getUserId())
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
    
    
    //MARK: POST CALLS
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: Verify Code & Login && Social Login User
    func codeVerificationNLogin(pram: Parameters, isFromSocial: Bool) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                let url = ""
                AF.request("\(self?.baseUrl ?? "")\(url)", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: isFromSocial ? self?.getRequestHeader() : nil)
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
                                if !isFromSocial {
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
                                        let isPhoneVerifyed : String = jwtValue["IsPhoneVerified"] as! String
                                        let isEmailVerifyed : String = jwtValue["IsEmailVerified"] as! String
                                        
                                        AppFunctions.saveToken(name: genResponse.body.token ?? "")
                                        AppFunctions.saveUserId(name: userId as! String)
                                        AppFunctions.saveRole(name: role as! String)
                                        AppFunctions.setIsLoggedIn(value: true)
                                        
                                        //                                        if paymentInfo.contains("True") {
                                        //                                            AppFunctions.setIsPaymentInfoSaved(value: true)
                                        //                                        }
                                        if isProfileUpdated.contains("True") {
                                            AppFunctions.setIsProfileUpdated(value: true)
                                        }
                                        if isUserAgreement.contains("True") {
                                            AppFunctions.setIsTermsNCndCheck(value: true)
                                        }
                                        if isPhoneVerifyed.contains("True") {
                                            AppFunctions.setIsNumberVerified(value: true)
                                        }
                                        if isEmailVerifyed.contains("True") {
                                            AppFunctions.setIsEmailVerified(value: true)
                                        }
                                        if (AppFunctions.getDevToken() != "") {
                                            self!.registerDeviceToken(token: AppFunctions.getDevToken())
                                        }
                                        
                                        observer.onNext(true)
                                        observer.onCompleted()
                                    } catch {
                                        observer.onError(error)
                                        AppFunctions.showSnackBar(str: "Server Parsing Error")
                                        Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    }
                                } else {
                                    observer.onNext(true)
                                    observer.onCompleted()
                                }
                                
                                Logs.show(message: "SUCCESS IN codeVerificationNLogin")
                                
                            case .failure( _):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onNext(false)
                                    Logs.show(isLogTrue: true, message: "S:: \(responce.errorMessage ?? "")")
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

