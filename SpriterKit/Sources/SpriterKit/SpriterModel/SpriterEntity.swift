//
//  SpriterEntity.swift
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

public struct SpriterEntity: SpriterParseable {
    
    /// The ID of the entity.
    var id: Int = 0
    
    /// The name of the entity.
    var name: String
    
    /// The animations applicable to this entity.
    var animations: [SpriterAnimation] = []
    
    /// The object infos in the entity.
    var objectInfos : [SpriterObjectInfo] = []
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let name = data.value(forKey: "name") as? String,
              let id = data.value(forKey: "id") as? Int else {
            return nil
        }
        
        self.name = name
        self.id = id
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
    }
    
    /// Retrieves the animation information for the specified ID.
    /// - Parameter id: The ID of the animation being requested.
    /// - Returns: A `SpriterAnimation` or nil if the ID is invalid.
    func animation(withID id: Int) -> SpriterAnimation? {
        return self.animations.first { animation in
            return animation.id == id
        }
    }
    
    /// Retrieves the object information for the specified name.
    /// - Parameter name: The name of the object info being requested.
    /// - Returns: A `SpriterObjectInfo` or nil if the name is invalid.
    func objectInfo(withName name: String) -> SpriterObjectInfo? {
        return self.objectInfos.first { info in
            return info.name == name
        }
    }
}
