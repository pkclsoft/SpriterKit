//
//  SpriterFile.swift
//  SpriterKit
//
//  Originally sourced within SwiftSpriter @ https://github.com/lumenlunae/SwiftSpriter
//
//  Created by Matt on 8/27/16.
//  Copyright © 2016 BiminiRoad. All rights reserved.
//
//  Changed to work within SpriterKit by Peter on 30/11/24
//
//  Refactored by Peter Easdown in 2023 to work within an Xcode 15 environment
//  using Asset Catalogs, and SpriteKit

import Foundation

///  A representation of a single art asset from within an exported Spriter project.  Each SpriterFile represents a single image
///  (typically a PNG) as written to a project/folder within the Spriter project.  This repository provides a bash script that can be
///  used to build an Xcode asset catalog from that export.
///
public struct SpriterFile: SpriterParseable {
    
    /// The ID of the file within it's folder.
    var id: Int
    
    /// The name of the file, which may include a folder prefix.
    var name: String
    
    /// The size in pixels of the image within the file.
    var size : CGSize = .zero
    
    /// The initial pivot point of the image.
    var pivot: CGPoint = DEFAULT_PIVOT
    
    /// The name of the file asset itself, stripped of the folder prefix.  (The asset catalog will not include the folder prefix.)
    var assetName : String {
        get {
            return NSString(string: name).lastPathComponent
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        
        guard let id = data.value(forKey: "id") as? Int,
            let name = data.value(forKey: "name") as? String,
            let width = data.value(forKey: "width") as? CGFloat,
            let height = data.value(forKey: "height") as? CGFloat else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.size.width = width
        self.size.height = height
    
        if let pivotX = data.value(forKey: "pivot_x") as? CGFloat {
            self.pivot.x = pivotX
        }
        
        if let pivotY = data.value(forKey: "pivot_y") as? CGFloat {
            self.pivot.y = pivotY
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
              let name = attributes["name"],
              let width = attributes["width"],
              let height = attributes["height"] else {
                return nil
        }
        
        self.id = id.intValue()
        self.name = name
        self.size.width = width.CGFloatValue()
        self.size.height = height.CGFloatValue()
    
        if let pivotX = attributes["pivot_x"] {
            self.pivot.x = pivotX.CGFloatValue()
        }
        
        if let pivotY = attributes["pivot_y"] {
            self.pivot.y = pivotY.CGFloatValue()
        }
    }
}
