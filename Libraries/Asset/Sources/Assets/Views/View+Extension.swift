//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import SwiftUI

public extension View {
  /// A basic helper function to help show alerts if the given `viewModel` is not nil
  ///
  /// Example:
  /// ```
  /// class MyViewModel: ObservableObject {
  ///     @Published var showError = false
  ///     @Published var validationError: AlertViewModel?
  /// }
  /// struct MyView: View {
  ///     @StateObject var viewModel: MyViewModel
  ///     var body: some View {
  ///         Text("Hello world!")
  ///             .alert(isPresented: $viewModel.showError, viewModel: viewModel.validationError)
  ///     }
  /// }
  /// ```
  @ViewBuilder
  func alert(
    isPresented: Binding<Bool>,
    viewModel: AlertViewModel?,
    type: AppAlertType = .simple
  ) -> some View {
    
    if let viewModel = viewModel,
       isPresented.wrappedValue {
      self.disabled(true)
        .overlay(
          AppAlertView(
            showPopUp: isPresented,
            viewModel: viewModel,
            alertType: type
          )
        )
    } else {
      self
    }
  }
}
