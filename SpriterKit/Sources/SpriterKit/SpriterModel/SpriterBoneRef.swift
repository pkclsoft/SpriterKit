//
//  SpriterBoneRef.swift
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

struct SpriterBoneRef: SpriterParseable {
    
    /// The ID of the bone.  It's worth noting that this ID can change and should not be trusted.
    var id: Int
    
    /// The ID of the parent bone, if any.
    var parentID: Int = NO_PARENT
    
    /// The ID of the timeline that manages the position, scale, rotation of the bone.
    var timelineID: Int
    
    // The ID of the key within the timeline this BoneRef represents.
    var keyID: Int
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int,
              let timelineID = data.value(forKey: "timeline") as? Int,
              let keyID = data.value(forKey: "key") as? Int else {
            return nil
        }
        
        self.id = id
        self.timelineID = timelineID
        self.keyID = keyID
        
        if let parentID = data.value(forKey: "parent") as? Int {
            self.parentID = parentID
        }
        
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
              let timelineID = attributes["timeline"],
              let keyID = attributes["key"] else {
            return nil
        }
        
        self.id = id.intValue()
        self.timelineID = timelineID.intValue()
        self.keyID = keyID.intValue()
        
        if let parentID = attributes["parent"] {
            self.parentID = parentID.intValue()
        }
    }
}
