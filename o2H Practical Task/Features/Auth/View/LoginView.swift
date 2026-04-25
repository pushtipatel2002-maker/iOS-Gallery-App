// LoginView.swift

import SwiftUI
import GoogleSignIn

struct LoginView: View {

    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DIContainer.shared.makeAuthViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError      = false
    @State private var pulse          = false
    @State private var orbFloat       = false
    @State private var shimmer        = false
    @State private var cardAppeared   = false
    @State private var logoAppeared   = false
    @State private var buttonPressed  = false

    // MARK: - Body

    var body: some View {
        ZStack {
            background
            orbLayer
            VStack(spacing: 0) {
                Spacer()
                logoSection
                    .offset(y: logoAppeared ? 0 : 50)
                    .opacity(logoAppeared ? 1 : 0)
                Spacer()
                signInCard
                    .offset(y: cardAppeared ? 0 : 70)
                    .opacity(cardAppeared ? 1 : 0)
                Spacer().frame(height: 48)
            }
            .padding(.horizontal, 26)
        }
        .ignoresSafeArea()
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong. Please try again.")
        }
        .onChange(of: viewModel.errorMessage) { _, msg in showError = msg != nil }
        .onAppear { startAnimations() }
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation(.spring(response: 0.85, dampingFraction: 0.72).delay(0.1)) {
            logoAppeared = true
        }
        withAnimation(.spring(response: 0.85, dampingFraction: 0.72).delay(0.28)) {
            cardAppeared = true
        }
        withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
            orbFloat = true
        }
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            pulse = true
        }
        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false).delay(0.6)) {
            shimmer = true
        }
    }

    // MARK: - Background

    private var background: some View {
        Group {
            if colorScheme == .dark {
                // Deep near-black with a subtle purple tint
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.04, blue: 0.10),
                        Color(red: 0.08, green: 0.06, blue: 0.14)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                // Soft lavender-white
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.96, blue: 1.0),
                        Color(red: 0.93, green: 0.91, blue: 0.99)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Floating Orbs

    private var orbLayer: some View {
        ZStack {
            // Primary top-left orb — blue/violet
            orbEllipse(
                colors: colorScheme == .dark
                    ? [Color(red: 0.36, green: 0.47, blue: 1.0).opacity(0.58), .clear]
                    : [Color(red: 0.50, green: 0.62, blue: 1.0).opacity(0.32), .clear],
                size: CGSize(width: 400, height: 400),
                offset: CGSize(width: -110, height: orbFloat ? -190 : -165),
                blur: 64
            )

            // Secondary bottom-right orb — violet/purple
            orbEllipse(
                colors: colorScheme == .dark
                    ? [Color(red: 0.75, green: 0.32, blue: 1.0).opacity(0.48), .clear]
                    : [Color(red: 0.80, green: 0.52, blue: 1.0).opacity(0.26), .clear],
                size: CGSize(width: 340, height: 340),
                offset: CGSize(width: 140, height: orbFloat ? 330 : 305),
                blur: 58
            )

            // Accent center orb — cyan
            orbEllipse(
                colors: colorScheme == .dark
                    ? [Color(red: 0.18, green: 0.72, blue: 0.92).opacity(0.22), .clear]
                    : [Color(red: 0.28, green: 0.76, blue: 0.96).opacity(0.16), .clear],
                size: CGSize(width: 280, height: 280),
                offset: CGSize(width: orbFloat ? 18 : -18, height: orbFloat ? 90 : 65),
                blur: 48
            )

            // Small hot-pink accent — subtle
            orbEllipse(
                colors: colorScheme == .dark
                    ? [Color(red: 1.0, green: 0.32, blue: 0.60).opacity(0.14), .clear]
                    : [Color(red: 1.0, green: 0.45, blue: 0.68).opacity(0.10), .clear],
                size: CGSize(width: 200, height: 200),
                offset: CGSize(width: orbFloat ? -60 : -80, height: orbFloat ? 200 : 180),
                blur: 40
            )
        }
        .ignoresSafeArea()
    }

    private func orbEllipse(
        colors: [Color],
        size: CGSize,
        offset: CGSize,
        blur: CGFloat
    ) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: colors,
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width / 2
                )
            )
            .frame(width: size.width, height: size.height)
            .offset(x: offset.width, y: offset.height)
            .blur(radius: blur)
            .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: orbFloat)
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 22) {
            iconStack
            titleStack
        }
    }

    private var iconStack: some View {
        ZStack {
            // Outermost slow pulse ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.38, green: 0.58, blue: 1.0).opacity(pulse ? 0.0 : 0.45),
                            Color(red: 0.68, green: 0.38, blue: 1.0).opacity(pulse ? 0.0 : 0.28),
                            Color(red: 0.38, green: 0.58, blue: 1.0).opacity(pulse ? 0.0 : 0.45)
                        ],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(
                    width: pulse ? 140 : 106,
                    height: pulse ? 140 : 106
                )
                .blur(radius: 1)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: pulse)

            // Inner steady ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.42, green: 0.60, blue: 1.0).opacity(0.30),
                            Color(red: 0.62, green: 0.36, blue: 0.98).opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .frame(width: 100, height: 100)

            // Icon background with layered glow
            ZStack {
                // Glow
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.38, green: 0.55, blue: 1.0).opacity(0.7),
                                Color(red: 0.55, green: 0.30, blue: 0.96).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)
                    .blur(radius: 16)
                    .opacity(colorScheme == .dark ? 0.9 : 0.35)

                // Main icon tile
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.38, green: 0.55, blue: 1.0),
                                Color(red: 0.55, green: 0.30, blue: 0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)
                    .overlay(
                        // Shimmer line across the icon
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white.opacity(0.22),
                                        .clear
                                    ],
                                    startPoint: shimmer
                                        ? UnitPoint(x: 1.2, y: 0)
                                        : UnitPoint(x: -0.5, y: 0),
                                    endPoint: shimmer
                                        ? UnitPoint(x: 2.0, y: 1)
                                        : UnitPoint(x: 0.3, y: 1)
                                )
                            )
                            .animation(
                                .linear(duration: 1.8).repeatForever(autoreverses: false),
                                value: shimmer
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                // Inner top-highlight bevel
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }

    private var titleStack: some View {
        VStack(spacing: 9) {
            Text("Wallpapers")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .tracking(-1.0)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white
                        : Color(red: 0.10, green: 0.07, blue: 0.22)
                )

            Text("Beautiful imagery, curated for you")
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.44)
                        : Color(red: 0.38, green: 0.32, blue: 0.52)
                )
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Sign-in Card

    private var signInCard: some View {
        VStack(spacing: 18) {
            dividerLabel

            googleSignInButton

        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(cardBorder)
    }

    private var dividerLabel: some View {
        HStack(spacing: 10) {
            thinLine
            Text("SIGN IN TO CONTINUE")
                .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                .tracking(2.2)
                .foregroundStyle(
                    colorScheme == .dark
                        ? Color.white.opacity(0.30)
                        : Color(red: 0.42, green: 0.36, blue: 0.54)
                )
            thinLine
        }
    }

    private var thinLine: some View {
        Rectangle()
            .fill(
                colorScheme == .dark
                    ? Color.white.opacity(0.10)
                    : Color(red: 0.55, green: 0.46, blue: 0.70).opacity(0.22)
            )
            .frame(height: 0.5)
    }

    private var googleSignInButton: some View {
        Button(action: signInWithGoogle) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: colorScheme == .dark
                            ? Color.black.opacity(0.45)
                            : Color(red: 0.38, green: 0.30, blue: 0.62).opacity(0.18),
                        radius: buttonPressed ? 4 : 20,
                        y: buttonPressed ? 2 : 9
                    )

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: Color(red: 0.28, green: 0.28, blue: 0.36))
                        )
                } else {
                    HStack(spacing: 13) {
                        Image("ic_Google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(5)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
                            .clipShape(Circle())
                        Text("Continue with Google")
                            .font(.system(size: 15.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.22))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
        }
        .disabled(viewModel.isLoading)
        .scaleEffect(buttonPressed ? 0.965 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.68), value: buttonPressed)
        ._onButtonGesture(pressing: { buttonPressed = $0 }, perform: {})
    }

    // MARK: - Card Background

    @ViewBuilder
    private var cardBackground: some View {
        if colorScheme == .dark {
            ZStack {
                // Blur glass base
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                // Tinted overlay
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.065))
                // Subtle inner gradient
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.78))
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.90),
                                Color.white.opacity(0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                colorScheme == .dark
                    ? Color.white.opacity(0.10)
                    : Color(red: 0.60, green: 0.50, blue: 0.82).opacity(0.22),
                lineWidth: 1
            )
    }

    // MARK: - Actions

    private func signInWithGoogle() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else { return }

        Task {
            if let _ = await viewModel.signInWithGoogle(presenting: rootVC) {
                coordinator.navigateToMain()
            }
        }
    }
}
