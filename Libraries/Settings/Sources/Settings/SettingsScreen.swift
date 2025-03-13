//
//  SettingsScreen.swift
//  EcoSort
//
//  Created by Abubakar Oladeji on 22/02/2025.
//

import Assets
import Platform
import SwiftUI
import UIKit

public struct SettingsScreen: View {
  @EnvironmentObject var settingsState: SettingsState
  @ObservedObject private var viewModel: SettingsViewModel

  @State private var backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus

  public var body: some View {
    NavigationView {
      ZStack {
        Color.EcoSort.Base.background
        VStack(spacing: SpacingSize.medium) {
          List {

            ForEach(viewModel.sections, id: \.self) { section in
              Section {
                ForEach(section.items, id: \.self) { item in
                  switch item.identifier {
                  case .notifications:
                    NotificationSettingsItem(settingsItem: item)
                      .environmentObject(viewModel)
                  case .modelDownload(_):
                    ClickableSettingsItem(settingsItem: item)
                  case .models:
                    NavigationLink(
                      destination: ManageModelScreen()
                        .environmentObject(viewModel.manageModelViewModel)
                    ) {
                      ClickableSettingsItem(settingsItem: item)
                    }
                  case .categories:
                    NavigationLink(
                      destination: ManageCategories()
                        .environmentObject(viewModel.manageCategoriesViewModel)
                    ) {
                      ClickableSettingsItem(settingsItem: item)
                    }
                  }
                }
              } header: {
                Text(section.identifier.title)
              }

            }

            Text("App Version 1.0.0")
          }
          .listStyle(.grouped)
          .background(Color.EcoSort.Base.background)
          .scrollContentBackground(.hidden)
        }
      }
      .onDisappear {
        viewModel.isMainViewVisible = false
      }
      .onAppear(perform: {
        viewModel.isMainViewVisible = true
        backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
        viewModel.isBackgroundProcessingEnabled = backgroundRefreshStatus == .available
        viewModel.loadSections()
      })
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button {
            settingsState.didSelectClose.toggle()
          } label: {
            Image(systemName: "xmark")
              .renderingMode(.template)
              .foregroundStyle(Color.EcoSort.Button.primary)
              .font(.EcoSort.body)
          }
        }
      }
    }
    .toolbarBackground(Color.EcoSort.Base.background, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .presentationContentInteraction(.scrolls)
  }

  public init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }
}
