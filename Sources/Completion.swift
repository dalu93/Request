//
//  Completion.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - Completion declaration
/// An enum that describes an operation completion
public enum Completion<Value, ErrorType> {
    case success(Value)
    case failed(ErrorType)
    
    /// The value.
    public var value: Value? {
        switch self {
        case .success(let value):   return value
        case .failed:               return nil
        }
    }
    
    /// The error.
    public var error: ErrorType? {
        switch self {
        case .success:              return nil
        case .failed(let error):    return error
        }
    }
}
