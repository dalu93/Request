//
//  URLConvertible.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - URLConversionError declaration
/// Error while converting a type in a URL by using the `URLConvertible` `toUrl()` function.
///
/// - notConvertible: The value is not convertible in a `URL`.
public enum URLConversionError: Error, CustomStringConvertible {
    
    case notConvertible(String)
    
    public var description: String {
        switch self {
        case .notConvertible(let objectDesc):   return "\(objectDesc) cannot be converted in a `URL`."
        }
    }
}

// MARK: - URLConvertible declaration
/// Describes a type that can be converted to a `URL` type.
public protocol URLConvertible {
    
    /// Convert the object in a `URL`.
    ///
    /// - Returns: The converted `URL`.
    /// - Throws: Throws an `URLConversionError` if something wrong happens during the conversion.
    func toUrl() throws -> URL
}

// MARK: - URLConvertible - String
extension String: URLConvertible {
    
    public func toUrl() throws -> URL {
        guard let url = URL(string: self) else {
            throw URLConversionError.notConvertible(self)
        }
        
        return url
    }
}

// MARK: - URLConvertible - URL
extension URL: URLConvertible {
    
    public func toUrl() throws -> URL {
        return self
    }
}
