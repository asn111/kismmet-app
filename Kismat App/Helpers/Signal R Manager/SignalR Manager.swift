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
    var headers = ["accessToken": "Bearer " + AppFunctions.getToken()]
    var chatHubConnectionDelegate: HubConnectionDelegate?

    
    //MARK: Initialization
    
    func initializeSignalR() {

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
    }
    
    func stopConnection() {
        connection.stop()
        connectionStarted = false
    }
    
}
