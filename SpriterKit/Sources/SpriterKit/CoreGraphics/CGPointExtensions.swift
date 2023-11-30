//
//  CGPointExtensions.swift
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

public extension CGPoint {
    
    /// Returns a new CGPoint as a representation of the input `CGSize`.
    /// - Parameter fromSize: the `size` to convert where the width becomes `x` and height, `y`.
    init(fromSize: CGSize) {
        self.init(x: fromSize.width, y: fromSize.height)
    }
    
    /// Provides a simple subtraction operator for `CGPoint`.
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint.init(x: left.x - right.x, y: left.y - right.y)
    }
    
    /// Decrements a `CGPoint` with the value of another.
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    /// Increments a `CGPoint` with the value of another.
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    /// Provides a simple addition operator for `CGPoint`.
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint.init(x: left.x + right.x, y: left.y + right.y)
    }
    
    /// Provides a simple multiplication operator for `CGPoint`, where the point is effectively scaled by s.
    static func * (v: CGPoint, s: CGFloat) -> CGPoint {
        return CGPoint.init(x: v.x*s, y: v.y*s)
    }
    
    /// Provides  a `CGPoint` multiplication with the value of another.
    static func *= (left: inout CGPoint, right: CGPoint) {
        left = left * right
    }

    /// Provides a simple multiplication operator for `CGPoint`.
    static func * (v: CGPoint, s: CGPoint) -> CGPoint {
        return CGPoint.init(x: v.x*s.x, y: v.y*s.y)
    }
    
    /// Provides a simple division operator for `CGPoint`, where the point is effectively scaled down by s.
    static func / (v: CGPoint, s: CGFloat) -> CGPoint {
        return CGPoint.init(x: v.x/s, y: v.y/s)
    }
    
    /// Compute an interpolated value between `a` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - a: the lower bound of the span.
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `a` and `b` as a percentage.
    /// - Returns: A value between `a` and `b`.
    static func lerp(a: CGPoint, b: CGPoint, alpha:CGFloat) -> CGPoint {
        return a.lerp(toB: b, alpha: alpha)
    }
    
    /// Compute an interpolated value between `self` and `b` using `alpha` as a percentage of the span between.
    /// - Parameters:
    ///   - b: the upper bound
    ///   - alpha: the amount to interpolate between `self` and `b` as a percentage.
    /// - Returns: A value between `self` and `b`.
    func lerp(toB b: CGPoint, alpha: CGFloat) -> CGPoint {
        return self + (b - self) * alpha
    }
    
    /// Computes the Dot Product of two points.
    static func dot (left: CGPoint, right: CGPoint) -> CGFloat {
        return left.x*right.x + left.y*right.y;
        
    }
    
    /// Provides a simple division operator for `CGPoint`.
    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
    
    /// Computes the distance between two `CGpoint`s
    func distanceTo(other: CGPoint) -> CGFloat {
        return  (self - other).lengthSQ().squareRoot()
    }
    
    /// Returns the square of the length of a `CGPoint`.
    func lengthSQ() -> CGFloat {
        return CGPoint.dot(left: self, right: self)
    }
    
    /// Computes the midpoint between two `CGPoint`s.
    static func midpoint(betweenStart start: CGPoint, andEnd end: CGPoint) -> CGPoint {
        return start.lerp(toB: end, alpha: 0.5)
    }
    
    /// Comptes the midpoint between self and another point.
    func midpointBetween(other: CGPoint) -> CGPoint {
        return .midpoint(betweenStart: self, andEnd: other)
    }
    
    /// Returns true if self is considered to be between the two specified points.
    func between(_ first: CGPoint, and second: CGPoint) -> Bool {
        // return false if self is at either extreme.  Can only return true if
        // self is between the two points.
        //
        if first == self || second == self {
            return false
        }
        
        if first.x == second.x {
            if first.x == self.x {
                if first.y < second.y {
                    return (first.y...second.y).contains(self.y)
                } else {
                    return (second.y...first.y).contains(self.y)
                }
            }
        } else if first.y == second.y {
            if first.y == self.y {
                if first.x < second.x {
                    return (first.x...second.x).contains(self.x)
                } else {
                    return (second.x...first.x).contains(self.x)
                }
            }
        }
        
        return false
    }
    
    /// Calculates the angle from self to another point, in radians.
    /// - Parameter toPoint: The other point which provides the direction of the vector
    /// - Returns: An angle specifying the heading from self to toPoint.
    func angle(to toPoint: CGPoint) -> CGFloat {
        return CGVector(point: toPoint - self).angle
    }
    
    
    /// Converts the input angle in degrees to a value in radians.
    /// - Parameter degrees: the input angle in degrees
    /// - Returns: A corresponding value in radians.
    func radians(fromDegrees degrees: CGFloat) -> CGFloat {
        return degrees * (.pi/180.0)
    }
    
    /// Returns a coordinate on the circle surrounding self with the specified radius at an angle in degrees.
    /// - Parameters:
    ///   - radius: The radius of the circle in points
    ///   - atDegrees: The angle of the point from the center where 0.0 is north, and angles increase in a clockwise direction.
    /// - Returns: A coordinate.
    func pointOnCircle(withRadius radius: CGFloat, atDegrees: CGFloat) -> CGPoint {
        return pointOnCircle(withRadius: radius, atRadians: radians(fromDegrees: atDegrees.antiClockwiseAngle()))
    }
    
    /// Returns a coordinate on the circle surrounding self with the specified radius at an angle in degrees.
    /// - Parameters:
    ///   - radius: The radius of the circle in points
    ///   - atRadians: The angle of the point from the center where 0.0 is north, and angles increase in a clockwise direction.
    /// - Returns: A coordinate.
    func pointOnCircle(withRadius radius: CGFloat, atRadians: CGFloat) -> CGPoint {
        let xPos : CGFloat = CGFloat(radius + CGFloat(cos(atRadians)) * radius)
        let yPos : CGFloat = CGFloat(radius + CGFloat(sin(atRadians)) * radius)

        return self + (CGPoint.init(x: xPos, y: yPos) - CGPoint.init(x: radius, y: radius))
    }
    
    /// Returns a point on the Quadratic Bezier Curve between self and `toPoint` using the specified control point, and
    /// a interpolated using `alpha`.
    /// - Parameters:
    ///   - toPoint: the destination point
    ///   - controlPoint: the control point used to help generate the curve
    ///   - alpha: the linear position along the curve (0 .. 1.0)
    /// - Returns: A point along the curve.
    func lerpPointOnArc(toPoint: CGPoint, usingControlPoint controlPoint: CGPoint, alpha: CGFloat) -> CGPoint {
        let xPos = self.lerp(toB: controlPoint, alpha: alpha)
        let yPos = controlPoint.lerp(toB: toPoint, alpha: alpha)

        return xPos.lerp(toB: yPos, alpha: alpha)
    }

#if canImport(GLKit)
    /// Computes the spherical polar coordinate corresponding to the input 3D vector on a sphere with the specified radius.
    /// - Parameters:
    ///   - vector3: The 3d vector defining  a cartesian coordinate.
    ///   - sphereRadius: The radius of the sphere on which the point should be computed.
    /// - Returns: A CGPoint containing a spherical polar coordinate where X is the effective longitude, and Y is the latitude.
    init(withCartesian3DCoordinate vector3: GLKVector3, andSphereRadius sphereRadius: CGFloat) {
        let theta = acosf(Float(CGFloat(vector3.y) / sphereRadius))
        let phi = atan2f(Float(vector3.z), Float(vector3.x))
        let halfPi = CGFloat.pi / 2.0

        // Return the angles, adjusted into spherical coordinates in the ranges:
        //
        //   -180 < theta < 180
        //    -90 < phi < 90
        //
        self.init(x: -(CGFloat(theta) - CGFloat.pi), y: -(halfPi - (halfPi - CGFloat(phi) - halfPi)))
    }

    func asCartesian3DCoordinate(withRadius sphereRadius: CGFloat) -> GLKVector3 {
        // First, adjust the angles back into:
        //   0 < theta < 360
        //   0 < phi < 180
        //
        let halfPi = CGFloat.pi / 2.0
        let phi   = Float(halfPi - self.y)
        let theta = Float(self.x + CGFloat.pi)
        
        // According to: https://www.omnicalculator.com/math/spherical-coordinates#converting-spherical-to-cartesian
        // where self.x = θ and self.y = φ
        //
        // x = r × sin θ × cos φ;
        // y = r × sin θ × sin φ;
        // z = r × cos θ.
        
        // According to: https://keisan.casio.com/exec/system/1359534351
        // where self.y = θ and self.x = ϕ
        //
        // x = r × sin ϕ × cos θ
        // y = r × sin ϕ × sin θ
        // z = r × cos ϕ
        

        let x = Float(Float(sphereRadius) * sinf(theta) * cosf(phi))
        let z = Float(Float(sphereRadius) * sinf(theta) * sinf(phi))
        let y = Float(Float(sphereRadius) * cosf(theta))

        return GLKVector3Make(x, y, z)
    }
    #endif
    
    /// Returns `true` is the point is within the polygon described by the input array of vertices.
    /// - Parameter vertices: An array of vertices defining a closed 2D polygon.
    /// - Returns: `true` if the point is within the polygon.
    func isInsidePolygon(vertices : [CGPoint]) -> Bool {
        var inside = false
        var i : Int = 0
        var j : Int = vertices.count-1

        while i < vertices.count {

            if (((vertices[i].y > self.y) != (vertices[j].y > self.y)) &&
                (self.x < (vertices[j].x - vertices[i].x) *
                    (self.y - vertices[i].y) /
                    (vertices[j].y - vertices[i].y) +
                    vertices[i].x)) {
                inside = !inside
            }

            j = i
            i += 1
        }

        return inside
    }
    
    /// Returns `true` is the point is within the specified rectangle.
    /// - Parameter rect: the rectangle to test
    /// - Returns: `true` is the poin tis within the rectangle.
    func isInside(rect: CGRect) -> Bool {
        return self.x >= rect.origin.x && self.x < rect.origin.x + rect.width && self.y >= rect.origin.y && self.y < rect.origin.y + rect.height
    }

}
