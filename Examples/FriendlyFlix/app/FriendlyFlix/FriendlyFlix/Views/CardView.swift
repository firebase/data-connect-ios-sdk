//
// CardView.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 30.09.24.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

// Try for blendmode https://saeedrz.medium.com/unleashing-creativity-a-deep-dive-into-blendmode-in-swiftui-2edc3f204fa8

struct CardView<Hero: View, Title: View, Details: View>: View {
  @Environment(\.dismiss) var dismiss

  var showDetails = true

  var hero: some View {
    heroView()
  }

  var heroView: () -> Hero
  var heroTitle: () -> Title
  var details: () -> Details

  public init(showDetails: Bool = false, @ViewBuilder heroView: @escaping () -> Hero,
              @ViewBuilder heroTitle: @escaping () -> Title,
              @ViewBuilder details: @escaping () -> Details) {
    self.showDetails = showDetails
    self.heroView = heroView
    self.heroTitle = heroTitle
    self.details = details
  }

  var cardView: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        hero
        heroTitle()
      }
      .clipShape(
        UnevenRoundedRectangle(
          cornerRadii: .init(
            topLeading: cornerRadius,
            bottomLeading: showDetails ? 0 : 16,
            bottomTrailing: showDetails ? 0 : 16,
            topTrailing: cornerRadius
          ),
          style: .continuous
        )
      )
      .padding(showDetails ? 0 : 16)
      .shadow(radius: showDetails ? 0 : 8)

      if showDetails {
        details()
          .background(Color(UIColor.systemBackground))
      }
    }
  }

  @State var scaleFactor: CGFloat = 1
  @State var cornerRadius: CGFloat = 16

  var body: some View {
    if showDetails {
      ScrollView {
        cardView
          .scaleEffect(scaleFactor)
          .navigationBarBackButtonHidden(true)
          .statusBarHidden()
      }
      .ignoresSafeArea()

      // Start: drag down to pop back
      .background(Color(UIColor.secondarySystemBackground))
      .scrollIndicators(scaleFactor < 1 ? .hidden : .automatic, axes: .vertical)
      .onScrollGeometryChange(for: CGFloat.self) { geometry in
        geometry.contentOffset.y
      } action: { oldValue, newValue in
        if newValue >= 0 {
          scaleFactor = 1
          cornerRadius = 16
        } else {
          scaleFactor = 1 - (0.1 * (newValue / -50))
          cornerRadius = 55 - (35 / 50 * -newValue)
        }
      }
      .onScrollGeometryChange(for: Bool.self) { geometry in
        geometry.contentOffset.y < -50
      } action: { oldValue, newValue in
        if newValue {
          dismiss()
        }
      }
      // End: drag down to pop back
    } else {
      cardView
        .foregroundColor(.primary)
    }
  }
}

#Preview {
  NavigationStack {
    CardView(showDetails: true) {
      GradientView(configuration: GradienConfiguration.sample)
        .frame(height: 450)
    } heroTitle: {
      VStack(alignment: .leading) {
        Spacer()
        Text("Here be titles")
          .font(.title)
        Text("And subtitles")
          .font(.title3)
      }
      .foregroundColor(Color(UIColor.systemGroupedBackground))
      .padding()
    } details: {
      VStack {
        Text(
          """
          Amet culpa excepteur sit ad tempor minim aute anim nisi voluptate do. Exercitation nisi adipisicing esse officia sit ullamco.
          Tempor ullamco irure proident cupidatat non Lorem ut voluptate est ad in deserunt esse velit exercitation. Tempor voluptate ex aute id.
          Fugiat in minim labore minim duis et duis eiusmod ullamco eiusmod minim deserunt voluptate.
          """
        )
        .font(.body)
        .padding()
      }
    }
  }
}

#Preview {
  ScrollView {
    CardView(showDetails: false) {
      GradientView(configuration: GradienConfiguration.sample)
        .frame(height: 450)
    } heroTitle: {
      VStack(alignment: .leading) {
        Spacer()
        Text("Here be titles")
          .font(.title)
        Text("And subtitles")
          .font(.title3)
      }
      .foregroundColor(Color(UIColor.systemGroupedBackground))
      .padding()
    } details: {
      VStack {
        Text(
          """
          Amet culpa excepteur sit ad tempor minim aute anim nisi voluptate do. Exercitation nisi adipisicing esse officia sit ullamco.
          Tempor ullamco irure proident cupidatat non Lorem ut voluptate est ad in deserunt esse velit exercitation. Tempor voluptate ex aute id.
          Fugiat in minim labore minim duis et duis eiusmod ullamco eiusmod minim deserunt voluptate.
          """
        )
        .font(.body)
        .padding()
      }
    }
    CardView(showDetails: false) {
      GradientView(configuration: GradienConfiguration.samples[1])
        .frame(height: 450)
    } heroTitle: {
      VStack(alignment: .leading) {
        Spacer()
        Text("Here be titles")
          .font(.title)
        Text("And subtitles")
          .font(.title3)
      }
      .foregroundColor(Color(UIColor.systemGroupedBackground))
      .padding()
    } details: {
      VStack {
        Text(
          """
          Amet culpa excepteur sit ad tempor minim aute anim nisi voluptate do. Exercitation nisi adipisicing esse officia sit ullamco.
          Tempor ullamco irure proident cupidatat non Lorem ut voluptate est ad in deserunt esse velit exercitation. Tempor voluptate ex aute id.
          Fugiat in minim labore minim duis et duis eiusmod ullamco eiusmod minim deserunt voluptate.
          """
        )
        .font(.body)
        .padding()
      }
    }
    CardView(showDetails: false) {
      GradientView(configuration: GradienConfiguration.samples[2])
        .frame(height: 450)
    } heroTitle: {
      VStack(alignment: .leading) {
        Spacer()
        Text("Here be titles")
          .font(.title)
        Text("And subtitles")
          .font(.title3)
      }
      .foregroundColor(Color(UIColor.systemGroupedBackground))
      .padding()
    } details: {
      VStack {
        Text(
          """
          Amet culpa excepteur sit ad tempor minim aute anim nisi voluptate do. Exercitation nisi adipisicing esse officia sit ullamco.
          Tempor ullamco irure proident cupidatat non Lorem ut voluptate est ad in deserunt esse velit exercitation. Tempor voluptate ex aute id.
          Fugiat in minim labore minim duis et duis eiusmod ullamco eiusmod minim deserunt voluptate.
          """
        )
        .font(.body)
        .padding()
      }
    }
  }
}
