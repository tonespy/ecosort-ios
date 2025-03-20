//
// HomeScreen.swift
// EcoSort
//
// Created by Abubakar Oladeji on 05/02/2025
//

import Assets
import SwiftUI
import PhotosUI
import Platform

public struct HomeScreen: View {
  @EnvironmentObject var homeState: HomeState
  @ObservedObject private var viewModel: HomeViewModel
  @State var selectedImage: PhotosPickerItem?

  @State var isMenuOpen: Bool = false

  public var body: some View {
    ZStack {
      Color.EcoSort.Base.background
      List {
        //
      }.overlay {
        ContentUnavailableView {
          EmptyHomeView()
            .environmentObject(viewModel)
        }
      }
//      EmptyHomeView()
      /*
      PhotosPicker(
        selection: $selectedImage,
        matching: .images,
        photoLibrary: .shared()
      ) {
        Text("Select a Photo")
          .padding()
          .background(Color.blue.opacity(0.8))
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .onChange(of: selectedImage, initial: false) {
 _,
 newValue in
        Task {
          if let resizedImage: Data = await newValue?.preprocessImage(
            CGSize(width: 256, height: 256)
          ) {
            viewModel.runInference(data: resizedImage)
          }
        }
      }
      */
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.EcoSort.Base.background)
    .overlay(toggleView, alignment: .bottomTrailing)
    .snackbar(
      show: $viewModel.isDownloadCompleted,
      message: "Model\(viewModel.downloadedModelVersion) downloaded successfully!"
    )
    .sheet(isPresented: $viewModel.showMediaPicker) {
      FilePickerFlowView()
        .environmentObject(viewModel)
        .presentationDetents([.fraction(0.25)])
    }
    .sheet(isPresented: $viewModel.showMediaAlbumOrDocumentPicker) {
      switch viewModel.finalMediaOption {
      case .photoInAlbum:
        EcoAlbumMediaPicker(result: $viewModel.mediaResult, type: .images)
      case .photoInDocument:
        EcoDocumentMediaPicker(result: $viewModel.mediaResult, type: .images)
      case .videoInAlbum:
        EcoAlbumMediaPicker(result: $viewModel.mediaResult, type: .video)
      case .videoInDocument:
        EcoDocumentMediaPicker(result: $viewModel.mediaResult, type: .video)
      default:
        EmptyView()
      }
    }
  }

  private var toggleView: some View {
    ExpandableViewMod(isExpanded: $isMenuOpen, placement: .right) {
        ZStack(alignment: .center) {
          if viewModel.isDownloadInProgress {
            CircularProgressView(progress: viewModel.progress)
          }

          Image.EcoSort.Home.scanIcon
            .resizable()
            .foregroundColor(Color.EcoSort.Content.primary)
            .frame(width: 25, height: 25)
        }
        .frame(width: 50, height: 50)
      } expandedAction: {
        ZStack(alignment: .center) {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .foregroundColor(Color.EcoSort.Content.primary)
            .frame(width: 25, height: 25)
        }
        .frame(width: 50, height: 50)
      } expandedContent: { direction in
        HStack(spacing: 16) {
          Text("Settings")
            .font(Font.EcoSort.heading)
            .foregroundStyle(Color.EcoSort.Text.text4)
            .padding(AppPadding.small.value)
            .background(Capsule().fill(Color.EcoSort.Brand.greenInverse))
            .onTapGesture {
              homeState.didSelectSettings.toggle()
              isMenuOpen.toggle()
            }

          Text("Scan")
            .font(Font.EcoSort.heading)
            .foregroundStyle(Color.EcoSort.Text.text4)
            .padding(AppPadding.small.value)
            .background(Capsule().fill(Color.EcoSort.Brand.greenInverse))
            .onTapGesture {
              viewModel.showMediaPicker.toggle()
              isMenuOpen.toggle()
            }
        }
      }
      .frame(minWidth: 200, maxWidth: .infinity)
      .padding(AppPadding.medium.value)
  }

  public init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
  }
}
