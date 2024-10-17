//
//  SignalR Manager.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Friday10/09/2021.
//

import Foundation
import SwiftSignalRClient

class SignalRManager: NSObject {
    
    //MARK: Singleton Instance
    static let singelton = SignalRManager()
    
    //MARK: Properties
    var connection : HubConnection!
    var chatHubConnectionDelegate: HubConnectionDelegate?

    
    //MARK: Initialization
    
    func initializeSignalR() {
        var headers = ["accessToken": "Bearer " + AppFunctions.getToken()]

        connection = HubConnectionBuilder(url: URL(string: baseUrl + "/kismmetHub")!)
            .withLogging(minLogLevel: .error)
            .withAutoReconnect()
            .withHubConnectionDelegate(delegate: chatHubConnectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { httpConOpt in
                //httpConOpt.skipNegotiation = true
                httpConOpt.headers = headers
            })
            .build()
        
        connection.start()
        connectionStarted = true
        
    //MARK: Web Methods

        connection.on(method: "HelloSignalR", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            Logs.show(message: ">>> HelloSignalR : \(value) |...|")
        })
        connection.on(method: "SignalRException", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            Logs.show(message: ">>> SignalRException : \(value) |...|")
        })
        
        connection.on(method: "ContactRequestRead", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            Logs.show(message: ">>> ContactRequestRead : \(value) |...|")
        })
        
        connection.on(method: "UserLocationUpdated", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            Logs.show(message: ">>> UserLocationUpdated : \(value) |...|")
        })
        
        connection.on(method: "MessageDelivered", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            //self.markMsgDelivered(msgId: value)
            Logs.show(message: ">>> MessageDelivered : \(value) |...|")
        })
        
        connection.on(method: "MessageRead", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: String.self)
            //self.markMsgDelivered(msgId: value)
            Logs.show(message: ">>> MessageRead : \(value) |...|")
        })
        
        connection.on(method: "NewMessageReceived", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: ChatModel.self)
            generalPublisherChat.onNext(value)
            Logs.show(message: ">>> NewMessageReceived : \(value) |...|")
        })
        
        connection.on(method: "MessageSent", callback: { argumentExtractor in
            
            let value = try argumentExtractor.getArgument(type: ChatModel.self)
            generalPublisherChat.onNext(value)
            Logs.show(message: ">>> MessageSent : \(value) |...|")
        })
    }
    
    func markMsgDelivered(msgId: String) {
        
            
            let pram = ["messageId": msgId]
            
            Logs.show(message: "PRAM: \(pram)")
            
            SignalRManager.singelton.connection.invoke(method: "MessageRecieved", pram) {  error in
                if let e = error {
                    Logs.show(message: "Error: \(e)")
                    AppFunctions.showSnackBar(str: "Error in sending message")
                    return
                }
                
            
        }
        
    }
    func stopConnection() {
        connection.stop()
        connectionStarted = false
    }
    
}
