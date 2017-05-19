//
//  StatusCodeValidator.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - StatusCodeValidatorError declaration
public enum StatusCodeValidatorError: Error, CustomStringConvertible {
    
    case invalidHTTPResponse
    case invalidStatusCode(Int)
    
    public var description: String {
        switch  self {
        case .invalidHTTPResponse:
            return "The response is not of type `HTTPURLResponse` as expected"
            
        case .invalidStatusCode(let code):
            return "Invalid status code received (\(code))."
        }
    }
}

// MARK: - StatusCodeValidator declaration
/// A `ResponseValidator` conforming struct that checks if the response status code
/// is a valid status code.
///
/// Override the value of the `validStatusCodeRange` property to assign a new range
/// of valid status codes.
public struct StatusCodeValidator: ResponseValidator {
    
    /// Range of valid status codes.
    public let validStatusCodeRange: Range<Int>
    
    /// Initialize the validator with a custom status code range.
    ///
    /// You can always set a new range by modifying the `validStatusCodeRange`
    /// variable.
    ///
    /// - Parameter statusCodeRange: The valid status code range.
    init(_ statusCodeRange: Range<Int> = 200..<300) {
        self.validStatusCodeRange = statusCodeRange
    }
    
    /// Validates the response status code
    ///
    /// - Throws: Throws a `StatusCodeValidatorError` in case the response is not valid
    /// or the response status code is invalid.
    public func validate(_ response: URLResponse?, data: Data?, error: Error?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StatusCodeValidatorError.invalidHTTPResponse
        }
        
        if !validStatusCodeRange.contains(httpResponse.statusCode) {
            throw StatusCodeValidatorError.invalidStatusCode(httpResponse.statusCode)
        }
    }
}
