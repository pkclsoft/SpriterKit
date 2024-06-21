//
//  SpriterObject.swift
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
import GLKit
import SpriteKit

struct SpriterObject: SpriterParseable {
    
    /// The folder ID of the folder containing the file displayed by this object.
    var folderID: Int?
    
    /// The file containing the image for this object.
    var fileID: Int?
    
    /// The position within the object parents space.
    var position: CGPoint = .zero
    
    /// The angle or zRotation of the object in radians.
    var angle: CGFloat = 0.0
    
    /// The xScale of the object.
    var xScale: CGFloat = DEFAULT_SCALE
    
    /// The yScale of the object.
    var yScale: CGFloat = DEFAULT_SCALE
    
    /// The pivot point of the object.
    var pivot: CGPoint = DEFAULT_PIVOT
    
    /// The alpha of the object.
    var alpha: CGFloat = 1.0
    
    /// The spin direction to be applied when rotating the object.
    var spin: SpriterSpinType = .clockwise
    
    /// this is not provided at parsing time; it is provided during animation as
    /// an object reference is used because that is where Spriter provides a
    /// possible change in the zIndex.
    ///
    var zIndex: Int? = 0

    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        if let folderID = data.value(forKey: "folder") as? Int {
            self.folderID = folderID
        }
        
        if let fileID = data.value(forKey: "file") as? Int {
            self.fileID = fileID
        }
        
        if let x = data.value(forKey: "x") as? CGFloat {
            self.position.x = x
        }
        
        if let y = data.value(forKey: "y") as? CGFloat {
            self.position.y = y
        }
        
        if let angle = data.value(forKey: "angle") as? CGFloat {
            self.angle = CGFloat(GLKMathDegreesToRadians(Float(angle)))
        }
        
        if let scaleX = data.value(forKey: "scale_x") as? CGFloat {
            self.xScale = scaleX
        }
        
        if let scaleY = data.value(forKey: "scale_y") as? CGFloat {
            self.yScale = scaleY
        }
        
        if let pivotX = data.value(forKey: "pivot_x") as? CGFloat {
            self.pivot.x = pivotX
        }
        
        if let pivotY = data.value(forKey: "pivot_y") as? CGFloat {
            self.pivot.y = pivotY
        }
        
        if let alpha = data.value(forKey: "a") as? CGFloat {
            self.alpha = alpha
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        if let folderID = attributes["folder"] {
            self.folderID = folderID.intValue()
        }

        if let fileID = attributes["file"] {
            self.fileID = fileID.intValue()
        }
                
        if let x = attributes["x"] {
            self.position.x = x.CGFloatValue()
        }
        
        if let y = attributes["y"] {
            self.position.y = y.CGFloatValue()
        }
        
        if let angle = attributes["angle"] {
            self.angle = CGFloat(GLKMathDegreesToRadians(Float(angle.CGFloatValue())))
        }
        
        if let scaleX = attributes["scale_x"] {
            self.xScale = scaleX.CGFloatValue()
        }
        
        if let scaleY = attributes["scale_y"] {
            self.yScale = scaleY.CGFloatValue()
        }
        
        if let pivotX = attributes["pivot_x"] {
            self.pivot.x = pivotX.CGFloatValue()
        }
        
        if let pivotY = attributes["pivot_y"] {
            self.pivot.y = pivotY.CGFloatValue()
        }
        
        if let alpha = attributes["a"] {
            self.alpha = alpha.CGFloatValue()
        }
    }
    
    /// Computes a tween between self and the specified `SpriterObject`.
    /// - Parameters:
    ///   - other: the other `SpriterObject` and the destination that would be reached if `percent` were 1.0.
    ///   - percent: The tweening percentage.
    /// - Returns: A `SpriterObject` representing the tween beteen the two objects at a given percentage.
    func tween(to other: SpriterObject, forPercent percent: CGFloat) -> SpriterObject {
        var result : SpriterObject = self
        
        result.angle = SKSpriterUtilities.tweenAngle(a: result.angle, b: other.angle, t: percent, spin: result.spin)
        
        result.position = result.position.lerp(toB: other.position, alpha: percent)
        
        result.pivot = result.pivot.lerp(toB: other.pivot, alpha: percent)
        
        result.xScale = result.xScale.lerp(toB: other.xScale, alpha: percent)
        result.yScale = result.yScale.lerp(toB: other.yScale, alpha: percent)
        
        result.alpha = result.alpha.lerp(toB: other.alpha, alpha: percent)

        return result
    }

}
