//
//  SKSpriterBone.swift
//
//
//  Created by Peter Easdown on 2/11/2023.
//

import Foundation
import SpriteKit

/// A SpriteKit node that provides a real bone implementation that can be inserted into the node tree, and be used as a
/// container for other bones and objects.  A `SKSpriterBone` uses the functions and features of SpriteKit to achieve a lot
/// of the math required to move it's children (and respectively, their children and so on).  A bone need only be given a
/// position and rotation.
///
/// Children should be positioned within the node space, applying the instructions embedded within a `SpriterBone`
/// instance via a call to `update(fromReference)`.
///
/// A `SKSpriterBone` maintains two internal SpriterBone objects that provide the previous and current keyframe data.
///
/// When compiled in a Debug environment, a `SKSpriterBone` can also provide a visualisation of the bone position,
/// size and orientation.
///
public class SKSpriterBone : SKNode {
    
    /// The timeline ID specific to this bone.  This is used instead of the bone ID to uniquely identify a bone because it never changes.  The bone ID can
    /// change on a key frame, so it can't be relied on.
    var timelineID : Int
    
    /// The previous SpriterBone
    var prevReference : SpriterBone
    
    /// The SpriterBone for the current key frame.
    var reference: SpriterBone
    
    #if DEBUG
    /// When true in DEBUG builds, the visualisation of the bone is shown.
    var showBones : Bool {
        didSet {
            self.boneJoint.isHidden = !showBones
        }
    }
    
    private let BONE_JOINT_NAME = "boneJoint"
    private let BONE_VISUALISATION_NAME = "boneShape"
    private let BONE_ALPHA = 0.5

    /// The SKNode used to visualise the bone position.
    var boneJoint : SKShapeNode
    #endif
    
    /// Initialises a new SKSpriterBone, and prepares it for initial use.
    /// - Parameters:
    ///   - withBone: The SpriterBone used to set the initial state of the bone.
    ///   - initialTimelineID: The timeline ID for the bone at creation.
    init(withBone: SpriterBone, initialTimelineID: Int) {
        timelineID = initialTimelineID
        prevReference = withBone
        reference = withBone
        
        #if DEBUG
        boneJoint = SKShapeNode(circleOfRadius: 25.0)
        
        showBones = true
        #endif
        
        super.init()
        
        #if DEBUG
        boneJoint.strokeColor = .clear
        boneJoint.fillColor = .blue
        boneJoint.alpha = BONE_ALPHA
        boneJoint.zPosition = 5000.0
        boneJoint.name = BONE_JOINT_NAME
        self.addChild(boneJoint)
        #endif
        
        self.update(fromReference: self.reference)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates this nodes reference with instructions from the specified parent bone.
    /// - Parameter parent: the parent bone.
    func update(withParent parent: SKSpriterBone) {
        // Compute our combined scale by combining our raw scale (that from the proect)
        // with that of the parents combined scale.
        //
        self.reference.xScaleCombined = self.reference.xScale * parent.reference.xScaleCombined
        self.reference.yScaleCombined = self.reference.yScale * parent.reference.yScaleCombined

        // if either of the parent scales are negatice then flip the rotation.
        if parent.reference.xScaleCombined * parent.reference.yScaleCombined < 0.0 {
            self.reference.angle *= -1.0
        }
        
        // finally, scale the position with the parents combined scale.
        //
        self.reference.position.x *= parent.reference.xScaleCombined
        self.reference.position.y *= parent.reference.yScaleCombined
        
        // if this bone has no parent in the (SpriteKit) node tree, then add it to the specified
        // parent.
        //
        if self.parent == nil {
            self.prevReference = self.reference
                        
            parent.addChild(self)
        }
        
        // Now update the bone using the computed reference.
        //
        self.update(fromReference: self.reference)
    }
    
    /// Update the actual SKNode properties (`position` and `zRotation` only) from the specified reference SpriterBone
    /// - Parameter updateReference: the SpriterBone used to dictate position and rotation.
    func update(fromReference updateReference: SpriterBone) {
        self.position = updateReference.position
        
        self.zRotation = updateReference.angle

        #if DEBUG
        let endPoint : CGPoint = CGPoint.zero.pointOnCircle(withRadius: updateReference.size.width * updateReference.xScaleCombined,
                                                            atRadians: 0.0)

        if let bone = boneJoint.childNode(withName: BONE_VISUALISATION_NAME) {
            bone.removeFromParent()
        }
                        
        let boneVisualisation = SKShapeNode(rectOf: CGSize(width: updateReference.size.width * updateReference.xScaleCombined,
                                                           height: updateReference.size.height * updateReference.yScaleCombined),
                                                           cornerRadius: updateReference.size.height / 2.0 * updateReference.yScaleCombined)
        
        boneVisualisation.position = CGPoint.midpoint(betweenStart: .zero, andEnd: endPoint)
        boneVisualisation.fillColor = .white
        boneVisualisation.strokeColor = .clear
        boneVisualisation.zPosition = 5000.0
        boneVisualisation.alpha = BONE_ALPHA
        boneVisualisation.name = BONE_VISUALISATION_NAME

        boneJoint.addChild(boneVisualisation)
        #endif
    }
    
    /// Computes a tween from this nodes previous reference to it's current using the specified linear interpolation.
    /// - Parameter percent: the interpolation factor.
    /// - Returns: A tween from prevReference to reference.
    func tween(forPercent percent: CGFloat) -> SpriterBone {
        return prevReference.tween(to: reference, forPercent: percent)
    }
}
