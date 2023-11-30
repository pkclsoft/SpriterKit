//
//  SpriterObjectType.swift
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

/// A simple enumeration of the various object types supported by Spriter.  Only bones, sprites and entities are supported
/// by SpriterKit.
/// 
enum SpriterObjectType: String {
    case sprite
    case bone
    case entity

    // The following types are currently unsupported by SpriterKit
    case box
    case point
    case sound
    case variable
}

