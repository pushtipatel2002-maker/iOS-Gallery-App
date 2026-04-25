// AppTheme.swift
// Design tokens, theme constants, and gradient utilities

import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: - Brand Gradients

    enum Gradients {
        /// Primary brand gradient — blue to violet
        static let brand = LinearGradient(
            colors: [
                Color(red: 0.38, green: 0.55, blue: 1.00),
                Color(red: 0.55, green: 0.30, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Soft brand gradient for light surfaces
        static let brandSoft = LinearGradient(
            colors: [
                Color(red: 0.52, green: 0.65, blue: 1.00).opacity(0.18),
                Color(red: 0.68, green: 0.46, blue: 1.00).opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Surface shimmer — overlay on any element for a gloss effect
        static func shimmerOverlay(progress: Bool) -> LinearGradient {
            LinearGradient(
                colors: [.clear, Color.white.opacity(0.22), .clear],
                startPoint: progress ? UnitPoint(x: 1.2, y: 0) : UnitPoint(x: -0.5, y: 0),
                endPoint:   progress ? UnitPoint(x: 2.0, y: 1) : UnitPoint(x: 0.3, y: 1)
            )
        }
    }

    // MARK: - Colors

    enum Colors {

        // MARK: Named Assets (define in Assets.xcassets with Dark/Light variants)
        static let background    = Color("AppBackground",  bundle: nil)
        static let surface       = Color("AppSurface",     bundle: nil)
        static let primary       = Color("AppPrimary",     bundle: nil)
        static let textPrimary   = Color("TextPrimary",    bundle: nil)
        static let textSecondary = Color("TextSecondary",  bundle: nil)
        static let divider       = Color("Divider",        bundle: nil)
        static let shimmer       = Color("Shimmer",        bundle: nil)
        static let onPrimary     = Color.white

        // MARK: Semantic Inline Fallbacks
        // (use when Assets.xcassets entry is not yet ready)
        static func backgroundFallback(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.05, green: 0.04, blue: 0.10)
                : Color(red: 0.97, green: 0.96, blue: 1.00)
        }

        static func surfaceFallback(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.07)
                : Color.white.opacity(0.82)
        }

        static func borderFallback(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.10)
                : Color(red: 0.60, green: 0.50, blue: 0.82).opacity(0.22)
        }

        static func textPrimaryFallback(scheme: ColorScheme) -> Color {
            scheme == .dark ? Color.white : Color(red: 0.10, green: 0.07, blue: 0.22)
        }

        static func textSecondaryFallback(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.44)
                : Color(red: 0.38, green: 0.32, blue: 0.52)
        }

        static func textTertiaryFallback(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.27)
                : Color(red: 0.46, green: 0.40, blue: 0.58)
        }

        // MARK: Orb Colors
        static func orbBlue(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.36, green: 0.47, blue: 1.00).opacity(0.58)
                : Color(red: 0.50, green: 0.62, blue: 1.00).opacity(0.32)
        }

        static func orbViolet(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.75, green: 0.32, blue: 1.00).opacity(0.48)
                : Color(red: 0.80, green: 0.52, blue: 1.00).opacity(0.26)
        }

        static func orbCyan(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.18, green: 0.72, blue: 0.92).opacity(0.22)
                : Color(red: 0.28, green: 0.76, blue: 0.96).opacity(0.16)
        }

        static func orbPink(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 1.00, green: 0.32, blue: 0.60).opacity(0.14)
                : Color(red: 1.00, green: 0.45, blue: 0.68).opacity(0.10)
        }

        // MARK: Icon Glow
        static func iconGlow(scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.45, green: 0.38, blue: 1.00).opacity(0.62)
                : Color(red: 0.38, green: 0.30, blue: 0.90).opacity(0.22)
        }
    }

    // MARK: - Typography

    enum Typography {
        static func displayTitle(_ weight: Font.Weight = .bold) -> Font {
            .system(size: 40, weight: weight, design: .rounded)
        }
        static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
            .system(size: 34, weight: weight, design: .rounded)
        }
        static func title(_ weight: Font.Weight = .semibold) -> Font {
            .system(size: 24, weight: weight, design: .rounded)
        }
        static func headline(_ weight: Font.Weight = .semibold) -> Font {
            .system(size: 17, weight: weight, design: .rounded)
        }
        static func body(_ weight: Font.Weight = .regular) -> Font {
            .system(size: 15, weight: weight, design: .rounded)
        }
        static func callout(_ weight: Font.Weight = .regular) -> Font {
            .system(size: 13, weight: weight, design: .rounded)
        }
        static func caption(_ weight: Font.Weight = .regular) -> Font {
            .system(size: 11, weight: weight, design: .rounded)
        }
        static func micro(_ weight: Font.Weight = .semibold) -> Font {
            .system(size: 9.5, weight: weight, design: .rounded)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat =  2
        static let xs:  CGFloat =  4
        static let sm:  CGFloat =  8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radii

    enum Radius {
        static let sm:   CGFloat =  8
        static let md:   CGFloat = 14
        static let lg:   CGFloat = 22
        static let xl:   CGFloat = 30
        static let pill: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadow {
        /// Standard card shadow
        static let card = ShadowToken(
            color: Color.black.opacity(0.14),
            radius: 16,
            x: 0,
            y: 6
        )

        /// Elevated/modal shadow
        static let elevated = ShadowToken(
            color: Color.black.opacity(0.22),
            radius: 32,
            x: 0,
            y: 12
        )

        /// Brand-tinted button shadow (light mode)
        static let buttonLight = ShadowToken(
            color: Color(red: 0.38, green: 0.30, blue: 0.62).opacity(0.18),
            radius: 20,
            x: 0,
            y: 9
        )

        /// Button shadow for dark mode
        static let buttonDark = ShadowToken(
            color: Color.black.opacity(0.45),
            radius: 20,
            x: 0,
            y: 9
        )

        static func button(scheme: ColorScheme) -> ShadowToken {
            scheme == .dark ? buttonDark : buttonLight
        }
    }

    // MARK: - Animation

    enum Animation {
        static let springCard   = SwiftUI.Animation.spring(response: 0.85, dampingFraction: 0.72)
        static let springButton = SwiftUI.Animation.spring(response: 0.22, dampingFraction: 0.68)
        static let orbFloat     = SwiftUI.Animation.easeInOut(duration: 5.5).repeatForever(autoreverses: true)
        static let pulse        = SwiftUI.Animation.easeInOut(duration: 2.8).repeatForever(autoreverses: true)
        static let shimmer      = SwiftUI.Animation.linear(duration: 1.8).repeatForever(autoreverses: false)
    }
}

// MARK: - Supporting Types

struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers

extension View {

    /// Standard raised card: white surface, border, rounded corners, shadow
    func cardStyle(scheme: ColorScheme? = nil) -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
    }

    /// Glassmorphism card: blur + translucent tint + border
    func glassCard(scheme: ColorScheme) -> some View {
        self
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                        .fill(scheme == .dark ? Color.white.opacity(0.065) : Color.white.opacity(0.78))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .stroke(AppTheme.Colors.borderFallback(scheme: scheme), lineWidth: 1)
            )
    }

    /// Brand-gradient icon background
    func brandIconBackground(size: CGFloat = 82, cornerRadius: CGFloat = 26) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.Gradients.brand)
            )
            .frame(width: size, height: size)
    }
}
