//
//  AppLoadingView.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 08/02/2025.
//

import SwiftUI

public struct SpinnerLoadingView: View {
  @ObservedObject var viewModel: SpinnerLoadingViewModel
  @State var fillRatio: CGFloat = 0
  @State var fillRatio1: CGFloat = 0.33
  @State var fillRatio2: CGFloat = 0.66
  private let animationDuration = 0.3
  
  public init(viewModel: SpinnerLoadingViewModel) {
    self.viewModel = viewModel
  }
  
  public init () {
    self.viewModel = .init()
  }
  
  public var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundColor(Color.EcoSort.Base.background)
      
      // Background circle
      Circle()
        .stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 2))
      
      ZStack {
        // Animation Circle
        Circle()
          .trim(from: 0, to: self.fillRatio)
          .stroke(Color.EcoSort.Content.primary, style: StrokeStyle(lineWidth: 5))
          .rotationEffect(.init(degrees: -180))
          .onAnimationCompleted(for: self.fillRatio) {
            self.fillRatio = 0
            withAnimation(.linear(duration: animationDuration)) {
              viewModel.nextImage()
              self.fillRatio1 = 0.66
            }
          }
        
        Circle()
          .trim(from: 0.33, to: self.fillRatio1)
          .stroke(Color.EcoSort.Content.secondary, style: StrokeStyle(lineWidth: 5))
          .rotationEffect(.init(degrees: -180))
          .onAnimationCompleted(for: self.fillRatio1) {
            self.fillRatio1 = 0.33
            withAnimation(.linear(duration: animationDuration)) {
              viewModel.nextImage()
              self.fillRatio2 = 1
            }
          }
        
        Circle()
          .trim(from: 0.66, to: self.fillRatio2)
          .stroke(Color.EcoSort.Neutral.neutralO, style: StrokeStyle(lineWidth: 5))
          .rotationEffect(.init(degrees: -180))
          .onAnimationCompleted(for: self.fillRatio2) {
            self.fillRatio2 = 0.66
            withAnimation(.linear(duration: animationDuration)) {
              viewModel.nextImage()
              self.fillRatio = 0.33
            }
          }
        
        // Icons
        viewModel.image
          .resizable()
      }
      .padding(AppPadding.large.value)
    }
    .onAppear {
      withAnimation(.linear(duration: animationDuration)) {
        self.fillRatio = 0.33
      }
    }
  }
}

public class SpinnerLoadingViewModel: ObservableObject {
  
  private let imagesArray = [
    Image.EcoSort.Loading.bottle,
    Image.EcoSort.Loading.glass,
    Image.EcoSort.Loading.paper,
    Image.EcoSort.Loading.plastic,
    Image.EcoSort.Loading.sock,
    Image.EcoSort.Loading.trash,
  ]
  private var imageIndex: Int = 0
  @Published var image: Image = Image.EcoSort.Loading.bottle
  
  public init() { }
  
  func nextImage() {
    imageIndex = imageIndex < imagesArray.count - 1 ? imageIndex + 1 : 0
    self.image = imagesArray[imageIndex]
  }
}

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {
  
  /// While animating, SwiftUI changes the old input value to the new target value using this property.
  /// This value is set to the old value until the animation completes.
  var animatableData: Value {
    didSet {
      notifyCompletionIfFinished()
    }
  }
  
  /// The target value for which we're observing. This value is directly set once the animation starts.
  /// During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
  private var targetValue: Value
  
  /// The completion callback which is called once the animation completes.
  private var completion: () -> Void
  
  init(observedValue: Value, completion: @escaping () -> Void) {
    self.completion = completion
    self.animatableData = observedValue
    targetValue = observedValue
  }
  
  /// Verifies whether the current animation is finished and calls the completion callback if true.
  private func notifyCompletionIfFinished() {
    guard animatableData == targetValue else { return }
    
    /// Dispatching is needed to take the next runloop for the completion callback.
    /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
    DispatchQueue.main.async {
      self.completion()
    }
  }
  
  func body(content: Content) -> some View {
    /// We're not really modifying the view so we can directly return the original input value.
    return content
  }
}

extension View {
  
  /// Calls the completion handler whenever an animation on the given value completes.
  /// - Parameters:
  ///   - value: The value to observe for animations.
  ///   - completion: The completion callback to call once the animation completes.
  /// - Returns: A modified `View` instance with the observer attached.
  func onAnimationCompleted<Value: VectorArithmetic>(
    for value: Value,
    completion: @escaping () -> Void
  ) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
    return modifier(
      AnimationCompletionObserverModifier(
        observedValue: value,
        completion: completion
      )
    )
  }
}
