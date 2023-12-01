//
//  SpriterTimeline.swift
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

struct SpriterTimeline: SpriterParseable {
    
    /// The ID of the timeline.
    var id: Int
    
    /// The name of the timeline.
    var name: String
    
    /// The object type of the timeline.  This always seems to be "Bone"
    var objectType: SpriterObjectType?
    
    /// An array of the keys associated with this timeline.
    var keys: [SpriterTimelineKey] = []
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int,
            let name = data.value(forKey: "name") as? String else {
                return nil
        }
        
        self.id = id
        self.name = name
        
        if let type = data.value(forKey: "type") as? String,
            let objectType = SpriterObjectType(rawValue: type) {
            self.objectType = objectType
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
            let name = attributes["name"] else {
                return nil
        }
        
        self.id = id.intValue()
        self.name = name
        
        if let type = attributes["type"],
            let objectType = SpriterObjectType(rawValue: type) {
            self.objectType = objectType
        }
    }
}
