//
//  StringMathTests.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/12/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import UIKit
import XCTest

class StringMathTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testAddition() {
        XCTAssert("3+5".formula().computed().v ~~ 8.0, "Adding straight numbers")
        XCTAssert("3+5+2".formula().computed().v ~~ 10.0, "Adding straight numbers")
    }
    
    func testParens() {
        XCTAssert("(1/2)^((4+3)*4/3)".formula().computed().v ~~ 0.00155, "Lots of parentheses") //holy crap it worked
    }
    func testUnary() {
        XCTAssert("exp(cos(4+(5/3))-2)".computed().v ~~ 0.30602, "unary as well as parens")
    }
    func testNegatives() {
        XCTAssert("7/-3".computed().v ~~ -2.333333, "negative")
    }
    func testPhantom() {
        XCTAssert("5cos(3/2)".computed().v ~~ 0.3537, "phantom!")
    }
    func testVariable() {
        XCTAssert("5*x".computed(["x": Formula(.Identity, M(3))]).v ~~ 15.0, "variable substitution")
        XCTAssert("3x+4cos(y)".computed(["x": Formula(.Identity, M(7.2)), "y": Formula(.Identity, M(2))]).v ~~ 19.9354, "multiple variables, phantom")
    }
    func testComplex() {
        XCTAssert("4i+3".complexComputed() ~~ 4*i+3, "complex")
        XCTAssert("i^i".complexComputed() ~~ 1.0/sqrt(e**pi), "i to the i")
    }
    func testComplexVariables() {
        XCTAssert("xi".complexComputed(["x":C(a:5, b:2)]) ~~ -2+5*i, "variable times i")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
