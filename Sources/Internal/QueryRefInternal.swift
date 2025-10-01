//
//  QueryRefInternal.swift
//  FirebaseDataConnect
//
//  Created by Aashish Patil on 9/29/25.
//

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
internal protocol QueryRefInternal: QueryRef {
  var operationId: String { get }
  func publishCacheResultsToSubscribers(allowStale: Bool) async throws
}
