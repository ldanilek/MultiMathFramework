//
//  StringMath.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/12/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation

//multiplication should go before paretheses and unary operations, which get changed into substitutions, if they are not preceded by an operator.
let formulaSubPrefix = "@#&"
//after a substitution is checked for preceding multiplication, change it to this substitution
let finalSubPrefix = "@&"
let negativeSub = "—"

let unaryFuncs: [String: (FE)->Formula] = ["sqrt": sqrt, "exp": exp, "ln": log, "sin": sin, "cos": cos, "tan": tan]
func id(m: FE) -> Formula {
    return Formula(.Identity, m)
}
let complexUnaryFuncs: [String: Operation] = ["sqrt": .Sqrt, "exp": .Exp, "ln": .Ln, "sin": .Sin, "cos": .Cos, "tan": .Tan]

//an operation is an indication that what follows is an expression. therefore, what follows shouldn't start with * and if it starts with - that means negative
let operators = ["*", "+", "^", "-", "/", "^", "("]

extension String {
    
    func computed(_ vars: [String: Formula]=[:]) -> M {
        var changedString = self
        var index = 0
        var subs: [String: Formula] = [:]
        for (variable, form) in vars {
            changedString = changedString.stringByReplacingOccurrencesOfString(variable, withString:formulaSubPrefix+String(index))
            subs[formulaSubPrefix + String(index)] = form
            index++
        }
        
        return changedString.formula(subs).computed()
    }
    
    func formula(var _ subs: [String: Formula] = [:]) -> Formula {
        //go through and replace all instances of parentheses with substitutions. substitutions have a prefix followed by an increasing integer.
        //this is a recursive function. first check if self has been simplified to a substitution
        if let form = subs[self] {
            return form
        }
        if let form = subs[self.stringByReplacingOccurrencesOfString(finalSubPrefix, withString: formulaSubPrefix)] {
            return form
        }
        //find outermost paren indices
        var nestedParens: Int = 0
        //start and ending index of part between parentheses
        var startingIndex: Int = 0
        var endingIndex: Int = 0
        for (index, character) in enumerate(self) {
            if character=="(" {
                if nestedParens == 0 {
                    startingIndex = index+1
                }
                nestedParens++
            }
            if character == ")" {
                if nestedParens == 1 {
                    endingIndex = index
                    break
                }
                nestedParens--
            }
        }
        if startingIndex>0 && endingIndex>0 {
            //find the in-between characters, replace them with a substitution, and recurse.
            var inBetween = self[startingIndex..<endingIndex]
            var beforeParen = self[0..<startingIndex-1]
            var unaryStr: String?
            var unaryFunc: FE->Formula = id
            for (possibleUnary, function) in unaryFuncs {
                if beforeParen.hasSuffix(possibleUnary) && countElements(possibleUnary)>countElements(unaryStr) {
                    unaryStr = possibleUnary
                    unaryFunc = function
                }
            }
            var subString = formulaSubPrefix+String(subs.count)
            subs[subString] = unaryFunc(inBetween.formula(subs))
            return self.stringByReplacingCharactersInRange(Range(start: advance(startIndex, startingIndex-1-countElements(unaryStr)), end: advance(startIndex, endingIndex+1)), withString: subString).formula(subs)
        }
        
        if let range = self.rangeOfString("-") {
            if range.startIndex==startIndex {
                return self.stringByReplacingCharactersInRange(range, withString: negativeSub).formula(subs)
            }
        }
        for op in operators {
            if let range = self.rangeOfString(op+"-") {
                return self.stringByReplacingCharactersInRange(range, withString: op+negativeSub).formula(subs)
            }
        }
        
        if let range = self.rangeOfString(formulaSubPrefix) {
            if range.startIndex==startIndex {
                return self.stringByReplacingCharactersInRange(range, withString: finalSubPrefix).formula(subs);
            }
            var beforeRange = self.substringToIndex(range.startIndex)
            var endsInOperator = false
            for op in operators {
                if beforeRange.hasSuffix(op) {
                    endsInOperator = true
                }
            }
            if endsInOperator {
                return self.stringByReplacingCharactersInRange(range, withString: finalSubPrefix).formula(subs)
            } else {
                return self.stringByReplacingCharactersInRange(range, withString: "*"+finalSubPrefix).formula(subs)
            }
        }
        
        
        if let range = self.rangeOfString("+") {
            return Formula(.Add, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).formula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).formula(subs))
        }
        if let range = self.rangeOfString("-") {
            return Formula(.Subtract, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).formula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).formula(subs))
        }
        //uh oh. subtraction will be tricky, because it can also be negation
        if let range = self.rangeOfString("*") {
            return Formula(.Multiply, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).formula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).formula(subs))
        }
        if let range = self.rangeOfString("/") {
            return Formula(.Divide, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).formula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).formula(subs))
        }
        if let range = self.rangeOfString("^") {
            return Formula(.Power, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).formula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).formula(subs))
        }
        
        if self.hasPrefix(negativeSub) {
            return Formula(.Negate, self.substringFromIndex(advance(startIndex, 1)).formula(subs))
        }
        
        var valueMustBe = self.toDouble()!
        return Formula(.Identity, M(v: valueMustBe))
    }
}

func countElements(s: String?) -> Int {
    if let str = s {
        return countElements(str)
    }
    return 0
}

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)!.doubleValue
    }
    subscript (r: Range<Int>) -> String {
        var start = advance(startIndex, r.startIndex)
        var end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }
}


extension String {
    
    func complexComputed(_ vars: [String: C]=[:]) -> C {
        var changedString = self.stringByReplacingOccurrencesOfString("i", withString: formulaSubPrefix+"0")
        var subs: [String: ComplexFormula] = [formulaSubPrefix+"0":ComplexFormula(.Identity, C(a: 0, b: 1))]
        var index = 1
        for (variable, form) in vars {
            changedString = changedString.stringByReplacingOccurrencesOfString(variable, withString:formulaSubPrefix+String(index))
            subs[formulaSubPrefix + String(index)] = ComplexFormula(.Identity, form)
            index++
        }
        
        return changedString.complexFormula(subs).computed()
    }
    
    func complexFormula(var _ subs: [String: ComplexFormula] = [:]) -> ComplexFormula {
        //go through and replace all instances of parentheses with substitutions. substitutions have a prefix followed by an increasing integer.
        //this is a recursive function. first check if self has been simplified to a substitution
        if let form = subs[self] {
            return form
        }
        if let form = subs[self.stringByReplacingOccurrencesOfString(finalSubPrefix, withString: formulaSubPrefix)] {
            return form
        }
        //find outermost paren indices
        var nestedParens: Int = 0
        //start and ending index of part between parentheses
        var startingIndex: Int = 0
        var endingIndex: Int = 0
        for (index, character) in enumerate(self) {
            if character=="(" {
                if nestedParens == 0 {
                    startingIndex = index+1
                }
                nestedParens++
            }
            if character == ")" {
                if nestedParens == 1 {
                    endingIndex = index
                    break
                }
                nestedParens--
            }
        }
        if startingIndex>0 && endingIndex>0 {
            //find the in-between characters, replace them with a substitution, and recurse.
            var inBetween = self[startingIndex..<endingIndex]
            var beforeParen = self[0..<startingIndex-1]
            var unaryStr: String?
            var unaryFunc: Operation = .Identity
            for (possibleUnary, operation) in complexUnaryFuncs {
                if beforeParen.hasSuffix(possibleUnary) && countElements(possibleUnary)>countElements(unaryStr) {
                    unaryStr = possibleUnary
                    unaryFunc = operation
                }
            }
            var subString = formulaSubPrefix+String(subs.count)
            subs[subString] = ComplexFormula(unaryFunc, inBetween.complexFormula(subs))
            return self.stringByReplacingCharactersInRange(Range(start: advance(startIndex, startingIndex-1-countElements(unaryStr)), end: advance(startIndex, endingIndex+1)), withString: subString).complexFormula(subs)
        }
        
        if let range = self.rangeOfString("-") {
            if range.startIndex==startIndex {
                return self.stringByReplacingCharactersInRange(range, withString: negativeSub).complexFormula(subs)
            }
        }
        for op in operators {
            if let range = self.rangeOfString(op+"-") {
                return self.stringByReplacingCharactersInRange(range, withString: op+negativeSub).complexFormula(subs)
            }
        }
        
        if let range = self.rangeOfString(formulaSubPrefix) {
            if range.startIndex==startIndex {
                return self.stringByReplacingCharactersInRange(range, withString: finalSubPrefix).complexFormula(subs);
            }
            var beforeRange = self.substringToIndex(range.startIndex)
            var endsInOperator = false
            for op in operators {
                if beforeRange.hasSuffix(op) {
                    endsInOperator = true
                }
            }
            if endsInOperator {
                return self.stringByReplacingCharactersInRange(range, withString: finalSubPrefix).complexFormula(subs)
            } else {
                return self.stringByReplacingCharactersInRange(range, withString: "*"+finalSubPrefix).complexFormula(subs)
            }
        }
        
        
        if let range = self.rangeOfString("+") {
            return ComplexFormula(.Add, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).complexFormula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).complexFormula(subs))
        }
        if let range = self.rangeOfString("-") {
            return ComplexFormula(.Subtract, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).complexFormula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).complexFormula(subs))
        }
        //uh oh. subtraction will be tricky, because it can also be negation
        if let range = self.rangeOfString("*") {
            return ComplexFormula(.Multiply, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).complexFormula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).complexFormula(subs))
        }
        if let range = self.rangeOfString("/") {
            return ComplexFormula(.Divide, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).complexFormula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).complexFormula(subs))
        }
        if let range = self.rangeOfString("^") {
            return ComplexFormula(.Power, self.substringWithRange(Range(start: startIndex, end: range.startIndex)).complexFormula(subs), self.substringWithRange(Range(start: range.endIndex, end: endIndex)).complexFormula(subs))
        }
        
        if self.hasPrefix(negativeSub) {
            return ComplexFormula(.Negate, self.substringFromIndex(advance(startIndex, 1)).complexFormula(subs))
        }
        
        var valueMustBe = self.toDouble()!
        return ComplexFormula(.Identity, C(a:valueMustBe, b:0))
    }
}