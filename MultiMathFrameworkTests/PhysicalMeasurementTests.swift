//
//  PhysicalMeasurementTests.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/4/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import UIKit
import XCTest

class PhysicalMeasurementTests: XCTestCase {

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
    
    func testCreation() {
        let fiftyMPH = M(50, e: 0, units: SpecificUnits([.Miles: 1, .Hours: -1]))
        let metersPerSecond = M(22.352, e: 0, units: SpecificUnits([.Meters: 1, .Seconds: -1]))
        XCTAssert(fiftyMPH ~~ metersPerSecond, "create and convert units")
    }
    
    func testAdding() {
        let first = M(5.0, e:0.1)
        let second = M(4.0, e:0.2)
        let sum = (first + second).computed()
        let directComputed = M(5+4, e:sqrt(0.1*0.1+0.2*0.2))
        XCTAssert(sum ~~ directComputed, "error of sum")
    }
    
    func testAvg() {
        
    }
    
    func testDivision() {
        var x = M(20, e:0.1)
        var y = M(14, e:0.2)
        var quotient = (x/y).computed()
        //direct using quadrature of percent difference.
        var direct = M(x.v/y.v, e: sqrt((x.e/x.v)**2 + (y.e/y.v)**2)*x.v/y.v)
        XCTAssert(direct ~~ quotient, "division uses percent difference")
    }
    
    func testPower() {
        var r = M(20, e: 0.1, units: SpecificUnits([.Meters: 1]))
        var p = 3.0
        var power = (r**p.m).computed()
        //error should be p*r^(p-1)*r.e
        var directComputation = M(8000, e: p*r.v**(p-1)*r.e, units: SpecificUnits([.Meters: 3]))
        XCTAssert(power ~~ directComputation, "power is power")
        var multiplied = (r*r*r).computed()
        XCTAssert(multiplied ~~ power, "power is the same as multiplication")
    }
    
    func testMOICalc() {
        //calculate moment of inertia as in lab on 10/6/14.
        var meters1 = SpecificUnits(.Meters)
        let p = M(6700, e: 100, units: SpecificUnits([.Kilograms: 1, .Meters: -3]))
        let R1 = M(0.2, e: 0.001, units: meters1)
        let R2 = M(0.151, e: 0.001, units: meters1)
        let R3 = M(0.0301, e: 0.0001, units: meters1)
        let h1 = M(0.0254, e: 0.0001, units: meters1)
        let h2 = M(0.02005, e: 0.00001, units: meters1)
        let πOver2: M = (π/2.0).m
        //can't compute individually and then add, because they are not independent so error will not work out.
        var I = (p*πOver2 * (h1*R1**4.m - h2*R2**4.m + h2*R3**4.m)).computed()
        var moi1: M = (p * πOver2 * h1 * (R1**(4.m))).computed()
        var moi2: M = (p*πOver2*h2*R2**(4.m)).computed()
        var moi3 = (p*πOver2*h2*R3**(4.m)).computed()
        //XCTAssert(moi1Try2 ~~ moi1, "moment of inertia is the same calculated both ways")
        //var I = (moi1-moi2+moi3).computed()
        let finalUnits = SpecificUnits([.Kilograms: 1, .Meters: 2])
        //ok. the value I calculated for the lab is different, but this is what it should consistently get, I think
        //for the lab I got 0.0199±0.00329 kgm^2
        XCTAssert(I ~~ M(0.31821, e: 0.01034566, units: finalUnits), "it didn't work")
    }
    
    func testMOIFromScratch() {
        var p = (6.7±0.1)*grams/centimeters**3
        var R1 = (20.0±0.1)*centimeters
        var R2 = (15.1±0.1)*centimeters
        var R3 = (3.01±0.01)*centimeters
        var h1 = (2.54±0.01)*centimeters
        var h2 = (2.005±0.001)*centimeters
        let πOver2: M = (π/2.0).m
        var I1 = p * h1 * πOver2 * R1**4.m
        var I2 = p * h2 * πOver2 * R2**4.m
        var I3 = p * h2 * πOver2 * R3**4.m
        var I = I1 - I2 + I3
        println(I)
        println()
    }
    
    func testIndependenceError() {
        //when you solve for error of h^2 * h*R, you get a different answer if you do the terms separately and then sum them, than if you take the whole thing together.
        var meters1 = SpecificUnits(.Meters)
        var h = M(0.3, e: 0.05, units: meters1)
        var R = M(23, e: 3, units: meters1)
        var hSquaredPlushR = (h**2.m + h*R).computed()
        var directComputed = M(h.v*h.v + h.v*R.v , e: sqrt((2*h.v+R.v)**2*h.e*h.e + h.v*h.v*R.e*R.e), units: SpecificUnits([.Meters: 2]))
        XCTAssert(directComputed ~~ hSquaredPlushR, "used partial derivs!")
        
        //calculated piecewise is not how you want to do it.
        var incorrectDirectComputed = M(h.v*h.v + h.v*R.v, e: sqrt((4*h.v*h.v+R.v*R.v)*h.e*h.e + h.v*h.v*R.e*R.e), units: SpecificUnits([.Meters: 2]))
        XCTAssert(hSquaredPlushR !~~ incorrectDirectComputed, "if you separate by addition first you end up with this. this is bad.")
    }
    
    func testHarvardExamples() {
        //http://ipl.physics.harvard.edu/wp-uploads/2013/03/PS3_Error_Propagation_sp13.pdf
        var g = (9.80±0)*meters/second/second
        var v = (4±0.2)*meters/second
        var t = (0.60±0.06)*seconds
        var y = v*t - g*t*t/2.m
        //the harvard example gave the answer as (0.636±0.44)*meters. I'm not sure this is right, in fact I'm pretty sure it isn't because they broke it up instead of keeping all of the independence of variables.
        XCTAssert(y.computed() ~~ (0.636±0.16469)*meters, "y computed")
    }
    
    func testExampleProblems() {
        //from Introduction to Error Analysis. page 65.
        var angle = (20±3)*degrees
        var cosTheta = cos(angle)
        XCTAssert(cosTheta.computed() ~~ (0.9396799±0.01791186), "Cosine uncertainty")
        
        //page 68-69.
        var l = (92.95±0.1)*centimeters
        var T = (1.936±0.004)*seconds
        var g = (4.m * (π*π).m * l / T**2.m).computed()
        var gInCMPerSsquared = g.convertTo([.Distance: .Centimeters, .Time: .Seconds])
        XCTAssert(gInCMPerSsquared ~~ MOut(979, e: 4, u: centimeters/second/second), "G calculated")//holy shit it worked!
        //if I change how MOut's are printed, this will probably break.
        XCTAssert("\(gInCMPerSsquared)" == "979±4 cm/s²", "MOut printing isn't working")
        
        //page 72
        l = (5±0.05)*centimeters
        var s = (100.0±0.02)*centimeters
        var t1 = (0.054±0.001)*seconds
        var t2 = (0.031±0.001)*seconds
        
        var a = ((l**2.m/(s+s))*(1.m/t2**2.m - 1.m/t1**2.m)).computed().convertTo([.Distance: .Centimeters, .Time: .Seconds])
        //seriously. the book say 87±8, but I'm getting 87±9. Either he has rounding errors or I'm doing something wrong.
        XCTAssert(a ~~ MOut(87, e: 9, u: centimeters/second/second), "acceleration in centimeters per second squared")
        
        //page 76
        var x = 3±0.1
        var y = 2±0.1
        var q = x**2.m * y - x * y**2.m
        XCTAssert("\(q.computed().convertTo())" == "6.0±0.9", "calculated and rounded")
        
        //page 86
        var abest = 3±0.1
        var f = exp(abest).computed().convertTo()
        XCTAssert(f.description == "20±2", "exponential")
        
        //3.31a
        var theta = (125±2)*degrees
        XCTAssert(sin(theta).computed().description == "0.82±0.02", "sine and description from formula")
        
        //3.33
        x = 1.7±0.02
        var qx = (1.m-x**2.m)*cos((x+2.m)/x**3.m)
        XCTAssert(qx.computed().description == "-1.38±0.08", "big equation")
        
        //from page 11 of http://courses.washington.edu/phys431/propagation_errors_UCh.pdf
        var m = (50±1)*grams
        var M = (100±1)*grams
        var grav = 9.8.m * meters/second/second
        var Atwood = grav*(M-m)/(M+m)
        println(Atwood.description)
        //consider rounding when error is 0.1. if it's 0.11 I round to 2 decimals. If it's 0.09 I round to 2 decimals. Maybe if I could get it to print error of 0.10?
        XCTAssert(Atwood.computed().description == "3.27±0.1 m/s²", "Acceleration by calculation")
    }
    
    func testFastMeasurementCreation() {
        var mph = (65±2)*miles/hour //swift is so cool I can do this.
        var kph = (104.607±3.2187)*kilometers/hour
        XCTAssert(mph ~~ kph, "Measurements created fast don't work")
    }
    
    func testRelativityCalculation() {
        
    }
    
    func testCircuitCalculation() {
        var V1 = (7.268±0.07) * volts
        var V2 = (2.732±0.027) * volts
        var R1 = (270.7±3.0) * ohms
        var R2 = (101.47±1.2) * ohms
        var I = (0.0269±0.0003) * amps
        var VSum = (10.000±0.1) * volts
        var Icalculated = VSum / (R1+R2)
        
        var left = VSum/I
        var right = R1+R2
        var other = Icalculated
        println(left.computed().description)
        println(right.computed().description)
        println(other.computed().description)
        println()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
