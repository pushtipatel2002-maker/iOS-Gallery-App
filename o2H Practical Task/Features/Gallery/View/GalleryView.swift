//// GalleryView.swift
//// Main gallery screen — paginated masonry-style image grid

import SwiftUI

struct GalleryView: View {

    @StateObject private var viewModel = DIContainer.shared.makeGalleryViewModel()
    @State private var selectedImage: ImageModel? = nil
    @State private var selectedIndex: Int = 0
    @State private var showDetail: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch viewModel.viewState {
            case .idle, .loading where viewModel.images.isEmpty:
                LoadingView(message: "Loading wallpapers…")

            case .error(let msg):
                ErrorView(message: msg) {
                    Task { await viewModel.refresh() }
                }

            default:
                galleryContent
            }
        }
        .navigationTitle("Wallpapers")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadInitial() }
        .fullScreenCover(isPresented: $showDetail) {
            ImageDetailView(
                images: viewModel.images,
                selectedIndex: $selectedIndex
            )
        }
    }
    

    // MARK: - Gallery Grid

private var galleryContent: some View {
       ScrollView {
           VStack(spacing: 0) {
            //   if viewModel.viewState == .offline { offlineBanner }

               LazyVGrid(columns: columns, spacing: 4) {
                   ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                       ImageGridCell(image: image)
                           .onTapGesture {
                               selectedIndex = index
                               showDetail = true
                           }
                           .task { await viewModel.loadMoreIfNeeded(currentItem: image) }
                   }
               }
               .padding(.horizontal, 4)


                if viewModel.isLoadingMore {
                    ProgressView().padding(.vertical, 32)
                }

                if !viewModel.hasMorePages && !viewModel.images.isEmpty {
                    Text("You've seen them all ✨")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 32)
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash").font(.system(size: 13, weight: .semibold))
            Text("Offline — showing saved images")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
    }
}

// MARK: - Grid Cell

struct ImageGridCell: View {
    let image: ImageModel

    var body: some View {
        GeometryReader { geo in
            OfflineImageView(
                imageID: image.id,
                thumbURL: image.thumbURL,
                fullURL: image.imageURL,
                size: .thumb
            )
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .contentShape(Rectangle())
    }
}

// Safe subscript — Array out-of-bounds crash rokta hai
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Int? ko Identifiable banata hai fullScreenCover ke liye
extension Int: Identifiable {
    public var id: Int { self }
}
