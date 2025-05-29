//
//  DevEnvironmentManager.swift
//  FDCToolsV1
//
//  Created by Aashish Patil on 5/26/25.
//

import Foundation


enum OutputMarkers: String, RawRepresentable {

  case starting = "**Starting**"
  case startingCodeServer = "**StartingCodeServer**"
  case doneCodeServer = "**EndCodeServer**"
  case startingFDCExtension = "-- Installing Firebase Data Connect extension"
  case doneFDCExtension = "**EndFirebaseDataConnectExtension**"
  case startingFirebaseCLI = "**StartFirebaseCLI**"
  case doneFirebaseCLI = "**EndFirebaseCLI**"
  case setupComplete = "HTTP server listening on"
  //TODO Add cases for error markers
}

actor DevEnvironmentManager {

  static let manager = DevEnvironmentManager()

  private init() {}

  private var codeServerProcess: Process? = nil

  private var outputPipe: Pipe? = nil

  // We use a dispatch queue since output is provided on a block which doesn't play well with actor
  private let outputUpdateQueue = DispatchQueue(label: "fdcTool.outputUpdateQ", autoreleaseFrequency: .workItem)

  func setupDevEnv() async throws {
    try await runScript(name: "setup-dev-env")
  }

  func startDevEnv() async throws {
    try await runScript(name: "start-dev-server")
  }

  private func runScript(name: String) async throws {

    if let codeServerProcess {
      print("We have an existing process. Terminating that")
      //codeServerProcess.terminate()
      return
    }

    guard let scriptLocalPath = Bundle.main.path(forResource: name, ofType: "sh") else {
      print("No local script path for \(name)")
      return
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    //process.arguments = ["-c", "curl -sL https://firebase.tools/dataconnect | bash"]
    process.arguments = ["-c", " source \(scriptLocalPath)"]

    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = outputPipe
    print("about to call run")

    try process.run()
    print("run completed")

    self.codeServerProcess = process
    self.outputPipe = outputPipe

    outputPipe.fileHandleForReading.readabilityHandler = { pipe in
      if let line = String(data: pipe.availableData, encoding: .utf8) {
        print(line)

        self.handleOutputLine(line: line)

        /*
        if line.contains("HTTP server listening on") {
          ViewState.state.selectedProjectFolder = URL(fileURLWithPath: "/Users/aashishp/Scratchpad/fdc-test-app")
        }*/
      } else {
        print("Error decoding outputData")
      }
    }


    process.terminationHandler = { p in
      print("Process terminated")
      do {
        if let outputData = try outputPipe.fileHandleForReading.readToEnd() {
          let output = String(data: outputData, encoding: .utf8)
          print("termination output \n \(output)")
        }
      } catch {
        print("Error getting outputData \(error)")
      }
    }

    process.waitUntilExit()

  }

  func stopProcess() {
    if let process = self.codeServerProcess {
      process.terminate()
      print("called process terminate")
    }
  }

  nonisolated private func handleOutputLine(line: String) {

    outputUpdateQueue.async {

      /*
      var state: SetupState = ViewState.state.setupState
      if line.contains(OutputMarkers.startingCodeServer.rawValue) {
        state = .codeServerInit
      } else if line.contains(OutputMarkers.doneCodeServer.rawValue) {
        state = .codeServerDone
      } else if line.contains(OutputMarkers.startingFDCExtension.rawValue) {
        state = .dataConnectExtInit
      } else if line.contains(OutputMarkers.doneFDCExtension.rawValue) {
        state = .dataConnectExtDone
      } else if line.contains(OutputMarkers.startingFirebaseCLI.rawValue) {
        state = .firebaseCLIInit
      } else if line.contains(OutputMarkers.doneFirebaseCLI.rawValue) {
        state = .firebaseCLIDone
      } else if line.contains(OutputMarkers.setupComplete.rawValue) {
        state = .setupComplete
      }
       */

      DispatchQueue.main.async {
        if line.contains(OutputMarkers.setupComplete.rawValue) {
          ViewState.state.setupState = .setupComplete

          if let lp = ViewState.state.lastProjectFolder {
            print("Setting selected folder to last saved")
            ViewState.state.selectedProjectFolder = lp
          }
        }

        ViewState.state.setupOutput += line
        //print("setupOutput \(ViewState.state.setupOutput)")

      }
    }

  }

}
