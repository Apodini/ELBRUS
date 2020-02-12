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
/// Defines a protocol to represent all the network functionality that is used to communicate with a REST endpoint, the encoding strategy and the different network requests (get, post, put, delete) 
public protocol NetworkHandler {
    associatedtype Encoder: TopLevelEncoder
    associatedtype Decoder: TopLevelDecoder
    
    var encoder: Encoder { get }
    var decoder: Decoder { get }
    
    func get<Element: Codable>(on route: URL) -> AnyPublisher<[Element], Error>
    func post<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error>
    func put<Element: Codable>(_ element: Element, on route: URL) -> AnyPublisher<Element, Error>
    func delete(at route: URL) -> AnyPublisher<Void, Error>
}
