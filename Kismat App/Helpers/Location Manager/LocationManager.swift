//
//  LocationManager.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Wednesday21/04/2021.
//

import Foundation
import CoreLocation
import Combine


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation : CLLocation? {
        willSet { objectWillChange.send() }
    }
    @Published var lastLocation : CLLocation? {
        willSet { objectWillChange.send() }
    }
    
    private var timer: Timer?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 //In meters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            self.currentLocation = locationManager.location
        }
    }
    
    func sendLocation() {
        let pram = ["lat": "\(self.lastLocation?.coordinate.latitude ?? 0.0)",
                    "long":"\(self.lastLocation?.coordinate.latitude ?? 0.0)"
        ]
        SignalRService.connection.invoke(method: "UpdateUserLocation", pram) {  error in            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        let pram = ["lat" : "\(location.coordinate.latitude)",
                    "long" : "\(location.coordinate.longitude)" ]
        if SignalRService.connection != nil && connectionStarted {
            sendLocation()
        }
        Logs.show(message: " --------- \(location) --------- ")
    }
}
