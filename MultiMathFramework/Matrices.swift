//
//  Matrices.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/22/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation

//row reduction
enum RRStep: Printable {
    case swap(Int, Int) //swap 2 rows
    case multiply(Int, Double) //multiply row by number
    case combine(Int, Double, Int) //add row*number to row
    var description: String {
        switch self {
        case let .swap(x, y):
            return "Swap rows \(x+1) and \(y+1)"
        case let .multiply(r, x):
            return "Multiply row \(r+1) by \(x)"
        case let .combine(src, x, dest):
            return "Row \(dest+1) + \(x) * row \(src+1) -> row \(dest+1)"
        }
    }
}

struct Matrix: Equatable, Similarity {
    let rows: Int, columns: Int
    var grid: [Double]
    
    //in O(n x m) calculations, n is rows and m is columns
    
    //setting grid / initialization is O(n x m)
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: 0.0)
    }
    init(rows: Int, values: [Double]) {
        self.rows = rows
        self.columns = values.count/rows
        grid = values
    }
    //copy is O(n x m)
    func copy() -> Matrix {
        var cpy = Matrix(rows: rows, columns: columns)
        cpy.grid = grid
        return cpy
    }
    //O(1)
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    //O(1)
    func isSquare() -> Bool {
        return rows == columns
    }
    //weak echelon form. for each row n, the first nonzero term (pivot) is 1 and to the left of the (n+1)th pivot
    //O(n x m)
    func isWeakEchelonForm() -> Bool {
        var indexOfPivotInPrevRow = -1
        for row in 0..<self.rows {
            var thisPivotIndex = indexOfPivot(inRow: row)
            if thisPivotIndex > indexOfPivotInPrevRow {
                indexOfPivotInPrevRow = thisPivotIndex
            } else {
                return false
            }
        }
        return true
    }
    //O(n^2 + n x m)
    func isStrongEchelonForm() -> Bool {
        //the rules of strong echelon form are a superset of the rules of weak echelon form
        //O(n x m)
        if !isWeakEchelonForm() {
            return false
        }
        //a column is pivotal iff it contains one pivot
        //therefore go through each row. if it has a pivot, check that column to see that all values above the pivot are 0
        //O(n * (m+n))
        for rowWithPivot in 0..<self.rows {
            //O(m)
            var column = indexOfPivot(inRow: rowWithPivot)
            if column>=0 && column<self.columns {
                //O(n)
                for row in 0..<rowWithPivot {
                    if self[row, column] !~~ 0 {
                        return false
                    }
                }
            }
        }
        return true
    }
    //if row is all zeros, return self.columns
    //else if row is nonpivotal, return -1
    //O(m) time
    func indexOfPivot(inRow row: Int) -> Int {
        for column in 0..<self.columns {
            if self[row, column] ~~ 1 {
                return column
            } else if self[row, column] !~~ 0 {
                return -1
            }
        }
        return self.columns
    }
    //O(m^2 * n)
    mutating func toWeakEchelon() -> [RRStep] {
        var steps = [RRStep]()
        var rowOfPivot = 0 //this might increment, depending on what happens
        //loop happens O(m) times, so entire loop is O(m^2 * n)
        for columnToDealWith in 0..<self.columns {
            if isWeakEchelonForm() {
                return steps
            }
            //O(n x m) inside loop
            if self[rowOfPivot, columnToDealWith] ~~ 0 {
                //O(n x m)
                //must swap to get a 1 here
                println(self[rowOfPivot, columnToDealWith])
                for possibleSwap in rowOfPivot+1 ..< self.rows {
                    if self[possibleSwap, columnToDealWith] !~~ 0 {
                        var swapStep: RRStep = RRStep.swap(rowOfPivot, possibleSwap)
                        self.apply(step: swapStep)
                        steps.append(swapStep)
                    }
                }
            }
            //now there might not be a zero in rowOfPivot, because I would have swapped it out. If not possible, and it's still zero, just move on to the next column
            var wherePivotShouldBe = self[rowOfPivot, columnToDealWith]
            if wherePivotShouldBe !~~ 0 {
                //O(m)
                if wherePivotShouldBe !~~ 1 {
                    //make it a 1 by multiplying the whole row
                    var divideStep: RRStep = RRStep.multiply(rowOfPivot, 1/wherePivotShouldBe)
                    self.apply(step: divideStep)
                    steps.append(divideStep)
                }
                //now this row is pivotal
                
                //now deal with the rest of the column by making everything below the pivot a 0
                //O(n x m)
                for rowToErase in rowOfPivot+1 ..< self.rows {
                    if self[rowToErase, columnToDealWith] !~~ 0 {
                        var combineStep: RRStep = RRStep.combine(rowOfPivot, -self[rowToErase, columnToDealWith], rowToErase)
                        steps.append(combineStep)
                        self.apply(step: combineStep)
                    }
                }
                
                //the next row should be pivotal in the next column
                rowOfPivot++
            }
        }
        return steps
    }
    //only 0 or 1 or 2 steps for each element in matrix, so steps is O(n*m) size
    //O( n*n*m + n*m*m ) = O( (n*m)*(n+m) )
    mutating func toStrongEchelon() -> [RRStep] {
        var steps = toWeakEchelon()
        //go through each pivotal column
        for pivotalRow in 0..<self.rows {
            var pivotalColumn = indexOfPivot(inRow: pivotalRow)
            if pivotalColumn>=0 && pivotalColumn<self.columns {
                //I now have a pivot
                //O(n*m)
                for rowToErase in 0..<pivotalRow {
                    if self[rowToErase, pivotalColumn] !~~ 0 {
                        var combineStep = RRStep.combine(pivotalRow, -self[rowToErase, pivotalColumn], rowToErase)
                        steps.append(combineStep)
                        self.apply(step: combineStep)
                    }
                }
            }
        }
        return steps
    }
    //O(m) time
    mutating func apply(#step: RRStep) {
        switch step {
        case let .swap(x, y):
            for column in 0..<self.columns {
                var temp = self[x, column]
                self[x, column] = self[y, column]
                self[y, column] = temp
            }
        case let .multiply(row, factor):
            for column in 0..<self.columns {
                self[row, column] *= factor
            }
        case let .combine(src, factor, dest):
            for column in 0..<self.columns {
                self[dest, column] += factor*self[src, column]
            }
        }
    }
    //O(m * (number of steps))
    mutating func apply(#steps: [RRStep]) {
        for step in steps {
            apply(step: step)
        }
    }
    //O(n^2)
    func isIdentity() -> Bool {
        return isSquare() && self~~Matrix.identity(ofSize: rows)
    }
    //O(n^2)
    static func identity(ofSize size:Int) -> Matrix {
        var square = Matrix(rows: size, columns: size)
        for i in 0..<size {
            square[i, i] = 1
        }
        return square
    }
    //if not square, O(1)
    //otherwise, O(n^3)
    var inverse: Matrix? {
        if !isSquare() {//this is already covered in checking for identity, but don't want to do unnecessary calculations
            return nil
        }
        var A = self.copy() // O(n^2)
        var steps = A.toStrongEchelon() // O( n^3 ), steps is O(n^2) size
        if !A.isIdentity() { //O(n^2)
            return nil
        }
        A.apply(steps: steps) // O(n^3)
        return A
    }
    //grid reads like a book (left to right, then top to bottom)
    //O(1) time
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

//for different m or n, completes in O(1) time. for same m and n, completes in O(n*m) time
func == (a: Matrix, b: Matrix) -> Bool {
    return a.rows==b.rows && a.grid==b.grid
}

func ~~ (a: Matrix, b: Matrix) -> Bool {
    if a.rows != b.rows || a.columns != b.columns {
        return false
    }
    for i in 0..<a.grid.count {
        if a.grid[i] !~~ b.grid[i] {
            return false
        }
    }
    return true
}

//a is m x n, b is n x p
//O(m*n*p)
func * (a: Matrix, b: Matrix) -> Matrix {
    assert(a.columns == b.rows)
    var product = Matrix(rows: a.rows, columns: b.columns)
    for i in 0..<product.rows {
        for j in 0..<product.columns {
            var sum: Double = 0
            for k in 0..<a.columns {
                sum += a[i, k] * b[k, j]
            }
            product[i, j] = sum
        }
    }
    return product
}