//
//  ProcessMediaView.swift
//  Home
//
//  Created by Abubakar Oladeji on 22/03/2025.
//

import Assets
import Foundation
import SwiftUI

struct ProcessMediaView: View {
  private let onDismiss: () -> Void

  private var titleSuffix: String {
    viewModel.videoUrl == nil ? "image" : "frame"
  }

  private var imageText: String {
    return allImages.count > 1 ? "\(allImages.count) \(titleSuffix)s" : "1 \(titleSuffix)"
  }

  private var allImages: [UIImage] {
    return viewModel.images.map(\.image)
  }

  @ObservedObject private var viewModel: ProcessMediaViewModel

  var body: some View {
    NavigationView {
      VStack {
        List {
          // Images preview
          HStack(spacing: SpacingSize.xSmall.value) {
            ForEach(Array(allImages.enumerated().prefix(5)), id: \.offset) { _, current in
              Image(uiImage: current)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            }

            Text(imageText)
              .foregroundColor(.EcoSort.Text.text6)
              .font(
                Font.EcoSort.ecoCustom(.PTMedium, size: 13, relativeTo: .caption)
              )
          }
          .padding([.leading, .top, .bottom], AppPadding.small.value)
          .padding([.trailing], AppPadding.medium.value)
          .background(
            RoundedRectangle(cornerRadius: AppRadius.xSmall.value)
              .fill(Color.EcoSort.Base.imageBg)
          )

          // Group picker
          if viewModel.groupConfigMessage == nil {
            Picker("Select Group", selection: $viewModel.selectedPickerId) {
              ForEach(viewModel.pickers, id: \.self) { current in
                Text(current.group.name).tag(current.id)
              }
            }
            .background(Color.EcoSort.Base.white)
            .font(Font.EcoSort.body1)
            .foregroundColor(.EcoSort.Text.text5)
            .pickerStyle(.menu)
            .disabled(viewModel.buttonDisabled)
          }

          if let groupConfigMessage = viewModel.groupConfigMessage {
            HStack {
              Text("Selected group")
                .font(Font.EcoSort.headline)
              //              .foregroundColor(.EcoSort.Text.textO)

              Spacer()

              Text(groupConfigMessage)
                .font(Font.EcoSort.subheadline)
              //              .foregroundColor(.EcoSort.Text.textO)
            }
            .padding()
          }

          // Progress updates
          if let processingMessage = viewModel.processingMessage {
            Text(processingMessage)
              .foregroundColor(.EcoSort.Text.text6)
              .font(Font.EcoSort.headingS)
          }

          Button {
            viewModel.attemptProcessing()
          } label: {
            Text(viewModel.buttonTitle)
              .font(Font.EcoSort.body)
              .foregroundColor(.EcoSort.Text.textO)
              .frame(minWidth: 0, maxWidth: .infinity)
              .padding()
              .background(
                RoundedRectangle(cornerRadius: SpacingSize.small.value)
                  .fill(
                    viewModel.buttonDisabled
                    ? Color.EcoSort.Button.primaryDisabled
                    : Color.EcoSort.Button.primary
                  )
              )
              .disabled(viewModel.buttonDisabled)
          }
        }
        .listStyle(.grouped)
        .background(Color.EcoSort.Base.background)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
      }
      .navigationTitle("Processing \(titleSuffix)(s)")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            // Temporary work around for view not reloading
            if !viewModel.buttonDisabled {
              onDismiss()
            }
          } label: {
            Image(systemName: "xmark")
              .font(Font.EcoSort.title3)
              .foregroundStyle(viewModel.buttonDisabled ? Color.EcoSort.Base.border : Color.EcoSort.Text.text5)
          }
          .disabled(viewModel.buttonDisabled)
        }
      }
    }
    .onAppear {
      if viewModel.needsRetry {
        viewModel.currentFlowState = .predicting
      }
    }
  }

  init(
    viewModel: ProcessMediaViewModel,
    onComplete: @escaping (String) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.viewModel = viewModel
    self.onDismiss = onDismiss

    self.viewModel.onComplete = onComplete
  }
}
