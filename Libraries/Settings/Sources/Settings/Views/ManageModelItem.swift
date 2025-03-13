//
//  ManageModelItem.swift
//  Settings
//
//  Created by Abubakar Oladeji on 08/03/2025.
//

import Assets
import SwiftUI

struct ManageModelItem: View {
  private let model: ModelInformation
  @EnvironmentObject var manageViewModel: ManageModelsViewModel

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: .xSmall) {
        HStack(alignment: .center) {
          Text(LocalizedStringKey("v\(model.model.version)"))
            .font(Font.EcoSort.body1)
            .foregroundColor(.EcoSort.Text.text5)
            .lineSpacing(AppPadding.small.value)

          Button {
            manageViewModel.setDefaultModel(model)
          } label: {
            Text(LocalizedStringKey(model.defaultMessage))
              .font(Font.EcoSort.body1)
              .foregroundColor(.EcoSort.Text.text5)
              .lineSpacing(AppPadding.small.value)
              .padding(4)
              .overlay {
                RoundedRectangle(cornerRadius: 4)
                  .stroke(Color.EcoSort.Brand.green, lineWidth: 2)
              }
          }

        }

        Text(LocalizedStringKey("Release Date: \(model.model.date)"))
          .font(Font.EcoSort.caption1)
          .foregroundColor(.EcoSort.Text.text3)
          .lineSpacing(AppPadding.small.value)

        Text(LocalizedStringKey("Accuracy: \(model.model.accuracy)"))
          .font(Font.EcoSort.caption1)
          .foregroundColor(.EcoSort.Text.text3)
          .lineSpacing(AppPadding.small.value)
      }

      Spacer()

      switch model.downloadState {
      case .notdownloaded, .cancelled:
        downloadButton
      case .downloaded:
        trashButton
      case .failed:
        retryButton
      case .queued:
        queueButton
      case .downloading(let progress):
        ZStack {
          Circle()
            .trim(from: 0, to: progress)
            .stroke(
              Color.EcoSort.Brand.green,
              style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .background(Color.clear)
            .rotationEffect(.degrees(-90))
            .animation(.easeOut, value: progress)
            .frame(width: 25, height: 25, alignment: .center)

          Button {
            manageViewModel.cancelModelDownload(model)
          } label: {
            Image(systemName: "xmark.circle.fill")
              .renderingMode(.template)
              .foregroundStyle(Color.EcoSort.Content.negative)
              .font(.EcoSort.body)
          }
        }
        .frame(width: 45, height: 45, alignment: .center)
      }
    }
  }

  private var queueButton: some View {
    Button {
      manageViewModel.cancelModelDownload(model)
    } label: {
      Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
        .renderingMode(.template)
        .foregroundStyle(Color.EcoSort.Content.primary)
        .font(.EcoSort.body)
    }
    .frame(width: 45, height: 45)
  }

  private var downloadButton: some View {
    Button {
      manageViewModel.downloadModel(model)
    } label: {
      Image(systemName: "square.and.arrow.down")
        .renderingMode(.template)
        .foregroundStyle(Color.EcoSort.Content.postive)
        .font(.EcoSort.body)
    }
    .frame(width: 45, height: 45)
  }

  private var trashButton: some View {
    Button {
      manageViewModel.deleteModel(model)
    } label: {
      Image(systemName: "trash")
        .renderingMode(.template)
        .foregroundStyle(Color.EcoSort.Content.negative)
        .font(.EcoSort.body)
    }
    .frame(width: 45, height: 45)
  }

  private var retryButton: some View {
    Button {
      manageViewModel.downloadModel(model)
    } label: {
      Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
        .renderingMode(.template)
        .foregroundStyle(Color.EcoSort.Content.warning)
        .font(.EcoSort.body)
    }
    .frame(width: 45, height: 45)
  }

  private var progressView: some View {
    ProgressView()
      .frame(width: 45, height: 45)
  }

  init(model: ModelInformation) {
    self.model = model
  }
}
