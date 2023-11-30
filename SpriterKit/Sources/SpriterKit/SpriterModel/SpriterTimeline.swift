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
    
    var id: Int
    var name: String
    var objectType: SpriterObjectType?
    var keys: [SpriterTimelineKey] = []
    
    
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
