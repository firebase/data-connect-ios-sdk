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

#if os(macOS)
  import ShellExecutor
  import TemplateProject
#endif

// port on which FDC tools (code-server) listen
let FDC_TOOLS_PORT: UInt = 9394

@available(macOS 12.0, *)
@main
struct SetupDevEnv {
  static func main() {
    #if os(macOS)
      let currentDirectoryPath = FileManager.default.currentDirectoryPath
      print(
        "ℹ️ Attempting to start Firebase Data Connect Tools in Directory: \(currentDirectoryPath)"
      )

      let executor = ShellExecutor()

      do {
        // When the `Start FDC Tools` process is stopped from Xcode,
        // it still leaves an orphaned code-server process since SIGKILL isn't received by the
        // command line utility
        try executor.killProcessOnPort(FDC_TOOLS_PORT)
      } catch {
        print("❌ Error killing process \(error)")
      }

      if !CommandLine.arguments.contains("--skip-template-project") {
        do {
          let templateManager = TemplateProjectManager()
          try templateManager
            .copyTemplateProject(to: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))

        } catch {
          print("❌ Error copying template project: \(error)")
        }
      } else {
        print("ℹ️ Skipping copying template project because --skip-template-project was provided")
      }

      do {
        let commandToRun = "curl -sL https://firebase.tools/dataconnect | bash"
        try executor.run(commandToRun)
      } catch {
        print("❌ Error running command: \(error)")
      }
    #endif // if macos
  }
}
