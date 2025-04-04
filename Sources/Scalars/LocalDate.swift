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

/*
 LocalDate represents an ISO-8601 formatted date without time components.

 Essentially represents: https://the-guild.dev/graphql/scalars/docs/scalars/local-date
 */
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct LocalDate: Codable, Comparable, CustomStringConvertible, Equatable, Sendable {
  private var calendar = Calendar(identifier: .gregorian)
  private var dateFormatter = DateFormatter()
  private var date = Date()

  private let components: Set<Calendar.Component> = [.year, .month, .day]

  // default initializing here to suppress a false compiler error of "used before initializing"
  // the date components will get actually initialized in various initializers.
  private var dateComponents: DateComponents = .init()

  public init(year: Int, month: Int, day: Int) throws {
    dateComponents = DateComponents(year: year, month: month, day: day)
    dateComponents.calendar = calendar
    guard dateComponents.isValidDate,
          let date = dateComponents.date else {
      throw DataConnectCodecError.invalidLocalDateFormat()
    }
    self.date = date

    setupDateFormat()
  }

  public init(date: Date) {
    dateComponents = calendar.dateComponents(components, from: date)
    self.date = calendar.date(from: dateComponents)!

    setupDateFormat()
  }

  // localDateString of format: YYYY-MM-DD
  public init(localDateString: String) throws {
    setupDateFormat()

    date = try convert(dateString: localDateString)
    dateComponents = calendar.dateComponents(components, from: date)
  }

  public var description: String {
    return dateFormatter.string(from: date)
  }

  // MARK: Private

  private func setupDateFormat() {
    dateFormatter.dateFormat = "yyyy-MM-dd"
  }

  private func convert(dateString: String) throws -> Date {
    guard let date = dateFormatter.date(from: dateString) else {
      throw DataConnectCodecError.invalidLocalDateFormat()
    }
    return date
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension LocalDate {
  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let localDateString = try container.decode(String.self)

    setupDateFormat()
    date = try convert(dateString: localDateString)
    dateComponents = calendar.dateComponents(components, from: date)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    let formattedDate = dateFormatter.string(from: date)
    try container.encode(formattedDate)
  }
}

// MARK: Equatable, Comparable

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension LocalDate {
  static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
    return lhs.date < rhs.date
  }

  static func == (lhs: LocalDate, rhs: LocalDate) -> Bool {
    return lhs.date == rhs.date
  }
}

// MARK: Hashable

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension LocalDate: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(date)
  }
}
