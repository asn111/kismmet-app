//
//  AppFunctions.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Friday14/08/2020.
//  Copyright © 2020 SelfIt. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialSnackbar
import RxSwift
import CoreLocation
import MKToolTip

//MARK: Globel Variables

var dateNow : Date!

let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
var connectionStarted = false
let dispose_Bag = DisposeBag()

let userRoleID = 2
let motiveRoleID = 3
//"Role": MotiveBusiness

var dict : [String:Any] = [String:Any]()

var selectedStartDate = ""
var selectedEndDate = ""

let ApiService = APIService.singelton
let DBService = Database.singleton
//let SignalRService = SignalRManager.singelton


//MARK: rx Publishers

public let loading: PublishSubject<Bool> = PublishSubject()
let generalPublisher: PublishSubject<String> = PublishSubject()


///stripeTestKeys
var testPublishKey = ""
var testSecretKey = ""

//MARK: Pref Strings

let authToken = "authToken"
let isLogin = "isLogin"
let isTermsNCond = "isTermsNCond"
let isNumVerified = "isNumVerified"
let isEmailVerifyed = "isEmailVerifyed"
let userId = "userId"
let role = "role"
let devTokenString = "devTokenString"
let isPaymentSaved = "isPaymentSaved"
let isProfileUpdated = "isProfileUpdated"
let stripeKey = "stripeKey"

class Logs {
    
    open class func show(fileName:String = #file,
                          functionName: String = #function,
                          isLogTrue : Bool = false,
                          message: String) {
        let file = URL(fileURLWithPath: fileName).lastPathComponent
        if isLogTrue{
            NSLog("\n 🍏 👉🏻 \(file) - \(functionName) , Message: \(message)\n", 0)
        }
        #if DEBUG
        print("\n 🍏 👉🏻 \(file) - \(functionName) , Message: \(message)\n")
        #endif
    }
}


class AppFunctions {
    
    static let preferences = UserDefaults.standard
    
    //MARK: PREFS
    
    open class func saveToken( name: String){
        preferences.set(name, forKey: authToken)
        preferences.synchronize()
    }
    open class func getToken() -> String{
        var token = ""
        if preferences.object(forKey: authToken) == nil {
            Logs.show(message: "NIL getToken")
        } else {
            token = preferences.string(forKey: authToken)!
        }
        return token
    }
    
    open class func saveStripeKey( name: String){
        preferences.set(name, forKey: stripeKey)
        preferences.synchronize()
    }
    open class func getStripeKey() -> String{
        var token = ""
        if preferences.object(forKey: stripeKey) == nil {
            Logs.show(message: "NIL getStripeKey")
        } else {
            token = preferences.string(forKey: stripeKey)!
        }
        return token
    }
    
    open class func saveUserId( name: String){
        preferences.set(name, forKey: userId)
        preferences.synchronize()
    }
    open class func getUserId() -> String{
        var token = ""
        if preferences.object(forKey: userId) == nil {
            Logs.show(message: "NIL getUserId")
        } else {
            token = preferences.string(forKey: userId)!
        }
        return token
    }
    
    open class func saveRole( name: String){
        preferences.set(name, forKey: role)
        preferences.synchronize()
    }
    open class func getRole() -> String{
        var token = ""
        if preferences.object(forKey: role) == nil {
            Logs.show(message: "NIL getUserId")
        } else {
            token = preferences.string(forKey: role)!
        }
        return token
    }
    
    open class func setIsLoggedIn(value: Bool){
        preferences.set(value, forKey: isLogin)
        preferences.synchronize()
    }
    open class func isLoggedIn() -> Bool{
        var value = false
        if preferences.object(forKey: isLogin) == nil {
            Logs.show(message: "NIL isLoggedIn")
        } else {
            value = preferences.bool(forKey: isLogin)
        }
        return value
    }
    
    open class func setIsPaymentInfoSaved(value: Bool){
        preferences.set(value, forKey: isPaymentSaved)
        preferences.synchronize()
    }
    open class func isPaymentInfoSaved() -> Bool{
        var value = false
        if preferences.object(forKey: isPaymentSaved) == nil {
            Logs.show(message: "NIL isPaymentInfoSaved")
        } else {
            value = preferences.bool(forKey: isPaymentSaved)
        }
        return value
    }
    
    open class func setIsProfileUpdated(value: Bool){
        preferences.set(value, forKey: isProfileUpdated)
        preferences.synchronize()
    }
    open class func IsProfileUpdated() -> Bool{
        var value = false
        if preferences.object(forKey: isProfileUpdated) == nil {
            Logs.show(message: "NIL getIsProfileUpdated")
        } else {
            value = preferences.bool(forKey: isProfileUpdated)
        }
        return value
    }
    
    open class func setDevToken(value: String){
        preferences.set(value, forKey: devTokenString)
        preferences.synchronize()
    }
    open class func getDevToken() -> String{
        var token = ""
        if preferences.object(forKey: devTokenString) == nil {
            Logs.show(message: "NIL getDevToken")
        } else {
            token = preferences.string(forKey: devTokenString)!
        }
        return token
    }
    
    open class func setIsTermsNCndCheck(value: Bool){
        preferences.set(value, forKey: isTermsNCond)
        preferences.synchronize()
    }
    open class func isTermsNCndCheck() -> Bool{
        var value = false
        if preferences.object(forKey: isTermsNCond) == nil {
            Logs.show(message: "NIL isTermsNCndCheck")
        } else {
            value = preferences.bool(forKey: isTermsNCond)
        }
        return value
    }
    
    open class func setIsNumberVerified(value: Bool){
        preferences.set(value, forKey: isNumVerified)
        preferences.synchronize()
    }
    open class func isNumberVerified() -> Bool{
        var value = false
        if preferences.object(forKey: isNumVerified) == nil {
            Logs.show(message: "NIL isNumberVerified")
        } else {
            value = preferences.bool(forKey: isNumVerified)
        }
        return value
    }
    
    open class func setIsEmailVerified(value: Bool){
        preferences.set(value, forKey: isEmailVerifyed)
        preferences.synchronize()
    }
    open class func isEmailVerified() -> Bool{
        var value = false
        if preferences.object(forKey: isEmailVerifyed) == nil {
            Logs.show(message: "NIL isEmailVerified")
        } else {
            value = preferences.bool(forKey: isEmailVerifyed)
        }
        return value
    }
    
    //MARK: Remove all data
    
    open class func resetDefaults2() {
        if let bundleID = Bundle.main.bundleIdentifier {
            AppFunctions.preferences.removePersistentDomain(forName: bundleID)
        }
    }
    
    open class func removeFromDefaults(key: String) {
        preferences.removeObject(forKey: key)
    }
    
    open class func resetDefaults() {
        let dictionary = preferences.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key == devTokenString {
                
            } else {
                preferences.removeObject(forKey: key)
            }

        }
    }
    
    //MARK: JWT Token Decode
    open class func decode(jwtToken jwt: String) throws -> [String: Any] {
        
        enum DecodeErrors: Error {
            case badToken
            case other
        }
        
        func base64Decode(_ base64: String) throws -> Data {
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else {
                throw DecodeErrors.badToken
            }
            return decoded
        }
        
        func decodeJWTPart(_ value: String) throws -> [String: Any] {
            let bodyData = try base64Decode(value)
            let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
            guard let payload = json as? [String: Any] else {
                throw DecodeErrors.other
            }
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
    
    //MARK: Base 64 Image
    open class func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    open class func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
    //MARK: Show SnackBar
    open class func showSnackBar(str: String) {
        let message = MDCSnackbarMessage()
        message.text = str
        MDCSnackbarManager.default.show(message)
    }
    
    //MARK: Show ToolTip
    open class func showToolTip(str: String, btn: UIButton) {
        
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor(red: 0.937, green: 0.964, blue: 1.000, alpha: 1.000)
        preference.drawing.bubble.spacing = 10
        preference.drawing.bubble.cornerRadius = 5
        preference.drawing.bubble.inset = 15
        preference.drawing.bubble.border.color = UIColor(named: "Secondary Grey")
        preference.drawing.bubble.border.width = 1
        preference.drawing.arrow.tipCornerRadius = 5
        preference.drawing.message.color = UIColor(named: "Text grey") ?? UIColor.lightGray
        preference.drawing.message.font = UIFont(name: "Roboto", size: 12)!.bold
        btn.showToolTip(identifier: "", message: str, arrowPosition: .top, preferences: preference, delegate: nil)
    }
    
    
    //MARK: iPad Check
    open class func isIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else { return false }
    }
    
    //MARK: Others
    
    open class func colorPlaceholder(tf: UITextField, s: String) {
        tf.attributedPlaceholder =
        NSAttributedString(string: s, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Text grey") as Any, .font: UIFont(name: "Roboto", size: 14)?.regular as Any])
    }

    
    open class func calculateElapsedTime(startingPoint : Date, s:String, functionName: String) {
        //startingPointA = startingPoint
        
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        print(df.string(from: dateNow))
        let startingPointA = dateNow
        func stringFromTimeInterval(interval: TimeInterval) -> NSString {
            let ti = NSInteger(interval)
            let ms = Int((interval.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = (ti / 3600)
            return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        }
        
        Logs.show(message:  "TIME ELAPSED in \(functionName) \(s):  \(stringFromTimeInterval(interval: startingPointA!.timeIntervalSinceNow * -1))")
    }
    
    open class func logoutUser() {
        AppFunctions.resetDefaults()
        
        DBService.removeCompletedDB()
        
    }
}
