//
//  CacheStore.swift
//  JTCacheStore
//
//  Created by Judy Tsai on 2024/7/4.
//

import Foundation

class CacheStore: CacheStoreProtocol, CacheStorePrivateProtocol {
    var cache: [String: Data] = [:]
    
    let storeURL: URL
    init(storeURL: URL) {
        self.storeURL = storeURL
        // retry mechanism
        loadFromStore { _ in }
    }
    
    func loadFromStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void) {
        do {
            let data = try Data(contentsOf: self.storeURL)
            let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
            if let cache = decodedData as? [String: Data] {
                self.cache = cache
                completion(.success(()))
            } else {
                // completion with failed
            }
            
        } catch {
            completion(.failure(.failureLoadCache))
        }
    }
    
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: cache, options: [])
            try data.write(to: storeURL)
            completion(.success(()))
        } catch {
            completion(.failure(.failureSaveCache))
        }
    }
    
    func insert(withID id: String, data: Data, completion: @escaping ((Result<Void, CacheStoreError>) -> Void)) {
        cache[id] = data
        // Should call saveToStore from outside
    }
    
    func retrieve(withID id: String, completion: @escaping ((Result<Data, CacheStoreError>) -> Void)) {
        if let data = cache[id] {
            completion(.success(data))
        } else {
            completion(.failure(.retrieveError))
        }
    }
    
    func delete(withID id: String) {
        cache.removeValue(forKey: id)
    }
}

enum CacheStoreError: Error {
    case insertionError
    case failureLoadCache
    case failureSaveCache
    case retrieveError
}

// private protocol 只有在同個 file 看得到
private protocol CacheStorePrivateProtocol {
    func loadFromStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void)
}

protocol CacheStoreProtocol {
    func saveToStore(completion: @escaping (Result<Void, CacheStoreError>) -> Void)
    
    func insert(withID id: String, data: Data, completion: @escaping ((Result<Void, CacheStoreError>) -> Void))
    func retrieve(withID id: String, completion: @escaping ((Result<Data, CacheStoreError>) -> Void))
    func delete(withID id: String)
}
