//
//  File.swift
//  
//
//  Created by Peter Easdown on 2/11/2023.
//

import Foundation
import SpriteKit

public class SKSpriterObject : SKSpriteNode {
    
    var spriterModel : SpriterData
    var prevReference: SpriterObject
    var reference: SpriterObject

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
    
    func update(withParent parent: SKSpriterBone) {
        self.reference.xScale *= parent.reference.xScaleCombined
        self.reference.yScale *= parent.reference.yScaleCombined
        self.reference.position.x *= parent.reference.xScaleCombined
        self.reference.position.y *= parent.reference.yScaleCombined
        
        if parent.reference.xScaleCombined * parent.reference.yScaleCombined < 0.0 {
            self.reference.angle *= -1.0
        }

        if self.parent == nil {
            self.prevReference = self.reference

            parent.addChild(self)
        }
        
        self.update(fromReference: self.reference)
    }
    
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
            self.zPosition = CGFloat(newZ)
        }
    }

    func changeTexture(using reference: SpriterObject) {
        if let folder = self.spriterModel.folder(withFolderID: reference.folderID),
           let file = folder.file(withID: reference.fileID) {
            if let modelTexture = folder.texture(ofObject: reference) {
                self.texture = modelTexture
                self.size = file.size
                
                self.anchorPoint = reference.pivot
            } else {
                print("unable to find texture for: \(self.name!)")
            }
        }
    }
    
    func tween(forPercent percent: CGFloat) -> SpriterObject {
        return prevReference.tween(to: self.reference, forPercent: percent)
    }

}
