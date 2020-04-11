//
//  LocalFileStorable.swift
//
//  Created by Paul Schmiedmayer on 10/11/19. Edited by Tom Mirwald on 21/01/20.
//  Copyright © 2019 TUM LS1. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - LocalFileStorable
/// an object that can be represented and stored as a local file
public protocol LocalFileStorable {
    /// specifies the data structure that will be stored
    associatedtype Element: RESTElement
    
    /// defines the data that will be stored
    var wrappedValue: [Element] { get set }
    
    /// defines a `String` that characterizes the unique attributes of the `wrappedValue`
    var storagePath: String { get }
}

// MARK: Extension: LocalFileStorable: URL
extension LocalFileStorable {
    /// `URL` of the parent folder to store the variable in
    public var localStorageURL: URL {
        guard let documentsDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the cache directory in the user's home directory.")
        }
        
        return documentsDirectory.appendingPathComponent(storagePath).appendingPathExtension("json")
    }
}

// MARK: Extension: LocalFileStorable: Load & Save
extension LocalFileStorable {
    ///  Load an array of `LocalFileStorables` from a file
    /// - Returns: an array of decoded objects
    public func loadFromFile() -> [Element] {
        do {
            let fileWrapper = try FileWrapper(url: localStorageURL, options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            
            return try JSONDecoder().decode([Element].self, from: data)
        } catch _ {
            print("Could not load \(Element.self)s, the Model uses an empty collection")
            return []
        }
    }
    
    
    /// Save a collection of `LocalFileStorables` to a file
    /// - Parameter collection: `Collection` of objects that should be saved
    public func saveToFile(_ collection: [Element]) {
        do {
            let data = try JSONEncoder().encode(collection)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: localStorageURL,
                                      options: FileWrapper.WritingOptions.atomic,
                                      originalContentsURL: nil)
        } catch _ {
            print("Could not save \(Element.self)s")
        }
    }
}
