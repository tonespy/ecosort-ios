//
// HomeScreen.swift
// EcoSort
//
// Created by Abubakar Oladeji on 05/02/2025
//

import Assets
import SwiftUI
import PhotosUI
import SwiftData

public struct HomeScreen: View {
  @Environment(\.modelContext) private var modelContext: ModelContext
  @Query(sort: \PredictionSessionModel.date, order: .forward) var modelSessions: [PredictionSessionModel]

  @EnvironmentObject var homeState: HomeState
  @ObservedObject private var viewModel: HomeViewModel
  @State var selectedImage: PhotosPickerItem?

  @State var isMenuOpen: Bool = false

  public var body: some View {
    NavigationStack {
      ZStack {
        Color.EcoSort.Base.background
          .ignoresSafeArea()
        ScrollView {
          LazyVStack(
            alignment: .leading,
            spacing: SpacingSize.medium.value,
            pinnedViews: [.sectionHeaders]
          ) {
            sectionedList
              .listRowSeparator(.hidden)
              .listRowInsets(EdgeInsets())
              .listRowBackground(Color.EcoSort.Base.background)
          }
        }.overlay {
          if modelSessions.isEmpty {
            ContentUnavailableView {
              EmptyHomeView()
                .environmentObject(viewModel)
            }
          }
        }
        .listStyle(.grouped)
        .background(Color.EcoSort.Base.background)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)

        if let progressMessage = viewModel.progressMessage {
          ZStack {
            // A full-screen semi-transparent overlay to block interaction.
            Color.black.opacity(0.5)
              .ignoresSafeArea()

            VStack(spacing: 16) {
              ProgressView(progressMessage)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
              Text(progressMessage)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            }
            .padding()
          }
          .transition(.opacity)
        }

      }
      .navigationDestination(
        isPresented: $homeState.showSessionReviewScreen,
        destination: {
          if let sessionId = viewModel.selectedSession?.modelId {
            HomeReviewScreen(sessionId: sessionId)
              .modelContainer(for: [
                PredictionSessionModel.self,
                PredictionSessionGroup.self,
                SessionGroupClass.self,
                PredictionSessionMedia.self
              ])
          } else {
            EmptyView()
          }
        }
      )
      .background(Color.EcoSort.Base.background)
      .overlay(toggleView, alignment: .bottomTrailing)
      .onAppear {
        viewModel.setModelContext(modelContext)
      }
      .navigationBarTitleDisplayMode(.inline)
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
      .sheet(isPresented: $viewModel.showProcessingUI) {
        ProcessMediaView()
        { sessionModel in
          viewModel.handleModelSession(sessionModel)
        } onDismiss: {
          print("Dismiss Called here")
          viewModel.stopProcessingImages()
        }
        .environmentObject(
          ProcessMediaViewModel(
            modelDataSource: viewModel.modelDataSource!,
            images: viewModel.selectedImages,
            videoUrl: viewModel.selectedVideoUrl
          )
        )
        .interactiveDismissDisabled()
        .presentationDetents([.fraction(0.5)])
      }
    }
  }

  private var sectionedList: some View {
    ForEach(viewModel.handleSessions(modelSessions), id: \.id) { section in
      Section {
        ForEach(section.models, id: \.id) { model in
          VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: SpacingSize.small) {
              VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                Text("When")
                  .font(Font.EcoSort.caption1)
                  .foregroundStyle(Color.EcoSort.Text.text2)

                Text(model.when)
                  .font(Font.EcoSort.headingL)
                  .foregroundStyle(Color.EcoSort.Text.text4)
              }

              HStack {
                if model.accuracy > 0 {
                  VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                    Text("Accuracy")
                      .font(Font.EcoSort.caption1)
                      .foregroundStyle(Color.EcoSort.Text.text2)

                    Text("\(model.accuracy, specifier: "%.2f")%")
                      .font(Font.EcoSort.body)
                      .foregroundStyle(Color.EcoSort.Text.text4)
                  }
                }

                VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                  Text("Group")
                    .font(Font.EcoSort.caption1)
                    .foregroundStyle(Color.EcoSort.Text.text2)

                  Text(model.groupName)
                    .font(Font.EcoSort.body)
                    .foregroundStyle(Color.EcoSort.Text.text4)
                }

                VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                  Text("Type")
                    .font(Font.EcoSort.caption1)
                    .foregroundStyle(Color.EcoSort.Text.text2)

                  Text(model.mediaType)
                    .font(Font.EcoSort.body)
                    .foregroundStyle(Color.EcoSort.Text.text4)
                }
              }

              HStack(spacing: SpacingSize.xSmall.value) {
                ForEach(Array(model.images.enumerated()), id: \.offset) { _, current in
                  Image(uiImage: current)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                }

                Text(model.imageText)
                  .foregroundColor(.EcoSort.Text.text6)
                  .font(Font.EcoSort.bodyS)
              }
              .padding([.leading, .top, .bottom], AppPadding.small.value)
              .padding([.trailing], AppPadding.medium.value)
              .background(
                RoundedRectangle(cornerRadius: AppRadius.xSmall.value)
                  .fill(Color.EcoSort.Base.imageBg)
              )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.EcoSort.Neutral.neutral0)
            .overlay {
              RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(Color.EcoSort.Neutral.neutral1)
            }
            .onTapGesture {
              viewModel.selectedSession = model
              homeState.showSessionReviewScreen.toggle()
            }
          }
          .padding([.leading, .trailing])
        }
      } header: {
        HStack(alignment: .center, spacing: 8) {
          Text(section.type.title.capitalized)
            .font(Font.EcoSort.heading)
            .foregroundStyle(Color.EcoSort.Text.text2)

          Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.EcoSort.Text.text2)
            .frame(maxWidth: .infinity)
        }
        .padding([.leading, .trailing])
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
