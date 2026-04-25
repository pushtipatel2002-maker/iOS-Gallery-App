
// SplashView.swift
// Animated splash screen shown briefly on app launch

import SwiftUI

struct SplashView: View {

    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var iconRotation: Double = -10

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.10, green: 0.08, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                    Color(red: 0.2, green: 0.4, blue: 0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.blue.opacity(0.5), radius: 24, y: 10)

                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(iconRotation))
                }

                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("Wallpapers")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Beautiful imagery, always with you")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                    iconRotation = 0
                }
            }
        }
    }
}
