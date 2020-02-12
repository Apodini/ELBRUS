//
//  CollectionExtensions.swift
//  
//
//  Created by Tom Mirwald on 19.12.19.
//

// MARK: Imports
import CodableKit

/// - Author: Joshua Brunhuber [GitHubLink](https://github.com/jbrunhuber/joshtastic-simples/blob/master/KeyPaths/KeyPaths.playground/Contents.swift)

// MARK: Extension: Collection: Sorting with a KeyPath
extension Collection {
    func sorted<Value: Comparable>(on property: KeyPath<Element, Value>, by areInIncreasingOrder: (Value, Value) -> Bool) -> [Element] {
        return sorted { currentElement, nextElement in
            areInIncreasingOrder(currentElement[keyPath: property], nextElement[keyPath: property])
        }
    }
}
