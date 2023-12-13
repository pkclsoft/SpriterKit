//
//  SKSpriterEntityDelegate.swift
//
//
//  Created by Peter Easdown on 13/12/2023.
//

import Foundation

public protocol SKSpriterEntityDelegate {
    
    /// This function will be called by the entity whenever a keyframe is reached with an associated point object.
    /// - Parameters:
    ///   - position: a position within the coordinate space of the entities parent.
    ///   - angle: an angle in radians, where zero represents due east with respect to the entity (taking into
    ///   consideration the entities zRotation).
    func point(updatedWithPosition position: CGPoint, andAngle angle: CGFloat)
    
    /// This function is called by the entity whenever a keyframe is reached with an associaed event.
    func event(reachedWithName name: String)
    
}
