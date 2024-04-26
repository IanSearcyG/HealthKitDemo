//
//  HealthDataManager.swift
//  HealthKitDemo
//
//  Created by Ian Searcy-Gardner on 4/26/24.
//

import Foundation
import HealthKit

final class HealthDataManager {
    
    static let shared = HealthDataManager()
    var healthStore: HKHealthStore?
    var query: HKStatisticsCollectionQuery?
    let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let healthStore = healthStore else {
            return completion(false)
        }
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            completion(success)
        }
    }
    
    func calculateSteps(interval: DateComponents, completion: @escaping (HKStatisticsCollection?) -> Void) {
        guard let healthStore = healthStore else { return }
        
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) // Fetch data from the last year
        let anchorDate = Date.mondayAt12AM() // Anchor date for the query
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: stepType,
                                            quantitySamplePredicate: predicate,
                                            options: .cumulativeSum,
                                            anchorDate: anchorDate,
                                            intervalComponents: interval)
        
        query?.initialResultsHandler = { query, statisticsCollection, error in
            completion(statisticsCollection)
        }
        
        healthStore.execute(query!)
    }
    
    // Helper function to get Monday at 12 AM for the anchor date
    private static func mondayAt12AM() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set the week start to Monday
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekday, .day], from: now)
        let startOfWeek = calendar.date(from: components)!
        let startOfDay = calendar.startOfDay(for: startOfWeek)
        return startOfDay
    }
}

extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}
