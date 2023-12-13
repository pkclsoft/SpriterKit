//
//  SpriterEventline.swift
//  SpriterKit
//
//  Created by Peter Easdown on 12/12/2023.
//

import Foundation

struct SpriterEventline: SpriterParseable {
    
    /// The ID of the eventline.
    var id: Int
    
    /// The name of the eventline.
    var name: String
    
    /// An array of the keys associated with this eventline.
    var keys: [SpriterEventlineKey] = []
    
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
}
