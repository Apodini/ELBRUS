//
//  Authorization.swift
//  
//
//  Created by Tom Mirwald on 17.02.20.
//  Copyright (c) 2019 Paul Schmiedmayer <paul.schmiedmayer@tum.de>

import Foundation

/// - Copyright:
///
/// Copyright © 2020 by Paul Schmiedmayer
///
/// The `Authorization` class represents three different authorization methods, none for no authentication, credentials for a basic authentication, and over the bearer token, or a custom token.
public enum Authorization {
    /// describes none authentication
    case none
    /// describes an authentication over a basic authentication
    case credentials(type: PasswordType)
    /// describes a token-based authentication
    case token(type: TokenType)
}

/// The `Credentials` offer the possibility to declare a user name and password for a basic authentication.
public struct Credentials {
    let userName: String
    let password: String
    
    /// The `init` for the initialization of a `Credential` consisting of a user name and a password. 
    public init(userName: String, password: String) {
        self.userName = userName
        self.password = password
    }
}

/// `PasswordType` implements the Base64 encoding of the credentials.
public enum PasswordType: CustomStringConvertible {
    /// describes basic authentication over given credentials.
    case basic(credentials: Credentials)
    
    /// `credentials` variable gives you access to the credentials in the basic `PasswordType` case.
    var credentials: Credentials {
        switch self {
        case .basic(let credentials): return credentials
        }
    }
    
    /// `description` variable is used for a string representation of the Base64 encoding of the credentials.
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
    /// describes the bearer token authentication.
    case bearer(token: String)
    /// describes a custom definable token authentication.
    case custom(token: String)
    
    /// `description` variable returns a `String` representation of the two token types
    public var description: String {
        switch self {
        case .bearer(let token):
            return "Bearer \(token)"
        case .custom(let token):
            return token
        }
    }
}
