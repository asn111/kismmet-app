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
        // Create a timer that triggers the sendLocation() function every 2 minutes
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        Logs.show(message: " --------- \(location) --------- ")
    }

}
