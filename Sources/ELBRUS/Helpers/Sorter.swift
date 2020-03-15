//
//  Sorter.swift
//  
//
//  Created by Tom Mirwald on 02.01.20.
//

// MARK: Imports
import Foundation
import CodableKit

/// represents possible sorting strategies on the server, client or none strategy
/// How to define a `FilterStrategy`:
///
///    `SortStrategy` example:
///    basic structure:
///
///         .strategy(SortStrategy.Sorter(direction: .direction, property: KeyPath))
///
///    server example:
///
///        let serverStrategy = .server(SortStrategy.Sorter(direction: .asc, property: \Account.name))
///
///   defines a sort strategy where a fictional account class is sorted ascending by the name

public enum SortStrategy<K, V> where K: RESTElement, V: Sortable {
    /// specifies that the sorting process is realized through a server route; the user has the option to specify an own translation function in the case
    /// - Important:
    /// The configuration of an own server strategy `URL` creation method takes precedence over the `SortStrategy` that is specified over the `Service`.
    case server(Sorter<K, V>, ((String, String) -> URLQueryItem)? = nil)
    /// describes a `SortStrategy` client-side
    case client(Sorter<K, V>)
    /// describes none `SortStrategy` is needed.
    case none
    
    /// describes a `Sorter` with a `Direction` (ascending, descending), the `property` as a `KeyPath` to the later sorted variable of a class
    public class Sorter<K: RESTElement, V: Sortable> {
        var direction: Direction
        var property: WritableKeyPath<K, V>
        var applied = false
        
        /// specifies the direction of sorting, ascending (`.asc`) or descending (`.desc`)
        public enum Direction {
            case asc
            case desc
        }
        
        /// The `init` initializes the `Sorter` with the `Direction` of sorting and the `Property` that is used to sort the data.
        public init(direction: Direction = .asc, property: WritableKeyPath<K, V>) {
            self.direction = direction
            self.property = property
        }
        
        /// Takes the direction and the property that is used to sort and passes this in a function
        /// - Parameter from: a function that returns a URLQueryItem to hold different server url strategies
        /// - Returns: An URLQueryitem that represents the server strategy for the URL
        func applyServerStrategy (from: (String, String) -> URLQueryItem) -> URLQueryItem {
            var output: URLQueryItem
            
            var propertyAsString = ""
            do {
                propertyAsString = try (K.reflectProperty(forKey: property)?.path.last ?? "")
            } catch {
                print(error)
            }
            
            switch direction {
            case .asc:
                output = from("asc", "\(propertyAsString)")
            case .desc:
                output = from("desc", "\(propertyAsString)")
            }
            
            return output
        }
    }
}

/// represents a default sorting strategy from https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/#sorting .
/// - Parameters:
///   - operation: specifies the sort direction
///   - property: specifies the sorted property
/// - Returns: an `URLQueryItem` that represents a single sorting strategy from the custom configuration
public func defaultSortServerStrategy (_ operation: String, _ property: String) -> URLQueryItem {
    if operation == "asc" {
        return URLQueryItem(name: "sort_by", value: "+\(property)")
    } else {
        return URLQueryItem(name: "sort_by", value: "-\(property)")
    }
}

/// - Author: Joshua Brunhuber [GitHubLink](https://github.com/jbrunhuber/joshtastic-simples/blob/master/KeyPaths/KeyPaths.playground/Contents.swift)

// MARK: Extension: Collection: Sorting with a KeyPath
extension Collection {
    func sorted<Value: Comparable>(on property: KeyPath<Element, Value>, by areInIncreasingOrder: (Value, Value) -> Bool) -> [Element] {
        return sorted { currentElement, nextElement in
            areInIncreasingOrder(currentElement[keyPath: property], nextElement[keyPath: property])
        }
    }
}
