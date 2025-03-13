//
//  ManageCategoriesViewModel.swift
//  Settings
//
//  Created by Abubakar Oladeji on 09/03/2025.
//

import Combine

public final class ManageCategoriesViewModel: ObservableObject {
  @Published var categories: [String] = []
  @Published var groups: String = ""
}
