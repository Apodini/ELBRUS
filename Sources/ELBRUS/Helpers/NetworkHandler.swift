//
//  NetworkHandler.swift
//  
//
//  Created by Tom Mirwald on 02.01.20.
//

// MARK: Imports
import Foundation
import Combine

// MARK: - NetworkHandler
/// Defines a protocol to represent all the network functionality that is used to communicate with a RESTful service, the encoding/decoding strategy, the different network requests (get, post, put, delete) and the authorization method.
public protocol NetworkHandler {
    /// defines the encoding strategy
    associatedtype Encoder: TopLevelEncoder
    /// defines the decoding strategy
    associatedtype Decoder: TopLevelDecoder
    
    /// the variable that holds the encoder
    var encoder: Encoder { get }
    /// the variable that holds the decoder
    var decoder: Decoder { get }
    /// the variable that holds the authorization method
    var authorization: Authorization { get }
    
    /// implements a GET request
    /// - Parameter route: specifies the `URL` for the GET request
    /// - Returns: an `AnyPublisher` that holds a data array and an error
    func get<Element: Codable>(on route: URL) -> AnyPublisher<[Element], Error>
    
    /// implements a POST request
    /// - Parameters:
    ///     - element: specifies the element that will be posted
    ///     -  route: specifies the `URL` for the POST request
    /// - Returns: an `AnyPublisher` that holds the posted element with a specified `ID` and an error
    func post<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error>
    
    /// implements a PUT request
    /// - Parameters:
    ///     - element: specifies the new element that will be edited on the ID of this element
    ///     -  route: specifies the `URL`` for the PUT request
    /// - Returns: an `AnyPublisher` that holds the changed element and an error
    func put<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error>
    
    /// implements a DELETE request
    /// - Parameter route: specifies the `URL` for the DELETE request
    /// - Returns: an `AnyPublisher` that holds an error
    func delete(at route: URL) -> AnyPublisher<Void, Error>
}
