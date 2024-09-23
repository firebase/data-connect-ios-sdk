// Copyright 2024 Google LLC
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

import FirebaseDataConnect
import Foundation

// MARK: Common Enums

public enum OrderDirection: String, Codable {
  case ASC
  case DESC
}

// End enum definitions

public class CreateTestIdMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createTestId"

  public typealias Ref = MutationRef<CreateTestIdMutation.Data, CreateTestIdMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      testId_insert: TestIdKey
  }

  public func ref(id: UUID)
    -> MutationRef<CreateTestIdMutation.Data, CreateTestIdMutation.Variables> {
    let variables = CreateTestIdMutation.Variables(id: id)

    let ref = dataConnect.mutation(
      name: "createTestId",
      variables: variables,
      resultsDataType: CreateTestIdMutation.Data.self
    )
    return ref as MutationRef<CreateTestIdMutation.Data, CreateTestIdMutation.Variables>
  }

  public func execute(id: UUID) async throws -> OperationResult<CreateTestIdMutation.Data> {
    let variables = CreateTestIdMutation.Variables(id: id)

    let ref = dataConnect.mutation(
      name: "createTestId",
      variables: variables,
      resultsDataType: CreateTestIdMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateTestAutoIdMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createTestAutoId"

  public typealias Ref = MutationRef<
    CreateTestAutoIdMutation.Data,
    CreateTestAutoIdMutation.Variables
  >

  public struct Variables: OperationVariable {}

  public struct Data: Decodable {
    public var
      testAutoId_insert: TestAutoIdKey
  }

  public func ref(
  ) -> MutationRef<CreateTestAutoIdMutation.Data, CreateTestAutoIdMutation.Variables> {
    let variables = CreateTestAutoIdMutation.Variables()

    let ref = dataConnect.mutation(
      name: "createTestAutoId",
      variables: variables,
      resultsDataType: CreateTestAutoIdMutation.Data.self
    )
    return ref as MutationRef<CreateTestAutoIdMutation.Data, CreateTestAutoIdMutation.Variables>
  }

  public func execute(
  ) async throws -> OperationResult<CreateTestAutoIdMutation.Data> {
    let variables = CreateTestAutoIdMutation.Variables()

    let ref = dataConnect.mutation(
      name: "createTestAutoId",
      variables: variables,
      resultsDataType: CreateTestAutoIdMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateStandardScalarMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createStandardScalar"

  public typealias Ref = MutationRef<
    CreateStandardScalarMutation.Data,
    CreateStandardScalarMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public var
      number: Int

    public var
      text: String

    public var
      decimal: Double

    public init(id: UUID,

                number: Int,

                text: String,

                decimal: Double) {
      self.id = id
      self.number = number
      self.text = text
      self.decimal = decimal
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id &&
        lhs.number == rhs.number &&
        lhs.text == rhs.text &&
        lhs.decimal == rhs.decimal
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)

      hasher.combine(number)

      hasher.combine(text)

      hasher.combine(decimal)
    }

    enum CodingKeys: String, CodingKey {
      case id

      case number

      case text

      case decimal
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)

      try codecHelper.encode(number, forKey: .number, container: &container)

      try codecHelper.encode(text, forKey: .text, container: &container)

      try codecHelper.encode(decimal, forKey: .decimal, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      standardScalars_insert: StandardScalarsKey
  }

  public func ref(id: UUID,

                  number: Int,

                  text: String,

                  decimal: Double)
    -> MutationRef<CreateStandardScalarMutation.Data,
      CreateStandardScalarMutation.Variables> {
    let variables = CreateStandardScalarMutation.Variables(
      id: id,
      number: number,
      text: text,
      decimal: decimal
    )

    let ref = dataConnect.mutation(
      name: "createStandardScalar",
      variables: variables,
      resultsDataType: CreateStandardScalarMutation.Data.self
    )
    return ref as MutationRef<
      CreateStandardScalarMutation.Data,
      CreateStandardScalarMutation.Variables
    >
  }

  public func execute(id: UUID,

                      number: Int,

                      text: String,

                      decimal: Double) async throws
    -> OperationResult<CreateStandardScalarMutation.Data> {
    let variables = CreateStandardScalarMutation.Variables(
      id: id,
      number: number,
      text: text,
      decimal: decimal
    )

    let ref = dataConnect.mutation(
      name: "createStandardScalar",
      variables: variables,
      resultsDataType: CreateStandardScalarMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateScalarBoundaryMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createScalarBoundary"

  public typealias Ref = MutationRef<
    CreateScalarBoundaryMutation.Data,
    CreateScalarBoundaryMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public var
      maxNumber: Int

    public var
      minNumber: Int

    public var
      maxDecimal: Double

    public var
      minDecimal: Double

    public init(id: UUID,

                maxNumber: Int,

                minNumber: Int,

                maxDecimal: Double,

                minDecimal: Double) {
      self.id = id
      self.maxNumber = maxNumber
      self.minNumber = minNumber
      self.maxDecimal = maxDecimal
      self.minDecimal = minDecimal
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id &&
        lhs.maxNumber == rhs.maxNumber &&
        lhs.minNumber == rhs.minNumber &&
        lhs.maxDecimal == rhs.maxDecimal &&
        lhs.minDecimal == rhs.minDecimal
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)

      hasher.combine(maxNumber)

      hasher.combine(minNumber)

      hasher.combine(maxDecimal)

      hasher.combine(minDecimal)
    }

    enum CodingKeys: String, CodingKey {
      case id

      case maxNumber

      case minNumber

      case maxDecimal

      case minDecimal
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)

      try codecHelper.encode(maxNumber, forKey: .maxNumber, container: &container)

      try codecHelper.encode(minNumber, forKey: .minNumber, container: &container)

      try codecHelper.encode(maxDecimal, forKey: .maxDecimal, container: &container)

      try codecHelper.encode(minDecimal, forKey: .minDecimal, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      scalarBoundary_insert: ScalarBoundaryKey
  }

  public func ref(id: UUID,

                  maxNumber: Int,

                  minNumber: Int,

                  maxDecimal: Double,

                  minDecimal: Double)
    -> MutationRef<CreateScalarBoundaryMutation.Data,
      CreateScalarBoundaryMutation.Variables> {
    let variables = CreateScalarBoundaryMutation.Variables(
      id: id,
      maxNumber: maxNumber,
      minNumber: minNumber,
      maxDecimal: maxDecimal,
      minDecimal: minDecimal
    )

    let ref = dataConnect.mutation(
      name: "createScalarBoundary",
      variables: variables,
      resultsDataType: CreateScalarBoundaryMutation.Data.self
    )
    return ref as MutationRef<
      CreateScalarBoundaryMutation.Data,
      CreateScalarBoundaryMutation.Variables
    >
  }

  public func execute(id: UUID,

                      maxNumber: Int,

                      minNumber: Int,

                      maxDecimal: Double,

                      minDecimal: Double) async throws
    -> OperationResult<CreateScalarBoundaryMutation.Data> {
    let variables = CreateScalarBoundaryMutation.Variables(
      id: id,
      maxNumber: maxNumber,
      minNumber: minNumber,
      maxDecimal: maxDecimal,
      minDecimal: minDecimal
    )

    let ref = dataConnect.mutation(
      name: "createScalarBoundary",
      variables: variables,
      resultsDataType: CreateScalarBoundaryMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateLargeNumMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createLargeNum"

  public typealias Ref = MutationRef<CreateLargeNumMutation.Data, CreateLargeNumMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public var
      num: Int64

    public var
      maxNum: Int64

    public var
      minNum: Int64

    public init(id: UUID,

                num: Int64,

                maxNum: Int64,

                minNum: Int64) {
      self.id = id
      self.num = num
      self.maxNum = maxNum
      self.minNum = minNum
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id &&
        lhs.num == rhs.num &&
        lhs.maxNum == rhs.maxNum &&
        lhs.minNum == rhs.minNum
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)

      hasher.combine(num)

      hasher.combine(maxNum)

      hasher.combine(minNum)
    }

    enum CodingKeys: String, CodingKey {
      case id

      case num

      case maxNum

      case minNum
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)

      try codecHelper.encode(num, forKey: .num, container: &container)

      try codecHelper.encode(maxNum, forKey: .maxNum, container: &container)

      try codecHelper.encode(minNum, forKey: .minNum, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      largeIntType_insert: LargeIntTypeKey
  }

  public func ref(id: UUID,

                  num: Int64,

                  maxNum: Int64,

                  minNum: Int64)
    -> MutationRef<CreateLargeNumMutation.Data, CreateLargeNumMutation.Variables> {
    let variables = CreateLargeNumMutation.Variables(
      id: id,
      num: num,
      maxNum: maxNum,
      minNum: minNum
    )

    let ref = dataConnect.mutation(
      name: "createLargeNum",
      variables: variables,
      resultsDataType: CreateLargeNumMutation.Data.self
    )
    return ref as MutationRef<CreateLargeNumMutation.Data, CreateLargeNumMutation.Variables>
  }

  public func execute(id: UUID,

                      num: Int64,

                      maxNum: Int64,

                      minNum: Int64) async throws -> OperationResult<CreateLargeNumMutation.Data> {
    let variables = CreateLargeNumMutation.Variables(
      id: id,
      num: num,
      maxNum: maxNum,
      minNum: minNum
    )

    let ref = dataConnect.mutation(
      name: "createLargeNum",
      variables: variables,
      resultsDataType: CreateLargeNumMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateLocalDateMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createLocalDate"

  public typealias Ref = MutationRef<
    CreateLocalDateMutation.Data,
    CreateLocalDateMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public var
      localDate: LocalDate

    public init(id: UUID,

                localDate: LocalDate) {
      self.id = id
      self.localDate = localDate
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id &&
        lhs.localDate == rhs.localDate
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)

      hasher.combine(localDate)
    }

    enum CodingKeys: String, CodingKey {
      case id

      case localDate
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)

      try codecHelper.encode(localDate, forKey: .localDate, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      localDateType_insert: LocalDateTypeKey
  }

  public func ref(id: UUID,

                  localDate: LocalDate)
    -> MutationRef<CreateLocalDateMutation.Data,
      CreateLocalDateMutation.Variables> {
    let variables = CreateLocalDateMutation.Variables(id: id, localDate: localDate)

    let ref = dataConnect.mutation(
      name: "createLocalDate",
      variables: variables,
      resultsDataType: CreateLocalDateMutation.Data.self
    )
    return ref as MutationRef<CreateLocalDateMutation.Data, CreateLocalDateMutation.Variables>
  }

  public func execute(id: UUID,

                      localDate: LocalDate) async throws
    -> OperationResult<CreateLocalDateMutation.Data> {
    let variables = CreateLocalDateMutation.Variables(id: id, localDate: localDate)

    let ref = dataConnect.mutation(
      name: "createLocalDate",
      variables: variables,
      resultsDataType: CreateLocalDateMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class CreateAnyValueTypeMutation {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "createAnyValueType"

  public typealias Ref = MutationRef<
    CreateAnyValueTypeMutation.Data,
    CreateAnyValueTypeMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public var
      props: AnyValue

    public init(id: UUID,

                props: AnyValue) {
      self.id = id
      self.props = props
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id &&
        lhs.props == rhs.props
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)

      hasher.combine(props)
    }

    enum CodingKeys: String, CodingKey {
      case id

      case props
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)

      try codecHelper.encode(props, forKey: .props, container: &container)
    }
  }

  public struct Data: Decodable {
    public var
      anyValueType_insert: AnyValueTypeKey
  }

  public func ref(id: UUID,

                  props: AnyValue) -> MutationRef<
    CreateAnyValueTypeMutation.Data,
    CreateAnyValueTypeMutation.Variables
  > {
    let variables = CreateAnyValueTypeMutation.Variables(id: id, props: props)

    let ref = dataConnect.mutation(
      name: "createAnyValueType",
      variables: variables,
      resultsDataType: CreateAnyValueTypeMutation.Data.self
    )
    return ref as MutationRef<
      CreateAnyValueTypeMutation.Data,
      CreateAnyValueTypeMutation.Variables
    >
  }

  public func execute(id: UUID,

                      props: AnyValue) async throws
    -> OperationResult<CreateAnyValueTypeMutation.Data> {
    let variables = CreateAnyValueTypeMutation.Variables(id: id, props: props)

    let ref = dataConnect.mutation(
      name: "createAnyValueType",
      variables: variables,
      resultsDataType: CreateAnyValueTypeMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class GetStandardScalarQuery {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetStandardScalar"

  public typealias Ref = QueryRefObservableObject<
    GetStandardScalarQuery.Data,
    GetStandardScalarQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public struct StandardScalars: Decodable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        number: Int

      public var
        text: String

      public var
        decimal: Double

      public var standardScalarsKey: StandardScalarsKey {
        return StandardScalarsKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: StandardScalars, rhs: StandardScalars) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case number

        case text

        case decimal
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        number = try codecHelper.decode(Int.self, forKey: .number, container: &container)

        text = try codecHelper.decode(String.self, forKey: .text, container: &container)

        decimal = try codecHelper.decode(Double.self, forKey: .decimal, container: &container)
      }
    }

    public var
      standardScalars: StandardScalars?
  }

  public func ref(id: UUID)
    -> QueryRefObservableObject<GetStandardScalarQuery.Data,
      GetStandardScalarQuery.Variables> {
    let variables = GetStandardScalarQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetStandardScalar",
      variables: variables,
      resultsDataType: GetStandardScalarQuery.Data.self,
      publisher: .observableObject
    )
    return ref as! QueryRefObservableObject<
      GetStandardScalarQuery.Data,
      GetStandardScalarQuery.Variables
    >
  }

  public func execute(id: UUID) async throws -> OperationResult<GetStandardScalarQuery.Data> {
    let variables = GetStandardScalarQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetStandardScalar",
      variables: variables,
      resultsDataType: GetStandardScalarQuery.Data.self,
      publisher: .observableObject
    )

    let refCast = ref as! QueryRefObservableObject<
      GetStandardScalarQuery.Data,
      GetStandardScalarQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetScalarBoundaryQuery {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetScalarBoundary"

  public typealias Ref = QueryRefObservableObject<
    GetScalarBoundaryQuery.Data,
    GetScalarBoundaryQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public struct ScalarBoundary: Decodable {
      public var
        maxNumber: Int

      public var
        minNumber: Int

      public var
        maxDecimal: Double

      public var
        minDecimal: Double

      enum CodingKeys: String, CodingKey {
        case maxNumber

        case minNumber

        case maxDecimal

        case minDecimal
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        maxNumber = try codecHelper.decode(Int.self, forKey: .maxNumber, container: &container)

        minNumber = try codecHelper.decode(Int.self, forKey: .minNumber, container: &container)

        maxDecimal = try codecHelper.decode(Double.self, forKey: .maxDecimal, container: &container)

        minDecimal = try codecHelper.decode(Double.self, forKey: .minDecimal, container: &container)
      }
    }

    public var
      scalarBoundary: ScalarBoundary?
  }

  public func ref(id: UUID)
    -> QueryRefObservableObject<GetScalarBoundaryQuery.Data,
      GetScalarBoundaryQuery.Variables> {
    let variables = GetScalarBoundaryQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetScalarBoundary",
      variables: variables,
      resultsDataType: GetScalarBoundaryQuery.Data.self,
      publisher: .observableObject
    )
    return ref as! QueryRefObservableObject<
      GetScalarBoundaryQuery.Data,
      GetScalarBoundaryQuery.Variables
    >
  }

  public func execute(id: UUID) async throws -> OperationResult<GetScalarBoundaryQuery.Data> {
    let variables = GetScalarBoundaryQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetScalarBoundary",
      variables: variables,
      resultsDataType: GetScalarBoundaryQuery.Data.self,
      publisher: .observableObject
    )

    let refCast = ref as! QueryRefObservableObject<
      GetScalarBoundaryQuery.Data,
      GetScalarBoundaryQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetLargeNumQuery {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetLargeNum"

  public typealias Ref = QueryRefObservableObject<GetLargeNumQuery.Data, GetLargeNumQuery.Variables>

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public struct LargeIntType: Decodable {
      public var
        num: Int64

      public var
        maxNum: Int64

      public var
        minNum: Int64

      enum CodingKeys: String, CodingKey {
        case num

        case maxNum

        case minNum
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        num = try codecHelper.decode(Int64.self, forKey: .num, container: &container)

        maxNum = try codecHelper.decode(Int64.self, forKey: .maxNum, container: &container)

        minNum = try codecHelper.decode(Int64.self, forKey: .minNum, container: &container)
      }
    }

    public var
      largeIntType: LargeIntType?
  }

  public func ref(id: UUID) -> QueryRefObservableObject<
    GetLargeNumQuery.Data,
    GetLargeNumQuery.Variables
  > {
    let variables = GetLargeNumQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetLargeNum",
      variables: variables,
      resultsDataType: GetLargeNumQuery.Data.self,
      publisher: .observableObject
    )
    return ref as! QueryRefObservableObject<GetLargeNumQuery.Data, GetLargeNumQuery.Variables>
  }

  public func execute(id: UUID) async throws -> OperationResult<GetLargeNumQuery.Data> {
    let variables = GetLargeNumQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetLargeNum",
      variables: variables,
      resultsDataType: GetLargeNumQuery.Data.self,
      publisher: .observableObject
    )

    let refCast = ref as! QueryRefObservableObject<
      GetLargeNumQuery.Data,
      GetLargeNumQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetLocalDateTypeQuery {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetLocalDateType"

  public typealias Ref = QueryRefObservableObject<
    GetLocalDateTypeQuery.Data,
    GetLocalDateTypeQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public struct LocalDateType: Decodable {
      public var
        localDate: LocalDate?

      enum CodingKeys: String, CodingKey {
        case localDate
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        localDate = try codecHelper.decode(
          LocalDate?.self,
          forKey: .localDate,
          container: &container
        )
      }
    }

    public var
      localDateType: LocalDateType?
  }

  public func ref(id: UUID) -> QueryRefObservableObject<
    GetLocalDateTypeQuery.Data,
    GetLocalDateTypeQuery.Variables
  > {
    let variables = GetLocalDateTypeQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetLocalDateType",
      variables: variables,
      resultsDataType: GetLocalDateTypeQuery.Data.self,
      publisher: .observableObject
    )
    return ref as! QueryRefObservableObject<
      GetLocalDateTypeQuery.Data,
      GetLocalDateTypeQuery.Variables
    >
  }

  public func execute(id: UUID) async throws -> OperationResult<GetLocalDateTypeQuery.Data> {
    let variables = GetLocalDateTypeQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetLocalDateType",
      variables: variables,
      resultsDataType: GetLocalDateTypeQuery.Data.self,
      publisher: .observableObject
    )

    let refCast = ref as! QueryRefObservableObject<
      GetLocalDateTypeQuery.Data,
      GetLocalDateTypeQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetAnyValueTypeQuery {
  let dataConnect: DataConnect

  public init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetAnyValueType"

  public typealias Ref = QueryRefObservableObject<
    GetAnyValueTypeQuery.Data,
    GetAnyValueTypeQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable {
    public struct AnyValueType: Decodable {
      public var
        props: AnyValue

      enum CodingKeys: String, CodingKey {
        case props
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        props = try codecHelper.decode(AnyValue.self, forKey: .props, container: &container)
      }
    }

    public var
      anyValueType: AnyValueType?
  }

  public func ref(id: UUID) -> QueryRefObservableObject<
    GetAnyValueTypeQuery.Data,
    GetAnyValueTypeQuery.Variables
  > {
    let variables = GetAnyValueTypeQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetAnyValueType",
      variables: variables,
      resultsDataType: GetAnyValueTypeQuery.Data.self,
      publisher: .observableObject
    )
    return ref as! QueryRefObservableObject<
      GetAnyValueTypeQuery.Data,
      GetAnyValueTypeQuery.Variables
    >
  }

  public func execute(id: UUID) async throws -> OperationResult<GetAnyValueTypeQuery.Data> {
    let variables = GetAnyValueTypeQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetAnyValueType",
      variables: variables,
      resultsDataType: GetAnyValueTypeQuery.Data.self,
      publisher: .observableObject
    )

    let refCast = ref as! QueryRefObservableObject<
      GetAnyValueTypeQuery.Data,
      GetAnyValueTypeQuery.Variables
    >
    return try await refCast.execute()
  }
}
