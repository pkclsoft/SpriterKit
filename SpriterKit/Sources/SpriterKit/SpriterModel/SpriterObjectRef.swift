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
    
    var id: Int
    var parentID: Int = SpriterRefNoParentValue
    var timelineID: Int
    var keyID: Int
    var zIndex: Int?


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
