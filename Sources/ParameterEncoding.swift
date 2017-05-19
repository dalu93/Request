//
//  ParameterEncoding.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - ParameterEncoding declaration
/// An object capable of encode a set of parameters inside a `URLRequest`.
public protocol ParameterEncoding {
    func encode(_ parameters: [String: Any], in request: URLRequest) throws -> URLRequest
}

// MARK: - URLEncodingError declaration
/// Set of possible errors during the URLEncoding operation
///
/// - invalidURL: The original URL is invalid
public enum URLEncodingError: Error, CustomStringConvertible {
    
    case invalidURL(URLRequest)
    
    public var description: String {
        switch self {
        case .invalidURL(let request):
            return "The request doesn't contain a valid URL\n[Request]: \(request)"
        }
    }
}

// MARK: - URLEncoding declaration
/// A URL enconding responsible object.
public struct URLEncoding: ParameterEncoding {
    
    /// Encodes a set of parameters in query string.
    ///
    /// - Parameters:
    ///   - parameters: Parameters to encode
    ///   - request: The request in which encode them.
    /// - Returns: New request with the encoded parameters.
    /// - Throws: Can throw in case the origina URL was malformed or missing.
    public func encode(_ parameters: [String : Any], in request: URLRequest) throws -> URLRequest {
        var httpRequest = request
        guard let requestUrl = request.url else {
            throw URLEncodingError.invalidURL(request)
        }
        
        var finalUrlString = requestUrl.absoluteString
        
        for (index, key) in parameters.keys.enumerated() {
            if index == 0 {
                finalUrlString += "?"
            } else {
                finalUrlString += "&"
            }
            
            finalUrlString += key + "=" + String(describing: parameters[key]!)
        }
        
        httpRequest.url = try? finalUrlString.toUrl()
        return httpRequest
    }
}

// MARK: - JSONEncodingError declaration
/// Set of possible errors during the JSONEncoding operation
///
/// - invalidParameters: The parameters encoding didn't succeeded. 
/// Probably the dictionary was somehow malformed
public enum JSONEncodingError: Error, CustomStringConvertible {
    
    case invalidParameters([String: Any])
    
    public var description: String {
        switch self {
        case .invalidParameters(let params):
            return "The parameters cannot be encoded in JSON data\n[Params]: \(params)"
        }
    }
}

// MARK: - JSONEncoding declaration
/// /// A JSON enconding responsible object.
public struct JSONEncoding: ParameterEncoding {
    
    /// Encodes the parameters in the body.
    ///
    /// The method can crash in case you use this method to encode parameters in 
    /// a `GET` request.
    ///
    /// - Parameters:
    ///   - parameters: The parameters to encode.
    ///   - request: The request in which encode them.
    /// - Returns: New request with the encoded parameters.
    /// - Throws: Can throw in case an error occured while encoding the parameters.
    public func encode(_ parameters: [String : Any], in request: URLRequest) throws -> URLRequest {
        guard (request.httpMethod ?? "") != "GET" else {
            fatalError("Cannot encode a JSON in the body when a request is `GET`")
        }
        
        var httpRequest = request
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
            httpRequest.httpBody = data
        } catch (_) {
            throw JSONEncodingError.invalidParameters(parameters)
        }
        
        return httpRequest
    }
}
