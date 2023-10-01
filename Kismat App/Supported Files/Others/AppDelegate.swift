//
//  AppDelegate.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit
import CoreData
import RxSwift
import RealmSwift
import Firebase
import GoogleSignIn
import AuthenticationServices


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializations()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        _ = SignalRManager.init()
        application.applicationIconBadgeNumber = 0
        if AppFunctions.isLoggedIn() {
            IAPManager.shared.checkSubscriptionStatus()
            //APIService.singelton.registerDeviceToken(token: AppFunctions.getDevToken())
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if AppFunctions.isLoggedIn() {
            sendLocation()
        }
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    // MARK: - Random Functions
    
    private func initializations() {
        
        //FirebaseApp.configure() //no GoogleService-Info.plist
        registerNotification()
        UNUserNotificationCenter.current().delegate = self

        AppFunctions.removeFromDefaults(key: tagsArray)
        AppFunctions.removeFromDefaults(key: socialArray)
        
        if AppFunctions.isLoggedIn() {
            IAPManager.shared.checkSubscriptionStatus()
            APIService.singelton.registerDeviceToken(token: AppFunctions.getDevToken())
        }
        
        ///Migration
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                
            }, deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        Logs.show(message: "MIGRATION: \(config)")
        ///Migration
    }
    
    func sendLocation() {
        let pram = ["lat": "",
                    "long":""
        ]
        SignalRService.connection.invoke(method: "UpdateUserLocation", pram) {  error in
            Logs.show(message: "\(pram)")
            AppFunctions.showSnackBar(str: "loc killed")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Kismat_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
                
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//MARK: NOTIFICATIONS
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Logs.show(message: "UINFO: \(userInfo)") // this one is calling when a notification got recevied on foreground & background.
        
        AppFunctions.setIsNotifCheck(value: true)
        generalPublisher.onNext("notif")

        let apsPayload = userInfo["aps"] as! [String: Any]

        let state = application.applicationState
        switch state {
            case .inactive:
                
                application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
                
            case .background:
                Logs.show(message: "Back Ground")
                Logs.show(message: "APS: \(apsPayload)")

                //let notifData = apsPayload["data"] as? [String: Any]
                
                application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
                
            case .active:
                
                //let notifData = apsPayload["data"] as? [String: Any]
                
                application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
                
            @unknown default: break
                
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let apsPayload = userInfo["aps"] as! [String: Any]
        
        Logs.show(message: "\(userInfo)")
        

        
        let state = application.applicationState
        switch state {
            case .inactive:
                print("")
            case .background:
                
                // update badge count here
                application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
                
            case .active:
                print("")
                
            @unknown default: break
        }
    }
    
    //for displaying notification when app is in foreground
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        var userInfo = [AnyHashable: Any]()
        userInfo = (notification.request.content.userInfo)
        Logs.show(message: "xxx: \n\(userInfo)")
        Logs.show(message: "App is in the foreground")
        
        AppFunctions.setIsNotifCheck(value: true)
        generalPublisher.onNext("notif")

        completionHandler([.alert, .badge, .sound])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notification tapped here")
        if let apsPayload = response.notification.request.content.userInfo["aps"] as? [String: Any] {
            if let alrt = apsPayload["alert"] as? String {
                if alrt.contains("New features and improvements!") {
                    AppFunctions.setIsNotifCheck(value: false)
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id1673236769") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        completionHandler()
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Sometimes it’s useful to store the device token in UserDefaults
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02.2hhx",    $1)})
        Logs.show(message: "Dev Toke: \(tokenString)")
        
        AppFunctions.setDevToken(value: tokenString)
        
        if AppFunctions.isLoggedIn() {
            APIService.singelton.registerDeviceToken(token: tokenString)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        Logs.show(message: "Dev Toke: \(error)")
        
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Logs.show(message: "Notification settings: \(settings)")

        }
    }
    
    func registerNotification() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                            // You might want to remove this, or handle errors differently in production
                            assert(error == nil)
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        })
                    case .authorized:
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    case .denied:
                        let useNotificationsAlertController = UIAlertController(title: "Turn on notifications", message: "This app needs notifications turned on for the best user experience", preferredStyle: .alert)
                        let goToSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { (action) in
                            
                            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                                
                                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                            }
                        })
                        useNotificationsAlertController.addAction(goToSettingsAction)
                        UIApplication.shared.keyWindow?.rootViewController?.present(useNotificationsAlertController, animated: true, completion: nil)
                    case .provisional:
                        print("")
                    case .ephemeral:
                        print("")
                    @unknown default: break
                }
            }
            
    }

    
}


