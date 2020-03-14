//
//  ELBRUSTests+SortTests.swift.swift
//  
//
//  Created by Tom Mirwald on 14.01.20.
//

// MARK: Imports
import XCTest
import CodableKit
@testable import ELBRUS

extension ELBRUSTests {
    
    // MARK: - Sort Test
    
    /**
     add three elements and sort them ascending, expect sorted wrapped value
     */
    func test_sortAscendingWithNamesClientside_expectSortedWrappedValue() {
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
                        sortStrategy: .client(SortStrategy.Sorter(direction: .asc, property: \Account.name)))
        
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: nil, name: "Max"))
        rest.wrappedValue.append(Account(id: nil, name: "Paul"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.last! == Account(id: 1, name: "Tom"))
    }
    
    /**
     add three elements and sort them descending, expect sorted wrapped value
     */
    func test_sortDescendingWithNamesClientside_expectSortedWrappedValue() {
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
                        sortStrategy: .client(SortStrategy.Sorter(direction: .desc, property: \Account.name)))
        
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: nil, name: "Max"))
        rest.wrappedValue.append(Account(id: nil, name: "Paul"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.last! == Account(id: 2, name: "Max"))
    }
    
    /**
     sort the elements ascending by the name and expect the correct url extension
     */
    func test_sortAscendingWithNamesServerside_expectCorrectURL() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=+name")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=+name")!,
            expectation: expectation(description: "empty array"),
            mockResult: .success([]))
        ]
        
        let rest = REST(endpoint,
                        sortStrategy: .server(SortStrategy.Sorter(direction: .asc, property: \Account.name)))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     sort the elements descending by the name and expect the correct url extension 
     */
    func test_sortDescendingWithNamesServerside_expectCorrectURL() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=-name")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=-name")!,
            expectation: expectation(description: "empty array"),
            mockResult: .success([]))
            
        ]
        
        let rest = REST(endpoint,
                        sortStrategy: .server(SortStrategy.Sorter(direction: .desc, property: \Account.name)))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    // MARK: - Test cases for checking the priority evaluation of the server route creation
    
    /**
     sort the elements from sortStrategy, sort strategy should be prioritized
     */
    func test_sortWithSortStrategy_expectSortStrategyhasPriority() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=name.asc")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=name.asc")!,
            expectation: expectation(description: "empty array"),
            mockResult: .success([]))
        ]
        
        let rest = REST(endpoint,
                        sortStrategy: .server(SortStrategy.Sorter(direction: .asc, property: \Account.name), dotSortServerStrategy))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     sort the elements from the endpoint, endpoint strategy should be prioritized
     */
    func test_sortWithEndpointStrategy_expectSortStrategyhasPriority() {
        //Given
        endpointWithSortStrategy.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=name.asc")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=name.asc")!,
            expectation: expectation(description: "empty array"),
            mockResult: .success([]))
        ]
        
        let rest = REST(endpointWithSortStrategy,
                        sortStrategy: .server(SortStrategy.Sorter(direction: .asc, property: \Account.name)))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     sort the elements from sortStrategy and the endpoint, sort strategy should be prioritized
     */
    func test_sortWithSortStrategyAndEndpointStrategy_expectSortStrategyhasPriority() {
        //Given
        endpointWithSortStrategy.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=asc(name)")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([])),
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?sort_by=asc(name)")!,
            expectation: expectation(description: "empty array"),
            mockResult: .success([]))
        ]
        
        let rest = REST(endpointWithSortStrategy,
                        sortStrategy: .server(SortStrategy.Sorter(direction: .asc, property: \Account.name), roundBracketsSortServerStrategy))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    
}


// MARK: - other filter strategies

public func dotSortServerStrategy (_ operation: String, _ property: String) -> URLQueryItem {
    if operation == "asc" {
        return URLQueryItem(name: "sort_by", value: "\(property).asc")
    } else {
        return URLQueryItem(name: "sort_by", value: "\(property).desc")
    }
}

public func roundBracketsSortServerStrategy (_ operation: String, _ property: String) -> URLQueryItem {
    if operation == "asc" {
        return URLQueryItem(name: "sort_by", value: "asc(\(property))")
    } else {
        return URLQueryItem(name: "sort_by", value: "desc(\(property))")
    }
}


