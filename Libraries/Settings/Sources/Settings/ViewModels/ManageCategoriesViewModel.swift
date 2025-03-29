//
//  ManageCategoriesViewModel.swift
//  Settings
//
//  Created by Abubakar Oladeji on 09/03/2025.
//

import Combine
import Foundation
import Platform
import SwiftUI

struct AddCategoryClassInfo: Identifiable, Encodable, Hashable {
  let id: String = UUID().uuidString
  let index: Int
  let classInfo: PredictionClasses
  let existingSection: String?

  init(index: Int = -1, classInfo: PredictionClasses, existingSection: String? = nil) {
    self.index = index
    self.classInfo = classInfo
    self.existingSection = existingSection
  }
}

public final class ManageCategoriesViewModel: ObservableObject {
  @Published var pickerItems: [PickerItem] = []
  @Published var selectedPickerId: String = ""
  @Published var isEditing: Bool = false
  @Published var toolbarActions: [ToolbarAction] = [.add]
  @Published var groupedList: [ListCategorySection] = []
  @Published var showAddSheet: Bool = false
  @Published var addCategoryData: (name: String, sectionList: [String], setAsDefault: Bool)? = nil
  @Published var showManualAddSheet: Bool = false
  @Published var editMode: EditMode = .inactive

  @Published var showSaveAlert: Bool = false
  var alertTitle: String = ""
  var alertMessage: String = ""

  private var allAvailableClasses: [PredictionClasses] = []
  private var newCategoryClassRefs: [PredictionClasses] = []
  private var manualAddSection: ListCategorySection? = nil
  private var existingUserSavedGroups: [UserConfigedGroups] = []

  var indexSortingClass: [AddCategoryClassInfo] {
    if !newCategoryClassRefs.isEmpty {
      return newCategoryClassRefs.map { AddCategoryClassInfo(classInfo: $0) }
    }

    var items: [AddCategoryClassInfo] = []
    for (index, section) in groupedList.enumerated() {
      guard let classInfo = section.classInfo else { continue }
      items
        .append(
          AddCategoryClassInfo(
            index: index,
            classInfo: classInfo,
            existingSection: section.sectionName
          )
        )
    }
    return items
  }

  @Published var currentSelectedItem: PickerItem?

  private var cancellables: Set<AnyCancellable> = []

  init() {
    self.observe()
  }

  public func fetchCategories () {
    let userDefaults = UserDefaults.standard
    guard
      let predictionConfiguration = userDefaults.predictionConfiguration,
      let userPreference = userDefaults.userPreference else {
      return
    }

    let defaultGroups = predictionConfiguration.groups
    let userConfigedGroups = userPreference.savedGroups
    existingUserSavedGroups = userConfigedGroups

    let userSavedGroupsPicker = userConfigedGroups.map { userConfig in
      let grouping = userConfig.config.groupConfig.map { groupConfig in
        let sectionItems = groupConfig.classes.map(\.self).map(CategoryItem.init)
        return CategorySection(name: groupConfig.name, items: sectionItems)
      }

      return PickerItem(
        label: userConfig.config.name,
        content: grouping,
        isDefault: userConfig.isDefault,
        canEdit: true
      )
    }

    let userHasDefault = !userConfigedGroups.isEmpty && userConfigedGroups.first?.isDefault ?? false

    let defaultGroupPicker = defaultGroups.map { groupConfig in
      let grouping = groupConfig.groupConfig.map { classGrouping in
        let sectionItems = classGrouping.classes.map(\.self).map(CategoryItem.init)
        return CategorySection(name: classGrouping.name, items: sectionItems)
      }

      return PickerItem(label: groupConfig.name, content: grouping, isDefault: !userHasDefault)
    }

    let allPickerItems = userSavedGroupsPicker + defaultGroupPicker
    pickerItems = allPickerItems.sorted { first, second in
      if first.isDefault != second.isDefault {
        // Return true if first is default and second is not
        return first.isDefault
      }

      // Otherwise, sort by name alphabetically
      return first.label < second.label
    }

    guard let defaultItem = pickerItems.first, defaultItem.isDefault else {
      return
    }
    currentSelectedItem = defaultItem
    selectedPickerId = defaultItem.id
    groupedList = defaultItem.customListSection
    allAvailableClasses = predictionConfiguration.classes
    fillToolBarInformation()
  }

  private func fillToolBarInformation() {
    guard let currentSelectedItem, !isEditing else { return }
    let favouriteOption: ToolbarAction = currentSelectedItem.isDefault ? .unFavorite : .favorite
    if currentSelectedItem.canEdit {
      toolbarActions = [favouriteOption, .add, .edit, .delete]
    } else {
      toolbarActions = [favouriteOption, .add]
    }
  }

  private func observe() {
    $selectedPickerId
      .dropFirst()
      .sink { selectedId in
        let firstItem = self.pickerItems.first(where: { item in
          item.id == selectedId
        })
        guard let currentSelected = firstItem else { return }

        self.currentSelectedItem = currentSelected
        self.groupedList = currentSelected.customListSection
        self.fillToolBarInformation()
      }
      .store(in: &cancellables)

    $addCategoryData
      .dropFirst()
      .sink { result in
        guard let result else { return }
        self.showAddSheet.toggle()
        self.createNewPickerItem(
          result.name,
          sections: result.sectionList,
          setAsDefault: result.setAsDefault
        )
        print("Result: \(result)")
      }
      .store(in: &cancellables)
  }

  private func createNewPickerItem(_ name: String, sections: [String], setAsDefault: Bool) {
    let categorySections = sections.map { current in
      return CategorySection(name: current, items: [])
    }

    let newPickerItem = PickerItem(
      label: name,
      content: categorySections,
      isDefault: setAsDefault,
      canEdit: true
    )
    pickerItems.append(newPickerItem)
    selectedPickerId = newPickerItem.id
    groupedList = newPickerItem.customListSection

    newCategoryClassRefs = allAvailableClasses
    isEditing = true
    editMode = .active
    toolbarActions = [.save]
  }

  private func updateGroupInformation() {
    guard newCategoryClassRefs.isEmpty else {
      alertTitle = "Warning"
      let ungrouped = newCategoryClassRefs.map(\.self.readableName).joined(
        separator: ", "
      )
      alertMessage = "\(ungrouped) still exist without grouping. Please group them before saving."
      showSaveAlert = true
      return
    }

    guard let currentSelectedItem, var userPreference = UserDefaults.standard.userPreference else {
      return
    }
    // Create UserConfigedGroups
    let groups = currentSelectedItem.content.map { section in
      let classes = section.items.map { $0.classInfo }
      return ClassGrouping(name: section.name, classes: classes)
    }

    let groupConfig = ClassGroupConfig(
      name: currentSelectedItem.label,
      groupConfig: groups
    )

    let userSaved = UserConfigedGroups(
      config: groupConfig,
      isDefault: currentSelectedItem.isDefault
    )

    if currentSelectedItem.isDefault {
      existingUserSavedGroups = existingUserSavedGroups
        .map { UserConfigedGroups(config: $0.config, isDefault: false) }
    }

    if let (index, _) = existingUserSavedGroups.enumerated().first(
      where: { $0.element.config.name == userSaved
        .config.name }) {
      existingUserSavedGroups[index] = userSaved
    } else {
      existingUserSavedGroups.append(userSaved)
    }

    userPreference.savedGroups = existingUserSavedGroups
    UserDefaults.standard.userPreference = userPreference

    isEditing = false
    editMode = .inactive
    fetchCategories()
  }

  private func toggleFavorite(_ isFavorite: Bool) {
    guard let currentSelectedItem, var userPreference = UserDefaults.standard.userPreference else { return }

    if isFavorite && !currentSelectedItem.isDefault {
      existingUserSavedGroups = existingUserSavedGroups
        .map {
          UserConfigedGroups(
            config: $0.config,
            isDefault: $0.config.name == currentSelectedItem
              .label
          )
        }
    } else {
      // Show an error
    }

    userPreference.savedGroups = existingUserSavedGroups
    UserDefaults.standard.userPreference = userPreference

    fetchCategories()
  }

  private func deleteCurrentSelectedItem() {
    guard let currentSelectedItem, var userPreference = UserDefaults.standard.userPreference, !currentSelectedItem.isDefault else {
      return
    }

    existingUserSavedGroups = existingUserSavedGroups.filter { $0.config.name != currentSelectedItem.label }
    userPreference.savedGroups = existingUserSavedGroups
    UserDefaults.standard.userPreference = userPreference
    
    fetchCategories()
  }

  func handleToolbarAction(_ action: ToolbarAction) {
    switch action {
    case .edit:
      isEditing = true
      editMode = .active
      toolbarActions = [.save]
    case .save:
      updateGroupInformation()
    case .add:
      showAddSheet.toggle()
    case .favorite:
      toggleFavorite(true)
    case .unFavorite:
      toggleFavorite(false)
    case .delete:
      deleteCurrentSelectedItem()
    }
  }

  func addClassToSection(_ classes: [AddCategoryClassInfo]) {
    guard
      let sectionToAdd = manualAddSection,
      let indexOfSection = groupedList.firstIndex(where: { $0.sectionName == sectionToAdd.sectionName && $0.isHeader }) else {
      manualAddSection = nil
      showManualAddSheet.toggle()
      return
    }

    let classesWithValidIndexes = classes.filter { $0.index >= 0 }.map { info in
      return info.index
    }

    if !classesWithValidIndexes.isEmpty {
      let indexSet = IndexSet(classesWithValidIndexes)
      moveItem(from: indexSet, to: indexOfSection + 1)
    }

    let classesWithInvalidIndexes = classes.filter { $0.index < 0 }.map { info in
      ListCategorySection(
        sectionName: sectionToAdd.sectionName,
        classInfo: info.classInfo,
        indexInfo: sectionToAdd.indexInfo
      )
    }

    if !classesWithInvalidIndexes.isEmpty {
      let newSectionItems = classesWithInvalidIndexes.compactMap { $0.classInfo }.map {
        CategoryItem(classInfo: $0)
      }
      if var update = currentSelectedItem {
        update.content[sectionToAdd.indexInfo.section].items = newSectionItems
        self.currentSelectedItem = update
        self.groupedList = update.customListSection
      }
    }

    // Cleanup
    let selectedClasses = classes.compactMap(\.classInfo)
    newCategoryClassRefs.removeAll { currentClass in
      selectedClasses.contains(currentClass)
    }

    showManualAddSheet = false
  }

  func closeSheetForManualEntry() {
    manualAddSection = nil
    showManualAddSheet = false
  }

  func showSheetForManualEntry(using section: ListCategorySection) {
    manualAddSection = section
    showManualAddSheet.toggle()
  }

  func moveItem(from source: IndexSet, to destination: Int) {
    // Move the item in the flattened list.
    groupedList.move(fromOffsets: source, toOffset: destination)
    print("Source: \(Array(source)) Destination: \(destination)")

    // Find the nearest header before the destination.
    guard let headerIndex = stride(from: destination - 1, through: 0, by: -1)
      .first(where: { groupedList[$0].isHeader })
    else { return }

    // Determine the target section from the header.
    let targetSection = groupedList[headerIndex].indexInfo.section

    // Find the range in groupedList that corresponds to this target section.
    let nextHeaderIndex: Int = {
      let range = (headerIndex + 1)..<groupedList.count
      return range.first(where: { groupedList[$0].isHeader }) ?? groupedList.count
    }()

    // Extract all items (non-header) in the target section from the flattened list.
    let sectionItems = groupedList[(headerIndex + 1)..<nextHeaderIndex]
    // Map these items to the CategoryItem model (if they have classInfo)
    let newSectionItems = sectionItems.compactMap { $0.classInfo }
      .map { CategoryItem(classInfo: $0) }

    // Update the underlying model accordingly.
    // Update currentSelectedItem's content for that target section.
    if var update = currentSelectedItem {
      update.content[targetSection].items = newSectionItems
      self.currentSelectedItem = update
    }
  }
}

extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
