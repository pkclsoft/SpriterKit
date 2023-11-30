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
    
    var angle: CGFloat = 0.0
    var scaleX: CGFloat = DEFAULT_SCALE
    var scaleY: CGFloat = DEFAULT_SCALE
    var alpha: CGFloat = 1.0
    var spin: SpriterSpinType = .clockwise

    /// The combined scales are the result of applying the scale of each parent node to that of their children.
    /// In a traditional Spriter implementation, this would simply be applied to the scale property however since
    /// SpriteKit is being used to manage the combined scale of nodes in the node tree, this combined scale
    /// needs to be managed separately.
    ///
    var combinedScaleX: CGFloat = DEFAULT_SCALE
    var combinedScaleY: CGFloat = DEFAULT_SCALE
    
    var scale : CGPoint {
        get {
            return CGPoint(x: scaleX, y: scaleY)
        }
    }
    
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
            self.scaleX = scaleX
            self.combinedScaleX = scaleX
        }
        
        if let scaleY = data.value(forKey: "scale_y") as? CGFloat {
            self.scaleY = scaleY
            self.combinedScaleY = scaleY
        }
        
        if let alpha = data.value(forKey: "a") as? CGFloat {
            self.alpha = alpha
        }
    }
    
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
            self.scaleX = scaleX.CGFloatValue()
            self.combinedScaleX = self.scaleX
        }
        
        if let scaleY = attributes["scale_y"] {
            self.scaleY = scaleY.CGFloatValue()
            self.combinedScaleY = self.scaleY
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
        
        result.scaleX = result.scaleX.lerp(toB: other.scaleX, alpha: percent)
        result.scaleY = result.scaleY.lerp(toB: other.scaleY, alpha: percent)

        result.combinedScaleX = result.combinedScaleX.lerp(toB: other.combinedScaleX, alpha: percent)
        result.combinedScaleY = result.combinedScaleY.lerp(toB: other.combinedScaleY, alpha: percent)

        return result
    }

}
