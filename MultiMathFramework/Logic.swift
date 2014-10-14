//
//  Logic.swift
//  MultiMathFramework
//
//  Created by Lee Danilek on 10/8/14.
//  Copyright (c) 2014 ShipShape. All rights reserved.
//

import Foundation

func * (x: Bool, y: Bool) -> Bool {
    return x && y
}
func + (x: Bool, y: Bool) -> Bool {
    return x || y
}
prefix operator ~ {}
prefix func ~ (x: Bool) -> Bool {
    return !x
}