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

class SQLiteCacheProvider: CacheProvider {

  let cacheIdentifier: String

  private var db: OpaquePointer?
  private let queue = DispatchQueue(label: "com.google.firebase.dataconnect.sqlitecacheprovider")

  init(_ cacheIdentifier: String) throws {
    self.cacheIdentifier = cacheIdentifier

    try queue.sync {
      let path = NSSearchPathForDirectoriesInDomains(
        .applicationSupportDirectory,
        .userDomainMask,
        true
      ).first!
      let dbURL = URL(fileURLWithPath: path).appendingPathComponent("\(cacheIdentifier).sqlite3")

      if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
        throw
          DataConnectInternalError
          .sqliteError(
            message: "Could not open database for identifier \(cacheIdentifier) at \(dbURL.path)"
          )
      }

      try createTables()
    }
  }

  deinit {
    sqlite3_close(db)
  }

  private func createTables() throws {
    dispatchPrecondition(condition: .onQueue(queue))

    let createResultTreeTable = """
      CREATE TABLE IF NOT EXISTS result_tree (
          query_id TEXT PRIMARY KEY NOT NULL,
          last_accessed REAL NOT NULL,
          tree BLOB NOT NULL
      );
      """
    if sqlite3_exec(db, createResultTreeTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Could not create result_tree table")
    }

    let createBackingDataTable = """
      CREATE TABLE IF NOT EXISTS backing_data (
          entity_guid TEXT PRIMARY KEY NOT NULL,
          object_state INTEGER DEFAULT 10,
          object BLOB NOT NULL
      );
      """
    if sqlite3_exec(db, createBackingDataTable, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(message: "Could not create backing_data table")
    }

    // table to store reverse mapping of BDO => queryRefs mapping
    // this is to know which BDOs are still referenced
    let createBackingDataRefs = """
      CREATE TABLE IF NOT EXISTS backing_data_query_refs (
        entity_guid TEXT NOT NULL REFERENCES backing_data(entity_guid),
        query_id TEXT NOT NULL REFERENCES result_tree(query_id),
        PRIMARY KEY (entity_guid, query_id)
      )
      """
    if sqlite3_exec(db, createBackingDataRefs, nil, nil, nil) != SQLITE_OK {
      throw DataConnectInternalError.sqliteError(
        message: "Could not create backing_data_query_refs table"
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

  func backingData(_ entityGuid: String) -> BackingDataObject {
    return queue.sync {
      let query = "SELECT object FROM backing_data WHERE entity_guid = ?;"
      var statement: OpaquePointer?

      if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
        DataConnectLogger.error("Error preparing select statement for backing_data")
      } else {
        sqlite3_bind_text(statement, 1, (entityGuid as NSString).utf8String, -1, nil)

        if sqlite3_step(statement) == SQLITE_ROW {
          if let dataBlob = sqlite3_column_blob(statement, 0) {
            let dataBlobLength = sqlite3_column_bytes(statement, 0)
            let data = Data(bytes: dataBlob, count: Int(dataBlobLength))
            sqlite3_finalize(statement)
            do {
              let bdo = try JSONDecoder().decode(BackingDataObject.self, from: data)
              DataConnectLogger.debug("Returning existing BDO for \(entityGuid)")

              let referencedQueryIds = _readQueryRefs(entityGuid: entityGuid)
              bdo.referencedFrom = Set<String>(referencedQueryIds)
              return bdo
            } catch {
              DataConnectLogger.error(
                "Error decoding data object for entityGuid \(entityGuid): \(error)"
              )
            }
          }
        }
        sqlite3_finalize(statement)
      }

      // if we reach here it means we don't have a BDO in our database.
      // So we create one.
      let bdo = BackingDataObject(guid: entityGuid)
      _setObject(entityGuid: entityGuid, object: bdo)
      DataConnectLogger.debug("Created BDO for \(entityGuid)")
      return bdo
    }
  }

  func updateBackingData(_ object: BackingDataObject) {
    queue.sync {
      _setObject(entityGuid: object.guid, object: object)
    }
  }

  // MARK: Private
  // These should run on queue but not call sync otherwise we deadlock
  private func _setObject(entityGuid: String, object: BackingDataObject) {
    dispatchPrecondition(condition: .onQueue(queue))
    do {
      let data = try JSONEncoder().encode(object)
      let insert = "INSERT OR REPLACE INTO backing_data (entity_guid, object) VALUES (?, ?);"
      var statement: OpaquePointer?

      if sqlite3_prepare_v2(db, insert, -1, &statement, nil) != SQLITE_OK {
        DataConnectLogger.error("Error preparing insert statement for backing_data")
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

  private func _updateQueryRefs(object: BackingDataObject) {
    dispatchPrecondition(condition: .onQueue(queue))

    guard object.referencedFrom.count > 0 else {
      return
    }
    var insertReferences =
      "INSERT OR REPLACE INTO backing_data_query_refs (entity_guid, query_id) VALUES "
    for queryId in object.referencedFrom {
      insertReferences += "('\(object.guid)', '\(queryId)'), "
    }
    insertReferences.removeLast(2)
    insertReferences += ";"

    var statementRefs: OpaquePointer?
    if sqlite3_prepare_v2(db, insertReferences, -1, &statementRefs, nil) != SQLITE_OK {
      DataConnectLogger.error("Error preparing insert statement for backing_data_query_refs")
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
      "SELECT query_id FROM backing_data_query_refs WHERE entity_guid = '\(entityGuid)'"
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
