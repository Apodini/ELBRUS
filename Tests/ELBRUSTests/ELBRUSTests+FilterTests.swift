//
//  ELBRUSTests+FilterTests.swift
//  
//
//  Created by Tom Mirwald on 14.01.20.
//

// MARK: Imports
import XCTest
import CodableKit
@testable import ELBRUS

extension ELBRUSTests {
    // MARK: - Filter Test
    // MARK: - clientside
    
    /**
     filter element, element name do not matches the inserted element and we expect an empty array
     */
    func test_filterExistsWithNamesClientside_expectEmptyArray() {
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
        
        let rest = REST(endpoint, filterStrategy: .client(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")])))
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element name is not less than the inserted element and we expect an empty array
     */
    func test_filterLteWithNamesClientside_expectEmptyArray() {
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
        
        let rest = REST(endpoint, filterStrategy: .client(FilterStrategy.Filter(operations: [.lte(\Account.name, "Paul")])))
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element name is greater than the inserted element and we expect an array with one element
     */
    func test_filterGteWithNamesClientside_expectArrayWithOneElement() {
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
        
        let rest = REST(endpoint, filterStrategy: .client(FilterStrategy.Filter(operations: [.gte(\Account.name, "Paul")])))
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssertFalse(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element id is in a specific range
     */
    func test_filterGteAndLteWithIDClientside_expectArrayWithIDsInRange() {
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
            .client(FilterStrategy.Filter(operations: [.lte(\Account.id!, 2), .gte(\Account.id!, 1)])))
        
        rest.wrappedValue.append(Account(id: nil, name: "Tom"))
        rest.wrappedValue.append(Account(id: nil, name: "Max"))
        rest.wrappedValue.append(Account(id: nil, name: "Paul"))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssertFalse(rest.wrappedValue.isEmpty)
        XCTAssert(rest.wrappedValue.count == 2)
    }
    
    // MARK: - serverside
    
    /**
     filter element, element name do not matches the inserted element and we expect an empty array
     */
    func test_filterExistsWithNamesServerside_expectEmptyArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name[exists]=Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint, filterStrategy: .server(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")])))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element name is not less than the inserted element and we expect an empty array
     */
    func test_filterLteWithNamesServerside_expectEmptyArray() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name[lte]=Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint, filterStrategy: .server(FilterStrategy.Filter(operations: [.lte(\Account.name, "Paul")])))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element name is greater than the inserted element and we expect an array with one element
     */
    func test_filterGteWithNamesServerside_expectArrayWithOneElement() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name[gte]=Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint, filterStrategy: .server(FilterStrategy.Filter(operations: [.gte(\Account.name, "Paul")])))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, element id is in a specific range
     */
    func test_filterGteAndLteWithIDServerside_expectArrayWithIDsInRange() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?id[lte]=2&id[gte]=1")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint,
                        filterStrategy:
            .server(FilterStrategy.Filter(operations: [.lte(\Account.id!, 2), .gte(\Account.id!, 1)])))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    // MARK: - Test cases for checking the priority evaluation of the server route creation
    
    /**
     filter element, check the priority, filterstrategy should be prioritized
     */
    func test_filterWithFilterStrategy_expectFilterStrategyHasPriority() {
        //Given
        endpoint.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name=exists:Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpoint, filterStrategy: .server(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")]), colonFilterServerStrategy))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, check the priority, endpoint should be prioritized
     */
    func test_filterWithEndPointStrategy_expectEndpointFilterStrategyHasPriority() {
        //Given
        endpointWithFilterStrategy.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name=exists:Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpointWithFilterStrategy, filterStrategy: .server(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")])))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    /**
     filter element, check the priority, filter strategy should be prioritized
     */
    func test_filterWithFilterStrategyAndEndpointStrategy_expectFilterStrategyHasPriority() {
        //Given
        endpointWithFilterStrategy.networkHandler.mockNetworkCalls = [
            .get(url: URL(string: "test.schmiedmayer.com/api/accounts?name(exists)=Paul")!,
                 expectation: expectation(description: "empty array"),
                 mockResult: .success([]))
        ]
        
        let rest = REST(endpointWithFilterStrategy, filterStrategy: .server(FilterStrategy.Filter(operations: [.exists(\Account.name, "Paul")]), roundBracketsFilterServerStrategy))
        
        //When
        waitForExpectations(timeout: 0.1, handler: nil)
        
        //Then
        XCTAssert(rest.wrappedValue.isEmpty)
    }
    
    
}

// MARK: - other filter strategies

public func colonFilterServerStrategy(_ property: String, _ operation: String, _ value: String) -> URLQueryItem {
    return URLQueryItem(name: "\(property)", value: "\(operation):\(value)")
}

public func roundBracketsFilterServerStrategy(_ property: String, _ operation: String, _ value: String) -> URLQueryItem {
    return URLQueryItem(name: "\(property)(\(operation))", value: "\(value)")
}

