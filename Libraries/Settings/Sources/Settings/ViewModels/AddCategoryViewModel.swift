//
//  AddCategoryViewModel.swift
//  Settings
//
//  Created by Abubakar Oladeji on 16/03/2025.
//

import Combine
import Foundation

final class AddCategoryViewModel: ObservableObject {
  @Published var name: String = ""
  @Published var sections: String = ""
  @Published var enableAdd: Bool = false
  @Published var disableSave: Bool = false

  var sectionList: [String] {
    return sections
      .trimmingCharacters(in: .whitespaces)
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
  }

  private var cancellables: Set<AnyCancellable> = []

  init () {
    observe()
  }

  func observe() {
    // Combine sectionList and name to determine if to enable saving
    Publishers.CombineLatest($name, $sections)
//      .dropFirst()
      .map { name, sectionList in
        if name.isEmpty || sectionList.isEmpty {
          return true
        }

        let splitInput = sectionList
          .trimmingCharacters(in: .whitespaces)
          .split(separator: ",")
          .map { $0.trimmingCharacters(in: .whitespaces) }

        return splitInput.isEmpty
      }
      .assign(to: \.disableSave, on: self)
      .store(in: &cancellables)
  }
}
