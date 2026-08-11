// Copyright 2026 Google LLC
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


private let connectionGracePeriodNanoseconds: UInt64 = 15_000_000_000

/// Tracks the grace period connection state.
/// This class is not thread-safe by itself and is intended to be encapsulated and accessed
/// exclusively within the isolation of `StreamSubscriptionManager` (which is an `actor`).
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class ConnectionGracePeriodTracker {
  private let clock: any DataConnectClock
  private var gracePeriodTask: Task<Void, Never>?

  private(set) var gracePeriodExpired = false

  init(clock: any DataConnectClock = ContinuousDataConnectClock()) {
    self.clock = clock
  }

  func startGracePeriod(onExpired: @escaping @Sendable () async -> Void) {
    guard gracePeriodTask == nil else { return }
    let clock = self.clock

    gracePeriodTask = Task { [weak self] in
      do {
        try await clock.sleep(for: connectionGracePeriodNanoseconds)
        guard let self = self, !Task.isCancelled else { return }
        self.gracePeriodExpired = true
        self.gracePeriodTask = nil
        await onExpired()
      } catch {
        // Task was cancelled
      }
    }
  }

  func cancelGracePeriod() {
    gracePeriodTask?.cancel()
    gracePeriodTask = nil
    gracePeriodExpired = false
  }
}
