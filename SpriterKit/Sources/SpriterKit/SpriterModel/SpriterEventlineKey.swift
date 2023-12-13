//
//  SpriterEventlineKey.swift
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

struct SpriterEventlineKey: SpriterParseable {
    
    /// The ID of the key.
    var id: Int
    
    /// The time in seconds for this Eventline key frame.
    var time: TimeInterval = 0
        
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int else {
            return nil
        }
        
        self.id = id
        
        if let time = data.value(forKey: "time") as? Int {
            self.time = TimeInterval(milliseconds: time)
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"] else {
            return nil
        }
        
        self.id = id.intValue()
        
        if let time = attributes["time"] {
            self.time = TimeInterval(millisecondsLiteral: time)
        }
    }
}
