//
//  SKSpriterUtilities.swift
//  SpriterKit
//
//  Note that the bulk of this code is a port of code from:
//
//    https://github.com/loodakrawa/SpriterDotNet/blob/develop/SpriterDotNet/Helpers/MathHelper.cs
//
//  Created by Peter Easdown on 11/11/2023.
//

import Foundation

class SKSpriterUtilities {
    
    static func wrapAngle(angle: CGFloat) -> CGFloat {
        if angle <= 0.0 {
            return fmod((angle - .pi), (2.0 * .pi)) + .pi
        } else {
            return fmod((angle + .pi), (2.0 * .pi)) - .pi
        }
    }
    
    static func tweenAngle(a: CGFloat, b: CGFloat, t: CGFloat, spin: SpriterSpinType) -> CGFloat {
        var bi : CGFloat = b
        
        if spin == .none {
            return a
        } else
        if spin == .clockwise {
            if ((bi - a) < 0.0) {
                bi += 2.0 * .pi
            }
        } else if spin == .counterClockwise {
            if ((bi - a) > 0.0) {
                bi -= 2.0 * .pi
            }
        }
        
        return wrapAngle(angle: a + (wrapAngle(angle: bi - a) * t))
    }
    
    /// Calculates the interpolation factor of the given values.
    static func getFactor(_ a: CGFloat, _ b: CGFloat, _ v: CGFloat) -> CGFloat {
        return (v - a) / (b - a)
    }

    /// Calculates the value of the 1-Dimensional Bezier curve defined with control points c for the
    /// given parameter f [0...1] using De Casteljau's algorithm.
    static func bezier(_ c0: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ f: CGFloat) -> CGFloat {
        return c0.lerp(toB:c1, alpha: f).lerp(toB: c1.lerp(toB: c2, alpha: f), alpha: f)
    }

    /// Calculates the value of the 1-Dimensional Bezier curve defined with control points c for the given
    /// parameter f [0...1] using De Casteljau's algorithm.
    static func bezier(_ c0: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ c3: CGFloat, _ f: CGFloat) -> CGFloat {
        return bezier(c0, c1, c2, f).lerp(toB: bezier(c1, c2, c3, f), alpha: f)
    }

    /// Calculates the value of the 1-Dimensional Bezier curve defined with control points c for the
    /// given parameter f [0...1] using De Casteljau's algorithm.
    static func bezier(_ c0: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ c3: CGFloat, _ c4: CGFloat, _ f: CGFloat) -> CGFloat {
        return bezier(c0, c1, c2, c3, f).lerp(toB: bezier(c1, c2, c3, c4, f), alpha: f)
    }

    /// Calculates the value of the 1-Dimensional Bezier curve defined with control points c for the
    /// given parameter f [0...1] using De Casteljau's algorithm.
    static func bezier(_ c0: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ c3: CGFloat, _ c4: CGFloat, _ c5: CGFloat, _ f: CGFloat) -> CGFloat {
        return bezier(c0, c1, c2, c3, c4, f).lerp(toB: bezier(c1, c2, c3, c4, c5, f), alpha: f)
    }

    static func bezier2D(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ t: CGFloat) -> CGFloat {
        let duration: CGFloat = 1
        let cx: CGFloat = 3.0 * x1
        let bx: CGFloat = 3.0 * (x2 - x1) - cx
        let ax: CGFloat = 1.0 - cx - bx
        let cy: CGFloat = 3.0 * y1
        let by: CGFloat = 3.0 * (y2 - y1) - cy
        let ay: CGFloat = 1.0 - cy - by

        return solve(ax, bx, cx, ay, by, cy, t, solveEpsilon(duration))
    }

    private static func sampleCurve(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ t: CGFloat) -> CGFloat {
        return ((a * t + b) * t + c) * t
    }

    private static func sampleCurveDerivativeX(_ ax: CGFloat, _ bx: CGFloat, _ cx: CGFloat, _ t: CGFloat) -> CGFloat {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }

    private static func solveEpsilon(_ duration: CGFloat) -> CGFloat {
        return 1.0 / (200.0 * duration)
    }

    private static func solve(_ ax: CGFloat, _ bx: CGFloat, _ cx: CGFloat, _ ay: CGFloat, _ by: CGFloat, _ cy: CGFloat, _ x: CGFloat, _ epsilon: CGFloat) -> CGFloat {
        return sampleCurve(ay, by, cy, solveCurveX(ax, bx, cx, x, epsilon))
    }

    private static func solveCurveX(_ ax: CGFloat, _ bx: CGFloat, _ cx: CGFloat, _ x: CGFloat, _ epsilon: CGFloat) -> CGFloat {
        var t0: CGFloat
        var t1: CGFloat
        var t2: CGFloat = x
        var x2: CGFloat
        var d2: CGFloat
        var i: Int = 0

        while i < 8 {
            x2 = sampleCurve(ax, bx, cx, t2) - x
            
            if abs(x2) < epsilon {
                return t2
            }

            d2 = sampleCurveDerivativeX(ax, bx, cx, t2)
            
            if abs(d2) < 1e-6 {
                break
            }
            
            t2 = t2 - x2 / d2
                
            i = i + 1
        }

        t0 = 0.0
        t1 = 1.0
        t2 = x

        if t2 < t0 {
            return t0
        }
        
        if t2 > t1 {
            return t1
        }

        while (t0 < t1) {
            x2 = sampleCurve(ax, bx, cx, t2)
            
            if abs(x2 - x) < epsilon {
                return t2
            }
            
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            
            t2 = (t1 - t0) * 0.5 + t0
        }

        return t2
    }
    
}
