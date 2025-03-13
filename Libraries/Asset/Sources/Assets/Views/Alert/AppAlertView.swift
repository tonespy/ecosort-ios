//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import SwiftUI

public enum AppAlertType {
  case simple
  case imageAsHeader
}

public struct AppAlertView: View {
  typealias ButtonAction = AlertViewModel.ButtonAction
  
  public init(
    showPopUp: Binding<Bool>,
    viewModel: AlertViewModel,
    alertType: AppAlertType = .simple
  ) {
    self.viewModel = viewModel
    self._showAlert = showPopUp
    self.alertType = alertType
  }
  
  @Binding var showAlert: Bool
  
  let viewModel: AlertViewModel
  let alertType: AppAlertType
  let buttonSidePadding: CGFloat = 15
  let buttonBottomPadding: CGFloat = 10
  
  public var body: some View {
    VStack(spacing: 5) {
      contentView
    }
    .fixedSize(horizontal: false, vertical: true)
    .background(Color.EcoSort.Base.background)
    .cornerRadius(12)
    .shadow(style: .modal)
    .padding(AppPadding.large.value)
    
  }
  
  @ViewBuilder
  private var contentView: some View {
    switch alertType {
    case .simple:
      Spacer()
      Text(viewModel.title).foregroundColor(Color.EcoSort.Text.text5)
        .font(.EcoSort.title3)
        .padding(5)
      messageView
      if let primaryButton = viewModel.primaryButtonTitle {
        alertButton(title: primaryButton, buttonAction: viewModel.primaryButtonAction)
          .buttonStyle(PrimaryCapsuleButtonStyle())
          .padding(.vertical, buttonBottomPadding)
          .padding(.horizontal, buttonSidePadding)
      }
      if let secondaryButton = viewModel.secondaryButtonTitle {
        alertButton(title: secondaryButton, buttonAction: viewModel.secondaryButtonAction)
          .buttonStyle(SecondaryButtonStyle())
          .padding(.bottom, buttonBottomPadding * 2)
          .padding(.horizontal, buttonSidePadding)
      }
    case .imageAsHeader:
      Spacer(minLength: 20)
      Image(viewModel.imageName ?? "", bundle: .sharedResources)
        .resizable()
        .frame(width: 100, height: 80, alignment: .center)
      Spacer(minLength: 20)
      messageView
      Spacer(minLength: 20)
      alertButton(title: viewModel.primaryButtonTitle ?? "",
                  buttonAction: viewModel.primaryButtonAction)
      .buttonStyle(PrimaryCapsuleButtonStyle())
      .padding(.vertical, buttonBottomPadding)
      .padding(.horizontal, buttonSidePadding)
      Spacer(minLength: 10)
    }
  }
  
  @ViewBuilder
  var messageView: some View {
    ScrollView(.vertical) {
      VStack(alignment: .center) {
        Text(viewModel.message)
          .foregroundColor(Color.EcoSort.Text.text5)
          .font(.EcoSort.body1)
          .multilineTextAlignment(.center)
          .frame(alignment: .center)
      }
    }
    .frame(alignment: .center)
    .padding(.horizontal, 20)
  }
  
  @ViewBuilder
  func alertButton(title: LocalizedStringKey, buttonAction: ButtonAction?) -> some View {
    VStack {
      Button(action: {
        buttonAction?()
        buttonTapped()
        withAnimation {
          dismissAlert()
        }
      }, label: {
        Text(title)
          .frame(maxHeight: 20)
      })
    }
  }
  
  func dismissAlert() {
    if viewModel.canDismiss {
      showAlert.toggle()
    }
  }
  
  private func buttonTapped() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
  }
}
