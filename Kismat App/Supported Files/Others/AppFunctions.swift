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
import StoreKit
import SafariServices
import CountryPickerView

//MARK: Globel Variables

var dateNow : Date!

let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
var connectionStarted = false
let dispose_Bag = DisposeBag()

let userRoleID = 1
let adminRoleID = 2

let freeSubscriptionId = 1
let premiumSubscriptionId = 2

let activeAccountStatusId = 1
let deactivedAccountStatusId = 2
let deletedAccountStatusId = 3


var initalLatitude = 0.0
var initalLongitude = 0.0


var dict : [String:Any] = [String:Any]()

var selectedStartDate = ""
var selectedEndDate = ""

let ApiService = APIService.singelton
let DBService = Database.singleton
//let SignalRManager.singelton = SignalRManager.singelton.singelton

var isFromProfile = false

//GOOGLE CLIENT ID 464505001033-pk77rgck0i7702u259nmv6n18sp8l331.apps.googleusercontent.com
let googleMapAPIKey = "AIzaSyDoOfDrlLrIeWHeM2hBJEETh9ErGgKnoTQ"


//let baseUrl = ""

func RGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

//MARK: rx Publishers

public let loading: PublishSubject<Bool> = PublishSubject()
let generalPublisher: PublishSubject<String> = PublishSubject()
let generalPublisherLoc: PublishSubject<CLLocation> = PublishSubject()
let generalPublisherCountry: PublishSubject<Country> = PublishSubject()
let generalPublisherChat: PublishSubject<ChatModel> = PublishSubject()
let productPublisher: PublishSubject<[String: SKProduct]> = PublishSubject()


///stripeTestKeys
var testPublishKey = ""
var testSecretKey = ""


//MARK: Pref Strings

let authToken = "authToken"
let userEmail = "userEmail"
let isLogin = "isLogin"
let isFirstDownload = "isFirstDownload"
let notifEnable = "notifEnable"
let isTermsNCond = "isTermsNCond"
let isNumVerified = "isNumVerified"
let isEmailVerifyed = "isEmailVerifyed"
let isShadowMode = "isShadowMode"
let profileVisble = "profileVisble"
let premiumUser = "premiumUser"
let userId = "userId"
let viewedCount = "viewedCount"
let profViewCount = "profViewCount"
let role = "role"
let devTokenString = "devTokenString"
let isPaymentSaved = "isPaymentSaved"
let isProfileUpdated = "isProfileUpdated"
let stripeKey = "stripeKey"
let tagsArray = "tagsArray"
let selectedCheck = "selectedCheck"
let socialArray = "socialArray"
let notif = "notif"
let platForm = "platForm"

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
    
    open class func saveEmail( name: String){
        preferences.set(name, forKey: userEmail)
        preferences.synchronize()
    }
    open class func getEmail() -> String{
        var token = ""
        if preferences.object(forKey: userEmail) == nil {
            Logs.show(message: "NIL getEmail")
        } else {
            token = preferences.string(forKey: userEmail)!
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
    
    open class func saveviewedCount( count: Int){
        preferences.set(count, forKey: viewedCount)
        preferences.synchronize()
    }
    open class func getviewedCount() -> Int{
        var count = 0
        if preferences.object(forKey: viewedCount) == nil {
            Logs.show(message: "NIL getviewedCount")
        } else {
            count = preferences.integer(forKey: viewedCount)
        }
        return count
    }
    
    open class func saveMaxProfViewedCount( count: Int){
        preferences.set(count, forKey: profViewCount)
        preferences.synchronize()
    }
    open class func getMaxProfViewedCount() -> Int{
        var count = 0
        if preferences.object(forKey: profViewCount) == nil {
            Logs.show(message: "NIL getMaxProfViewedCount")
        } else {
            count = preferences.integer(forKey: profViewCount)
        }
        return count
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
    
    open class func savePlatForm( name: String){
        preferences.set(name, forKey: platForm)
        preferences.synchronize()
    }
    open class func getplatForm() -> String{
        var token = ""
        if preferences.object(forKey: platForm) == nil {
            Logs.show(message: "NIL getplatForm")
        } else {
            token = preferences.string(forKey: platForm)!
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
    
    open class func setNotifEnable(value: Bool){
        preferences.set(value, forKey: notifEnable)
        preferences.synchronize()
    }
    open class func isNotifEnable() -> Bool{
        var value = true
        if preferences.object(forKey: notifEnable) == nil {
            Logs.show(message: "NIL isNotifEnable")
        } else {
            value = preferences.bool(forKey: notifEnable)
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
    
    open class func setIsNotifCheck(value: Bool){
        preferences.set(value, forKey: notif)
        preferences.synchronize()
    }
    open class func isNotifNotCheck() -> Bool{
        var value = false
        if preferences.object(forKey: notif) == nil {
            Logs.show(message: "NIL isNotifCheckCheck")
        } else {
            value = preferences.bool(forKey: notif)
        }
        return value
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
    
    open class func setIsShadowMode(value: Bool){
        preferences.set(value, forKey: isShadowMode)
        preferences.synchronize()
    }
    open class func isShadowModeOn() -> Bool{
        var value = false
        if preferences.object(forKey: isShadowMode) == nil {
            Logs.show(message: "NIL isShadowMode")
        } else {
            value = preferences.bool(forKey: isShadowMode)
        }
        return value
    }
    
    open class func setIsProfileVisble(value: Bool){
        preferences.set(value, forKey: profileVisble)
        preferences.synchronize()
    }
    open class func isProfileVisble() -> Bool{
        var value = false
        if preferences.object(forKey: profileVisble) == nil {
            Logs.show(message: "NIL isProfileVisble")
        } else {
            value = preferences.bool(forKey: profileVisble)
        }
        return value
    }
    
    open class func setTagsArray(value: [String]){
        preferences.set(value, forKey: tagsArray)
        preferences.synchronize()
    }
    open class func getTagsArray() -> [String]{
        var value = [String]()
        if preferences.object(forKey: tagsArray) == nil {
            Logs.show(message: "NIL getTagsArray")
        } else {
            value = (preferences.array(forKey: tagsArray) as? [String])!
        }
        return value
    }
    
    open class func setSocialArray(value: [String]){
        preferences.set(value, forKey: socialArray)
        preferences.synchronize()
    }
    open class func getSocialArray() -> [String]{
        var value = [String]()
        if preferences.object(forKey: socialArray) == nil {
            Logs.show(message: "NIL getSocialArray")
        } else {
            value = (preferences.array(forKey: socialArray) as? [String])!
        }
        return value
    }
    
    open class func setIsPremiumUser(value: Bool){
        preferences.set(value, forKey: premiumUser)
        preferences.synchronize()
    }
    open class func isPremiumUser() -> Bool{
        var value = false
        if preferences.object(forKey: premiumUser) == nil {
            Logs.show(message: "NIL isPremiumUser")
        } else {
            value = preferences.bool(forKey: premiumUser)
        }
        return value
    }
    
    open class func setSelectedCheckValue(value: Int) {
        // Fetch the existing array from UserDefaults
        var selectedChecks = getSelectedCheckArray()
        
        // Check if the value already exists in the array
        if let index = selectedChecks.firstIndex(of: value) {
            // If the value exists, remove it from the array
            selectedChecks.remove(at: index)
        } else {
            // If the value does not exist, append it to the array
            selectedChecks.append(value)
        }
        
        // Save the updated array back to UserDefaults
        preferences.set(selectedChecks, forKey: selectedCheck)
        preferences.synchronize()
    }
    
    open class func setSelectedCheckArrValues(values: [Int]) {
        // Fetch the existing array from UserDefaults
        var selectedChecks = getSelectedCheckArray()
        
        // Remove all existing values
        selectedChecks.removeAll()
        
        // Add the new values to the array
        selectedChecks.append(contentsOf: values)
        
        // Save the updated array back to UserDefaults
        preferences.set(selectedChecks, forKey: "selectedCheck")
        preferences.synchronize()
    }

    open class func getSelectedCheckArray() -> [Int]{
        var value = [Int]()
        if preferences.object(forKey: selectedCheck) == nil {
            Logs.show(message: "NIL getSelectedCheckArray")
        } else {
            value = (preferences.array(forKey: selectedCheck) as? [Int])!
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
    
    //MARK: Open app functions
    
    open class func openLinkIfValid(_ urlString: String) {
        // Check if the string is a valid URL
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            AppFunctions.showSnackBar(str: "Invalid link provided")
            return
        }
        
        // Open the URL in the default web browser
        UIApplication.shared.open(url)
    }
    
    open class func openSnapchat(userName: String) {
        
        let application = UIApplication.shared
        
        if let appURL = NSURL(string: "snapchat://add/\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL =  NSURL(string: "https://www.snapchat.com/add/\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
        
        
    }
    
    open class func openTwitter(userName: String) {
        
        let application = UIApplication.shared
        
        if let appURL = NSURL(string: "twitter://user?screen_name=\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL =  NSURL(string: "https://twitter.com/\(userName)") {
                    application.open(webURL as URL)
                } else {
                    showSnackBar(str: "Invalid link provided")
                }
            }
        } else { showSnackBar(str: "Invalid link provided") }
        
        

    }
    
    open class func openFacebook(userName: String) {
        
        let application = UIApplication.shared
        
        if let appURL = NSURL(string: "fb://profile/\(userName)") {
            if(UIApplication.shared.canOpenURL(appURL as URL)){
                // FB installed
                application.open(appURL as URL)
            } else {
                if let webURL =  NSURL(string: "https://www.facebook.com/\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
        
        
    }
    
    open class func openRedditProfile(userName: String) {
        let application = UIApplication.shared
        
        if let webURL = URL(string: "https://www.reddit.com/user/\(userName)") {
            if application.canOpenURL(webURL) {
                application.open(webURL)
            } else {
                // Reddit app is not installed, open in Safari or default browser
                application.open(URL(string: "https://www.reddit.com/user/\(userName)")!)
            }
        } else {
            // Invalid link provided
            showSnackBar(str: "Invalid link provided")
        }
    }

    
    open class func openLinkedIn(userName: String) {
        
        let application = UIApplication.shared
        
        if let appURL = NSURL(string: "linkedin://profile/\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL =  NSURL(string: "https://www.linkedin.com/in/\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
        
    }
    
    open class func openInstagram(userName: String) {

        let application = UIApplication.shared
        
        if let appURL = NSURL(string: "instagram://user?username=\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL =  NSURL(string: "https://instagram.com/\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
        
       
    }
    
    open class func openTikTok(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "tiktok://user/profile/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.tiktok.com/@\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openYouTube(channelName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "youtube://\(channelName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.youtube.com/user/\(channelName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openTwitch(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "twitch://user/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.twitch.tv/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openKickstarter(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "kickstarter://user/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.kickstarter.com/profile/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openVenmo(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "venmo://users/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://venmo.com/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openShopify(storeName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "shopify://store/\(storeName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://\(storeName).myshopify.com") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openDiscord(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "discord://user/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://discord.com/users/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openPaypal(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "paypal://send?recipient=\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.paypal.me/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openTumblr(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "tumblr://x-callback-url/blog?blogName=\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://\(userName).tumblr.com") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openSoundCloud(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "soundcloud://users/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://soundcloud.com/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openQuora(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "quora://profile/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.quora.com/profile/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openSpotify(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "spotify://user/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://open.spotify.com/user/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openPinterest(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "pinterest://user/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.pinterest.com/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openWeChat(userName: String) {
        let application = UIApplication.shared
        if let appURL = URL(string: "weixin://contacts/profile/\(userName)") {
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                if let webURL = URL(string: "https://www.wechat.com/\(userName)") {
                    application.open(webURL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openWebLink(link: String, vc: UIViewController) {
        
        if let privacyPolicyURL = URL(string: link) {
            if link.contains("http") {
                let safariVC = SFSafariViewController(url: privacyPolicyURL)
                vc.present(safariVC, animated: true)
            } else { showSnackBar(str: "Invalid link provided") }
        } else { showSnackBar(str: "Invalid link provided") }

    }
    
    open class func openPatreon(userName: String) {
        let application = UIApplication.shared
        if let appURL = NSURL(string: "patreon://user?userName=\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL = NSURL(string: "https://www.patreon.com/\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openCashApp(userName: String) {
        let application = UIApplication.shared
        if let appURL = NSURL(string: "cashapp://$\(userName)") {
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                if let webURL = NSURL(string: "https://cash.app/$\(userName)") {
                    application.open(webURL as URL)
                } else { showSnackBar(str: "Invalid link provided") }
            }
        } else { showSnackBar(str: "Invalid link provided") }
    }
    
    open class func openWhatsApp(phoneNumber: String) {
        guard let url = URL(string: "whatsapp://send?phone=\(phoneNumber)") else {
            showSnackBar(str: "Invalid phone number")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to WhatsApp website if app isn't installed
            let webURL = URL(string: "https://wa.me/\(phoneNumber)")
            UIApplication.shared.open(webURL!)
        }
    }
    
    open class func openiMessage(phoneNumber: String) {
        guard let url = URL(string: "sms:\(phoneNumber)") else {
            showSnackBar(str: "Invalid phone number")
            return
        }
        
        UIApplication.shared.open(url)
    }

    open class func initiateCall(phoneNumber: String) {
        guard let url = URL(string: "tel:\(phoneNumber)") else {
            showSnackBar(str: "Invalid phone number")
            return
        }
        
        UIApplication.shared.open(url)
    }

    
    //MARK: Show ToolTip
    open class func showToolTip(str: String, btn: UIButton, arrowPos: String = "top") {
        
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
        if arrowPos == "top" {
            btn.showToolTip(identifier: "", message: str, arrowPosition: .top, preferences: preference, delegate: nil)
        } else {
            btn.showToolTip(identifier: "", message: str, arrowPosition: .right, preferences: preference, delegate: nil)
        }
    }
    
    
    //MARK: iPad Check
    open class func isIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else { return false }
    }
    
    //MARK: Others
    
    open class func baseUrl() -> String {
        if AppFunctions.getCurrentTarget().contains("Dev") {
            return "http://54.226.245.172"
        } else {
            return "https://api.kismmet.com"
        }
    }
    
    open class func colorPlaceholder(tf: UITextField, s: String) {
        let attributedString = NSMutableAttributedString(string: s)
        
        // Apply default attributes for the placeholder text
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "Text grey") as Any,
            .font: UIFont(name: "Roboto", size: 14)?.light as Any
        ]
        attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: s.count))
        
        // Find and color the asterisks in red
        let redAsteriskAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red
        ]
        for (index, character) in s.enumerated() {
            if character == "*" {
                attributedString.addAttributes(redAsteriskAttributes, range: NSRange(location: index, length: 1))
            }
        }
        
        tf.attributedPlaceholder = attributedString
    }


    open class func getCurrentTarget() -> String {
        return ProcessInfo.processInfo.processName
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
