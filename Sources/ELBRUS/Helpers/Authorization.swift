//
//  Authorization.swift
//  
//
//  Created by Tom Mirwald on 17.02.20.
//  Copyright (c) 2019 Paul Schmiedmayer <paul.schmiedmayer@tum.de>

import Foundation

/// - Copyright:
/// Copyright © 2020 by Paul Schmiedmayer

/// The `Authorization` class represents  3 different authorization methods, none for no authentication, credentials for a basic authentication and a bearer token or a custom token.
public enum Authorization {
    case none
    case credentials(type: PasswordType)
    case token(type: TokenType)
}

/// The `Credentials` offer the possibility to declare a user name and password for a basic authentication.
public struct Credentials {
    let userName: String
    let password: String
    
    public init(userName: String, password: String) {
        self.userName = userName
        self.password = password
    }
}

/// `PasswordType` implements the Base64 encoding of the credentials.
public enum PasswordType: CustomStringConvertible {
    case basic(credentials: Credentials)
    
    var credentials: Credentials {
        switch self {
        case .basic(let credentials): return credentials
        }
    }
    
    /// The description variable is used for the Base64 encoding of the credentials.
    public var description: String {
        switch self {
        case .basic(let credentials):
            let base64String = Data("\(credentials.userName):\(credentials.password)".utf8).base64EncodedString()
            return "Basic \(base64String)"
        }
    }
}

/// `TokenType` is used for token authentication over a bearer token or a custom defined token.
public enum TokenType: CustomStringConvertible {
    case bearer(token: String)
    case custom(token: String)
    
    /// The description variable returns a `String` representation of the two token types.
    public var description: String {
        switch self {
        case .bearer(let token):
            return "Bearer \(token)"
        case .custom(let token):
            return token
        }
    }
}
