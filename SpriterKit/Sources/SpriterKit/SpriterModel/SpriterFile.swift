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
struct SpriterFile: SpriterParseable {
    
    var id: Int
    var name: String
    var width: CGFloat
    var height: CGFloat
    var pivot: CGPoint = DEFAULT_PIVOT
    
    var assetName : String {
        get {
            return NSString(string: name).lastPathComponent
        }
    }
    
    var size : CGSize {
        get {
            return CGSize(width: self.width, height: self.height)
        }
    }
    
    init?(data: AnyObject) {
        
        guard let id = data.value(forKey: "id") as? Int,
            let name = data.value(forKey: "name") as? String,
            let width = data.value(forKey: "width") as? CGFloat,
            let height = data.value(forKey: "height") as? CGFloat else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.width = width
        self.height = height
    
        if let pivotX = data.value(forKey: "pivot_x") as? CGFloat {
            self.pivot.x = pivotX
        }
        
        if let pivotY = data.value(forKey: "pivot_y") as? CGFloat {
            self.pivot.y = pivotY
        }
    }
    
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
              let name = attributes["name"],
              let width = attributes["width"],
              let height = attributes["height"] else {
                return nil
        }
        
        self.id = id.intValue()
        self.name = name
        self.width = width.CGFloatValue()
        self.height = height.CGFloatValue()
    
        if let pivotX = attributes["pivot_x"] {
            self.pivot.x = pivotX.CGFloatValue()
        }
        
        if let pivotY = attributes["pivot_y"] {
            self.pivot.y = pivotY.CGFloatValue()
        }
    }
}
