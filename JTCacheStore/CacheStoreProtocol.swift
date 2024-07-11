//
//  CacheStoreProtocol.swift
//  JTCacheStore
//
//  Created by Judy Tsai on 2024/7/11.
//

import Foundation

enum CacheStoreError: Error {
    case failureLoadCache
    case failureSaveCache
}

protocol CacheStoreProtocol {
    func loadFromStore(completion: @escaping (Result<[String: Any], CacheStoreError>) -> Void)
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void)
    
    func insert(withID id: String, json: Any)
    func retrieve(withID id: String, completion: @escaping (RetrieveStoreResult) -> Void)
    func delete(withID id: String)
}
