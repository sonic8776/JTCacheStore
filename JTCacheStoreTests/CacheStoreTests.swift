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
    
    func test_insert_withSuccessWriteToTheCache() {
        let sut = makeSUT()
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        
        sut.retrieve(withID: anyRates1.id) { result in
            switch result {
            case .found(_):
                break
            default:
                XCTFail("Fail to retrieve anyRate1!")
            }
        }
    }
    
    func test_insert_twice_withSuccessfullyWriteToTheStore() {
        let sut = makeSUT()
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        sut.insert(withID: anyRates2.id, json: anyRates2.json)
        
        sut.retrieve(withID: anyRates1.id) { result in
            switch result {
            case .found(_):
                break
            default:
                XCTFail("Fail to retrieve anyRate1!")
            }
        }
        
        sut.retrieve(withID: anyRates2.id) { result in
            switch result {
            case .found(_):
                break
            default:
                XCTFail("Fail to retrieve anyRate2!")
            }
        }
    }
    
    func test_delete_withSuccessDeleteFromTheStore() {
        let sut = makeSUT()
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        sut.insert(withID: anyRates2.id, json: anyRates2.json)
        
        sut.delete(withID: anyRates2.id)
        
        sut.retrieve(withID: anyRates1.id) { result in
            switch result {
            case .found(_):
                break
            default:
                XCTFail("Fail to retrieve anyRate1!")
            }
        }
        
        sut.retrieve(withID: anyRates2.id) { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Fail to delete anyRate2!")
            }
        }
    }
    
    func test_operations_runSerially() {
        var operationResults = [String]()
        let sut = makeSUT()
        
        let op1 = "Operation1: Insertion"
        sut.insert(withID: anyRates1.id, json: anyRates1.json)
        operationResults.append(op1)
        
        let op2 = "Operation2: Deletion"
        sut.delete(withID: anyRates1.id)
        operationResults.append(op2)
        
        let op3 = "Operation3: Insertion"
        sut.insert(withID: anyRates2.id, json: anyRates2.json)
        operationResults.append(op3)
        
        XCTAssertEqual(operationResults, [op1, op2, op3])
        
        sut.retrieve(withID: anyRates1.id) { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Fail to delete anyRate1!")
            }
        }
        
        sut.retrieve(withID: anyRates2.id) { result in
            switch result {
            case .found(_):
                break
            default:
                XCTFail("Fail to retrieve anyRate2!")
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
