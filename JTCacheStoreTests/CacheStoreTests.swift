//
//  CacheStoreTests.swift
//  JTCacheStoreTests
//
//  Created by Judy Tsai on 2024/7/4.
//

import XCTest
@testable import JTCacheStore

class CacheStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoSideEffects()
    }
    
    func test_insert_withSuccessWriteToTheStore() {
        let sut = makeSUT()
        let (id, json) = anyRates1
        let data = toData(with: json)
        sut.insert(withID: id, data: data) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                sut.retrieve(withID: id) { result in
                    switch result {
                    case let .success(receivedData):
                        let retrievedJson = self.toJson(with: receivedData)
                        XCTAssertEqual(json, retrievedJson)
                    default:
                        XCTFail("Should retrieve to store successfully!")
                    }
                }
                
            default:
                XCTFail("Should insert to store successfully!")
            }
        }
        
    }
    
}

private extension CacheStoreTests {
    var anyStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
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
    
    func toData(with json: [String: Double]) -> Data {
        try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    func toJson(with data: Data) -> [String: Double] {
        try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Double]
    }
}
