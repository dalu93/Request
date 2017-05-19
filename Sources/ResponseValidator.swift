//
//  ResponseValidator.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import Foundation

// MARK: - ResponseValidator declaration
/// Describes an object capable of analyze a response and throw an error.
public protocol ResponseValidator {
    func validate(_ response: URLResponse?, data: Data?, error: Error?) throws
}
