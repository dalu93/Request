//
//  Request.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - RequestError declaration
/// Describes an error that can occur while building the request
public enum RequestError: Error, CustomStringConvertible {
    
    case noInternetConnection
    case operationCancelled
    case invalidParameters([String: Any])
    case operationRefused(String)
    case invalidJSONData
    
    public var description: String {
        switch self {
        case .invalidParameters(let params):
            return "An invalid parameters list has been passed.\n\(params)"
        
        case .operationRefused(let description):
            return description
            
        case .invalidJSONData:
            return "Data returned by the server are not decodable in a valid JSON object"
            
        case .operationCancelled:
            return "The operation was cancelled"
            
        case .noInternetConnection:
            return "The operation failed because there isn't internet connection"
        }
    }
}

// MARK: - Request declaration
/// An object that includes the info about a URL request.
open class Request {
    
    public typealias ResponseJSONCallback = Closure< Response<Any> >
    
    /// The request URL.
    open let url: URLConvertible
    
    /// The request HTTP method.
    open let method: HTTPMethod
    
    /// The encoding for the parameters.
    open let encoding: ParameterEncoding
    
    /// The request parameters.
    open let parameters: [String: Any]?
    
    /// The request headers.
    ///
    /// The `Content-Type` is set to `application/json` by default.
    /// To override it, simply add your custom `Content-Type` in this dictionary
    open let headers: [String: String]?
    
    /// The request timeout.
    ///
    /// Once the request reaches the timeout value, it fails.
    /// Default value is 60 seconds.
    open var timeoutInterval: TimeInterval = 60
    
    /// The cache policy.
    open var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    fileprivate var _request: URLRequest?
    fileprivate var _responseJSONCallback: ResponseJSONCallback?
    fileprivate var _validators: [ResponseValidator] = []
    fileprivate var _connector: Connector?
    
    /// Initializes a new `Request`.
    public init(url: URLConvertible,
         method: HTTPMethod,
         parameters: [String: Any]? = nil,
         headers: [String: String]? = nil,
         parameterEncoding: ParameterEncoding) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.encoding = parameterEncoding
    }
    
    /// Try to build the request to see if everything is ok.
    ///
    /// By default this method is called when calling the `run()` method, but
    /// you can simply run it to check wheter there is some error while building
    /// the request.
    ///
    /// - Throws: Can throw an error if the parameter encoding somehow fails.
    /// If you're not encoding eny parameter, you can force unwrapped the `try` operation.
    open func build() throws {
        let requestUrl = try url.toUrl()
        _request = try URLRequest(url: requestUrl,
                                  method: method,
                                  parameters: parameters,
                                  headers: headers,
                                  encoding: encoding,
                                  cachePolicy: cachePolicy, 
                                  timeoutInterval: timeoutInterval)
    }
    
    /// Validate the HTTP response using a specific validator.
    ///
    /// - Parameter validator: A validator
    @discardableResult
    open func validate(using validator: ResponseValidator) -> Request {
        _validators.append(validator)
        return self
    }
    
    /// Validate the HTTP response using a set of validators.
    ///
    /// - Parameter validators: The validators
    @discardableResult
    open func validate(using validators: [ResponseValidator]) -> Request {
        _validators.append(contentsOf: validators)
        return self
    }
    
    /// Assign a callback for handling the request completion.
    ///
    /// - Parameter closure: The closure
    @discardableResult
    open func responseJSON(_ closure: @escaping ResponseJSONCallback) -> Request {
        _responseJSONCallback = closure
        return self
    }
    
    /// Executes the request
    ///
    /// This method can crash in case the `build()` method throws somehow.
    @discardableResult
    open func run() throws -> Request {
        try build()
        
        // If the build operation worked, _request cannot be nil.
        _connector = Connector(request: _request!,
                                  validators: _validators,
                                  callBack: _responseJSONCallback,
                                  configuration: .default)
        _connector!.connect()
        return self
    }
    
    /// Cancels the request.
    @discardableResult
    func cancel() throws -> Request {
        guard let connector = _connector else {
            throw RequestError.operationRefused("Cannot cancel the request.\n[Request]: \(self)")
        }
        
        connector.cancel()
        
        return self
    }
}

// MARK: - URLRequest helpers
private extension URLRequest {
    
    init(url: URL,
         method: HTTPMethod,
         parameters: [String: Any]?,
         headers: [String: String]?,
         encoding: ParameterEncoding,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = 60) throws {
        
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        
        httpMethod = method.rawValue
        addingHeaders(from: headers)
        
        if let params = parameters {
            self = try encoding.encode(params, in: self)
        }
    }
    
    mutating func addingHeaders(from dictionary: [String: String]?) {
        dictionary?.forEach { key, value in
            addValue(value, forHTTPHeaderField: key)
        }
        
        if value(forHTTPHeaderField: "Content-Type") == nil {
            addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
