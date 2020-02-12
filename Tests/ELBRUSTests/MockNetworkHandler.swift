//
//  MockNetworkHandler.swift
//  
//
//  Created by Paul Schmiedmayer on 1/5/20.
//

import XCTest
import Foundation
import Combine

@testable import ELBRUS

// MARK: - TestEncoder
class TestEncoder: TopLevelEncoder {
    func encode<Element>(_ value: Element) throws -> Data where Element: Encodable {
        fatalError("Unexpected Call to `encode` in `TestEncoder`")
    }
}

// MARK: - TestDecoder
class TestDecoder: TopLevelDecoder {
    func decode<Element>(_ type: Element.Type, from: Data) throws -> Element where Element: Decodable {
        fatalError("Unexpected Call to `decode` in `TestDecoder`")
    }
}

// MARK: - AnyPublisher
extension Fail: Error {}

// MARK: - MockNetworkHandler
class MockNetworkHandler<Element: RESTElement>: NetworkHandler {
    let encoder = TestEncoder()
    let decoder = TestDecoder()
    
    var mockNetworkCalls: [MockNetworkCall<Element>]
    
    init(mockNetworkCalls: [MockNetworkCall<Element>]) {
        self.mockNetworkCalls = mockNetworkCalls
    }
    
    func get<E: Codable>(on route: URL) -> AnyPublisher<[E], Error> {
        switch nextMockNetworkCall([E].self) {
        case .success(.get(route, let expectation, let result)):
            expectation.fulfill()
            return result as! AnyPublisher<[E], Error>
        case let .failure(fail):
            return fail.eraseToAnyPublisher()
        default:
            print(route.absoluteString)
            return noMatchingMockNetworkCall([E].self)
        }
    }
    
    func post<E: Codable>(_ element: E, on route: URL) -> AnyPublisher<E, Error> {
        switch nextMockNetworkCall(E.self) {
        case .success(.post(route, element as? Element, let expectation, let result)):
            expectation.fulfill()
            return result as! AnyPublisher<E, Error>
        case let .failure(fail):
            return fail.eraseToAnyPublisher()
        default:
            print(route.absoluteString)
            return noMatchingMockNetworkCall(E.self)
        }
    }
    
    func put<E: Codable>(_ element: E, on route: URL) -> AnyPublisher<E, Error> {
        switch nextMockNetworkCall(E.self) {
        case .success(.put(route, element as? Element, let expectation, let result)):
            expectation.fulfill()
            return result as! AnyPublisher<E, Error>
        case let .failure(fail):
            return fail.eraseToAnyPublisher()
        default:
            print(route.absoluteString)
            return noMatchingMockNetworkCall(E.self)
        }
    }
    
    func delete(at route: URL) -> AnyPublisher<Void, Error> {
        switch nextMockNetworkCall(Void.self) {
        case .success(.delete(route, let expectation, let result)):
            expectation.fulfill()
            return result
        case let .failure(fail):
            return fail.eraseToAnyPublisher()
        default:
            print(route.absoluteString)
            return noMatchingMockNetworkCall(Void.self)
        }
        
    }
    
    private func nextMockNetworkCall<T>(_ type: T.Type) -> Result<MockNetworkCall<Element>, Fail<T, Error>> {
        guard !mockNetworkCalls.isEmpty else {
            XCTFail("No MockNetworkCall left in the MockNetworkHandler.")
            return .failure(Fail(outputType: type, failure: XCTFailError()))
        }
        
        return .success(mockNetworkCalls.removeFirst())
    }
    
    private func noMatchingMockNetworkCall<T>(_ type: T.Type) -> AnyPublisher<T, Error> {
        XCTFail("Coult not match the network call to the next MockNetworkCall.")
        return Fail(outputType: type, failure: XCTFailError()).eraseToAnyPublisher()
    }
}
