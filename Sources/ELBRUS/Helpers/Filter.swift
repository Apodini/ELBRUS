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
/// Represents the filter strategy with the different options client, server and none filter
public enum FilterStrategy <K: RESTElement, V: Filterable> {
    case server(Filter<K, V>, ((String, String, String) -> URLQueryItem)? = nil)
    case client(Filter<K, V>)
    case none
    
    
    // MARK: Filter
    /// Represents a filter that takes a generic RESTElement and Filterable element to perform the operations: greater equal, less equal and exists, with the possibility to have more than one filter operation
    /// The serverStrategyApplied variable indicates wether the server strategy is already added to the URLComponent
    public class Filter<K: RESTElement, V: Filterable> {
        let operations: [Operation<K, V>]
        public var applied = false
        
        enum Operation<K, V> {
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
        
        init(operations: [Operation<K, V>]) {
            self.operations = operations
        }
        
        /// This function connects different URLQueryItems regarding to a sever url function, it uses the property name, the operation and the value to parse it into a function
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

/// This is the default filter server strategy oriented a the LHS Brackets from https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/#lhs-brackets
/// - Parameters:
///   - property: the property for the filtering
///   - operation: the operation that is uses to evaluate the property
///   - value: the value that is used to check if the property fulfills the needs
/// - Returns: An URLQueryItem that represents a single filter from the default configuration
public func defaultFilterServerStrategy(_ property: String, _ operation: String, _ value: String) -> URLQueryItem {
    return URLQueryItem(name: "\(property)[\(operation)]", value: "\(value)")
}