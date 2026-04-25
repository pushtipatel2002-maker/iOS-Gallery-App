// ImageDetailView.swift
// Full-screen paged gallery — swipe left/right to navigate like iOS Photos

import SwiftUI

struct ImageDetailView: View {
    let images: [ImageModel]
    @Binding var selectedIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showChrome: Bool = true
    @State private var verticalOffset: CGFloat = 0
    @State private var horizontalDrag: CGFloat = 0
    @State private var isDraggingHorizontal: Bool? = nil  // nil = undecided

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .opacity(max(0.3, 1 - abs(verticalOffset) / 300))
                    .ignoresSafeArea()

                // Manual paging — HStack shifted by index + drag
                HStack(spacing: 0) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        ZoomableImagePage(
                            image: image,
                            showChrome: $showChrome,
                            verticalOffset: $verticalOffset
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                .offset(x: -CGFloat(selectedIndex) * geo.size.width + horizontalDrag)
                .gesture(
                    DragGesture(minimumDistance: 15)
                        .onChanged { value in
                            // Decide direction on first meaningful movement
                            if isDraggingHorizontal == nil {
                                let isH = abs(value.translation.width) > abs(value.translation.height)
                                isDraggingHorizontal = isH
                            }

                            if isDraggingHorizontal == true {
                                horizontalDrag = value.translation.width
                            } else {
                                verticalOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if isDraggingHorizontal == true {
                                let threshold = geo.size.width * 0.3
                                let velocity = value.predictedEndTranslation.width

                                if value.translation.width < -threshold || velocity < -500 {
                                    // Swipe left → next
                                    if selectedIndex < images.count - 1 {
                                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 35)) {
                                            selectedIndex += 1
                                        }
                                    } else {
                                        withAnimation(.spring()) { horizontalDrag = 0 }
                                    }
                                } else if value.translation.width > threshold || velocity > 500 {
                                    // Swipe right → previous
                                    if selectedIndex > 0 {
                                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 35)) {
                                            selectedIndex -= 1
                                        }
                                    } else {
                                        withAnimation(.spring()) { horizontalDrag = 0 }
                                    }
                                } else {
                                    withAnimation(.spring()) { horizontalDrag = 0 }
                                }
                            } else {
                                // Vertical — swipe to dismiss
                                if abs(value.translation.height) > 120 {
                                    dismiss()
                                } else {
                                    withAnimation(.spring()) { verticalOffset = 0 }
                                }
                            }

                            // Reset after gesture ends
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 35)) {
                                horizontalDrag = 0
                            }
                            isDraggingHorizontal = nil
                        }
                )
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(!showChrome)
        .persistentSystemOverlays(showChrome ? .automatic : .hidden)
    }
}
private struct ZoomableImagePage: View {
    @Environment(\.dismiss) private var dismiss
    let image: ImageModel
    @Binding var showChrome: Bool
    @Binding var verticalOffset: CGFloat

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            OfflineImageView(
                       imageID: image.id,
                       thumbURL: image.thumbURL,
                       fullURL: image.thumbURL,   // ← thumb hi load karo placeholder ke liye
                       size: .thumb
                   )
                   .scaledToFit()
                   .blur(radius: 8)
            
        OfflineImageView(
            imageID: image.id,
            thumbURL: image.thumbURL,
            fullURL: image.imageURL,
            size: .full
        )
        .scaledToFit()
        .scaleEffect(scale)
        .offset(x: offset.width, y: offset.height + verticalOffset)
        .simultaneousGesture(scale > 1 ? magnifyGesture : nil)
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                if scale > 1 {
                    scale = 1; offset = .zero; lastOffset = .zero
                } else {
                    scale = 2.5
                }
            }
        }
        .onTapGesture(count: 1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showChrome.toggle()
            }
        }
    }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1 {
                    withAnimation(.spring()) { scale = 1; offset = .zero }
                }
            }
    }
}
