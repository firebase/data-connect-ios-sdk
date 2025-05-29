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


import Darwin
import DarwinFoundation
import Foundation

@available(macOS 12.0, *)
@main
struct StartDevEnv {

  static let process: Process = Process()

  static func main() {
    print("Start Dev Environment Called \(FileManager.default.currentDirectoryPath)")

    let outputPipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "curl -sL https://firebase.tools/dataconnect | bash"]
    process.standardOutput = outputPipe
    process.standardError = outputPipe

    // Set up the signal handler
    let signalSource: DispatchSourceSignal = DispatchSource.makeSignalSource(
      signal: SIGTERM,
      queue: .main
    )

    signalSource.setEventHandler {
      print("\nCaught SIGINT (Ctrl+C). Performing cleanup tasks...")
      // Add your cleanup logic here
      process.terminate()
      print("Cleanup complete. Exiting gracefully.")
      exit(EXIT_SUCCESS)
    }

    signalSource.resume()

    print("Swift command line app is running.")
    print("Press Ctrl+C to send a SIGINT signal and trigger the cleanup process.")

    do {
      try process.run()
      let pid = process.processIdentifier
      print("process run called. pid \(pid)")

      process.terminationHandler = { terminatedTask in
        print("termination handler called \(terminatedTask.processIdentifier)")
        do {
          if let outputData = try outputPipe.fileHandleForReading.readToEnd() {
            let output = String(data: outputData, encoding: .utf8)
            print("output \n \(output)")
          }
        } catch {
          print("Error getting outputData \(error)")
        }

      }

      outputPipe.fileHandleForReading.readabilityHandler = { pipe in
        if let line = String(data: pipe.availableData, encoding: .utf8) {
          print(line)
        } else {
          // this is rare
          print("Error decoding outputData")
        }
      }

      defer {
        print("Terminating script process")
        process.terminate()
      }

      process.waitUntilExit()

      // print out any leftover output
      do {
        if let outputData = try outputPipe.fileHandleForReading.readToEnd() {
          let output = String(data: outputData, encoding: .utf8)
          print(output)
        }
      }

      print("Calling terminate before exiting main")
      process.terminate()

    } catch {
      print("Error executing script \(error)")
      process.terminate()
    }

  }
}
