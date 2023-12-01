//
//  SpriterBone.swift
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

struct SpriterBone: SpriterParseable {
    
    /// The position of the bone within it's parent space.
    var position: CGPoint = .zero
    
#if DEBUG
    /// The size of the bone according to the `bone_info`.  This is added by the parser as it is not available
    /// in the `bone_ref`.  You only really need this if you want to display the bones.
    var size: CGSize = .zero
#endif
    
    /// The angle or zRotation of the bone in radians.
    var angle: CGFloat = 0.0
    
    /// The xScale of the bone.
    var xScale: CGFloat = DEFAULT_SCALE
    
    /// The yScale of the bone.
    var yScale: CGFloat = DEFAULT_SCALE
    
    /// The alpha component of the bone.
    var alpha: CGFloat = 1.0
    
    /// The spin direction to be applied when rotating a bone.
    var spin: SpriterSpinType = .clockwise
    
    /// The combined scales are the result of applying the scale of each parent node to that of their children.
    /// In a traditional Spriter implementation, this would simply be applied to the scale property however since
    /// SpriteKit is being used to manage the combined scale of nodes in the node tree, this combined scale
    /// needs to be managed separately.
    ///
    var xScaleCombined: CGFloat = DEFAULT_SCALE
    var yScaleCombined: CGFloat = DEFAULT_SCALE
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        if let x = data.value(forKey: "x") as? CGFloat {
            self.position.x = x
        }
        
        if let y = data.value(forKey: "y") as? CGFloat {
            self.position.y = y
        }
        
        if let angle = data.value(forKey: "angle") as? CGFloat {
            self.angle = angle
        }
        
        if let scaleX = data.value(forKey: "scale_x") as? CGFloat {
            self.xScale = scaleX
            self.xScaleCombined = scaleX
        }
        
        if let scaleY = data.value(forKey: "scale_y") as? CGFloat {
            self.yScale = scaleY
            self.yScaleCombined = scaleY
        }
        
        if let alpha = data.value(forKey: "a") as? CGFloat {
            self.alpha = alpha
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
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
            self.xScaleCombined = self.xScale
        }
        
        if let scaleY = attributes["scale_y"] {
            self.yScale = scaleY.CGFloatValue()
            self.yScaleCombined = self.yScale
        }
        
        if let alpha = attributes["a"] {
            self.alpha = alpha.CGFloatValue()
        }
    }
    
    /// Computes a tween between self and the specified `SpriterBone`.
    /// - Parameters:
    ///   - other: the other `SpriterBone` and the destination that would be reached if `percent` were 1.0.
    ///   - percent: The tweening percentage.
    /// - Returns: A `SpriterBone` representing the tween beteen the two objects at a given percentage.
    func tween(to other: SpriterBone, forPercent percent: CGFloat) -> SpriterBone {
        var result : SpriterBone = self
        
        result.angle = SKSpriterUtilities.tweenAngle(a: result.angle, b: other.angle, t: percent, spin: result.spin)
        
        result.position = result.position.lerp(toB: other.position, alpha: percent)
        
        result.xScale = result.xScale.lerp(toB: other.xScale, alpha: percent)
        result.yScale = result.yScale.lerp(toB: other.yScale, alpha: percent)
        
        result.xScaleCombined = result.xScaleCombined.lerp(toB: other.xScaleCombined, alpha: percent)
        result.yScaleCombined = result.yScaleCombined.lerp(toB: other.yScaleCombined, alpha: percent)
        
        return result
    }
    
}
