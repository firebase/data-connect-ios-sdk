// Copyright 2025 Google LLC
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

import Foundation

/// This struct is for internal Firebase Data Connect use only
public struct TemplateProjectManager {
  public init() {}

  /// Copies a folder named "Templates" from the package's resource bundle
  /// to the current working directory.
  public func copyTemplateProject(to directoryURL: URL? = nil) throws {
    #if os(macOS)
      let fileManager = FileManager.default

      guard let workingDirectoryURL = directoryURL else {
        print("❌ Invalid target directory URL. Cannot copy template project.")
        return
      }

      guard !containsDataConnectProject(folderURL: workingDirectoryURL) else {
        print(
          "ℹ️ Working directory already contains a dataconnect project. Skipping copy of template project."
        )
        return
      }

      let resourceFolderName = "dataconnect"
      let destinationURL = workingDirectoryURL.appendingPathComponent(resourceFolderName)

      // 3. Find the URL for the resource folder within the compiled tool's bundle
      guard let sourceURL = Bundle.module.url(
        forResource: resourceFolderName,
        withExtension: nil,
        subdirectory: "Resources/demo-iosproject"
      ) else {
        throw NSError(domain: "StartFDCTools", code: 1, userInfo: [
          NSLocalizedDescriptionKey: "Could not find '\(resourceFolderName)' in the resource bundle.",
        ])
      }

      // 4. Perform the copy operation
      try fileManager.copyItem(at: sourceURL, to: destinationURL)

      // Copy the firebase.json
      if let sourceJsonUrl = Bundle.module.url(
        forResource: "firebase",
        withExtension: "json",
        subdirectory: "Resources/demo-iosproject"
      ) {
        let destinationJson = workingDirectoryURL.appendingPathComponent("firebase.json")
        try fileManager.copyItem(at: sourceJsonUrl, to: destinationJson)
      }

      // Copy the GoogleServices-Info.plist
      if let sourcePlistUrl = Bundle.module.url(
        forResource: "GoogleService-Info",
        withExtension: "plist",
        subdirectory: "Resources/demo-iosproject"
      ) {
        let destinationPlist = workingDirectoryURL
          .appendingPathComponent("GoogleService-Info.plist")
        try fileManager.copyItem(at: sourcePlistUrl, to: destinationPlist)
      }
    #endif
  }

  // Looks for dataconnect.yaml file within the specified folder recursively
  func containsDataConnectProject(folderURL: URL) -> Bool {
    #if os(macOS)
      let fileManager = FileManager.default
      if let enumerator = fileManager.enumerator(
        at: folderURL,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
      ) {
        for case let itemURL as URL in enumerator {
          if itemURL.lastPathComponent.contains("dataconnect.yaml") {
            print("Found existing dataconnect.yaml \(itemURL)")
            return true
          }
        }
      }
    #endif
    return false
  }
}
