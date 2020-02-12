//
//  MockNetworkCall.swift
//  
//
//  Created by Paul Schmiedmayer on 1/5/20.
//

// MARK: Imports
import Foundation
import Combine
import XCTest

// MARK: - XCTFailError
struct XCTFailError: Error {}

// MARK: - MockNetworkCall
enum MockNetworkCall<Element: Codable> {
    
    case get(url: URL, expectation: XCTestExpectation, mockResult: AnyPublisher<[Element], Error>)
    case put(url: URL, element: Element, expectation: XCTestExpectation, mockResult: AnyPublisher<Element, Error>)
    case post(url: URL, element: Element, expectation: XCTestExpectation, mockResult: AnyPublisher<Element, Error>)
    case delete(url: URL, expectation: XCTestExpectation, mockResult: AnyPublisher<Void, Error>)
    
    @available(*, unavailable) private init() {
        fatalError("Not implemented, use static methods instead")
    }
    
    static func get<Element>(url: URL, expectation: XCTestExpectation, mockResult: Result<[Element], Error>) -> MockNetworkCall<Element> {
        return .get(url: url, expectation: expectation, mockResult: publisher(from: mockResult))
    }
    
    static func put<Element>(url: URL,
                             element: Element,
                             expectation: XCTestExpectation,
                             mockResult: Result<Element, Error>) -> MockNetworkCall<Element> {
        return .put(url: url, element: element, expectation: expectation, mockResult: publisher(from: mockResult))
    }
    
    static func post<Element>(url: URL,
                              element: Element,
                              expectation: XCTestExpectation,
                              mockResult: Result<Element, Error>) -> MockNetworkCall<Element> {
        return .post(url: url, element: element, expectation: expectation, mockResult: publisher(from: mockResult))
    }
    
    static func delete (url: URL, expectation: XCTestExpectation, mockResult: Result<Void, Error>) -> MockNetworkCall<Element> {
        return .delete(url: url, expectation: expectation, mockResult: publisher(from: mockResult))
    }
    
    private static func publisher<Output>(from result: Result<Output, Error>) -> AnyPublisher<Output, Error> {
        switch result {
        case let .success(output):
            return Just(output).tryMap({ $0 }).eraseToAnyPublisher()
        case let .failure(error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
