//
//  Sorter.swift
//  
//
//  Created by Tom Mirwald on 02.01.20.
//

// MARK: Imports
import Foundation
import CodableKit

/// Represents possible sorting strategies on the server, client or none strategy
public enum SortStrategy<K, V> where K: RESTElement, V: Sortable {
    case server(Sorter<K, V>, ((String, String) -> URLQueryItem)? = nil)
    case client(Sorter<K, V>)
    case none
    
    /// Represents the sort functionality
    public class Sorter<K: RESTElement, V: Sortable> {
        var direction: Direction
        var property: WritableKeyPath<K, V>
        var applied = false
        
        enum Direction {
            case asc
            case desc
        }
        
        init(direction: Direction = .asc, property: WritableKeyPath<K, V>) {
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

/// Represents a default sorting strategy from https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/#sorting
/// - Parameters:
///   - operation: the operation in which direction the sorting should go
///   - property: the property on which the sorting should happen
/// - Returns: An URLQueryItem that represents a single sorting strategy from the custom configuration
public func defaultSortServerStrategy (_ operation: String, _ property: String) -> URLQueryItem {
    if operation == "asc" {
        return URLQueryItem(name: "sort_by", value: "+\(property)")
    } else {
        return URLQueryItem(name: "sort_by", value: "-\(property)")
    }
}
