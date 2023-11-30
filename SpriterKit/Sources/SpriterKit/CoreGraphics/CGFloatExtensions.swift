//
//  CGFloatExtensions.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.
//

import Foundation

public extension CGFloat {
    
    /// Compute an interpolated value between `a` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - a: the lower bound of the span.
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `a` and `b` as a percentage.
    /// - Returns: A value between `a` and `b`.
    static func lerp(a: CGFloat, b: CGFloat, alpha: CGFloat) -> CGFloat {
        return a.lerp(toB: b, alpha: alpha)
    }
    
    /// Compute an interpolated value between `self` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `self` and `b` as a percentage.
    /// - Returns: A value between `self` and `b`.
    func lerp(toB b: CGFloat, alpha: CGFloat) -> CGFloat {
        return self + (b - self) * alpha
    }
    
    /**
     * Assuming that self is an angle in degrees in a clockwise direction where 0.0 is north, returns an angle in degrees in an anticlockwise direction
     * where 0 is east.
     */
    func antiClockwiseAngle() -> CGFloat {
        return (450.0 - self).truncatingRemainder(dividingBy: 360.0)
    }

}
