// ProfileView.swift

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DIContainer.shared.makeProfileViewModel()
    @State private var showLogoutAlert = false

    var body: some View {
        List {

            // MARK: - Header
            Section {
                profileHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())

            // MARK: - Account Info (only show when user is loaded)
            if let user = viewModel.user {
                Section("Account") {
                    infoRow(icon: "envelope.fill",  tint: .blue,   title: "Email", value: user.email)
                    infoRow(icon: "person.fill",    tint: .purple, title: "Name",  value: user.displayName)
                }
            } else {
                // Still loading
                Section("Account") {
                    HStack {
                        ProgressView().scaleEffect(0.8)
                        Text("Loading profile…")
                            .font(AppTheme.Typography.body())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Sign Out
            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        Text("Sign Out")
                    }
                }
            }

            // MARK: - Version footer (standard iOS style — like Settings app)
            Section {
                EmptyView()
            } footer: {
                Text("Version \(appVersion)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Sign Out", role: .destructive) { coordinator.logout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.md) {

            // Avatar — async loaded via URLSession (no Kingfisher needed)
            AvatarView(urlString: viewModel.user?.photoURL)
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            VStack(spacing: 4) {
                Text(viewModel.user?.displayName ?? "Loading…")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .redacted(reason: viewModel.user == nil ? .placeholder : [])

                Text(viewModel.user?.email ?? "please wait")
                    .font(AppTheme.Typography.caption())
                    .foregroundStyle(.secondary)
                    .redacted(reason: viewModel.user == nil ? .placeholder : [])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
    }

    // MARK: - Info Row

    private func infoRow(icon: String, tint: Color, title: String, value: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(title)
                .font(AppTheme.Typography.body())

            Spacer()

            Text(value)
                .font(AppTheme.Typography.body())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

// MARK: - AvatarView
// Loads profile photo with URLSession — no Kingfisher dependency

struct AvatarView: View {

    let urlString: String?
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: urlString) {
            await loadAvatar()
        }
    }

    private func loadAvatar() async {
        guard let urlString, let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data) {
                await MainActor.run { image = img }
            }
        } catch {
            // Silently fail — placeholder shown
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppCoordinator())
    }
}
