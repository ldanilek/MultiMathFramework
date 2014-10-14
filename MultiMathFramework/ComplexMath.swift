//
//  ComplexMath.swift
//  MultiMath
//
//  Created by Lee Danilek on 9/16/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation

//don't worry about generic math functions or anything. Just use complex numbers for everything.
//In math, the set of complex numbers is represented with a big C
//hopefully this won't conflict. It makes everything really succinct and readable.
struct C {
    //a+bi
    var a: Double = 0
    var b: Double = 0
}

extension C : Similarity {
    //for additional initializers
    init(r: Double, theta: Double) {
        a = r*cos(theta)
        b = r*sin(theta)
    }
    init(_ x: Double) {
        a = x
    }
}

extension Double : Similarity {
    
}

//incorporate doubles in calculations
func / (c: C, r: Double) -> C {
    return C(a: c.a/r, b: c.b/r)
}
func / (r: Double, c: C) -> C {
    return C(a: (c.a*r)/(c.a*c.a+c.b*c.b), b: -(r*c.b)/(c.a*c.a+c.b*c.b))
}
func / (c: C, i: Int) -> C {
    return C(a: (c.a/Double(i)), b: (c.b/Double(i)))
}
func * (c: C, r: Double) -> C {
    return C(a: c.a*r, b: c.b*r)
}
func * (r: Double, c: C) -> C {
    return C(a: c.a*r, b: c.b*r)
}
func + (r: Double, c: C) -> C {
    return C(a: c.a+r, b: c.b)
}
func + (c: C, r: Double) -> C {
    return C(a: c.a+r, b: c.b)
}
func - (r: Double, c: C) -> C {
    return C(a: r-c.a, b: -c.b)
}
func - (c: C, r: Double) -> C {
    return C(a: c.a-r, b: c.b)
}

//constants
let i: C = C(a: 0, b: 1)
let zero: C = C(a: 0, b: 0)
let one: C = C(1)
let π: Double = 3.141926535897932384626433832795
let pi: Double = π
let Cpi = C(π)
let Cπ = C(π)
let e = C(M_E)

infix operator ** { associativity left precedence 160}

func + (c: C, d: C) -> C {
    return C(a: c.a+d.a, b: c.b+d.b)
}
func - (c: C, d: C) -> C {
    return C(a: c.a-d.a, b: c.b-d.b)
}
prefix func - (c: C) -> C {
    return C(a: -c.a, b: -c.b)
}
func * (c: C, d: C) -> C {
    return C(a: c.a*d.a-c.b*d.b, b: c.a*d.b+c.b*d.a)
}
func / (c: C, d: C) -> C {
    return C(a: (c.a*d.a+c.b*d.b)/(d.a*d.a+d.b*d.b), b: (d.a*c.b-c.a*d.b)/(d.a*d.a+d.b*d.b))
}
func cis(t: Double) -> C {
    return C(a: cos(t), b: sin(t))
}
func arg(c: C) -> Double {
    return atan2(c.b, c.a)
}
func abs(c: C) -> Double {
    return sqrt(c.a*c.a + c.b*c.b)
}
func log(c: C) -> C {
    return C(a: log(abs(c)), b: arg(c))
}
func log10(c: C) -> C {
    return log(c)/log(10)
}
func log(b: C, x: C) -> C {
    return log(x)/log(b)
}
func ln(c: C) -> C {
    return log(c)
}
//the natural log of a negative number is complex, so ln(Double)-> C
func ln(r: Double) -> C {
    return log(C(r))
}
func exp(c: C) -> C {
    return C(r: exp(c.a), theta: c.b)
}
func ** (c: C, d: C) -> C {
    if c == zero {
        return zero
    }
    return exp(d * log(c))
}
func ** (c: C, r: Double) -> C {
    //(a+bi)^r = e^(r*ln(a+bi))
    return exp(r * log(c))
}
func ** (r: Double, c: C) -> C {
    //r^(a+bi) = e^((a+bi)*ln(r)) = e^(a*ln(r))*e^(b*i*ln(r)). so much complex analysis already it's probably faster to just do it.
    return exp(c*ln(r))
}
func ** (r: Double, exp: Double) -> Double {
    return pow(r, exp)
}
func sqrt(c: C) -> C {
    return c**0.5
}

//trig
func sin(c: C) -> C {
    var exponential = exp(c*i)
    return i/2 * (1/exponential - exponential)
}
func cos(c: C) -> C {
    var exponential = exp(c*i)
    return (exponential + 1/exponential) / 2
}
func tan(c: C) -> C {
    return sin(c)/cos(c)
}
func asin(c: C) -> C {
    return -i * log(c*i + sqrt(1-c*c))
}
func acos(x: C) -> C {
    let xSquared = x*x
    return π/2 + i*log(x*i + sqrt(1-xSquared))
}
func atan(x: C) -> C {
    let xi = x*i
    return i/2 * (log(1-xi) - log(xi+1))
}
func sinh(x: C) -> C {
    return (exp(x) - exp(-x))/2
}
func cosh(x: C) -> C {
    return (exp(x) + exp(-x))/2
}
func tanh(x: C) -> C {
    return sinh(x)/cosh(x)
}
func asinh(x: C) -> C {
    return log(x+sqrt(x*x+1))
}
func acosh(x: C) -> C {
    return log(x+sqrt(x-1)*sqrt(x+1))
}
func atanh(x: C) -> C {
    return (log(1+x)-log(1-x))/2
}

func += (inout c: C, d: C) {
    c = c + d
}
func -= (inout c: C, d: C){
    c = c-d
}
func *= (inout c: C, d: C) {
    c = c * d
}
func /= (inout c: C, d: C) {
    c = c / d
}

func == (c: C, d: C) -> Bool {
    return c.a==d.a && c.b==d.b
}
func == (c: C, r: Double) -> Bool {
    return c.a==r && c.b==0
}
func == (r: Double, c: C) -> Bool {
    return c.a==r && c.b==0
}
func != (c: C, d: C) -> Bool {
    return !(c==d)
}
func != (c: C, r: Double) -> Bool {
    return !(c==r)
}
func != (r: Double, c: C) -> Bool {
    return !(c==r)
}
//almost equal to. to check for similarity in tests, for example.
infix operator ~~ {associativity none precedence 130}
//not almost equal to
infix operator !~~ {associativity none precedence 130}
//option- > gives a ≥ character, and these are more readable than >=
infix operator ≥ {associativity none precedence 130}
infix operator ≤ {associativity none precedence 130}

func ~~ (r: Double, s: Double) -> Bool {
    if abs(r)<0.0001 {
        return s<0.000001
    }
    if abs(s)<0.000001 {
        return s<0.000001
    }
    return abs(s-r) / abs(r) < 0.01
}
func ~~ (c: C, d: C) -> Bool {
    return c.a~~d.a && c.b~~d.b
}
func ~~ (c: C, r: Double) -> Bool {
    return c.a~~r && c.b~~0
}
func ~~ (r: Double, c: C) -> Bool {
    return c.a~~r && c.b~~0
}
protocol Similarity {
    func ~~ (x: Self, y: Self) -> Bool
}
func !~~<T: Similarity> (x: T, y: T) -> Bool {
    var similar = x ~~ y
    return !similar
}
func ≤ <T:Comparable> (x: T, y: T) -> Bool {
    return x==y || x<y
}
func ≥ <T:Comparable> (x: T, y: T) -> Bool {
    return x==y || x>y
}

//option-V
prefix operator √ {}
prefix func √ (x: Double) -> Double {
    return sqrt(x)
}
prefix func √ (c: C) -> C {
    return sqrt(c)
}

