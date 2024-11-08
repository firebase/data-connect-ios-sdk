// Copyright © 2024 Google LLC. All rights reserved.
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

struct DetailsSection<Title, Details>: View where Title: View, Details: View {
  var title: () -> Title
  var content: () -> Details

  init(@ViewBuilder _ title: @escaping () -> Title, @ViewBuilder content: @escaping () -> Details) {
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center) {
        title()
          .font(.title2)
          .bold()
        Image(systemName: "chevron.right")
          .font(.title3)
          .bold()
          .foregroundStyle(Color.secondary)
        Spacer()
      }
      .padding(.bottom, 8)

      content()
    }
    .padding(.bottom, 20)
  }
}

extension DetailsSection where Title == Text {
  init(_ title: Text, content: @escaping () -> Details) {
    self.title = { title }
    self.content = { content() }
  }

  init(_ title: any StringProtocol, content: @escaping () -> Details) {
    self.title = { Text(title) }
    self.content = { content() }
  }
}

#Preview {
  ScrollView {
    DetailsSection(Text("Title")) {
      Text("Details go here")
    }

    DetailsSection("Title as string") {
      Text("Details go here")
    }

    DetailsSection {
      NavigationLink(value: Movie.mock) {
        Text("Movie")
      }
    } content: {
      Text("Details go here")
    }
  }
}
