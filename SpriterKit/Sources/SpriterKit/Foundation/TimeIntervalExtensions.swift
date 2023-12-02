//
//  TimeIntervalExtensions.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.

import Foundation

public extension TimeInterval {
    
    /// A constant for doing conversions between Spriter project representations of time as an Integer number of milliseconds
    /// and a TimeInterval in seconds.
    static let MillisecondsPerSecond : TimeInterval = 1000.0
    
    /// Initialises a new TimeInterval from an Integer value in milliseconds.
    /// - Parameter milliseconds: the number of milliseconds
    init(milliseconds: Int) {
        self = TimeInterval(milliseconds) / TimeInterval.MillisecondsPerSecond
    }
    
    /// Initialises a new TimeInterval from a string representation in milliseconds.
    /// - Parameter millisecondsLiteral: the number of milliseconds as a string.
    init(millisecondsLiteral: String) {
        self.init(milliseconds: millisecondsLiteral.intValue())
    }
    
    /// Returns an Integer representation of self as a number of Milliseconds.
    /// - Returns: An Int containing the number of milliseconds represented by self.
    func millisecondIntValue() -> Int {
        return Int(self * TimeInterval.MillisecondsPerSecond)
    }
}
