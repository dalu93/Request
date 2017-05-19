//
//  Connector.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - Typealias declaration
public typealias Closure<Value> = (Value) -> ()
public typealias ResponseJSONCallback = Closure< Response<Any> >

public enum ConnectorError: Error, CustomStringConvertible {
    
    case invalidJSONData
    case emptyResponse
    
    public var description: String {
        switch self {
        case .invalidJSONData:
            return "The data retrieved is not convertible to a JSON object"
            
        case .emptyResponse:
            return "The request did not fail, but no data was retrieved"
        }
    }
}

// MARK: - Connector declaration
/// Responsible of the HTTP request.
///
/// It sends the requests, executes the validators and returns a `Response` to pass
/// in the call back.
public class Connector {
    
    // MARK: - Public properties
    /// The request.
    public let request: URLRequest
    
    /// Set of validators to apply.
    public let validators: [ResponseValidator]
    
    /// The call back.
    public let callBack: ResponseJSONCallback?
    
    /// The URLSession configuration.
    public let configuration: URLSessionConfiguration
    
    // MARK: - Private properties
    fileprivate var _session: URLSessionDataTask?
    
    // MARK: - Object lifecycle
    /// Initializes a new connector.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to send.
    ///   - validators: List of validators to run.
    ///   - callBack: The callback to call when the operation is completed.
    ///   - configuration: The `URLSessionConfiguration`.
    init(request: URLRequest, validators: [ResponseValidator], callBack: ResponseJSONCallback?, configuration: URLSessionConfiguration) {
        self.request = request
        self.validators = validators
        self.callBack = callBack
        self.configuration = configuration
    }
    
    // MARK: - Public methods
    /// Sends the request.
    ///
    /// It calls the call back whenever the operation finishes.
    public func connect() {
        let session = URLSession(configuration: configuration)
        _session = session.dataTask(with: request) { data, urlResponse, error in
            if
                let nsError = error as NSError?,
                nsError.code == -1009 || nsError.code == -999 {
                
                var requestError: RequestError!
                if nsError.code == -1009 { requestError = .noInternetConnection }
                else if nsError.code == -999  { requestError = .operationCancelled }
                
                let response = self._makeResponseWith(urlResponse, data: data, result: .failed(requestError))
                self.callBack?(response)
                return
            }
        
            do {
                try self.validators.forEach {
                    try $0.validate(urlResponse, data: data, error: error)
                }
            } catch (let exception) {
                let response = self._makeResponseWith(urlResponse, data: data, result: .failed(exception))
                self.callBack?(response)
                return
            }
            
            let result = self._makeResultWith(data, and: error)
            let response = self._makeResponseWith(urlResponse, data: data, result: result)
            self.callBack?(response)
        }
        
        _session?.resume()
    }
    
    /// Cancels the connection.
    func cancel() {
        _session?.cancel()
        _session = nil
    }
}

// MARK: - Logic helpers
private extension Connector {
    
    func _makeResponseWith(_ urlResponse: URLResponse?, data: Data?, result: Completion<Any, Error>) -> Response<Any> {
        return Response<Any>(request: self.request, response: urlResponse, data: data, result: result)
    }
    
    func _makeResultWith(_ data: Data?, and error: Error?) -> Completion<Any, Error> {
        if let error = error {
            return .failed(error)
        } else if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return .success(json)
            } catch (_) {
                return .failed(ConnectorError.invalidJSONData)
            }
        } else {
            return .failed(ConnectorError.emptyResponse)
        }
    }
}
