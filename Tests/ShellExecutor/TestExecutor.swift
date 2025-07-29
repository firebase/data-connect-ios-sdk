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

import XCTest

#if os(macOS)
  @testable import ShellExecutor

  @available(macOS 12.0, *)
  final class ShellExecutorTests: XCTestCase {
    var executor: ShellExecutor!

    override func setUp() {
      super.setUp()
      // This is run before each test
      executor = ShellExecutor()
    }

    /// Tests that a simple, successful command completes without throwing a Swift error.
    func testSuccessfulCommand() {
      // The `true` command does nothing and exits with status 0.
      XCTAssertNoThrow(
        try executor.run("true"),
        "A successful command should not throw an error."
      )
    }

    /// Tests that a failing command completes without throwing a Swift error,
    /// as our function handles the non-zero exit code internally.
    func testFailingCommand() {
      // The `false` command does nothing and exits with status 1.
      XCTAssertNoThrow(
        try executor.run("false"),
        "A failing command should be handled gracefully, not throw."
      )
    }

    /// Tests if the standard output from the command is correctly captured and printed.
    func testStandardOutputCapture() throws {
      let testString = "Hello from XCTest!"
      let command = "echo '\(testString)'"

      // We need to capture the process's stdout to verify it.
      // This is a common pattern for testing command-line output.
      let outputPipe = Pipe()

      // Save the original standard output file handle
      let originalStdout = dup(STDOUT_FILENO)

      // Redirect stdout to our pipe's write end
      dup2(outputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

      // Run the command. Its output will go into the pipe.
      try executor.run(command)

      // Close the write end of the pipe to signal end-of-file
      try outputPipe.fileHandleForWriting.close()

      // Restore the original standard output
      dup2(originalStdout, STDOUT_FILENO)
      close(originalStdout)

      // Read all data from the pipe
      let capturedData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      let capturedOutput = String(data: capturedData, encoding: .utf8) ?? ""

      XCTAssertTrue(
        capturedOutput.contains(testString),
        "The captured output should contain the test string '\(testString)'"
      )

      XCTAssertTrue(
        capturedOutput.contains("✅ ShellExecutor: Command finished successfully."),
        "The output should contain the success message."
      )
    }
  }
#endif
