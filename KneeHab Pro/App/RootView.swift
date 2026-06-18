import SwiftUI

struct RootView: View {
    @StateObject private var angleSource = AngleService()
    @State private var selectedTab: MainTab = .dashboard
    @State private var didConfirmWorkoutSensors = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.khSurface)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardScreen(selectedTab: $selectedTab)
            }
            .tabItem { Label(MainTab.dashboard.title, systemImage: MainTab.dashboard.icon) }
            .tag(MainTab.dashboard)

            NavigationStack {
                MeasurementScreen()
            }
            .tabItem { Label(MainTab.measurement.title, systemImage: MainTab.measurement.icon) }
            .tag(MainTab.measurement)

            NavigationStack {
                if angleSource.isConnected && didConfirmWorkoutSensors {
                    ExerciseListScreen()
                } else {
                    SensorConnectScreen {
                        didConfirmWorkoutSensors = true
                    }
                }
            }
            .tabItem { Label(MainTab.exercises.title, systemImage: MainTab.exercises.icon) }
            .tag(MainTab.exercises)

            NavigationStack {
                ProfileScreen()
            }
            .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.icon) }
            .tag(MainTab.profile)
        }
        .tint(Color.khBlue)
        .environmentObject(angleSource)
        .onChange(of: angleSource.isConnected) { _, isConnected in
            if !isConnected {
                didConfirmWorkoutSensors = false
            }
        }
    }
}
