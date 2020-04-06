//
//  XCTestManifests.swift
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Copyright © 2019 TUM LS1. All rights reserved.
//

// MARK: Imports
import XCTest
import Foundation
import CodableKit
@testable import ELBRUS

// MARK: - Account
/// Represents a single account that consists of a set of transactions.
struct Account: RESTElement {
    // MARK: Stored Properties
    public var id: Int?
    public var name: String
    
    // MARK: Initializers
    public init(id: Account.ID = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func < (lhs: Account, rhs: Account) -> Bool {
        return lhs.name < rhs.name
    }
    
    public var description: String {
        return "id: \(String(describing: id)), name: \(name)"
    }
}

// MARK: - ELBRUSTests
final class ELBRUSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        endpoint.networkHandler.mockNetworkCalls = []
        super.tearDown()
    }
    
    let endpoint: Service<MockNetworkHandler<Account>> = {
        let networkHandler = MockNetworkHandler<Account>(mockNetworkCalls: [])
        return Service(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                       networkHandler: networkHandler)
    }()
    
    let endpointWithFilterStrategy: Service<MockNetworkHandler<Account>> = {
        let networkHandler = MockNetworkHandler<Account>(mockNetworkCalls: [])
        return Service(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                       networkHandler: networkHandler, filterServerStrategy: colonFilterServerStrategy)
    }()
    
    let endpointWithSortStrategy: Service<MockNetworkHandler<Account>> = {
        let networkHandler = MockNetworkHandler<Account>(mockNetworkCalls: [])
        return Service(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                       networkHandler: networkHandler, sortServerStrategy: dotSortServerStrategy)
    }()
    
    // MARK: - simple network requests
    
    /**
     load initial state and receive empty array
     */
    func test_doNothing_expectEmptyArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(mock: endpoint)
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     add one account and receive a post request
     */
    func test_addAnAccount_expectOnePostAndOneElementInArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom")))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssertFalse(rest.wrappedValue.isEmpty)
        XCTAssert(rest.wrappedValue.first == Account(id: 1, name: "Tom"))
    }
    
    /**
     add one account and edit this account
     */
    func test_assignOneAccountWithGivenID_expectPutAndChangedElementInArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom"))),
            .put(url: URL(string: "test.schmiedmayer.com/api/accounts/1")!,
                 element: Account(id: 1, name: "Paul"),
                 expectation: expectation(description: "changed Tom's account to Paul's account"),
                 mockResult: .success(Account(id: 1, name: "Paul")))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue = [Account(id: nil, name: "Tom")]
        rest.wrappedValue = [Account(id: 1, name: "Paul")]
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.first == Account(id: 1, name: "Paul"))
    }
    
    /**
     add one account and edit this account
     */
    func test_appendOneAccountWithGivenID_expectPutAndChangedElementInArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom"))),
            .put(url: URL(string: "test.schmiedmayer.com/api/accounts/1")!,
                 element: Account(id: 1, name: "Paul"),
                 expectation: expectation(description: "changed Tom's account to Paul's account"),
                 mockResult: .success(Account(id: 1, name: "Paul")))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: 1, name: "Paul"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.first == Account(id: 1, name: "Paul"))
    }
    
    /**
     add one account and delete this account
     */
    func test_addAnAccountAndDeleteIt_expectDeleteAndEmptyArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom"))),
            .delete(url: URL(string: "test.schmiedmayer.com/api/accounts/1")!,
                    expectation: expectation(description: "account with ID 1 is deleted"),
                    mockResult: .success(Void()))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.removeFirst()
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    // MARK: - complex network requests, simultaneous changes
    
    /**
     add three elements, assign new data with the same different elements but in a different order and expect no network requests
     */
    func test_assignNewArrayWithSameElementsInDifferentOrder_expectNoMoreRequestsAfterAssign() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom"))),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Max"),
                  expectation: expectation(description: "Max's account with ID 2"),
                  mockResult: .success(Account(id: 2, name: "Max"))),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Paul"),
                  expectation: expectation(description: "Paul's account with ID 3"),
                  mockResult: .success(Account(id: 3, name: "Paul")))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: nil, name: "Max"))
        rest.wrappedValue.append(Account(id: nil, name: "Paul"))
        rest.wrappedValue = [Account(id: 1, name: "Tom"), Account(id: 3, name: "Paul"), Account(id: 2, name: "Max")]
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssertFalse(rest.wrappedValue.isEmpty)
    }
    
    /**
     assign edited element and inserted element at the same time and expect a put and post request
     */
    func test_assignEditedElementAndInsertedElementSimultaneously() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Tom"),
                  expectation: expectation(description: "Tom's account with ID 1"),
                  mockResult: .success(Account(id: 1, name: "Tom"))),
            .put(url: URL(string: "test.schmiedmayer.com/api/accounts/1")!,
                 element: Account(id: 1, name: "Tommy"),
                 expectation: expectation(description: "changed Tom's account to Tommy's account"),
                 mockResult: .success(Account(id: 1, name: "Tommy"))),
            .post(url: URL(string: "test.schmiedmayer.com/api/accounts")!,
                  element: Account(id: nil, name: "Max"),
                  expectation: expectation(description: "Max's account with ID 4"),
                  mockResult: .success(Account(id: 2, name: "Max")))
        ]
        
        let rest = REST(mock: endpoint)
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        
        rest.wrappedValue = [Account(id: 1, name: "Tommy"), Account(id: nil, name: "Max")]
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.first == Account(id: 1, name: "Tommy"))
        XCTAssert(rest.wrappedValue.last == Account(id: 2, name: "Max"))
        
    }
}

extension String: Reflectable {}
extension Int: Reflectable {}
