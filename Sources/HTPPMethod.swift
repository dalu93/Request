//
//  HTPPMethod.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - HTTPMethod declaration
/// The HTTP method (verb) based on RFC2616.
///
/// Use the rawValue property to get the RFC2616 value for the specific method.
public enum HTTPMethod: String {
    
    case options    = "OPTIONS"
    case get        = "GET"
    case head       = "HEAD"
    case post       = "POST"
    case put        = "PUT"
    case delete     = "DELETE"
    case trace      = "TRACE"
    case connect    = "CONNECT"
}
