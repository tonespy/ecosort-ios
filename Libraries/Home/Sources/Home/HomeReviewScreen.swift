//
//  NewHomeReviewScreen.swift
//  Home
//
//  Created by Abubakar Oladeji on 24/03/2025.
//

import Assets
import Combine
import Foundation
import SwiftData
import SwiftUI

enum SwipeCardDirection {
  case left
  case right
  case none
}

struct SectionItemReview: Identifiable {
  var id: UUID
  var groupName: String
  var items: [PredictionSessionMedia]
}

final class HomeReviewScreenViewModel: ObservableObject {
  var selectedItemForChange: PredictionSessionMedia? = nil
}

struct HomeReviewScreen: View {
  @Environment(\.modelContext) private var modelContext: ModelContext
  @EnvironmentObject var homeState: HomeState
  let sessionId: UUID

  @State private var unreviewedItems: [PredictionSessionMedia] = []
  @State private var allItems: [PredictionSessionMedia] = []
  @State private var renderedSections: [SectionItemReview] = []
  @State private var allClass = [SessionGroupClass]()
  @State private var showCorrectionSheet: Bool = false
  @State private var showChangeSheet: Bool = false
  @State private var showSelectedSheet: Bool = false
  @StateObject private var viewModel = HomeReviewScreenViewModel()

  @State private var dragState = CGSize.zero
  private let rotationFactor: Double = 35.0

  init (sessionId: UUID) {
    self.sessionId = sessionId
  }

  var body: some View {
    ZStack {
      Color.EcoSort.Base.background

      // Implementation gotten from:
      // https://medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8
      if !unreviewedItems.isEmpty {
        VStack {
          VStack(alignment: .center) {
            ZStack {
              ForEach(unreviewedItems.reversed()) { card in
                let isTopCard = card == unreviewedItems.first
                let isSecondCard = card == unreviewedItems.dropFirst().first

                NewCardView(
                  model: card,
                  dragOffset: dragState,
                  isTopCard: isTopCard,
                  isSecondCard: isSecondCard
                )
                .offset(x: isTopCard ? dragState.width : 0)
                .rotationEffect(.degrees(isTopCard ? Double(dragState.width) / rotationFactor : 0))
              }
            }
            .padding()

            // Buttons to trigger swipe animation.
            HStack(spacing: 40) {
              Button(action: {
                swipeTopCard(.left)
              }) {
                Image(systemName: "xmark")
                  .font(.largeTitle)
                  .padding()
                  .background(Color.red)
                  .foregroundColor(.white)
                  .clipShape(Circle())
              }

              Button(action: {
                swipeTopCard(.right)
              }) {
                Image(systemName: "heart")
                  .font(.largeTitle)
                  .padding()
                  .background(Color.green)
                  .foregroundColor(.white)
                  .clipShape(Circle())
              }
            }
            .padding(.top, 20)
          }
        }
      }

      if unreviewedItems.isEmpty && !renderedSections.isEmpty {
        ScrollView {
          LazyVStack(
            alignment: .leading,
            spacing: SpacingSize.medium.value,
            pinnedViews: [.sectionHeaders]
          ) {
            ForEach(renderedSections, id: \.id) { section in
              Section {
                ForEach(section.items, id: \.id) { item in
                  VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: SpacingSize.small) {
                      HStack(alignment: .top) {
                        Image(uiImage: UIImage(data: item.data)!)
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 50, height: 50)

                        VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                          Text("Classification")
                            .font(Font.EcoSort.caption1)
                            .foregroundStyle(Color.EcoSort.Text.text2)

                          Text(item.actualClass?.displayName ?? "Unknown")
                            .font(Font.EcoSort.body)
                            .foregroundStyle(Color.EcoSort.Text.text4)

                          if !item.isPredictionAccurate {
                            Text(item.predictedClass?.displayName ?? "Unknown")
                              .font(Font.EcoSort.caption1)
                              .foregroundStyle(Color.EcoSort.Text.text4)
                              .strikethrough(pattern: .dashDot, color: Color.EcoSort.Brand.brick)
                          }
                        }

                        VStack(alignment: .leading, spacing: SpacingSize.xSmall) {
                          Text("Prediction State")
                            .font(Font.EcoSort.caption1)
                            .foregroundStyle(Color.EcoSort.Text.text2)

                          Text(item.isPredictionAccurate ? "Accurate" : "Inaccurate")
                            .font(Font.EcoSort.body)
                            .foregroundStyle(
                              item.isPredictionAccurate ? Color.EcoSort.Brand.green : Color.EcoSort.Brand.brick
                            )
                            .padding([.top, .bottom], 4)
                            .padding([.trailing, .leading], 8)
                            .background(
                              RoundedRectangle(cornerRadius: 4)
                                .fill(item.isPredictionAccurate ? Color.EcoSort.Content.positiveLight : Color.EcoSort.Brand.brickInverse)
                            )
                        }

                        VStack(
                          alignment: .trailing,
                          spacing: SpacingSize.xSmall
                        ) {
                          Spacer()

                          HStack {
                            Spacer()

                            Button {
                              viewModel.selectedItemForChange = item
                              self.showSelectedSheet = true
                            } label: {
                              Text("Change")
                                .font(Font.EcoSort.body)
                                .foregroundColor(.EcoSort.Text.textO)
                                .padding(8)
                                .background(
                                  RoundedRectangle(cornerRadius: SpacingSize.small.value)
                                    .fill(Color.EcoSort.Button.primary)
                                )
                            }
                          }
                        }
                      }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.EcoSort.Neutral.neutral0)
                    .overlay {
                      RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color.EcoSort.Neutral.neutral1)
                    }
                  }
                  .padding([.leading, .trailing])
                }
              } header: {
                HStack(alignment: .center, spacing: 8) {
                  Text(section.groupName.capitalized)
                    .font(Font.EcoSort.heading)
                    .foregroundStyle(Color.EcoSort.Text.text2)

                  Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.EcoSort.Text.text2)
                    .frame(maxWidth: .infinity)
                }
                .padding([.leading, .trailing])
              }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.EcoSort.Base.background)
          }
        }
        .listStyle(.grouped)
        .background(Color.EcoSort.Base.background)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
      }
    }
    .onAppear {
      if allItems.isEmpty {
        loadItems()
      }

      if allClass.isEmpty {
        loadClasses()
      }
    }
    .sheet(isPresented: $showCorrectionSheet) {
      NavigationView {
        List(fetchAllClassExcludingFirstMedia()) { item in
          HStack {
            Text(item.displayName)
              .font(Font.EcoSort.body)
              .foregroundColor(.EcoSort.Text.text4)

            if let groupName = item.group?.name {
              Text(groupName)
                .font(Font.EcoSort.bodyS)
                .foregroundColor(.EcoSort.Text.text3)
            }
          }
          .onTapGesture {
            handleSwipeLeftCorrection(item)
            showCorrectionSheet = false
          }
        }
        .navigationTitle("Select Items")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              resetSwipe()
              showCorrectionSheet = false
            } label: {
              Text("Cancel")
            }
          }
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
      }
    }
    .sheet(isPresented: $showSelectedSheet) {
      NavigationView {
        List(fetchClassForItemChange()) { item in
          HStack {
            Text(item.displayName)
              .font(Font.EcoSort.body)
              .foregroundColor(.EcoSort.Text.text4)

            if let groupName = item.group?.name {
              Text(groupName)
                .font(Font.EcoSort.bodyS)
                .foregroundColor(.EcoSort.Text.text3)
            }
          }
          .onTapGesture {
            handleSelectedItemCorrection(item)
            showSelectedSheet = false
          }
        }
        .navigationTitle("Select Items")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              showSelectedSheet = false
              viewModel.selectedItemForChange = nil
            } label: {
              Text("Cancel")
            }
          }
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
      }
    }
  }

  private func loadItems() {
    let descriptor = FetchDescriptor<PredictionSessionMedia>(
      predicate: #Predicate { $0.session?.id == sessionId && $0.predictedClass != nil }
    )

    guard let allItems = try? modelContext.fetch(descriptor) else {
      return
    }

    self.unreviewedItems = allItems.filter { $0.actualClass == nil }
    self.allItems = allItems
    groupBySection()
  }

  private func groupBySection() {
    var grouped: [String: [PredictionSessionMedia]] = [:]
    for item in allItems {
      guard let groupName = item.actualClass?.group?.name else {
        continue
      }

      if var groupData = grouped[groupName] {
        groupData.append(item)
        grouped[groupName] = groupData
      } else {
        grouped[groupName] = [item]
      }
    }

    renderedSections = grouped.map { (key, value) in
      return SectionItemReview(id: UUID(), groupName: key, items: value)
    }.sorted { $0.groupName < $1.groupName }
  }

  private func loadClasses() {
    let classDescriptor = FetchDescriptor<PredictionSessionGroup>(
      predicate: #Predicate { $0.session?.id == sessionId }
    )

    guard let allGroups = try? modelContext.fetch(classDescriptor) else {
      return
    }
    self.allClass = allGroups.map { $0.classes }.flatMap(\.self)
  }

  private func fetchAllClassExcludingFirstMedia() -> [SessionGroupClass] {
    guard let firstMedia = unreviewedItems.first, let name = firstMedia.predictedClass?.name else {
      return []
    }

    return allClass.filter { $0.name != name }
  }

  private func fetchClassForItemChange() -> [SessionGroupClass] {
    guard let name = viewModel.selectedItemForChange?.actualClass?.name else {
      return []
    }

    return allClass.filter { $0.name != name }
  }

  private func handleSwipeRight() {
    guard let first = unreviewedItems.first else {
      return
    }

    self.dragState.width = 1000
    first.actualClass = first.predictedClass

    try? modelContext.save()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.dragState = .zero
      self.unreviewedItems.removeFirst()

      if unreviewedItems.isEmpty {
        self.loadItems()
      }
    }
  }

  private func handleSelectedItemCorrection(_ item: SessionGroupClass) {
    guard let selectedItemForChange = viewModel.selectedItemForChange else {
      return
    }
    
    selectedItemForChange.actualClass = item
    try? modelContext.save()
    viewModel.selectedItemForChange = nil
    self.loadItems()
  }

  private func handleSwipeLeftCorrection(_ item: SessionGroupClass) {
    guard let first = unreviewedItems.first else {
      return
    }

    first.actualClass = item
    try? modelContext.save()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.dragState = .zero
      self.unreviewedItems.removeFirst()

      if unreviewedItems.isEmpty {
        self.loadItems()
      }
    }
  }

  private func handleSwipeLeft() {
    guard let _ = unreviewedItems.first else {
      return
    }

    self.dragState.width = -1000
    self.showCorrectionSheet = true
  }

  // Animate and swipe the top card using a button action.
  private func swipeTopCard(_ direction: SwipeCardDirection) {
    withAnimation(.easeInOut(duration: 0.5)) {
      switch direction {
      case .left:
        handleSwipeLeft()
      case .right:
        handleSwipeRight()
      case .none:
        self.dragState = .zero
      }
    }
  }

  private func resetSwipe() {
    withAnimation(.easeInOut(duration: 0.5)) {
      self.dragState = .zero
    }
  }
}
