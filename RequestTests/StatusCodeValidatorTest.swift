//
//  StatusCodeValidatorTest.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import XCTest
@testable import Request

class StatusCodeValidatorTest: XCTestCase {
    
    let someUrl: URL = URL(string: "http://www.google.com")!
    let correctStatusCodeRange: Range<Int> = 200..<300
    let incorrectStatusCodeRange: Range<Int> = 100..<200
    
    func testCorrectStatusCode() {
        let validator = StatusCodeValidator(correctStatusCodeRange)
        
        let response = HTTPURLResponse(url: someUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            try validator.validate(response, data: nil, error: nil)
        } catch (let exception) {
            if let validatorError = exception as? StatusCodeValidatorError {
                XCTFail(validatorError.localizedDescription)
            }
        }
    }
    
    func testInvalidStatusCode() {
        let validator = StatusCodeValidator(incorrectStatusCodeRange)
        
        let response = HTTPURLResponse(url: someUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            try validator.validate(response, data: nil, error: nil)
            XCTFail("The status code is wrong. Expected a status code between \(incorrectStatusCodeRange). The operation should fail.")
        } catch (_) { }
    }
}
