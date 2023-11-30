//
//  SpriterParsable.swift
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

/// Provides a common protocol used to define all of the data structures that make up a Spriter project.
protocol SpriterParseable {
    init?(data: AnyObject)
    init?(withAttributes attributes: [String: String])
}
