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
