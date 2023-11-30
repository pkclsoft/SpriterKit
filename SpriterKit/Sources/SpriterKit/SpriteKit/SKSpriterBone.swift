//
//  File.swift
//
//
//  Created by Peter Easdown on 2/11/2023.
//

import Foundation
import SpriteKit
import GLKit

public class SKSpriterBone : SKNode {
    
    var timelineID : Int
    var prevReference : SpriterBone
    var reference: SpriterBone
    var entityNode: SKNode
    
    #if DEBUG
    var showBones : Bool {
        didSet {
            self.boneJoint.isHidden = !showBones
        }
    }
    
    private let BONE_JOINT_NAME = "boneJoint"
    private let BONE_VISUALISATION_NAME = "boneShape"
    private let BONE_ALPHA = 0.5

    var boneJoint : SKShapeNode
    #endif
    
    init(withBone: SpriterBone, initialTimelineID: Int, inEntity entity: SKNode) {
        timelineID = initialTimelineID
        prevReference = withBone
        reference = withBone
        entityNode = entity
        
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
    
    func updated(bone: SpriterBone, withParent parent: SKSpriterBone) -> SpriterBone {
        var result = bone
        
        result.combinedScaleX = result.scaleX * parent.reference.combinedScaleX
        result.combinedScaleY = result.scaleY * parent.reference.combinedScaleY
        
        if parent.reference.combinedScaleX * parent.reference.combinedScaleY < 0.0 {
            result.angle *= -1.0
        }
        
        result.position.x *= parent.reference.combinedScaleX
        result.position.y *= parent.reference.combinedScaleY

        return result
    }
    
    func update(withParent parent: SKSpriterBone) {
        self.reference = updated(bone: self.reference, withParent: parent)
        
        if self.parent == nil {
            self.prevReference = self.reference
                        
            parent.addChild(self)
        }
        
        self.update(fromReference: self.reference)
    }
    
    func update(fromReference updateReference: SpriterBone) {
        self.position = updateReference.position
        
        self.zRotation = updateReference.angle

        #if DEBUG
        let endPoint : CGPoint = CGPoint.zero.pointOnCircle(withRadius: updateReference.size.width * updateReference.combinedScaleX,
                                                            atRadians: 0.0)

        if let bone = boneJoint.childNode(withName: BONE_VISUALISATION_NAME) {
            bone.removeFromParent()
        }
                        
        let boneVisualisation = SKShapeNode(rectOf: CGSize(width: updateReference.size.width * updateReference.combinedScaleX,
                                                           height: updateReference.size.height * updateReference.combinedScaleY),
                                                           cornerRadius: updateReference.size.height / 2.0 * updateReference.combinedScaleY)
        
        boneVisualisation.position = CGPoint.midpoint(betweenStart: .zero, andEnd: endPoint)
        boneVisualisation.fillColor = .white
        boneVisualisation.strokeColor = .clear
        boneVisualisation.zPosition = 5000.0
        boneVisualisation.alpha = BONE_ALPHA
        boneVisualisation.name = BONE_VISUALISATION_NAME

        boneJoint.addChild(boneVisualisation)
        #endif
    }

    func tween(forPercent percent: CGFloat) -> SpriterBone {
        return prevReference.tween(to: reference, forPercent: percent)
    }
}
