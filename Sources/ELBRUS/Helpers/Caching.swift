//
//  File.swift
//  
//
//  Created by Tom Mirwald on 17.02.20.
//

import Foundation
import Combine


@propertyWrapper public class Cached<Element: Codable> {
    
    public var localStorageURL: URL {
        guard let documentsDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the cache directory in the user's home directory.")
        }
        
        return documentsDirectory.appendingPathComponent(storagePath).appendingPathExtension("json")
    }
    
    private var storagePath: String
    
    public init(storagePath: String) {
        self.storagePath = storagePath
    }
    
    public var wrappedValue: [Element] {
        get {
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
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
                try jsonFileWrapper.write(to: localStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
            } catch _ {
                print("Could not save \(Element.self)s")
            }
        }
    }
}


