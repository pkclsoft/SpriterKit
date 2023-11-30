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
    
    var id: Int
    var parentID: Int = SpriterRefNoParentValue
    var timelineID: Int
    var timeline: SpriterTimeline?
    var keyID: Int
    var timelineKey: SpriterTimelineKey?
    
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
