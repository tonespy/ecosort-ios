//
//  ManageCategories.swift
//  Settings
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import Assets
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ManageCategories: View {
  @EnvironmentObject private var viewModel: ManageCategoriesViewModel

  var body: some View {
    ZStack {
      Color.EcoSort.Base.background
        .ignoresSafeArea()

      List {
        pickerConfiguration
        categoryList
      }
      .environment(\.editMode, $viewModel.editMode)
      .listStyle(.grouped)
      .background(Color.EcoSort.Base.background)
      .scrollContentBackground(.hidden)
    }
    .toolbarBackground(Color.EcoSort.Base.background, for: .navigationBar)
    .onAppear {
      viewModel.fetchCategories()
    }
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        ForEach(viewModel.toolbarActions) { action in
          Button {
            viewModel.handleToolbarAction(action)
          } label: {
            Image(systemName: action.systemImageName)
              .renderingMode(.template)
              .foregroundStyle(Color.EcoSort.Button.primary)
              .font(.EcoSort.body)
          }
        }
      }
    }
    .sheet(isPresented: $viewModel.showAddSheet) {
      addCategoryView
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $viewModel.showManualAddSheet) {
      MultiSelectionSheet(
        items: viewModel.indexSortingClass) { selectedItems in
          viewModel.addClassToSection(selectedItems)
        } onDismiss: {
          viewModel.closeSheetForManualEntry()
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    .alert(
      viewModel.alertTitle,
      isPresented: $viewModel.showSaveAlert) {
        Button("OK") {
          viewModel.showSaveAlert = false
        }
      } message: {
        Text(viewModel.alertMessage)
      }
  }

  private var addCategoryView: some View {
    AddCategoryView(
      saveData: $viewModel.addCategoryData,
      closeView: $viewModel.showAddSheet
    ).environmentObject(AddCategoryViewModel())
  }

  private var categoryList: some View {
    ForEach(viewModel.groupedList, id: \.self) { section in
      if section.isHeader {
        VStack(alignment: .leading) {
          Divider()

          Spacer(minLength: AppPadding.large.value)

          HStack {
            Text(section.sectionName.uppercased())
              .foregroundColor(.EcoSort.Text.text3)
              .font(Font.EcoSort.body)
              .padding([.leading], AppPadding.medium.value)

            if viewModel.currentSelectedItem?.canEdit ?? false && viewModel.isEditing {
              Spacer()

              Button {
                viewModel.showSheetForManualEntry(using: section)
              } label: {
                Image(systemName: "plus")
                  .renderingMode(.template)
                  .foregroundStyle(Color.EcoSort.Button.primary)
                  .font(.EcoSort.body)
              }
              .padding([.trailing], AppPadding.medium.value)
            }
          }

          Spacer(minLength: AppPadding.small.value)

          Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowSeparator(.hidden)
        .moveDisabled(true)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.EcoSort.Base.background)
      }

      if let classInfo = section.classInfo {
        Text(classInfo.readableName)
          .font(Font.EcoSort.body)
          .foregroundColor(.EcoSort.Text.text5)
      }
    }
    .onMove { indexSet, newOffset in
      viewModel.moveItem(from: indexSet, to: newOffset)
    }
  }

  private var pickerConfiguration: some View {
    Picker("Classification Groups", selection: $viewModel.selectedPickerId) {
      ForEach(viewModel.pickerItems, id: \.self) { current in
        Text(current.label).tag("\(current.id)")
      }
    }
    .background(Color.EcoSort.Base.white)
    .font(Font.EcoSort.body1)
    .foregroundColor(.EcoSort.Text.text5)
    .pickerStyle(.menu)
    .disabled(viewModel.isEditing)
  }

//  private var categoryInput: some View {
//    HStack(spacing: SpacingSize.medium.value) {
//      TextField(
//        "Enter comma-separated grouping...",
//        text: $viewModel.groups
//      )
//      .textInputAutocapitalization(.never)
//      .disableAutocorrection(true)
//      .font(Font.EcoSort.bodyS)
//
//      Button {} label: {
//        Text("Save")
//          .font(Font.EcoSort.body)
//          .foregroundColor(.EcoSort.Text.textO)
//          .padding()
//          .disabled(viewModel.groups.count == 0)
//          .background(
//            RoundedRectangle(cornerRadius: SpacingSize.small.value)
//              .fill(Color.EcoSort.Button.primary)
//          )
//      }
//    }
//    .textFieldStyle(OutlinedTextFieldStyle())
//    .padding()
//  }
}
