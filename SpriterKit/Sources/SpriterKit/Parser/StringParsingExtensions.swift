//
//  StringParsingExtensions.swift
//  SpriterKit
//
//  Originally sourced within SwiftSpriter @ https://github.com/lumenlunae/SwiftSpriter
//
//  Created by Matt on 8/27/16.
//  Copyright © 2016 BiminiRoad. All rights reserved.
//
//  Changed to work within SpriterKit by Peter on 30/11/24
//

import Foundation

/// Useful functions to take a string read from a Spriter project and convert that string into a type
/// required by Spriter.
public extension String {
    
    /// Returns a simple Int representation for the String.
    /// - Returns: An Int representation of self, or 0.
    func intValue() -> Int {
        return Int(self) ?? 0
    }
    
    /// Returns a TimeInterval representation of self.  Input values are assumed to be in milliseconds as an Int
    /// and are converted to seconds as per the TimeInterval type.
    /// - Returns: A TimeInterval value in seconds.
    func timeIntervalValue() -> TimeInterval {
        return TimeInterval(Double(self) ?? 0.0) / 1000.0
    }
    
    /// Returns a CGFloat representation of the String.
    /// - Returns: A CGFloat.
    func CGFloatValue() -> CGFloat {
        return CGFloat(Double(self) ?? 0.0)
    }
    
    /// Returns a Bool representation of self.
    /// - Returns: A Bool.
    func boolValue() -> Bool {
        return self == "true" ? true : false
    }
}
