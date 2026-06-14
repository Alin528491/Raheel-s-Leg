import SwiftUI

struct AppRootView: View {
    @StateObject private var angleSource = KneeAngleSimulator()
    @State private var selectedTab: AppTab = .dashboard

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
                DashboardView(selectedTab: $selectedTab)
            }
            .tabItem { Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon) }
            .tag(AppTab.dashboard)

            NavigationStack {
                MeasurementView()
            }
            .tabItem { Label(AppTab.measurement.title, systemImage: AppTab.measurement.icon) }
            .tag(AppTab.measurement)

            NavigationStack {
                ExerciseListView()
            }
            .tabItem { Label(AppTab.exercises.title, systemImage: AppTab.exercises.icon) }
            .tag(AppTab.exercises)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.icon) }
            .tag(AppTab.profile)
        }
        .tint(Color.khBlue)
        .environmentObject(angleSource)
    }
}
