//
//  ELBRUSTests+FilterAndSortTests.swift
//  
//
//  Created by Tom Mirwald on 15.01.20.
//

// MARK: Imports
import XCTest
import CodableKit
@testable import ELBRUS

extension ELBRUSTests {
    
    // MARK: - Filter + Sort
    
    /**
     filter and sort elements serverside, expect the correct URL 
     */
    func test_filterAndSort_expectEmptyArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name[exists]=Paul&sort_by=+name")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint, filterStrategy: .server(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")])), sortStrategy: .server(SortStrategy.Sorter(direction: .asc, property: \Account.name)) )
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element id is in a specific range and sorted ascending
     */
    func test_filterGteAndLteWithIDClientsideAndSortAsc_expectSortedArrayWithIDsInRange() {
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
        
        let rest = REST(endpoint,
                        filterStrategy:
            .client(FilterStrategy.Filter(operations: [.lte(\Account.id!, 2), .gte(\Account.id!, 1)])), sortStrategy: .client(SortStrategy.Sorter(direction: .asc, property: \Account.name)))
        
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: nil, name: "Max"))
        rest.wrappedValue.append(Account(id: nil, name: "Paul"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssertFalse(rest.wrappedValue.isEmpty)
        XCTAssert(rest.wrappedValue.count == 2)
        XCTAssert(rest.wrappedValue.first == Account(id: 2, name: "Max"))
    }
    
    
}
