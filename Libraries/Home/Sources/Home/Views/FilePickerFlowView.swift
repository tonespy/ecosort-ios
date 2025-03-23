//
//  FilePickerFlowView.swift
//  Home
//
//  Created by Abubakar Oladeji on 20/03/2025.
//

import Assets
import SwiftUI

struct FilePickerFlowView: View {
  @EnvironmentObject var homeViewModel: HomeViewModel

  private let flows: [FilePickerFlow] = [.image, .video]

  var body: some View {
    NavigationStack {
      List {
        ForEach(flows, id: \.self) { flow in
          NavigationLink(value: flow) {
            Text(flow.title)
              .font(Font.EcoSort.body)
              .foregroundColor(.EcoSort.Text.text4)
          }
        }
      }
      .navigationDestination(for: FilePickerFlow.self) { flow in
        FilePickerSeconSelection(flow)
          .environmentObject(homeViewModel)
      }
      .toolbar {
        Button {
          homeViewModel.showMediaPicker = false
        } label: {
          Image(systemName: "xmark")
            .font(Font.EcoSort.title3)
            .foregroundStyle(Color.EcoSort.Text.text5)
        }
      }
      .navigationTitle("Select an option")
    }
  }
}

struct FilePickerSeconSelection: View {
  private let previousSelection: FilePickerFlow
  private let flows: [FilePickerFlow] = [.mediaAlbum, .documentPicker]

  @EnvironmentObject var homeViewModel: HomeViewModel

  var body: some View {
    List {
      ForEach(flows, id: \.self) { flow in
        Text(flow.title)
          .font(Font.EcoSort.body)
          .foregroundColor(.EcoSort.Text.text4)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .onTapGesture {
            if previousSelection == FilePickerFlow.image {
              let destination = flow == FilePickerFlow.mediaAlbum ? FilePickerFlow.photoInAlbum : FilePickerFlow.photoInDocument
              homeViewModel.finalMediaOption = destination
            } else {
              let destination = flow == FilePickerFlow.mediaAlbum ? FilePickerFlow.videoInAlbum : FilePickerFlow.videoInDocument
              homeViewModel.finalMediaOption = destination
            }
          }
      }
    }
    .navigationTitle("Using")
  }

  init(_ previousSelection: FilePickerFlow) {
    self.previousSelection = previousSelection
  }
}
