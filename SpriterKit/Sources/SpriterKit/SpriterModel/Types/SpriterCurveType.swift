//
//  SpriterCurveType.swift
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

/// The timing of an animation can be configured to use one of a number of curve types, allowing the animation to speed up
/// or slow down within the span of a frame.
///
/// This type provides a definition for the available curve types.
enum SpriterCurveType : Equatable {
    
    case instant
    case linear
    case quadratic(c1: CGFloat)
    case cubic(c1: CGFloat, c2: CGFloat)
    case quartic(c1: CGFloat, c2: CGFloat, c3: CGFloat)
    case quintic(c1: CGFloat, c2: CGFloat, c3: CGFloat, c4: CGFloat)
    case bezier(c1: CGFloat, c2: CGFloat, c3: CGFloat, c4: CGFloat)
    
    init?(data: AnyObject) {
        var c1: CGFloat = 0.0
        var c2: CGFloat = 0.0
        var c3: CGFloat = 0.0
        var c4: CGFloat = 0.0

        if let c1Value = data.value(forKey: "c1") as? CGFloat {
            c1 = c1Value
        }
        
        if let c2Value = data.value(forKey: "c2") as? CGFloat {
            c2 = c2Value
        }
        
        if let c3Value = data.value(forKey: "c3") as? CGFloat {
            c3 = c3Value
        }
        
        if let c4Value = data.value(forKey: "c4") as? CGFloat {
            c4 = c4Value
        }
        
        if let curveTypeInt = data.value(forKey: "curve_type") as? Int {
            switch curveTypeInt {
                case 0:
                    self = .instant
                case 1:
                    self = .linear
                case 2:
                    self = .quadratic(c1: c1)
                case 3:
                    self = .cubic(c1: c1, c2: c2)
                case 4:
                    self = .quartic(c1: c1, c2: c2, c3: c3)
                case 5:
                    self = .quintic(c1: c1, c2: c2, c3: c3, c4: c4)
                case 6:
                    self = .bezier(c1: c1, c2: c2, c3: c3, c4: c4)
                default:
                    return nil
            }
        } else {
            return nil
        }
    }
    
    init?(withAttributes attributes: [String: String]) {
        var c1: CGFloat = 0.0
        var c2: CGFloat = 0.0
        var c3: CGFloat = 0.0
        var c4: CGFloat = 0.0
        
        if let c1Value = attributes["c1"] {
            c1 = c1Value.CGFloatValue()
        }
        
        if let c2Value = attributes["c2"] {
            c2 = c2Value.CGFloatValue()
        }
        
        if let c3Value = attributes["c3"] {
            c3 = c3Value.CGFloatValue()
        }
        
        if let c4Value = attributes["c4"] {
            c4 = c4Value.CGFloatValue()
        }
        
        if let curveTypeStr = attributes["curve_type"] {
            switch curveTypeStr {
                case "instant":
                    self = .instant
                case "linear":
                    self = .linear
                case "quadratic":
                    self = .quadratic(c1: c1)
                case "cubic":
                    self = .cubic(c1: c1, c2: c2)
                case "quartic":
                    self = .quartic(c1: c1, c2: c2, c3: c3)
                case "quintic":
                    self = .quintic(c1: c1, c2: c2, c3: c3, c4: c4)
                case "bezier":
                    self = .bezier(c1: c1, c2: c2, c3: c3, c4: c4)
                default:
                    return nil
            }
        } else {
            return nil
        }

    }
    
    init?(string: String) {
        switch string.lowercased() {
            case "instant": self = .instant
            case "linear":  self = .linear
            case "quadratic": self = .quadratic(c1: 0.0)
            case "cubic": self = .cubic(c1: 0.0, c2: 0.0)
            case "quartic": self = .quartic(c1: 0.0, c2: 0.0, c3: 0.0)
            case "quintic": self = .quintic(c1: 0.0, c2: 0.0, c3: 0.0, c4: 0.0)
            case "bezier": self = .bezier(c1: 0.0, c2: 0.0, c3: 0.0, c4: 0.0)
            default: return nil
        }
    }
}
