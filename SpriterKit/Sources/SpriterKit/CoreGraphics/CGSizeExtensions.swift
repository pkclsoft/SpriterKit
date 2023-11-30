//
//  CGSizeExtensions.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.
//

import Foundation
import CoreGraphics
#if canImport(GLKit)
import GLKit
#endif

public extension CGSize {
    
    /// Provides a simple subtraction operator for `CGSize`.
    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize.init(width: left.width - right.width, height: left.height - right.height)
    }
    
    /// Provides a simple addition operator for `CGSize`.
    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize.init(width: left.width + right.width, height: left.height + right.height)
    }
    
    /// Provides a simple multiplication operator for `CGSize`, effectively scaling the CGSize..
    static func * (v: CGSize, s: CGFloat) -> CGSize {
        return CGSize.init(width: v.width*s, height: v.height*s)
    }
    
    /// Provides a simple multiplication operator for `CGSize`.
    static func * (v: CGSize, s: CGSize) -> CGSize {
        return CGSize.init(width: v.width*s.width, height: v.height*s.height)
    }
    
    /// Provides a simple division operator for `CGSize`, effectively scaling the CGSize down..
    static func / (v: CGSize, s: CGFloat) -> CGSize {
        return CGSize.init(width: v.width/s, height: v.height/s)
    }
    
    /// Compute an interpolated value between `a` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - a: the lower bound of the span.
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `a` and `b` as a percentage.
    /// - Returns: A value between `a` and `b`.
    static func lerp(a: CGSize, b: CGSize, alpha:CGFloat) -> CGSize {
        return a.lerp(toB: b, alpha: alpha)
    }
    
    /// Compute an interpolated value between `self` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `self` and `b` as a percentage.
    /// - Returns: A value between `self` and `b`.
    func lerp(toB b: CGSize, alpha: CGFloat) -> CGSize {
        return (self * (1.0 - alpha)) + (b * alpha)
    }
    
    /// Computes the Dot Product of two sizes.
    static func dot (left: CGSize, right: CGSize) -> CGFloat {
        return left.width*right.width + left.height*right.height;
        
    }
    
    /// Returns the square of the length of a `CGSize`.
    func lengthSQ() -> CGFloat {
        return CGSize.dot(left: self, right: self)
    }
}
