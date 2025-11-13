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

import FirebaseCore
import Foundation
import SQLite3

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private enum TableName {
  static let entityDataObjects = "entity_data"
  static let resultTree = "query_results"
  static let entityDataQueryRefs = "entity_data_query_refs"
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
  let cacheIdentifier: String

  private var db: OpaquePointer?
  private let queue = DispatchQueue(
    label: "com.google.firebase.dataconnect.sqlitecacheprovider",
    autoreleaseFrequency: .workItem
  )

  init(_ cacheIdentifier: String, ephemeral: Bool = false) throws {
    self.cacheIdentifier = cacheIdentifier

    try queue.sync {
      var dbIdentifier = ":memory:"
      if !ephemeral {
        guard let path = FileManager.default.urls(
          for: .documentDirectory,
          in: .userDomainMask
        )
        .first else {
          throw DataConnectInternalError.sqliteError(
            message: "Could not find document directory."
          )
        }
        let dbURL = path.appendingPathComponent("\(cacheIdentifier).sqlite3")
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
        try createTables()
      } catch {
        sqlite3_close(db)
        db = nil
        throw error
      }
    }
  }

  deinit {
    sqlite3_close(db)
  }

  private func createTables() throws {
    dispatchPrecondition(condition: .onQueue(queue))

    let createResultTreeTable = """
    CREATE TABLE IF NOT EXISTS \(TableName.resultTree) (
        \(ColumnName.queryId) TEXT PRIMARY KEY NOT NULL,
        \(ColumnName.lastAccessed) REAL NOT NULL,
        \(ColumnName.data) BLOB NOT NULL
    );
    """
    if sqlite3_exec(db, createResultTreeTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError
        .sqliteError(message: "Could not create \(TableName.resultTree) table")
    }

    let createEntityDataTable = """
    CREATE TABLE IF NOT EXISTS \(TableName.entityDataObjects) (
        \(ColumnName.entityId) TEXT PRIMARY KEY NOT NULL,
        \(ColumnName.data) BLOB NOT NULL
    );
    """
    if sqlite3_exec(db, createEntityDataTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Could not create entity_data table")
    }

    // table to store reverse mapping of EDO => queryRefs mapping
    // this is to know which EDOs are still referenced
    let createEntityDataRefs = """
    CREATE TABLE IF NOT EXISTS \(TableName.entityDataQueryRefs) (
      \(ColumnName.entityId) TEXT NOT NULL REFERENCES \(TableName.entityDataObjects)(\(ColumnName
      .entityId)),
      \(ColumnName.queryId) TEXT NOT NULL REFERENCES \(TableName.resultTree)(\(ColumnName
      .queryId)),
      PRIMARY KEY (\(ColumnName.entityId), \(ColumnName.queryId))
    )
    """
    if sqlite3_exec(db, createEntityDataRefs, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(
        message: "Could not create entity_data_query_refs table"
      )
    }
  }

  private func updateLastAccessedTime(forQueryId queryId: String) {
    dispatchPrecondition(condition: .onQueue(queue))
    let updateQuery =
      "UPDATE \(TableName.resultTree) SET \(ColumnName.lastAccessed) = ? WHERE \(ColumnName.queryId) = ?;"
    var statement: OpaquePointer?

    guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
      DataConnectLogger.error("Error preparing update statement for result_tree")
      return
    }
    defer {
      sqlite3_finalize(statement)
    }

    sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
    sqlite3_bind_text(statement, 2, (queryId as NSString).utf8String, -1, nil)

    if sqlite3_step(statement) != SQLITE_DONE {
      DataConnectLogger.error("Error updating \(ColumnName.lastAccessed) for query \(queryId)")
    }
  }

  func resultTree(queryId: String) -> ResultTree? {
    return queue.sync {
      let query =
        "SELECT \(ColumnName.data) FROM \(TableName.resultTree) WHERE \(ColumnName.queryId) = ?;"
      var statement: OpaquePointer?

      guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
        DataConnectLogger.error("Error preparing select statement for \(TableName.resultTree)")
        return nil
      }
      defer {
        sqlite3_finalize(statement)
      }

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

  func setResultTree(queryId: String, tree: ResultTree) {
    queue.sync {
      do {
        let data = try JSONEncoder().encode(tree)
        let insert =
          "INSERT OR REPLACE INTO \(TableName.resultTree) (\(ColumnName.queryId), \(ColumnName.lastAccessed), \(ColumnName.data)) VALUES (?, ?, ?);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK else {
          DataConnectLogger.error("Error preparing insert statement for \(TableName.resultTree)")
          return
        }
        defer {
          sqlite3_finalize(statement)
        }

        sqlite3_bind_text(statement, 1, (queryId as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
          sqlite3_bind_blob(statement, 3, bytes.baseAddress, Int32(bytes.count), nil)
        }

        if sqlite3_step(statement) != SQLITE_DONE {
          DataConnectLogger.error("Error inserting result tree for queryId \(queryId)")
        }

        DataConnectLogger.debug("\(#function) - query \(queryId), tree \(tree)")
      } catch {
        DataConnectLogger.error("Error encoding result tree for queryId \(queryId): \(error)")
      }
    }
  }

  func entityData(_ entityGuid: String) -> EntityDataObject {
    return queue.sync {
      let query =
        "SELECT \(ColumnName.data) FROM \(TableName.entityDataObjects) WHERE \(ColumnName.entityId) = ?;"
      var statement: OpaquePointer?

      guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
        DataConnectLogger
          .error("Error preparing select statement for \(TableName.entityDataObjects)")
        // if we reach here it means we don't have a EDO in our database.
        // So we create one.
        let edo = EntityDataObject(guid: entityGuid)
        _setObject(entityGuid: entityGuid, object: edo)
        DataConnectLogger.debug("Created EDO for \(entityGuid)")
        return edo
      }
      defer {
        sqlite3_finalize(statement)
      }

      sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)

      if sqlite3_step(statement) == SQLITE_ROW {
        if let dataBlob = sqlite3_column_blob(statement, 0) {
          let dataBlobLength = sqlite3_column_bytes(statement, 0)
          let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
          do {
            let edo = try JSONDecoder().decode(EntityDataObject.self, from: data)
            DataConnectLogger.debug("Returning existing EDO for \(entityGuid)")

            let referencedQueryIds = _readQueryRefs(entityGuid: entityGuid)
            edo.updateReferencedFrom(Set<String>(referencedQueryIds))
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
      _setObject(entityGuid: entityGuid, object: edo)
      DataConnectLogger.debug("Created EDO for \(entityGuid)")
      return edo
    }
  }

  func updateEntityData(_ object: EntityDataObject) {
    queue.sync {
      _setObject(entityGuid: object.guid, object: object)
    }
  }

  // MARK: Private

  // These should run on queue but not call sync otherwise we deadlock
  private func _setObject(entityGuid: String, object: EntityDataObject) {
    dispatchPrecondition(condition: .onQueue(queue))
    do {
      let data = try JSONEncoder().encode(object)
      let insert =
        "INSERT OR REPLACE INTO \(TableName.entityDataObjects) (\(ColumnName.entityId), \(ColumnName.data)) VALUES (?, ?);"
      var statement: OpaquePointer?

      guard sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK else {
        DataConnectLogger.error("Error preparing insert statement for entity_data")
        return
      }
      defer {
        sqlite3_finalize(statement)
      }

      sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)
      _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        sqlite3_bind_blob(statement, 2, bytes.baseAddress, Int32(bytes.count), nil)
      }

      if sqlite3_step(statement) != SQLITE_DONE {
        DataConnectLogger.error("Error inserting data object for entityGuid \(entityGuid)")
      }

    } catch {
      DataConnectLogger.error("Error encoding data object for entityGuid \(entityGuid): \(error)")
    }
    
    // update references
    _updateQueryRefs(object: object)
  }

  private func _updateQueryRefs(object: EntityDataObject) {
    dispatchPrecondition(condition: .onQueue(queue))

    guard object.isReferencedFromAnyQueryRef else {
      return
    }
    
    let sql = "INSERT OR REPLACE INTO \(TableName.entityDataQueryRefs) (\(ColumnName.entityId), \(ColumnName.queryId)) VALUES (?, ?);"
    var statementRefs: OpaquePointer?

    guard sqlite3_prepare_v2(db, sql, -1, &statementRefs, nil) == SQLITE_OK else {
      DataConnectLogger.error("Error preparing insert statement for entity_data_query_refs")
      return
    }
    defer {
      sqlite3_finalize(statementRefs)
    }

    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)

    var success = true
    let entityGuid = object.guid
    for queryId in object.referencedFromRefs() {
      guard sqlite3_bind_text(
        statementRefs,
        1,
        entityGuid,
        -1,
        SQLITE_TRANSIENT
      ) == SQLITE_OK,
        sqlite3_bind_text(statementRefs, 2, queryId, -1, SQLITE_TRANSIENT) == SQLITE_OK
      else {
        DataConnectLogger.error("Error binding parameters for entity_data_query_refs")
        success = false
        break
      }

      if sqlite3_step(statementRefs) != SQLITE_DONE {
        DataConnectLogger
          .error("Error inserting data object references for entityGuid \(entityGuid)")
        success = false
        break
      }
      
      sqlite3_reset(statementRefs)
    }

    if success {
      sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil)
    } else {
      sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
    }
  }

  private func _readQueryRefs(entityGuid: String) -> [String] {
    let readRefs =
      "SELECT \(ColumnName.queryId) FROM \(TableName.entityDataQueryRefs) WHERE \(ColumnName.entityId) = ?"
    var statementRefs: OpaquePointer?
    var queryIds: [String] = []

    guard sqlite3_prepare_v2(db, readRefs, -1, &statementRefs, nil) == SQLITE_OK else {
      DataConnectLogger.error("Error preparing select statement for \(TableName.entityDataQueryRefs)")
      return []
    }
    defer {
      sqlite3_finalize(statementRefs)
    }

    sqlite3_bind_text(statementRefs, 1, (entityGuid as NSString).utf8String, -1, nil)

    while sqlite3_step(statementRefs) == SQLITE_ROW {
      if let cString = sqlite3_column_text(statementRefs, 0) {
        queryIds.append(String(cString: cString))
      }
    }

    return queryIds
  }
}
