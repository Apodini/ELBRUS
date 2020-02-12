//
//  File.swift
//  
//
//  Created by Paul Schmiedmayer on 1/10/20.
//

import Foundation
@testable import ELBRUS

extension REST where F == Never, S == Never, N == MockNetworkHandler<Element> {
    convenience init(mock endpoint: Service<N>) {
        self.init(endpoint)
    }
}
