// MainTabView.swift
// Root tab bar for authenticated users

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {

            // MARK: - Gallery Tab
            NavigationStack {
                GalleryView()
            }
            .tabItem {
                Label("Gallery", systemImage: "photo.stack.fill")
            }
            .tag(AppCoordinator.Tab.gallery)

            // MARK: - Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
            .tag(AppCoordinator.Tab.profile)
        }
        .tint(.blue)
    }
}

