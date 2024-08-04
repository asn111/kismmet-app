//
//  TimeTracker.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 04/08/2024.
//

import Foundation

class TimeTracker {
    static let shared = TimeTracker()
    
    private var startTimes: [String: Date] = [:]
    private var endTimes: [String: Date] = [:]
    
    private init() {}
    
    func startTracking(for identifier: String) {
        startTimes[identifier] = Date()
    }
    
    func stopTracking(for identifier: String) {
        guard let startTime = startTimes[identifier] else {
            print("No start time found for identifier: \(identifier)")
            return
        }
        endTimes[identifier] = Date()
        
        guard let endTime = endTimes[identifier] else {
            print("No end time found for identifier: \(identifier)")
            return
        }
        
        let elapsedTime = endTime.timeIntervalSince(startTime)
        let elapsedTimeMillis = elapsedTime * 1000
        
        Logs.show(message: "Elapsed time for \(identifier): \(elapsedTime) seconds (\(elapsedTimeMillis) milliseconds)")
        //print("Elapsed time for \(identifier): \(elapsedTime) seconds (\(elapsedTimeMillis) milliseconds)")
        
        // Optionally, clear the times after logging
        startTimes.removeValue(forKey: identifier)
        endTimes.removeValue(forKey: identifier)
    }
    
    func elapsedTime(for identifier: String) -> TimeInterval? {
        guard let startTime = startTimes[identifier], let endTime = endTimes[identifier] else {
            print("No complete tracking data for identifier: \(identifier)")
            return nil
        }
        return endTime.timeIntervalSince(startTime)
    }
}
