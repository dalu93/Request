//
//  Response.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - Response declaration
/// The response info container.
public struct Response<Value> {
    
    /// The original request.
    public let request: URLRequest?
    
    /// The HTTP response.
    public let response: URLResponse?
    
    /// The response data.
    public let data: Data?
    
    /// The response result.
    public let result: Completion<Value, Error>
}
