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
    
    /*var statusString: String {
     guard let status = locationStatus else {
     return "unknown"
     }
     
     switch status {
     case .notDetermined: return "notDetermined"
     case .authorizedWhenInUse: return "authorizedWhenInUse"
     case .authorizedAlways: return "authorizedAlways"
     case .restricted: return "restricted"
     case .denied: return "denied"
     default: return "unknown"
     }
     }
     
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     //locationStatus = status
        Logs.show(message: "\(status)")
     }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        /*//Measuring my distance to user's (in km)
         var calculatedDistance = 0.0
        calculatedDistance = AppFunctions.getLastSavedLocation().distance(from: location) / 1000
        
        //Display the result in km
        
        var timeInterval = 0.0
        
        switch calculatedDistance {
            case 1.0..<2.0:
                timeInterval = 0.030
            default:
                timeInterval = 3000
        }
        
        Logs.show(message: "Calculated Distance: \(calculatedDistance) TimeInterval: \(timeInterval)")
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            
        }*/
        
        let pram = ["lat" : "\(location.coordinate.latitude)",
                    "long" : "\(location.coordinate.longitude)" ]
        
        Logs.show(message: " --------- \(location) --------- ")
    }
}
