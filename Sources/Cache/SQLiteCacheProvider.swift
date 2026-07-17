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
import SQLite3

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private enum TableName {
  static let entityDataObjects = "entity_data"
  static let resultTree = "query_results"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private enum ColumnName {
  static let entityId = "entity_guid"
  static let data = "data"
  static let queryId = "query_id"
  static let lastAccessed = "last_accessed"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class SQLiteCacheProvider: CacheProvider {
  let identifier: String

  private var db: OpaquePointer?
  private let queue = DispatchQueue(
    label: "com.google.firebase.dataconnect.sqlitecacheprovider",
    autoreleaseFrequency: .workItem
  )
  private static let queueKey = DispatchSpecificKey<Void>()
  private var inTransaction = false

  private var selectResultTreeStmt: OpaquePointer?
  private var insertResultTreeStmt: OpaquePointer?
  private var selectEntityDataStmt: OpaquePointer?
  private var insertEntityDataStmt: OpaquePointer?
  private var updateLastAccessedStmt: OpaquePointer?

  private func perform<T>(_ action: () throws -> T) rethrows -> T {
    if DispatchQueue.getSpecific(key: Self.queueKey) != nil {
      return try action()
    } else {
      return try queue.sync {
        try action()
      }
    }
  }

  init(_ cacheIdentifier: String, ephemeral: Bool = false) throws {
    identifier = cacheIdentifier
    queue.setSpecific(key: Self.queueKey, value: ())

    try queue.sync {
      var dbIdentifier = ":memory:"
      if !ephemeral {
        guard
          let path = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
          )
          .first
        else {
          throw DataConnectInternalError.sqliteError(
            message: "Could not find document directory."
          )
        }
        let dirPath = path.appendingPathComponent("com.google.firebase.dataconnect")
        try FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true)
        let dbURL = dirPath.appendingPathComponent("\(identifier).sqlite3")
        dbIdentifier = dbURL.path
      }
      if sqlite3_open(dbIdentifier, &db) != SQLITE_OK {
        throw
          DataConnectInternalError
          .sqliteError(
            message: "Could not open database for identifier \(cacheIdentifier) at \(dbIdentifier)"
          )
      }

      DataConnectLogger
        .debug(
          "Opened database with db path/id \(dbIdentifier) and cache identifier \(cacheIdentifier)"
        )
      do {
        let curVersion = getDatabaseVersion()
        if curVersion.isZero {
          try createTables()
        } else if curVersion.major != 1 {
          throw
            DataConnectInternalError
            .sqliteError(
              message: "Unsupported schema major version \(curVersion.major) detected. Expected 1"
            )
        }
        try prepareStatements()
      } catch {
        sqlite3_close(db)
        db = nil
        throw error
      }
    }
  }

  deinit {
    finalizeStatements()
    sqlite3_close(db)
  }

  private func prepareStatements() throws {
    dispatchPrecondition(condition: .onQueue(queue))

    let selectResultTreeSql =
      "SELECT \(ColumnName.data) FROM \(TableName.resultTree) WHERE \(ColumnName.queryId) = ?;"
    if sqlite3_prepare_v2(db, selectResultTreeSql, -1, &selectResultTreeStmt, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Failed to prepare selectResultTreeStmt")
    }

    let insertResultTreeSql =
      "INSERT OR REPLACE INTO \(TableName.resultTree) (\(ColumnName.queryId), \(ColumnName.lastAccessed), \(ColumnName.data)) VALUES (?, ?, ?);"
    if sqlite3_prepare_v2(db, insertResultTreeSql, -1, &insertResultTreeStmt, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Failed to prepare insertResultTreeStmt")
    }

    let selectEntityDataSql =
      "SELECT \(ColumnName.data) FROM \(TableName.entityDataObjects) WHERE \(ColumnName.entityId) = ?;"
    if sqlite3_prepare_v2(db, selectEntityDataSql, -1, &selectEntityDataStmt, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Failed to prepare selectEntityDataStmt")
    }

    let insertEntityDataSql =
      "INSERT OR REPLACE INTO \(TableName.entityDataObjects) (\(ColumnName.entityId), \(ColumnName.data)) VALUES (?, ?);"
    if sqlite3_prepare_v2(db, insertEntityDataSql, -1, &insertEntityDataStmt, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Failed to prepare insertEntityDataStmt")
    }

    let updateLastAccessedSql =
      "UPDATE \(TableName.resultTree) SET \(ColumnName.lastAccessed) = ? WHERE \(ColumnName.queryId) = ?;"
    if sqlite3_prepare_v2(db, updateLastAccessedSql, -1, &updateLastAccessedStmt, nil) !=
      SQLITE_OK {
      throw DataConnectInternalError
        .sqliteError(message: "Failed to prepare updateLastAccessedStmt")
    }
  }

  private func finalizeStatements() {
    sqlite3_finalize(selectResultTreeStmt)
    sqlite3_finalize(insertResultTreeStmt)
    sqlite3_finalize(selectEntityDataStmt)
    sqlite3_finalize(insertEntityDataStmt)
    sqlite3_finalize(updateLastAccessedStmt)
  }

  private func createTables() throws {
    dispatchPrecondition(condition: .onQueue(queue))

    sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)

    let createResultTreeTable = """
    CREATE TABLE IF NOT EXISTS \(TableName.resultTree) (
        \(ColumnName.queryId) TEXT PRIMARY KEY NOT NULL,
        \(ColumnName.lastAccessed) REAL NOT NULL,
        \(ColumnName.data) BLOB NOT NULL
    );
    """
    if sqlite3_exec(db, createResultTreeTable, nil, nil, nil) != SQLITE_OK {
      sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
      throw
        DataConnectInternalError
        .sqliteError(message: "Could not create \(TableName.resultTree) table")
    }

    let createEntityDataTable = """
    CREATE TABLE IF NOT EXISTS \(TableName.entityDataObjects) (
        \(ColumnName.entityId) TEXT PRIMARY KEY NOT NULL,
        \(ColumnName.data) BLOB NOT NULL
    );
    """
    if sqlite3_exec(db, createEntityDataTable, nil, nil, nil) != SQLITE_OK {
      sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
      throw DataConnectInternalError.sqliteError(message: "Could not create entity_data table")
    }

    if let version = DBSemanticVersion(1, 0, 0), setDatabaseVersion(version) != SQLITE_OK {
      sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
      throw
        DataConnectInternalError
        .sqliteError(message: "Could not set database version to initial value")
    }

    sqlite3_exec(db, "COMMIT;", nil, nil, nil)
  }

  private func getDatabaseVersion() -> DBSemanticVersion {
    dispatchPrecondition(condition: .onQueue(queue))

    var statement: OpaquePointer?
    let query = "PRAGMA user_version;"
    var version = DBSemanticVersion(storageInt: 0)

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
      if sqlite3_step(statement) == SQLITE_ROW {
        let intVal = Int32(sqlite3_column_int(statement, 0))
        version = DBSemanticVersion(storageInt: intVal)
      }
    }

    defer {
      sqlite3_finalize(statement)
    }

    return version
  }

  private func setDatabaseVersion(_ version: DBSemanticVersion) -> Int32 {
    dispatchPrecondition(condition: .onQueue(queue))

    let sql = "PRAGMA user_version = \(version.storageInt);"
    return sqlite3_exec(db, sql, nil, nil, nil)
  }

  func getSchemaVersion() -> DBSemanticVersion {
    queue.sync { self.getDatabaseVersion() }
  }

  private func updateLastAccessedTime(forQueryId queryId: String) {
    dispatchPrecondition(condition: .onQueue(queue))
    let statement = updateLastAccessedStmt
    sqlite3_reset(statement)
    sqlite3_clear_bindings(statement)

    sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
    sqlite3_bind_text(statement, 2, (queryId as NSString).utf8String, -1, nil)

    if sqlite3_step(statement) != SQLITE_DONE {
      DataConnectLogger.error("Error updating \(ColumnName.lastAccessed) for query \(queryId)")
    }
  }

  func resultTree(queryId: String) -> ResultTree? {
    return perform {
      let statement = selectResultTreeStmt
      sqlite3_reset(statement)
      sqlite3_clear_bindings(statement)

      sqlite3_bind_text(statement, 1, (queryId as NSString).utf8String, -1, nil)

      if sqlite3_step(statement) == SQLITE_ROW {
        if let dataBlob = sqlite3_column_blob(statement, 0) {
          let dataBlobLength = sqlite3_column_bytes(statement, 0)
          let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
          do {
            let tree = try JSONDecoder().decode(ResultTree.self, from: data)
            self.updateLastAccessedTime(forQueryId: queryId)
            return tree
          } catch {
            DataConnectLogger.error("Error decoding result tree for queryId \(queryId): \(error)")
            return nil
          }
        }
      }

      DataConnectLogger.debug("\(#function) no result tree found for queryId \(queryId)")
      return nil
    }
  }

  func setResultTree(queryId: String, tree: ResultTree) throws {
    try perform {
      let data = try JSONEncoder().encode(tree)
      let statement = insertResultTreeStmt
      sqlite3_reset(statement)
      sqlite3_clear_bindings(statement)

      sqlite3_bind_text(statement, 1, (queryId as NSString).utf8String, -1, nil)
      sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
      _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        sqlite3_bind_blob(statement, 3, bytes.baseAddress, Int32(bytes.count), nil)
      }

      let needsTransaction = !inTransaction
      if needsTransaction {
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) != SQLITE_OK {
          throw DataConnectInternalError.sqliteError(message: "Failed to begin transaction")
        }
      }

      let stepResult = sqlite3_step(statement)

      if needsTransaction {
        if stepResult == SQLITE_DONE {
          sqlite3_exec(db, "COMMIT;", nil, nil, nil)
        } else {
          sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
        }
      }

      if stepResult != SQLITE_DONE {
        throw DataConnectInternalError
          .sqliteError(message: "Error inserting result tree for queryId \(queryId)")
      }

      DataConnectLogger.debug("\(#function) - query \(queryId), tree \(tree)")
    }
  }

  func entityData(_ entityGuid: String) -> EntityDataObject {
    return perform {
      let statement = selectEntityDataStmt
      sqlite3_reset(statement)
      sqlite3_clear_bindings(statement)

      sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)

      if sqlite3_step(statement) == SQLITE_ROW {
        if let dataBlob = sqlite3_column_blob(statement, 0) {
          let dataBlobLength = sqlite3_column_bytes(statement, 0)
          let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
          do {
            let edo = try JSONDecoder().decode(EntityDataObject.self, from: data)
            DataConnectLogger.debug("Returning existing EDO for \(entityGuid)")

            return edo
          } catch {
            DataConnectLogger.error(
              "Error decoding data object for entityGuid \(entityGuid): \(error)"
            )
          }
        }
      }

      // if we reach here it means we don't have a EDO in our database.
      // So we create one.
      let edo = EntityDataObject(guid: entityGuid)
      do {
        try _setObject(entityGuid: entityGuid, object: edo)
      } catch {
        DataConnectLogger.error("Failed to insert initial EDO for \(entityGuid): \(error)")
      }
      DataConnectLogger.debug("Created EDO for \(entityGuid)")
      return edo
    }
  }

  func updateEntityData(_ object: EntityDataObject) throws {
    try perform {
      try _setObject(entityGuid: object.guid, object: object)
    }
  }

  // MARK: Private

  // These should run on queue but not call sync otherwise we deadlock
  private func _setObject(entityGuid: String, object: EntityDataObject) throws {
    dispatchPrecondition(condition: .onQueue(queue))
    let data = try JSONEncoder().encode(object)
    let statement = insertEntityDataStmt
    sqlite3_reset(statement)
    sqlite3_clear_bindings(statement)

    sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)
    _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
      sqlite3_bind_blob(statement, 2, bytes.baseAddress, Int32(bytes.count), nil)
    }

    let needsTransaction = !inTransaction
    if needsTransaction {
      if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) != SQLITE_OK {
        throw DataConnectInternalError.sqliteError(message: "Failed to begin transaction")
      }
    }

    let stepResult = sqlite3_step(statement)

    if needsTransaction {
      if stepResult == SQLITE_DONE {
        sqlite3_exec(db, "COMMIT;", nil, nil, nil)
      } else {
        sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
      }
    }

    if stepResult != SQLITE_DONE {
      throw DataConnectInternalError
        .sqliteError(message: "Error inserting data object for entityGuid \(entityGuid)")
    }
  }

  func runInTransaction<T>(_ action: () throws -> T) throws -> T {
    return try perform {
      if inTransaction {
        return try action()
      }

      if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) != SQLITE_OK {
        throw DataConnectInternalError.sqliteError(message: "Failed to begin transaction")
      }
      inTransaction = true
      defer {
        inTransaction = false
      }
      do {
        let result = try action()
        if sqlite3_exec(db, "COMMIT;", nil, nil, nil) != SQLITE_OK {
          throw DataConnectInternalError.sqliteError(message: "Failed to commit transaction")
        }
        return result
      } catch {
        sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
        throw error
      }
    }
  }
}

// MARK: DB Version Struct

// Represents the semantic version for the DB schema.
// DB version only uses major.minor.patch, with each being 0 - 999
// DB doesn't use suffixes like -beta, ...
// For Googlers, see go/fdc-sdk-caching [tab: Schema Versioning]
struct DBSemanticVersion: Comparable, CustomStringConvertible {
  let major: Int32
  let minor: Int32
  let patch: Int32

  // The multiplier used for SQLite storage
  private static let multiplier: Int32 = 1000

  var description: String {
    return "\(major).\(minor).\(patch)"
  }

  // Initialize from String: "1.2.3"
  init?(_ major: Int32, _ minor: Int32, _ patch: Int32) {
    let range = 0 ..< Self.multiplier

    guard range.contains(major) && range.contains(minor) && range.contains(patch) else {
      return nil
    }

    self.major = major
    self.minor = minor
    self.patch = patch
  }

  // Initialize from SQLite Int32: 1002003
  init(storageInt: Int32) {
    major = storageInt / (Self.multiplier * Self.multiplier)
    minor = (storageInt % (Self.multiplier * Self.multiplier)) / Self.multiplier
    patch = storageInt % Self.multiplier
  }

  // Convert to SQLite Int32
  var storageInt: Int32 {
    return (major * Self.multiplier * Self.multiplier) + (minor * Self.multiplier) + patch
  }

  var isZero: Bool {
    return major == 0 && minor == 0 && patch == 0
  }

  // Implementation for Comparable
  static func < (lhs: DBSemanticVersion, rhs: DBSemanticVersion) -> Bool {
    return lhs.storageInt < rhs.storageInt
  }
}
