//
//  SpriterObjectInfo.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.
//

import Foundation

struct SpriterObjectInfo: SpriterParseable {
    
    /// The name of the file, which may include a folder prefix.
    var name: String
    
    /// The size in pixels of the image within the file.
    var size : CGSize = .zero
    
    /// The type of the object.  This always seems to be "bone" or "sprite"
    var type: SpriterObjectType?

    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let width = data.value(forKey: "w") as? Double,
              let height = data.value(forKey: "h") as? Double,
              let name = data.value(forKey: "name") as? String else {
                return nil
        }

        self.name = name
        self.size = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        if let typeStr = data.value(forKey: "type") as? String,
            let type = SpriterObjectType(rawValue: typeStr) {
            self.type = type
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let width = attributes["w"],
              let height = attributes["h"],
              let name = attributes["name"] else {
                return nil
        }

        self.name = name
        self.size = CGSize(width: width.CGFloatValue(), height: height.CGFloatValue())
        
        if let type = attributes["type"],
            let type = SpriterObjectType(rawValue: type) {
            self.type = type
        }
    }
}
