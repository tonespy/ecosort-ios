//
//  HomeState.swift
//  Home
//
//  Created by Abubakar Oladeji on 23/02/2025.
//

import Combine

public final class HomeState: ObservableObject {
  @Published public var didSelectSettings: Bool = false
  @Published public var didSelectScan: Bool?

  public init() {}
}
