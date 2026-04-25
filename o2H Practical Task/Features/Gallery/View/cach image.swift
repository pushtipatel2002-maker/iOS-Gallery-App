//// CachedImageView.swift
//// Drop-in image view — disk cache → URL stream, no blank flash.
//
//import SwiftUI
//
//struct CachedImageView: View {
//
//    let imageID: String
//    let url: URL
//    var contentMode: ContentMode = .fill
//
//    @StateObject private var loader = AsyncImageLoader()
//
//    var body: some View {
//        ZStack {
//            switch loader.state {
//
//            case .idle, .loading:
//                // Smooth shimmer placeholder — never a blank white flash
//                ShimmerView()
//
//            case .loaded(let image):
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: contentMode)
//                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
//
//            case .failed:
//                ZStack {
//                    Color(.secondarySystemBackground)
//                    Image(systemName: "photo")
//                        .foregroundStyle(.tertiary)
//                }
//            }
//        }
//        .task {
//            loader.load(imageID: imageID, url: url)
//        }
//        .onDisappear {
//            loader.cancel()
//        }
//    }
//}
//
//// MARK: - Shimmer placeholder
//
//private struct ShimmerView: View {
//
//    @State private var phase: CGFloat = -1
//
//    var body: some View {
//        GeometryReader { geo in
//            ZStack {
//                Color(.secondarySystemBackground)
//
//                LinearGradient(
//                    colors: [
//                        Color(.secondarySystemBackground),
//                        Color(.systemBackground).opacity(0.6),
//                        Color(.secondarySystemBackground)
//                    ],
//                    startPoint: UnitPoint(x: phase, y: 0),
//                    endPoint:   UnitPoint(x: phase + 1, y: 0)
//                )
//            }
//        }
//        .onAppear {
//            withAnimation(
//                .linear(duration: 1.2).repeatForever(autoreverses: false)
//            ) {
//                phase = 1
//            }
//        }
//    }
//}
