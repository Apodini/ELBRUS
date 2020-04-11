//
//  UnsafeURL.swift
//  ELBRUSTests
//
//  Created by Paul Schmiedmayer on 4/11/20.
//

import Foundation
import XCTest

extension URL {
    init(unsafe string: String, file: StaticString = #file, line: UInt = #line) {
        guard let url = URL(string: string) else {
            fatalError("""
                The URL \(string) used for testing seems to be wrong.
                Please check the testcase in \(file), line \(line).
                """)
        }
        self = url
    }
}
