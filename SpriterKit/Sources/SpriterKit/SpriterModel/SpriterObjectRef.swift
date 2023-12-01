//
//  SpriterObjectRef.swift
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

struct SpriterObjectRef: SpriterParseable {
    
    /// The ID of the object being referenced.
    var id: Int
    
    /// The ID of the parent bone to which the referenced object should be attached.  Note that a Spriter project can renumber the bones
    /// with each key frame.  It's important that the in-memory structures handle this.
    var parentID: Int = NO_PARENT
    
    /// The ID of the timeline that controls how this object moves with relation to it's bone.
    var timelineID: Int
    
    /// The ID of the key within the timeline that controls how this object moves with relation to it's bone.
    var keyID: Int
    
    /// The optional zPosition of the object.
    var zIndex: Int?

    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int,
            let timelineString = data.value(forKey: "timeline") as? String,
            let keyID = data.value(forKey: "key") as? Int else {
                return nil
        }
        
        self.id = id
        self.timelineID = timelineString.intValue()
        self.keyID = keyID
        
        if let zIndexString = data.value(forKey: "z_index") as? String,
            let zIndex = Int(zIndexString) {
            self.zIndex = zIndex
        } else {
            self.zIndex = nil
        }
        
        if let parentID = data.value(forKey: "parent") as? Int {
            self.parentID = parentID
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
              let timeline = attributes["timeline"],
              let keyID = attributes["key"] else {
                return nil
        }
        
        self.id = id.intValue()
        self.timelineID = timeline.intValue()
        self.keyID = keyID.intValue()
        
        if let zIndex = attributes["z_index"] {
            self.zIndex = zIndex.intValue()
        } else {
            self.zIndex = nil
        }
        
        if let parentID = attributes["parent"] {
            self.parentID = parentID.intValue()
        }
    }
}
