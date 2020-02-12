//
//  Endpoint.swift
//  
//
//  Created by Tom Mirwald on 02.01.20.
//

// MARK: Imports
import Foundation

// MARK: - Service
/// Represents the service that holds all the network functionality, offers configuration to the filter and sort query creation and stores the endpoints to perform the network requests
public class Service<N: NetworkHandler> {
    var url: URL
    var urlComponents: URLComponents
    var networkHandler: N
    var filterServerStrategy: ((String, String, String) -> URLQueryItem)?
    var sortServerStrategy: ((String, String) -> URLQueryItem)?
    
    public init(url: URL,
                networkHandler: N,
                filterServerStrategy: ((String, String, String) -> URLQueryItem)? = nil,
                sortServerStrategy: ((String, String) -> URLQueryItem)? = nil) {
        self.url = url
        self.urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) ?? URLComponents()
        self.networkHandler = networkHandler
        self.filterServerStrategy = filterServerStrategy
        self.sortServerStrategy = sortServerStrategy
    }
    
    /// Appends a route string to the URL and returns it
    /// - Parameter route: the route that should be appended
    /// - Returns: An URL with the appended path
    func append(route: String) -> URL {
        url.appendingPathComponent(route)
    }
    
    /// Adds the queries to the url
    /// - Parameter queryStrategy: specifies the queries that should be added
    func append(queryStrategy: [URLQueryItem]) {
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryStrategy
    }
}

/// JSONService provides a initialisation of a Service with a URLSessionNetworkHandler
public class JSONService: Service<URLSessionJSONNetworkHandler> {
    public init (url: URL) {
        super.init(url: url, networkHandler: URLSessionJSONNetworkHandler())
    }
}
