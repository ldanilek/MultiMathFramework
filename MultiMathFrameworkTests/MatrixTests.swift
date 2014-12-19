//
//  MatrixTests.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/22/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation
import XCTest

class MatrixTests: XCTestCase {

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
    
    func testRowReduction() {
        var matrix = Matrix(rows: 3, columns: 3)
        matrix.grid = [3, 7, -2, 8, 9, 4, 2, 3, 5]
        var steps = matrix.toWeakEchelon()
        println(matrix)
        println(steps)
        
        matrix = Matrix(rows: 3, columns: 3)
        matrix.grid = [3, 7, -2, 8, 9, 4, 2, 3, 5]
        steps = matrix.toStrongEchelon()
        XCTAssert(matrix.isIdentity(), "should reduce to identity")
    }
    
    func testBasic() {
        XCTAssert(-0.25 !~~ 0, "not similar to")
    }
    
    func testInverse() {
        //examples
        //http://www.mathwords.com/i/inverse_of_a_matrix.htm
        var A = Matrix(rows: 2, values: [4, 3, 3, 2])
        XCTAssert(A.inverse! == Matrix(rows: 2, values: [-2, 3, 3, -4]), "2x2 matrix inverse")
        
        A = Matrix(rows: 3, values: [1, 2, 3, 0, 4, 5, 1, 0, 6])
        var AInverse = A.inverse!
        var values: [Double] = [12.0/11, -6.0/11, -1.0/11, 5.0/22, 3.0/22, -5.0/22, -2.0/11, 1.0/11, 2.0/11]
        var compare = Matrix(rows: 3, values: values)
        XCTAssert(AInverse ~~ compare, "3x3 matrix inverse")
        
        //http://www.purplemath.com/modules/mtrxinvr2.htm
        A = Matrix(rows: 3, values: [1, 2, 3, 0, 1, 4, 5, 6, 0])
        AInverse = A.inverse!
        values = [-24, 18, 5, 20, -15, -4, -5, 4, 1]
        compare = Matrix(rows: 3, values: values)
        XCTAssert(AInverse ~~ compare, "another 3x3 matrix inverse")
        
        values = [108, 8, 26, 95, 69, 3, 79, 0, 13, 95, 76, 1, 238, 40, 79, 114, 60, 11]
        var M = Matrix(rows: 3, values: values)
        var c = AInverse * M
        values = [20, 8, 5, 0, 12, 1, 23, 0, 9, 19, 0, 1, 14, 0, 1, 19, 19, 0]
        compare = Matrix(rows: 3, values: values)
        XCTAssert(compare ~~ c, "Decode message (multiplication")
        
        A = Matrix(rows: 3, values: [1, 3, 3, 1, 4, 3, 1, 3, 4])
        AInverse = A.inverse!
        values = [7, -3, -3, -1, 1, 0, -1, 0, 1]
        compare = Matrix(rows: 3, values: values)
        XCTAssert(AInverse ~~ compare, "another inverse example")
        
        //with swap, from http://www.mathsisfun.com/algebra/matrix-inverse-row-operations-gauss-jordan.html
        A = Matrix(rows: 3, values: [3, 0, 2, 2, 0, -2, 0, 1, 1])
        AInverse = A.inverse!
        values = [0.2, 0.2, 0, -0.2, 0.3, 1, 0.2, -0.3, 0]
        compare = Matrix(rows: 3, values: values)
        XCTAssert(AInverse ~~ compare, "another 3x3 matrix inverse")
        
        //from http://www.mathsisfun.com/algebra/matrix-calculator.html
        A = Matrix(rows: 6, values: [5, 3, -0.4, -8, 10, -3, 9, 8, 12, -3, -2, 2, -4, 3, -9, -4, 0.8, 5, 9, 9, 0, 12, 2, 8, 0.4, -12, 23, 0.3, -4, 9, 8, 12, -4, -8, 5, 0])
        AInverse = A.inverse!
        var vals1: [Double] = [-0.241866, -0.34356, -0.282586, -0.0015618, 0.1541057, 0.5154312, 0.153211, 0.283926, 0.18689, 0.016307487]
        var vals2: [Double] = [-0.130349, -0.333556, 0.134129, 0.198293, 0.104559, 0.0043827, -0.06133999, -0.256495, 0.0541457, 0.062579, 0.0203772]
        var vals3: [Double] = [0.046865, -0.048836, -0.144335, 0.213221594, 0.127036, 0.119848, 0.04185126, -0.0609418, -0.260287, -0.034785388]
        values = vals1 + vals2 + vals3 + [-0.0585384, 0.0471283, 0.027650787, 0.06176365, 0.07696547]
        compare = Matrix(rows: 6, values: values)
        XCTAssert(AInverse ~~ compare, "another 3x3 matrix inverse")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            var A = Matrix(rows: 3, values: [1, 3, 3, 1, 4, 3, 1, 3, 4])
            var AInverse = A.inverse!
            // Put the code you want to measure the time of here.
            
            A = Matrix(rows: 6, values: [5, 3, -0.4, -8, 10, -3, 9, 8, 12, -3, -2, 2, -4, 3, -9, -4, 0.8, 5, 9, 9, 0, 12, 2, 8, 0.4, -12, 23, 0.3, -4, 9, 8, 12, -4, -8, 5, 0])
            AInverse = A.inverse!
        }
    }
    
    func testPerformanceHW7() {
        self.measureBlock {
            var A1 = Matrix(rows: 3, values:[2, -3, -5, -1, 4, 3, 0, 5, 1])
            var steps = A1.toStrongEchelon()
            println()
            
            var A2 = Matrix(rows: 3, values: [2, -3, -5, -1, 4, 3, 0, 5, 2])
            var A2Steps = A2.toStrongEchelon()
            A2 = Matrix(rows: 3, values: [2, -3, -5, -1, 4, 3, 0, 5, 2])
            var A2Inverse = A2.inverse!
            for step in A2Steps {
                println(step)
            }
            println()
        }
    }
    
    func testPerformanceHW8() {
        self.measureBlock {
            var A = Matrix(rows: 3, values:[1, 1, 3, 6, 2, 2, -1, 0, 4, 1, 4, 1, 6, 16, 5])
            var steps = A.toStrongEchelon()
            for step in steps {
                println(step)
            }
            println()
        }
    }
    
}
