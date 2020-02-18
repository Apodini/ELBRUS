//
//  REST+Never.swift
//  
//
//  Created by Paul Schmiedmayer on 1/9/20.
//

// MARK: Imports
import Foundation
import CodableKit

// MARK: Extension: Never
/// An extension to Never to enable an initialisation of a property wrapper without a filter and/or sort strategy to not specifiy the generic types
extension Never: Reflectable & ReflectionDecodable & LosslessStringConvertible & Codable {
    public static func reflectDecoded() -> (Never, Never) {
        fatalError("Can not create an instance of Never")
    }
    
    public init(from decoder: Decoder) throws {
        fatalError("Can not create an instance of Never")
    }
    
    public init?(_ description: String) {
        fatalError("Can not create an instance of Never")
    }
    
    public var description: String {
        fatalError("Can not create an instance of Never")
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("Can not create an instance of Never")
    }
}

extension REST where F == Never {
    /// In the case that no filter is needed, the generic `Filterable` type will be inferred as `Never`
    public convenience init(_ endpoint: Service<N>, sortStrategy: SortStrategy<Element, S>, caching: Bool = false) {
        self.init(endpoint, filterStrategy: .none, sortStrategy: sortStrategy, caching: caching)
    }
}

extension REST where S == Never {
    /// In the case that no filter is needed, the generic `Sortable` type will be inferred as `Never`
    public convenience init(_ endpoint: Service<N>, filterStrategy: FilterStrategy<Element, F>, caching: Bool = false) {
        self.init(endpoint, filterStrategy: filterStrategy, sortStrategy: .none, caching: caching)
    }
}
/// In the case that no filter and sorting is needed, the generic `Filterable` and  `Sortable` type will be both inferred as `Never`
extension REST where F == Never, S == Never {
    public convenience init(_ endpoint: Service<N>, caching: Bool = false) {
        self.init(endpoint, filterStrategy: .none, sortStrategy: .none, caching: caching)
    }
}
