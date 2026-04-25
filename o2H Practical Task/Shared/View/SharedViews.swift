// SharedViews.swift
// Reusable UI components used across the app

import SwiftUI

// MARK: - LoadingView

struct LoadingView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(.secondary)

            Text(message)
                .font(AppTheme.Typography.caption())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ErrorView

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Something went wrong")
                    .font(AppTheme.Typography.headline())
                    .foregroundStyle(.primary)

                Text(message)
                    .font(AppTheme.Typography.caption())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(AppTheme.Typography.body(.semibold))
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ShimmerView

struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(shimmerGradient)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }

    private var shimmerGradient: some ShapeStyle {
        LinearGradient(
            stops: [
                .init(color: Color(.systemGray5), location: phase - 0.3),
                .init(color: Color(.systemGray4), location: phase),
                .init(color: Color(.systemGray5), location: phase + 0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

