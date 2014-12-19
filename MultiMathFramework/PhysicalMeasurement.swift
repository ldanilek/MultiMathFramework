//
//  PhysicalMeasurement.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/4/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation

//import CollectionsFramework
//linking with the collections framework is not working, so I'll reference the files from that project directly.
//Important: don't change any files linked from CollectionsFramework! Change them from that project, if needed, but not from MultiMathFramework.

enum UnitType {
    case Distance, Time, Mass, Angle, Current
    
    var defaultUnit: Unit {
        switch self {
        case .Distance:
            return .Meters
        case .Time:
            return .Seconds
        case .Mass:
            return .Kilograms
        case .Angle:
            return .Radians
        case .Current:
            return .Amperes
        }
    }
}

enum Unit : Printable {
    case Meters, Kilometers, Miles, Decimeters, Centimeters, Millimeters
    case Seconds, Hours
    case Kilograms, Grams
    case Degrees, Radians
    case Amperes
    //tried to include temperature units, but the offset was too confusing.
    
    //convert to the default unit.
    //multiply conversion by the value to get answer in default units.
    var conversion: Double {
        var factor: Double = 0 // factor * default unit = given unit, so multiplying by factor converts given unit into default unit
        switch self {
        case .Meters, .Seconds, .Kilograms, .Radians, .Amperes:
            factor = 1.0
        case .Decimeters:
            factor = 0.1
        case .Kilometers:
            factor = 1000.0
        case .Miles:
            factor = 1609.344
        case .Hours:
            factor = 3600.0
        case .Grams:
            factor = 0.001
        case .Degrees:
            factor = π/180
        case .Centimeters:
            factor = 0.01
        case .Millimeters:
            factor = 0.01
        }
        return factor
    }
    
    var type: UnitType {
        switch self {
        case .Miles, .Kilometers, .Meters, .Centimeters, .Millimeters, .Decimeters:
            return .Distance
        case .Seconds, .Hours:
            return .Time
        case .Kilograms, .Grams:
            return .Mass
        case .Degrees, .Radians:
            return .Angle
        case .Amperes:
            return .Current
        }
    }
    
    var description: String {
        switch self {
        case .Meters:
            return "m"
        case .Seconds:
            return "s"
        case .Kilograms:
            return "kg"
        case Radians:
            return "rad"
        case .Kilometers:
            return "km"
        case .Miles:
            return "mi"
        case .Hours:
            return "hr"
        case .Grams:
            return "g"
        case .Degrees:
            return "°"
        case .Centimeters:
            return "cm"
        case .Millimeters:
            return "mm"
        case .Amperes:
            return "A"
        case .Decimeters:
            return "dm"
            }
    }
}

//units is actually a bag of UnitTypes.
//important: immutable
//better using UnitTypes instead of straight units because won't end up with something like mi/km as units, instead everything possible will cancel out.
struct Units : Equatable {
    let units: Bag<UnitType>
    init() {
        units = Bag()
    }
    init(_ units: Bag<UnitType>) {
        self.units = units
    }
    init(_ units: [UnitType: Int]) {
        self.units = Bag(units)
    }
    init(_ unit: UnitType) {
        self.units = Bag([unit: 1])
    }
    var printable: String {
        return "\(units.data)"
    }
}
let unitless = Units()
func * (u: Units, v: Units) -> Units {
    return Units(u.units*v.units)
}
func *= (inout u: Units, v: Units) {
    u = Units(u.units*v.units)
}
func / (u: Units, v: Units) -> Units {
    return Units(u.units/v.units)
}
func /= (inout u: Units, v: Units) {
    u = Units(u.units/v.units)
}
func *= (inout u: Units, o: UnitType) {
    u = Units(u.units * o)
}
func /= (inout u: Units, o: UnitType) {
    u = Units(u.units / o)
}
func * (u: Units, o: UnitType) -> Units {
    return Units(u.units*o)
}
func ** (u: Units, p: Double) -> Units {
    //to raise units to a power p, multiply the multiplicity of each unit by p
    return Units(u.units**p)
}
func / (u: Units, o: UnitType) -> Units {
    return Units(u.units/o)
}
func pow(u: UnitType, m: Int) -> Units {
    return Units(Bag().added(object: u, multiplicity: m))
}

func pow(u: Unit, m: Int) -> SpecificUnits {
    return SpecificUnits(Bag().added(object: u, multiplicity: m))
}
func *= (inout u: SpecificUnits, v: SpecificUnits) {
    u = SpecificUnits(u.units*v.units)
}
func * (u: SpecificUnits, o: Unit) -> SpecificUnits {
    return SpecificUnits(u.units * o)
}
func * (o: Unit, u: SpecificUnits) -> SpecificUnits {
    return SpecificUnits(u.units * o)
}
func * (o: SpecificUnits, u: SpecificUnits) -> SpecificUnits {
    return SpecificUnits(o.units * u.units)
}
func / (u: SpecificUnits, o: Unit) -> SpecificUnits {
    return SpecificUnits(u.units / o)
}
func / (o: Unit, u:SpecificUnits) -> SpecificUnits {
    return SpecificUnits(Bag([o: 1]) / u.units)
}
func / (o: SpecificUnits, u: SpecificUnits) -> SpecificUnits {
    return SpecificUnits(o.units / u.units)
}
func * (u: Unit, o: Unit) -> SpecificUnits {
    return SpecificUnits(Bag([u: 1, o: 1]))
}
func / (u: Unit, o: Unit) -> SpecificUnits {
    return SpecificUnits(Bag([u: 1, o: -1]))
}
func ** (u: Unit, p: Int) -> SpecificUnits {
    return SpecificUnits(Bag([u: p]))
}

func == (u: Units, v: Units) -> Bool {
    return u.units == v.units
}

struct SpecificUnits : Equatable, Printable {
    let units: Bag<Unit>
    init() {
        units = Bag()
    }
    init(_ units: Bag<Unit>) {
        self.units = units
    }
    init(_ units: [Unit: Int]) {
        self.units = Bag(units)
    }
    init(_ unit: Unit) {
        self.units = Bag([unit: 1])
    }
    
    var description: String {
        return "\(units)"
    }
}
//to make the syntax look nicer
//Wikipedia: In the SI system, there are seven fundamental units: kilogram, meter, candela, second, ampere, kelvin, and mole.
//fundamental units (just shortcuts)
let meters = Unit.Meters
let miles = Unit.Miles
let hours = Unit.Hours
let hour = Unit.Hours
let second = Unit.Seconds
let seconds = Unit.Seconds
let kilometers = Unit.Kilometers
let degrees = Unit.Degrees
let centimeters = Unit.Centimeters
let grams = Unit.Grams
let kilograms = Unit.Kilograms
let amps = Unit.Amperes

//derived units
let newtons = kilograms*meters/second**2
let joules = newtons * meters
let watts = joules/second
let volts = watts / amps
let ohms = watts / amps**2
let hertz = second**(-1)
let liter = Unit.Decimeters**3

//speed of light is c velocity. Don't want to use c, because that will cause all sorts of conflicts
let cv = 299792458 * meters/second //this value has no error, because meters are defined to make this exactly true
//planck's constant is important. use reduced here instead? the wikipedia page mentions uncertainty but I don't understand the notation
let hP = 6.62606957e-34 * joules*seconds

func lorentz(v: FE) -> Formula {
    var insqrt = 1.m - v**2.m/cv**2.m
    var thesqrt = sqrt(insqrt)
    return 1.m / thesqrt
}

func == (u: SpecificUnits, v: SpecificUnits) -> Bool {
    return u.units==v.units
}

//mathematical functions given FE (formula elements) return formulae
//necessary to create a formula for a calculation before evaluating to make sure all error propogation is accurate.
protocol FE : Printable {
    func computed(vars: [Variable: M]) -> M
    func computedIgnoringError(vars: [Variable: M]) -> M
    func computedIgnoringErrorAndUnits(vars: [Variable: M]) -> M
    func values(vars: [Variable: M]) -> [M]
}

//physical measurement. represents value, error, and units
//units are represented by generic UnitTypes, so for instance all measurements are automatically converted to the default unit for each type.
struct M : FE, Printable, Similarity {
    let v: Double
    let e: Double
    let u: Units
    
    init(_ v: Double, e: Double = 0, units:SpecificUnits = SpecificUnits()) {
        var accumulatedConversion: Double = 1
        var accumulatedUnits: Units = unitless
        for (unit, power) in units.units.data {
            accumulatedConversion *= pow(unit.conversion, Double(power))
            if unit.type != UnitType.Angle { //angle is actually unitless, when converted to radians.
                accumulatedUnits *= pow(unit.type, power)
            }
        }
        self.v = v*accumulatedConversion
        self.e = e*accumulatedConversion
        self.u = accumulatedUnits
    }
    
    //no need to convert, units are all OK.
    //must be different to tell inits apart when last parameters are left out
    //it actually doesn't matter whether you use the v or not, if units are not given it is unitless no matter which init you use.
    init(v: Double = 0, e: Double = 0, units: Units = unitless) {
        self.v = v
        self.e = e
        self.u = units
    }
    
    func computed(vars: [Variable : M]) -> M {
        return self
    }
    func computedIgnoringError(vars: [Variable : M]) -> M {
        return self
    }
    func computedIgnoringErrorAndUnits(vars: [Variable : M]) -> M {
        return self
    }
    func values(vars: [Variable : M]) -> [M] {
        return [self]
    }
    func withUnits(u: Units) -> M {
        return M(v: self.v, e:self.e, units: u)
    }
    
    func convertTo(_ conversion: [UnitType: Unit] = [:]) -> MOut {
        var accumulatedConversion: Double = 1
        var accumulatedUnits = SpecificUnits()
        for (unitType, power) in self.u.units.data {
            if let unit = conversion[unitType] {
                assert(unit.type == unitType, "Unit for substitution has to be of the same type as base unit")
                accumulatedConversion *= pow(unit.conversion, Double(power))
                accumulatedUnits *= pow(unit, power)
            } else {
                accumulatedUnits *= pow(unitType.defaultUnit, power)
            }
        }
        return MOut(self.v/accumulatedConversion, e: self.e/accumulatedConversion, u: accumulatedUnits)
    }
    var description: String {
        return self.convertTo().description
    }
}

//output from M for printing. converted from base units into real units.
//also rounded to the correct amount (so the uncertainty has 1 or 2 sig figs and value is rounded to the same decimal place)
//rounding happens on init.
struct MOut : Similarity, Equatable, Printable {
    let v: Double
    let e: Double
    let u: SpecificUnits
    let integers: Bool
    
    init(var _ v: Double, var e: Double, u: SpecificUnits) {
        self.u = u
        if e>0 {
            var orderOfMagnitude: Int = 0
            while e ≥ 20.0 {
                e /= 10.0
                v /= 10.0
                orderOfMagnitude++
            }
            while e ≤ 2.0 {
                e *= 10.0
                v *= 10.0
                orderOfMagnitude--
            }
            e = round(e)
            v = round(v)
            e *= pow(10, Double(orderOfMagnitude))
            v *= pow(10, Double(orderOfMagnitude))
            
            integers = orderOfMagnitude >= 0
        } else {
            integers = false
        }
        
        self.v = v
        self.e = e
        
        
    }
    
    var description: String {
        var units = "\(u)"
            if !units.isEmpty {
                units = " "+units
            }
        if integers {
            return "\(Int(v))±\(Int(e))"+units
            }
        return "\(v)±\(e)"+units
    }
}

func ~~ (m: M, n: M) -> Bool {
    return m.v~~n.v && m.e~~n.e && m.u==n.u
}
func == (m: M, n: M) -> Bool {
    return m.v==n.v && m.e==n.e && m.u==n.u
}
func ~~ (m: MOut, n: MOut) -> Bool {
    return m.v~~n.v && m.e~~n.e && m.u==n.u
}
func == (m: MOut, n: MOut) -> Bool {
    return m.v==n.v && m.e==n.e && m.u==n.u
}

//I want calculations to work well with doubles, but I don't want to override basic operations with just doubles. therefore double can't be part of protocol FE.
extension Double {
    var m: M {
        return M(self)
    }
}
extension Int {
    var m: M {
        return M(Double(self))
    }
}

//variables are basically strings with extra functionality so they can be used as Formula Expressions
struct Variable : FE, Printable, Hashable {
    let str: String
    
    var hashValue: Int {
        return str.hashValue
    }
    
    func computed(vars: [Variable : M]) -> M {
        if let val = vars[self] {
            return val
        }
        return M(0)
    }
    
    func computedIgnoringError(vars: [Variable : M]) -> M {
        return computed(vars)
    }
    
    func computedIgnoringErrorAndUnits(vars: [Variable : M]) -> M {
        return computed(vars)
    }
    
    func values(vars: [Variable : M]) -> [M] {
        return [computed(vars)]
    }
    
    var description: String {
        return str
    }
}

func == (v1: Variable, v2: Variable) -> Bool {
    return v1.str==v2.str
}

enum Operation {
    case Identity
    case Multiply, Divide, Add, Subtract, Power
    case Negate, Reciprocal, Ln, Exp, Sqrt
    case Cos, Sin, Tan
}

//prints in default units if none provided.
struct Formula : FE, Printable {
    let op: Operation
    let v1: FE
    let v2: FE?
    
    init(_ op: Operation, _ v1: FE, _ v2: FE? = nil) {
        self.op=op
        self.v1=v1
        self.v2=v2
    }
    
    func values(vars: [Variable : M]) -> [M] {
        if let n = v2 {
            return combineVariables(v1, n, vars)
        } else {
            return v1.values(vars)
        }
    }
    
    //If error is not needed, like when calculating the partial derivative, use this function instead
    func computedIgnoringErrorAndUnits(_ vars: [Variable: M]=[:]) -> M {
        var val = M()
        var m = v1.computedIgnoringErrorAndUnits(vars)
        var n: M! = v2?.computedIgnoringErrorAndUnits(vars)
        //since the error of val will be ignored, since it's wrong, don't bother calculating it here.
        switch op {
        case .Identity:
            val = m
        case .Multiply:
            val = M(v:m.v*n.v)
        case .Divide:
            val = M(v:m.v/n.v)
        case .Add:
            val = M(v: m.v+n.v)
        case .Subtract:
            val = M(v: m.v-n.v)
        case .Negate:
            val = M(v: -m.v)
        case .Power:
            val = M(v: m.v**n.v)
        case .Ln:
            val = M(v: log(m.v))
        case .Reciprocal:
            val = M(v: 1/m.v)
        case .Cos:
            val = M(v: cos(m.v))
        case .Sin:
            val = M(v: sin(m.v))
        case .Tan:
            val = M(v: tan(m.v))
        case .Exp:
            val = M(v: exp(m.v))
        case .Sqrt:
            val = M(v: sqrt(m.v))
        }
        return val
    }
    
    //If error is not needed, like when calculating the partial derivative, use this function instead
    func computedIgnoringError(_ vars: [Variable: M]=[:]) -> M {
        var val = computedIgnoringErrorAndUnits(vars)
        var m = v1.computedIgnoringError(vars)
        var n: M! = v2?.computedIgnoringError(vars)
        //since the error of val will be ignored, since it's wrong, don't bother calculating it here.
        switch op {
        case .Identity:
            return m
        case .Multiply:
            //propogate error: sqrt((partial h / partial m * m.e)^2 + (partial h / partial n * n.e)^2), partial h/partial m = n and partial h/partial n = m
            return val.withUnits(m.u*n.u)
        case .Divide:
            //partial h/partial m = 1/n; partial h / partial n = m/n^2
            return val.withUnits(m.u/n.u)
        case .Add:
            assert(m.u == n.u, "Cannot add values with different units")
            //the hard part will be calculating the error.
            //h = m + n
            //by propogation of error, sqrt((partial h / partial m * m uncertainty)^2 + (partial h / partial n * n uncertainty)^2) = sqrt(m uncertainty ^2 + n uncertainty^2)
            return val.withUnits(m.u)
        case .Subtract:
            assert(m.u == n.u, "Cannot subtract values with different units")
            return val.withUnits(m.u)
        case .Negate:
            return val.withUnits(m.u)
        case .Power:
            //partial h / partial m = n * m^(n-1)
            //partial h / partial n = ln(m) * m^n
            assert(n.u == unitless, "Cannot raise to a power with units (I think)")
            return val.withUnits(m.u**n.v)
        case .Ln:
            assert(m.u == unitless, "Cannot take the natural log of units")
            return val
        case .Reciprocal:
            return val.withUnits(unitless / m.u)
        case .Cos:
            assert(m.u == unitless, "Cannot do cosine of units")
            return val
        case .Sin:
            assert(m.u == unitless, "Cannot do sine of units")
            return val
        case .Tan:
            assert(m.u == unitless, "Cannot do tangent of units")
            return val
        case .Exp:
            assert(m.u==unitless, "exp(units) doesn't make sense!")
            return val
        case .Sqrt:
            return val.withUnits(m.u ** 0.5)
        }
    }
    
    
    func computed(_ vars: [Variable: M]=[:]) -> M {
        //go through, getting the right value and units. then go back and recalculate error
        var val = computedIgnoringError(vars)
        //now calculate error with sqrt of sum of squares of (partial * error)
        var sumSquares: Double = 0.0
        for m in self.values(vars) {
            var partialAtVal = partial(wrt:m, vars: vars).computedIgnoringErrorAndUnits(vars) //error of this will be ignored. units too, which is good because for some reason the units get messed up.
            sumSquares += partialAtVal.v*partialAtVal.v * m.e*m.e
        }
        return M(v: val.v, e: sqrt(sumSquares), units: val.u)
    }
    
    //error of partial doesn't matter, only the values of each variable are used
    //partial with respect to m, which is a value in allVars
    func partial(#wrt: M, vars: [Variable: M]) -> Formula {
        var partialm = subPartial(v1, wrt, vars)
        var partialn: Formula! = nil
        var m = v1
        var n: FE! = v2
        if let anN = v2 {
            partialn = subPartial(anN, wrt, vars)
        }
        switch op {
        case .Identity:
            return partialm
        case .Add:
            return partialm + partialn
        case .Subtract:
            return partialm - partialn
        case .Multiply:
            return (partialm * n) + (partialn * m)
        case .Divide:
            return ((n * partialm) - (m * partialn)) / (n * n)
        case .Power:
            //from http://mathforum.org/library/drmath/view/53679.html
            //d/dx( f(x)^g(x) ) = f(x)^g(x) * d/dx( g(x) ) * ln( f(x) ) + f(x)^( g(x)-1 ) * g(x) * d/dx( f(x) )
            //simplify using my variables
            //d/dx( f(x)^g(x) ) = n^m * partialn * ln( m ) + m^( n-1 ) * n * partialm
            return n**m * partialn * log(m) + m**(n-1.0.m) * n * partialm
        case .Ln:
            return partialm / m
        case .Reciprocal:
            //like division where m is 1, partialm is 0, n is m, and partialn is partialm
            return -partialm / (m*m)
        case .Negate:
            return -partialm
        case .Sin:
            return partialm * cos(m)
        case .Cos:
            return partialm * -sin(m)
        case .Tan:
            return partialm / cos(m) / cos(m)
        case .Exp:
            return partialm * exp(m)
        case .Sqrt:
            return partialm / (2.m * sqrt(m))
        }
    }
    /*
    //0 is never needs parethesis around, like unary operations and identity
    //1 is
    var needOfParetheses: Int {
        
    }
    */
    var description: String {
        var m = v1.description
        var n: String! = v2?.description
        switch op {
        case .Identity:
            return m
        case .Add:
            return "(\(m))+(\(n))"
        case .Subtract:
            return "(\(m))-(\(n))"
        case .Divide:
            return "(\(m))/(\(n))"
        case .Multiply:
            return "(\(m))*(\(n))"
        case .Power:
            return "(\(m))^(\(n))"
        case .Reciprocal:
            return "1/(\(m))"
        case .Ln:
            return "ln(\(m))"
        case .Negate:
            return "-(\(m))"
        case .Sin:
            return "sin(\(m))"
        case .Cos:
            return "cos(\(m))"
        case .Tan:
            return "tan(\(m))"
        case .Sqrt:
            return "sqrt(\(m))"
        case .Exp:
            return "exp(\(m))"
            }
    }
    func convertTo(units: [UnitType: Unit] = [:], vars: [Variable: M] = [:]) -> MOut {
        return self.computed(vars).convertTo(units)
    }
}

func subPartial(fe: FE, m: M, vars: [Variable: M]) -> Formula {
    if let f = (fe as? Formula) {
        return f.partial(wrt:m, vars: vars)
    }
    if let v = (fe as? Variable) {
        if let val = vars[v] {
            return val == m ? Formula(.Identity, M(1)) : Formula(.Identity, M(0))
        }
        return Formula(.Identity, M(0))
    }
    //fe must be an M.
    var f = fe as M
    if f == m {
        return Formula(.Identity, M(1))
    }
    return Formula(.Identity, M(0))
}

func contains(varlist: [M], variable: M) -> Bool {
    for mvar in varlist {
        if mvar == variable {
            return true
        }
    }
    return false
}

func combineVariables(m: FE, n: FE, inputVars: [Variable : M]) -> [M] {
    var vars: [M] = m.values(inputVars)
    for nvar in n.values(inputVars) {
        if !contains(vars, nvar) {
            vars.append(nvar)
        }
    }
    return vars
}

func + (m: FE, n: FE) -> Formula {
    return Formula(.Add, m, n)
}
func - (m: FE, n: FE) -> Formula {
    return Formula(.Subtract, m, n)
}
prefix func - (m: FE) -> Formula {
    return Formula(.Negate, m, nil)
}
func * (m: FE, n: FE) -> Formula {
    return Formula(.Multiply, m, n)
}
func / (m: FE, n: FE) -> Formula {
    return Formula(.Divide, m, n)
}
func ** (m: FE, n: FE) -> Formula {
    return Formula(.Power, m, n)
}
func log(m: FE) -> Formula {
    return Formula(.Ln, m)
}
func cos(m: FE) -> Formula {
    return Formula(.Cos, m)
}
func sin(m: FE) -> Formula {
    return Formula(.Sin, m)
}
func tan(m: FE) -> Formula {
    return Formula(.Tan, m)
}
func exp(m: FE) -> Formula {
    return Formula(.Exp, m)
}
func sqrt(m: FE) -> Formula {
    return Formula(.Sqrt, m)
}

//create an M on the fly
infix operator ± {associativity left precedence 140}

func ± (x: Double, y: Double) -> M {
    return M(v: x, e: y)
}
func ± (x: Int, y: Double) -> M {
    return M(v: Double(x), e: y)
}
func ± (x: Int, y: Int) -> M {
    return M(v: Double(x), e: Double(y))
}

//imagine I have a number 4±2, and then I tell the computer that's actually in feet.
//I have to make the units [length] and convert the numbers into meters.
func * (m: M, u: Unit) -> M {
    return M(v: m.v*u.conversion, e: m.e*u.conversion, units: u.type==UnitType.Angle ? m.u : m.u * u.type)
}
func / (m: M, u: Unit) -> M {
    return M(v: m.v/u.conversion, e: m.e/u.conversion, units: u.type==UnitType.Angle ? m.u : m.u / u.type)
}
func * (d: Int, u: Unit) -> M {
    return M(v: Double(d))*u
}
func * (d: Double, u: Unit) -> M {
    return M(v: d)*u
}
func * (d: Double, u: SpecificUnits) -> M {
    return M(v: d)*u
}
func * (d: Int, u: SpecificUnits) -> M {
    return M(v: Double(d))*u
}
func * (var m: M, u: SpecificUnits) -> M {
    for (unit, power) in u.units.data {
        m = M(v: m.v*pow(unit.conversion, Double(power)), e: m.e*pow(unit.conversion, Double(power)), units: unit.type==UnitType.Angle ? m.u : m.u * pow(unit.type, power))
    }
    return m
}
func / (var m: M, u: SpecificUnits) -> M {
    for (unit, power) in u.units.data {
        m = M(v: m.v/pow(unit.conversion, Double(power)), e: m.e/pow(unit.conversion, Double(power)), units: unit.type==UnitType.Angle ? m.u : m.u / pow(unit.type, power))
    }
    return m
}

typealias MList = [M]

//calculates RMSE
func mean(ms: MList) -> M {
    //list must not be empty
    var totalSum: Double = 0
    var squaredErrorSum: Double = 0
    var count: Double = 0
    for m in ms {
        totalSum += m.v
        squaredErrorSum += m.e*m.e
        count++
    }
    return M(v: totalSum/count, e: sqrt(squaredErrorSum/count), units: ms.last?.u ?? unitless)
}

//I want to be able to make a new list by combining lists. for example, if I have a list of voltages and currents, I want to be able to make a list of resistances by doing V/I
//operation must take the same size list as the count of columns
func listCompute(operation: [M]->FE, columns: MList...) -> MList {
    var output: [M] = []
    for index in 0..<columns.last!.count {
        var inputs: [M] = []
        for column in columns {
            inputs.append(column[index])
        }
        output.append(operation(inputs).computed([:]))
    }
    return output
}
func applyUnits(ms: MList, u: SpecificUnits) -> MList {
    var output: MList = []
    for input in ms {
        output.append(input*u)
    }
    return output
}
func applyUnits(ms: MList, u: Unit) -> MList {
    var output: MList = []
    for input in ms {
        output.append(input*u)
    }
    return output
}
