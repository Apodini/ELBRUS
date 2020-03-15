//
//  Filter.swift
//  
//
//  Created by Tom Mirwald on 02.01.20.
//

// MARK: Imports
import Foundation
import CodableKit

// MARK: FilterStrategy
/// represents the filter strategy with the different options client, server and none filter
///
/// How to define a `FilterStrategy`:
///
///    `FilterStrategy` example:
///    
///    basic structure:
///
///         .strategy(FilterStrategy.Filter(operations: operation1, operation2, ...)))
///
///    client example:
///
///        let clientStrategy = .client(FilterStrategy.Filter(operations: [.lte(\Account.id!, 100), .gte(\Account.id!, )])))
///
///    defines a filter strategy where a fictional account class is filtered for 1 <= ID <= 100
/// - Attention: You can only define the operations array where all `KeyPaths` are from the same data type
 
 

public enum FilterStrategy <K: RESTElement, V: Filterable> {
    /// specifies that the filter process is realized through a server route; the user has the option to specify an own translation function in the case
    /// - Important:
    /// The configuration of an own server strategy `URL` creation method takes precedence over the `FilterStrategy` that is specified over the `Service`.
    case server(Filter<K, V>, ((String, String, String) -> URLQueryItem)? = nil)
    ///  specifies that the filter process is realized through the `REST` property wrapper locally by the client.
    case client(Filter<K, V>)
    ///  specfies that filtering is not wanted and the default case.
    case none
    
    
    // MARK: Filter
    /// represents a filter that takes a generic `RESTElement` and `Filterable` element to perform the operations: greater equal, less equal and exists, with the possibility to have more than one filter operation
    public class Filter<K: RESTElement, V: Filterable> {
        let operations: [Operation<K, V>]
        var applied = false
        
        /// specifies the filter operation with the possible options of less equal (`.lte`), greater equal (`.gte`) and equal (`.exists`)
        public enum Operation<K, V> {
            case lte(WritableKeyPath<K, V>, V)
            case gte(WritableKeyPath<K, V>, V)
            case exists(WritableKeyPath<K, V>, V)
            
            var description: String {
                switch self {
                case .gte:
                    return "gte"
                case .lte:
                    return "lte"
                case .exists:
                    return "exists"
                }
            }
        }
        
        /// `init` to initialize a `Filter` with the `Operations` that define the `FilterStrategy`
        public init(operations: [Operation<K, V>]) {
            self.operations = operations
        }
        
        ///   connects different `URLQueryItems` regarding to a sever url function, it uses the property name, the operation and the value to parse it into a function
        /// - Parameter from: the functions that is used to build the URLQueryItem
        /// - Returns: An array of URLQueryItems that represent the filter strategy in an URL
        func applyServerStrategy (from: (String, String, String) -> URLQueryItem) -> [URLQueryItem] {
            var output: [URLQueryItem] = []
            
            for operation in operations {
                var propertyAsString: String = ""
                
                switch operation {
                case let .gte(property, value), let .lte(property, value), let .exists(property, value):
                    do {
                        propertyAsString = try (K.reflectProperty(forKey: property)?.path.last ?? "")
                    } catch {
                        print(error)
                    }
                    let queryItem = from(propertyAsString, operation.description, value.description)
                    output.append(queryItem)
                }
            }
            return output
        }
    }
}

/// This is the default filter server strategy oriented at the LHS Brackets structure from https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/#lhs-brackets .
/// - Parameters:
///   - property: specifies the property that should be filtered
///   - operation: the operation that is uses to evaluate the property
///   - value: the value that is used to check if the property fulfills the criteria
/// - Returns: an `URLQueryItem` that represents a single filter from the default configuration
public func defaultFilterServerStrategy(_ property: String, _ operation: String, _ value: String) -> URLQueryItem {
    return URLQueryItem(name: "\(property)[\(operation)]", value: "\(value)")
}
