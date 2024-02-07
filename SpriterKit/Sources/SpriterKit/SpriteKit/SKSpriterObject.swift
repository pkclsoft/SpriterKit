//
//  SKSpriterObject.swift
//
//
//  Created by Peter Easdown on 2/11/2023.
//

import Foundation
import SpriteKit

/// A `SpriteKit` node that provides a visual sprite representation of a Spriter Object.  Being a `SKSpriteNode` subclass, it
/// can be inserted into the node tree, as a child of the `SKSpriterBone` that is it's parent, both in the Spriter project and
/// within the SpriteKit node hierarchy.
///
/// Like `SKSpriterBone`,  `SKSpriterObject` uses the functions and features of SpriteKit to achieve a lot
/// of the math required to move it on the screen.  Unlike a bone however, instances of this class make use of the
/// scale, zPosition, alpha in addition to the position and rotation.
///
/// Objects are adjusted by information from the parent `SKSpriterBone` via a call to `update(withParent)`.
///
/// Like `SKSpriterBone`, a `SKSpriterObject`  maintains two internal SpriterBone objects that provide the previous
/// and current keyframe data.
///
///
public class SKSpriterObject : SKSpriteNode {
    
    /// The entire model from the Spriter project so that changes to the object file (sprite) can be picked up as needed.
    var spriterModel : SpriterData
    
    /// The previous SpriterObject
    var prevReference: SpriterObject
    
    /// The SpriterObject for the current key frame
    var reference: SpriterObject
    
    /// An override value for the zPosition of the objects parent.  Normally, a SpriterObject uses the zPosition of it's
    /// parent node to manage it's own zPosiiton relative to other nodes.  This property may be used via the
    /// `zIndexOverride` property of the SKSpriterEntity to supplant the parents zPosition.
    var zPositionOverride : CGFloat? = nil
    
    /// Initialises a new SKSpriterObject, and prepares it for initial use.
    /// - Parameters:
    ///   - spriterObj: The SpriterObject use to se tthe initial state of the object.
    ///   - model: The Spriter project model so that the object can access files for loading sprite assets.
    ///   - name: The name of the object, which is used for searching the node tree.
    init(forSpriterObject spriterObj: SpriterObject, usingSpriterModel model: SpriterData, andName name: String) {
        spriterModel = model
        prevReference = spriterObj
        reference = spriterObj
        
        super.init(texture: nil, color: .clear, size: .zero)
        
        self.name = name
        
        // force the texture to be initialised the first time.
        self.changeTexture(using: self.reference)

        self.update(fromReference: self.reference)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates this nodes reference with instructions from the specified parent bone.
    /// - Parameter parent: the parent bone.
    func update(withParent parent: SKSpriterBone) {
        // Apply the parents combined scale so that this object respects the overall
        // scale of the project.
        self.reference.xScale *= parent.reference.xScaleCombined
        self.reference.yScale *= parent.reference.yScaleCombined
        
        // Scale the position with the parents combined scale.
        self.reference.position.x *= parent.reference.xScaleCombined
        self.reference.position.y *= parent.reference.yScaleCombined
        
        // if either of the parent scales are negatice then flip the rotation.
        if parent.reference.xScaleCombined * parent.reference.yScaleCombined < 0.0 {
            self.reference.angle *= -1.0
        }

        // if this object has no parent in the (SpriteKit) node tree, then add it to the specified
        // parent.
        //
        if self.parent == nil {
            self.prevReference = self.reference

            parent.addChild(self)
        }
        
        // Now update the object using the computed reference.
        //
        self.update(fromReference: self.reference)
    }
    
    /// Update the actual SKSpriteNode properties from the specified reference SpriterObject.
    /// - Parameter updateReference: the SpriterObject used to dictate all visual aspects of the object.
    func update(fromReference updateReference: SpriterObject) {
        // if the next frame is using a new texture, then change to it.
        if updateReference.folderID != prevReference.folderID ||
            updateReference.fileID != prevReference.fileID {
            self.changeTexture(using: reference)
        }
        
        self.position = updateReference.position

        self.xScale = updateReference.xScale

        self.yScale = updateReference.yScale

        self.zRotation = updateReference.angle
        
        self.alpha = updateReference.alpha
        
        if let newZ = updateReference.zIndex {
            // Because SpriteKit apps quite often optimize performance by using the ignoresSiblingOrder
            // property on the SKView, the zIndex needs to be turned into a fraction and added to
            // the zPosition of the parents so that the Spriter animation fits in with the rest of
            // the SpriteKit presentation.
            //
            let relativeZPosition = CGFloat(newZ) / 1000.0
            let zPositionBase : CGFloat
            
            if let override = self.zPositionOverride {
                zPositionBase = override
            } else if let parent = self.parent {
                zPositionBase = parent.zPosition
            } else {
                // if there is no parent, then just ensure that the components of this entity respect
                // the zIndex.
                //
                zPositionBase = 0.0
            }
            
            self.zPosition = zPositionBase + relativeZPosition
        }
    }
    
    /// Load the sprite texture using the folder/file IDs specified in the input SpriterObject.
    /// - Parameter reference: The spriter object specifying the visualisation of the object.
    func changeTexture(using reference: SpriterObject) {
        if let folderID = reference.folderID,
           let fileID = reference.fileID,
           let folder = self.spriterModel.folder(withFolderID: folderID),
           let file = folder.file(withID: fileID) {
            if let modelTexture = folder.texture(ofObject: reference, fromBundle: self.spriterModel.resourceBundle) {
                self.texture = modelTexture
                self.size = file.size
                
                self.anchorPoint = reference.pivot
            } else {
                print("WARNING: Unable to find texture for: \(self.name!)")
            }
        }
    }
    
    /// Computes a tween from this nodes previous reference to it's current using the specified linear interpolation.
    /// - Parameter percent: the interpolation factor.
    /// - Returns: A tween from prevReference to reference.
    func tween(forPercent percent: CGFloat) -> SpriterObject {
        return prevReference.tween(to: self.reference, forPercent: percent)
    }

}
