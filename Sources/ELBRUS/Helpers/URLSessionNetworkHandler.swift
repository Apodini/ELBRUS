//
//  URLSessionNetworkHandler.swift
//  
//
//  Created by Paul Schmiedmayer on 1/5/20.
//

// MARK: Imports
import Foundation
import Combine

// MARK: URLSessionNetworkHandler
/// `URLSessionNetworkHandler` conforms to the `NetworkHandler` protocol and represents an implementation of the different network requests
public class URLSessionNetworkHandler<Encoder: TopLevelEncoder, Decoder: TopLevelDecoder>: NetworkHandler
where Encoder.Output == Data, Decoder.Input == Data {
    /// specifies the encoding strategy
    public let encoder: Encoder
    /// specifies the decoding strategy
    public let decoder: Decoder
    /// specifies the authorization method
    public let authorization: Authorization
    
    /// initialization of the `URLSessionNetworkHandler` with `.none` as default `Authorization` variable
    public init(encoder: Encoder, decoder: Decoder, authorization: Authorization = .none) {
        self.encoder = encoder
        self.decoder = decoder
        self.authorization = authorization
    }
    
    /// performs a PUT request on the specified `URL` and replaces the element located on the `URL` with the `Element` that is passed in
    /// - Parameters:
    ///   - element: the element that is used to replace the old element
    ///   - route: the `URL` where the old element is located
    /// - Returns: an `AnyPublisher` that holds the new `Element` and an `Error`
    public func put<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error> {
        var urlRequest = URLRequest(url: route, authorization: authorization)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? encoder.encode(element)
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: Element.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// performs a GET request on the specified `URL`
    /// - Parameter route: the `URL` where the GET request gets the `Elements`
    /// - Returns: an `AnyPublisher` that holds the returned array of `Elements` and an `Error`
    public func get<Element: Codable>(on route: URL) -> AnyPublisher<[Element], Error> {
        var urlRequest = URLRequest(url: route, authorization: authorization)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [Element].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    /// performs a POST request on the specified `URL`
    /// - Parameters:
    ///   - element: the new `Element` that is posted
    ///   - route: the `URL` for the new `Element`
    /// - Returns: an `AnyPublisher` that holds the new `Element` and an `Error`
    public func post<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error> {
        var urlRequest = URLRequest(url: route, authorization: authorization)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? encoder.encode(element)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: Element.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// performs a DELETE request on the specified `URL`
    /// - Parameter route: the `URL` where the removal happens
    /// - Returns: an `AnyPublisher` that holds a `Void` type and an `Error`
    public func delete(at route: URL) -> AnyPublisher<Void, Error> {
        var urlRequest = URLRequest(url: route, authorization: authorization)
        urlRequest.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { _, response in
                guard let response = response as? HTTPURLResponse, 200..<299 ~= response.statusCode else {
                    throw URLError(.unknown)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

/// The `URLSessionJSONNetworkHandler` is a specialized version of `URLSessionNetworkHandler` that uses JSON as encoding and decoding strategy.
public class URLSessionJSONNetworkHandler: URLSessionNetworkHandler<JSONEncoder, JSONDecoder> {
    /// `init `initializes a `URLSessionNetworkHandler` with a `JSONEncoder` and `JSONDecoder`
    public init() {
        super.init(encoder: JSONEncoder(), decoder: JSONDecoder())
    }
}

extension URLRequest {
    init(url: URL, authorization: Authorization) {
        self.init(url: url)
        
        switch authorization {
        case .none: break
        case .credentials(let type):
            self.addValue(type.description, forHTTPHeaderField: "Authorization")
        case .token(let type):
            self.addValue(type.description, forHTTPHeaderField: "Authorization")
        }
    }
}
