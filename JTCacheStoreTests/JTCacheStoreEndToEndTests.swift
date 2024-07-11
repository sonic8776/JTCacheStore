//
//  JTCacheStoreEndToEndTests.swift
//  JTCacheStoreIntegrationTests
//
//  Created by Judy Tsai on 2024/7/11.
//

import XCTest
@testable import JTCacheStore

class JTCacheStoreEndToEndTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoSideEffects()
    }
    
    func test_insert_to_file() {
        // 1. 存兩個 rates 到 json file 中
        let sut = makeSUT()
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        sut.insert(withID: anyRates2.id, json: anyRates2.json)
        
        // 2. 將 cache 存回 file
        sut.saveToStore { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(_):
                // 3. 重新 load file
                sut.loadFromStore { result in
                    switch result {
                    case .success(let cache):
                        // 4. 看 load file 過後的 cache 裡面有沒有那兩個 rates
                        XCTAssertNotNil(cache[self.anyRates1.id])
                        XCTAssertNotNil(cache[self.anyRates2.id])
                        
                    default:
                        XCTFail("Fail to save cache to file!")
                    }
                }
                
            case .failure(let failure):
                XCTFail("Fail to save cache to file!")
            }
        }
    }
    
    func test_delete_to_file() {
        // 1. 存兩個 rates 到 json file 中
        let sut = makeSUT()
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        sut.insert(withID: anyRates2.id, json: anyRates2.json)
        
        // 2. 將 cache 存回 file
        sut.saveToStore { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(_):
                
                // 3. 重新 load file
                sut.loadFromStore { result in
                    switch result {
                    case .success(let cache):
                        // 4. 做 delete 的動作
                        sut.delete(withID: self.anyRates1.id)
                        sut.delete(withID: self.anyRates2.id)
                        
                        // 5. 看 load file 過後的 cache 裡面有沒有那兩個 rates
                        sut.retrieve(withID: self.anyRates1.id) { result in
                            switch result {
                            case .empty:
                                break
                            case .found(_):
                                XCTFail("Fail to delete file!")
                            }
                        }
                        
                        sut.retrieve(withID: self.anyRates2.id) { result in
                            switch result {
                            case .empty:
                                break
                            case .found(_):
                                XCTFail("Fail to delete file!")
                            }
                        }
                        
                    default:
                        XCTFail("Fail to save cache to file!")
                        
                    }
                }
                
            case .failure(let failure):
                XCTFail("Fail to save cache to file!")
            }
        }
    }
}

private extension JTCacheStoreEndToEndTests {
    var anyStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).json")
    }
    
    var anyRates1: (id: String, json: [String: Double]) {
        let id = "anyRates1ID"
        let json = [
            "AED": 1.0,
            "AUD": 2.0,
            "TWD": 3.0,
        ]
        return (id, json)
    }
    
    var anyRates2: (id: String, json: [String: Double]) {
        let id = "anyRates2ID"
        let json = [
            "USD": 3.0,
            "JPD": 2.0,
            "BIC": 1.0,
        ]
        return (id, json)
    }
    
    func makeSUT() -> CacheStore {
        let sut = CacheStore(storeURL: anyStoreURL)
        return sut
    }
    
    func deleteStoreSideEffect() {
        try? FileManager.default.removeItem(at: anyStoreURL)
    }
    
    func setupEmptyStoreState() {
        deleteStoreSideEffect()
    }
    
    func undoSideEffects() {
        deleteStoreSideEffect()
    }
}
