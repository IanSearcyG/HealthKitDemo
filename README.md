HealthKitDemo is a SwiftUI application designed to demonstrate the integration of HealthKit to fetch and display step data. It provides a visual representation of a user's steps over the past 30 days using both bar and line charts. The application can operate with real data from HealthKit or with mock data when running in the simulator.

Features
HealthKit Integration: Fetches step data from HealthKit.
Mock Data Generation: Generates mock step data when running in environments where HealthKit is unavailable.
Data Visualization: Displays step data using bar and line charts.
Dynamic Data Loading: Data is fetched and updated upon toggling between real and mock data.

Usage
Run the app in Xcode's iOS Simulator. The app will automatically use mock data in the simulator. If running on an actual device, ensure HealthKit is available and permissions are granted to access step data.
