//
//  Authorization.swift
//  
//
//  Created by Tom Mirwald on 17.02.20.
//  Copyright (c) 2019 Paul Schmiedmayer <paul.schmiedmayer@tum.de>

import Foundation

/// - Copyright:
/// Copyright © 2020 by Paul Schmiedmayer
public enum Authorization {
    case none
    case credentials(type: PasswordType)
    case token(type: TokenType)
}

public struct Credentials {
    let userName: String
    let password: String
    
    public init(userName: String, password: String) {
        self.userName = userName
        self.password = password
    }
}

public enum PasswordType: CustomStringConvertible {
    case basic(credentials: Credentials)
    
    var credentials: Credentials {
        switch self {
        case .basic(let credentials): return credentials
        }
    }
    
    public var description: String {
        switch self {
        case .basic(let credentials):
            let base64String = Data("\(credentials.userName):\(credentials.password)".utf8).base64EncodedString()
            return "Basic \(base64String)"
        }
    }
}

public enum TokenType: CustomStringConvertible {
    case bearer(token: String)
    case custom(token: String)
    
    public var description: String {
        switch self {
        case .bearer(let token):
            return "Bearer \(token)"
        case .custom(let token):
            return token
        }
    }
}
