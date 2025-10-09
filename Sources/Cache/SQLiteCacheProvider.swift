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

fileprivate enum TableName {
  static let entityDataObjects = "entity_data"
  static let resultTree = "result_tree"
  static let entityDataQueryRefs = "entity_data_query_refs"
}

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
        let path = NSSearchPathForDirectoriesInDomains(
          .applicationSupportDirectory,
          .userDomainMask,
          true
        ).first!
        let dbURL = URL(fileURLWithPath: path).appendingPathComponent("\(cacheIdentifier).sqlite3")
        dbIdentifier = dbURL.path
      }
      if sqlite3_open(dbIdentifier, &db) != SQLITE_OK {
        throw
          DataConnectInternalError
          .sqliteError(
            message: "Could not open database for identifier \(cacheIdentifier) at \(dbIdentifier)"
          )
      }

      DataConnectLogger.debug("Opened database with db path/id \(dbIdentifier) and cache identifier \(cacheIdentifier)")
      try createTables()
    }
  }

  deinit {
    sqlite3_close(db)
  }

  private func createTables() throws {
    dispatchPrecondition(condition: .onQueue(queue))

    let createResultTreeTable = """
      CREATE TABLE IF NOT EXISTS \(TableName.resultTree) (
          query_id TEXT PRIMARY KEY NOT NULL,
          last_accessed REAL NOT NULL,
          tree BLOB NOT NULL
      );
      """
    if sqlite3_exec(db, createResultTreeTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Could not create result_tree table")
    }

    let createEntityDataTable = """
      CREATE TABLE IF NOT EXISTS \(TableName.entityDataObjects) (
          entity_guid TEXT PRIMARY KEY NOT NULL,
          object_state INTEGER DEFAULT 10,
          object BLOB NOT NULL
      );
      """
    if sqlite3_exec(db, createEntityDataTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Could not create entity_data table")
    }

    // table to store reverse mapping of EDO => queryRefs mapping
    // this is to know which EDOs are still referenced
    let createEntityDataRefs = """
      CREATE TABLE IF NOT EXISTS \(TableName.entityDataQueryRefs) (
        entity_guid TEXT NOT NULL REFERENCES entity_data(entity_guid),
        query_id TEXT NOT NULL REFERENCES result_tree(query_id),
        PRIMARY KEY (entity_guid, query_id)
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
    let updateQuery = "UPDATE result_tree SET last_accessed = ? WHERE query_id = ?;"
    var statement: OpaquePointer?

    if sqlite3_prepare_v2(self.db, updateQuery, -1, &statement, nil) != SQLITE_OK {
      DataConnectLogger.error("Error preparing update statement for result_tree")
      return
    }

    sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
    sqlite3_bind_text(statement, 2, (queryId as NSString).utf8String, -1, nil)

    if sqlite3_step(statement) != SQLITE_DONE {
      DataConnectLogger.error("Error updating last_accessed for query \(queryId)")
    }
    sqlite3_finalize(statement)

  }

  func resultTree(queryId: String) -> ResultTree? {
    return queue.sync {
      let query = "SELECT tree FROM result_tree WHERE query_id = ?;"
      var statement: OpaquePointer?

      if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
        DataConnectLogger.error("Error preparing select statement for result_tree")
        return nil
      }

      sqlite3_bind_text(statement, 1, (queryId as NSString).utf8String, -1, nil)

      if sqlite3_step(statement) == SQLITE_ROW {
        if let dataBlob = sqlite3_column_blob(statement, 0) {
          let dataBlobLength = sqlite3_column_bytes(statement, 0)
          let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
          sqlite3_finalize(statement)
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

      sqlite3_finalize(statement)
      DataConnectLogger.debug("\(#function) no result tree found for queryId \(queryId)")
      return nil
    }
  }

  func setResultTree(queryId: String, tree: ResultTree) {
    queue.sync {
      do {
        var tree = tree
        let data = try JSONEncoder().encode(tree)
        let insert =
          "INSERT OR REPLACE INTO result_tree (query_id, last_accessed, tree) VALUES (?, ?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insert, -1, &statement, nil) != SQLITE_OK {
          DataConnectLogger.error("Error preparing insert statement for result_tree")
          return
        }

        tree.lastAccessed = Date()

        sqlite3_bind_text(statement, 1, (queryId as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 2, tree.lastAccessed.timeIntervalSince1970)
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
          sqlite3_bind_blob(statement, 3, bytes.baseAddress, Int32(bytes.count), nil)
        }

        if sqlite3_step(statement) != SQLITE_DONE {
          DataConnectLogger.error("Error inserting result tree for queryId \(queryId)")
        }

        sqlite3_finalize(statement)

        DataConnectLogger.debug("\(#function) - query \(queryId), tree \(tree)")
      } catch {
        DataConnectLogger.error("Error encoding result tree for queryId \(queryId): \(error)")
      }
    }
  }

  func entityData(_ entityGuid: String) -> EntityDataObject {
    return queue.sync {
      let query = "SELECT object FROM entity_data WHERE entity_guid = ?;"
      var statement: OpaquePointer?

      if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
        DataConnectLogger.error("Error preparing select statement for entity_data")
      } else {
        sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)

        if sqlite3_step(statement) == SQLITE_ROW {
          if let dataBlob = sqlite3_column_blob(statement, 0) {
            let dataBlobLength = sqlite3_column_bytes(statement, 0)
            let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
            sqlite3_finalize(statement)
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
        sqlite3_finalize(statement)
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
      let insert = "INSERT OR REPLACE INTO entity_data (entity_guid, object) VALUES (?, ?);"
      var statement: OpaquePointer?

      if sqlite3_prepare_v2(db, insert, -1, &statement, nil) != SQLITE_OK {
        DataConnectLogger.error("Error preparing insert statement for entity_data")
        return
      }

      sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)
      _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        sqlite3_bind_blob(statement, 2, bytes.baseAddress, Int32(bytes.count), nil)
      }

      if sqlite3_step(statement) != SQLITE_DONE {
        DataConnectLogger.error("Error inserting data object for entityGuid \(entityGuid)")
      }

      sqlite3_finalize(statement)

      // update references
      _updateQueryRefs(object: object)

    } catch {
      DataConnectLogger.error("Error encoding data object for entityGuid \(entityGuid): \(error)")
    }
  }

  private func _updateQueryRefs(object: EntityDataObject) {
    dispatchPrecondition(condition: .onQueue(queue))

    guard object.isReferencedFromAnyQueryRef else {
      return
    }
    var insertReferences =
      "INSERT OR REPLACE INTO entity_data_query_refs (entity_guid, query_id) VALUES "
    for queryId in object.referencedFromRefs() {
      insertReferences += "('\(object.guid)', '\(queryId)'), "
    }
    insertReferences.removeLast(2)
    insertReferences += ";"

    var statementRefs: OpaquePointer?
    if sqlite3_prepare_v2(db, insertReferences, -1, &statementRefs, nil) != SQLITE_OK {
      DataConnectLogger.error("Error preparing insert statement for entity_data_query_refs")
      return
    }

    if sqlite3_step(statementRefs) != SQLITE_DONE {
      DataConnectLogger.error(
        "Error inserting data object references for entityGuid \(object.guid)"
      )
    }

    sqlite3_finalize(statementRefs)
  }

  private func _readQueryRefs(entityGuid: String) -> [String] {
    let readRefs =
      "SELECT query_id FROM entity_data_query_refs WHERE entity_guid = '\(entityGuid)'"
    var statementRefs: OpaquePointer?
    var queryIds: [String] = []

    if sqlite3_prepare_v2(db, readRefs, -1, &statementRefs, nil) == SQLITE_OK {
      while sqlite3_step(statementRefs) == SQLITE_ROW {
        if let cString = sqlite3_column_text(statementRefs, 0) {
          queryIds.append(String(cString: cString))
        }
      }

      sqlite3_finalize(statementRefs)

      return queryIds
    } else {
      DataConnectLogger.error("Error reading query references for \(entityGuid)")
    }

    return []

  }

}
