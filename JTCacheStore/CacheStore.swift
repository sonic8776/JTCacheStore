//
//  CacheStore.swift
//  JTCacheStore
//
//  Created by Judy Tsai on 2024/7/4.
//

import Foundation

class CacheStore: CacheStoreProtocol {

    typealias Cache = [String: Any]
    
    var cache: Cache = [:]
    
    let storeURL: URL
    init(storeURL: URL) {
        self.storeURL = storeURL
        // retry mechanism
        
        loadFromStore { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(cache):
                self.cache = cache
            default:
                // 第一次運行一定會找不到，因為 cache folder 還沒有這個 file
                break
            }
        }
    }
    
    func loadFromStore(completion: @escaping (Result<Cache, CacheStoreError>) -> Void) {
        do {
            let data = try Data(contentsOf: self.storeURL)
            let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
            if let cache = decodedData as? Cache {
                completion(.success(cache))
            } else {
                completion(.failure(.failureLoadCache))
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
    
    func insert(withID id: String, json: Any) {
        cache[id] = json
    }
    
    func retrieve(withID id: String, completion: @escaping (RetrieveStoreResult) -> Void) {
        guard let json = cache[id] else {
            completion(.empty)
            return
        }
        completion(.found(json))
    }
    
    func delete(withID id: String) {
        cache.removeValue(forKey: id)
    }
}
