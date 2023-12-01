//
//  SpriterMainlineKey.swift
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

struct SpriterMainlineKey: SpriterParseable {
    
    /// Th ID for this key.
    var id: Int
    
    /// The time in seconds at which the key should be triggered in the animation.  If the key within the project has
    /// no time specified, then this defaults to zero.
    var time: TimeInterval = 0
    
    /// An array of the bone references defined for this key.
    var boneRefs: [SpriterBoneRef] = []
    
    /// An array of the object references defined for this key.
    var objectRefs: [SpriterObjectRef] = []
    
    /// The timing curve defined for this key.
    var curveType: SpriterCurveType?
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int else {
            return nil
        }
        
        self.id = id
        
        if let time = data.value(forKey: "time") as? TimeInterval {
            self.time = time / 1000.0
        }
        
        self.curveType = SpriterCurveType(data: data)
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
            self.time = time.timeIntervalValue()
        }
        
        self.curveType = SpriterCurveType(withAttributes: attributes)
    }
    
}
