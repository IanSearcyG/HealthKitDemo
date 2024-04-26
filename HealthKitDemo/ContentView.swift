//
//  ContentView.swift
//  HealthKitDemo
//
//  Created by Ian Searcy-Gardner on 4/26/24.
//

import SwiftUI
import HealthKit
import HealthKit
import Charts

struct ContentView: View {
    @State private var steps: [Step] = []
    @State private var useMockData: Bool = false
    @State var bob = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Toggle("Use Mock Data", isOn: $useMockData)
                        .padding()
                    
                    Text("Past 30 Days")
                    
                    
                    
                    if steps.isEmpty {
                        Text("No data loaded yet")
                            .foregroundColor(.gray)
                            .font(.title)
                            .padding()
                    } else {
                        Chart {
                            ForEach(steps, id: \.id) { step in
                                BarMark(
                                    x: .value("Date", step.formattedDate),
                                    y: .value("Steps", step.count)
                                )
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) {
                                AxisGridLine()
                                AxisTick()
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8)
                        .padding(.bottom, 30)
                        Chart {
                            ForEach(steps, id: \.id) { step in
                                LineMark(
                                    x: .value("Date", step.formattedDate),
                                    y: .value("Steps", step.count)
                                )
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) {
                                AxisGridLine()
                                AxisTick()
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.5)
                        .padding(.bottom, 30)
                        
                        Spacer()
                    }
                    
                    
                    
                    
                    
                }
                .navigationTitle("Healthkit Demo")
            }
        }
        .onAppear {
            #if targetEnvironment(simulator)
            useMockData = true
            #endif
            if useMockData {
                self.steps = self.mockSteps()
                self.fetchStepsFromHealthKit()
            } else {
                self.fetchStepsFromHealthKit()
            }
        }
        .onChange(of: useMockData) { newValue in
            if newValue {
                self.steps = self.mockSteps()
            } else {
                self.steps = []
                self.fetchStepsFromHealthKit()
            }
        }
        
        
    }
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        var newSteps: [Step] = []
        let endDate = Date() // today
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate)! // 30 days ago
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            newSteps.append(step)
        }
        
        DispatchQueue.main.async {
            self.steps = newSteps
        }
    }
    
    
    
    func mockSteps() -> [Step] {
        var steps: [Step] = []
        let currentDate = Date()
        let calendar = Calendar.current
        
        for day in (0..<30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -day, to: currentDate) {
                let count = Int.random(in: 1000...10000)
                let step = Step(count: count, date: date)
                steps.append(step)
            }
        }
        print("Mock steps generated: \(steps)")
        return steps
    }
    
    
    
    func fetchStepsFromHealthKit() {
        #if targetEnvironment(simulator)
        print("Running on the Simulator - HealthKit is not available")
        #else
        HealthDataManager.shared.requestAuthorization { success in
            print("HealthKit Auth: \(success)")
            if success && !useMockData {
                let dailyInterval = DateComponents(day: 1)
                HealthDataManager.shared.calculateSteps(interval: dailyInterval) { statisticsCollection in
                    if let statisticsCollection = statisticsCollection {
                        DispatchQueue.main.async {
                            self.updateUIFromStatistics(statisticsCollection)
                        }
                    }
                }
            }
        }
        #endif
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
