//
//  SpriterSpinType.swift
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

/// An enumeration describing a spin that is applied for a frame.  The spin appears to be used by Spriter to ensure that a sprite/bone
/// rotates in a given direction.  the default spin is clockwise.
enum SpriterSpinType: Int {
    case none = 0
    case counterClockwise = -1
    case clockwise = 1
}
