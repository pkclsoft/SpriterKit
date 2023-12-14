//
//  GameSceneEvents.swift
//  SpriterKitDemo Shared
//
//  Created by Peter Easdown on 3/12/2023.
//

import SpriteKit
import SpriterKit

class GameSceneEvents: SKScene, SKSpriterEntityDelegate {
    
    var spriterData : SpriterData?
    
    var eventY : CGFloat = 0.0

    class func newGameSceneEvents() -> GameSceneEvents {
        // Load 'GameSceneEvents.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameSceneEvents") as? GameSceneEvents else {
            print("Failed to load GameSceneEvents.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    func entity(withID: Int, usingAnimationID: Int) -> SKSpriterEntity? {
        if let data = self.spriterData {
            return SKSpriterEntity(withEntityID: withID, usingAnimationID: usingAnimationID, inSpriterData: data)
        }
        
        return nil
    }
    
    func setUpScene() {
        if let parser = ScmlParser(fileName: "gunner_player_smaller_head.scml") {
            self.spriterData = parser.spriterData
        }
        
        if let testGreyGuy = entity(withID: 0, usingAnimationID: 1),
           let scene = self.scene {
            
            eventY = scene.size.height / 2.0 - 30.0

            // first off, find out roughly how big he is.
            let tggRect = testGreyGuy.calculateAccumulatedFrame()
            
            let ggSize = tggRect.size
            
            let numberAcross = CGFloat(2.0)
            let numberDown = CGFloat(1.0)

            // We want to fill most of the screen with him, say 10 x 6
            //
            let ggScale = (scene.size.height / numberDown) / ggSize.height
            
            let fullWidth = numberAcross * ggSize.width * ggScale
            let fullHeight = numberDown * ggSize.height * ggScale
            
            var animation = 0
            
            for x in 0 ..< Int(numberAcross) {
                for y in 0 ..< Int(numberDown) {
                    if let greyGuy = entity(withID: 0, usingAnimationID: animation) {
                        greyGuy.delegate = self
                        greyGuy.setScale(ggScale)
                        
                        greyGuy.position = CGPoint(x: CGFloat(x) * ggSize.width * ggScale + 0.5 * ggSize.width * ggScale - (fullWidth / 2.0),
                                                   y: CGFloat(y) * ggSize.height * ggScale + 0.5 * ggSize.height * ggScale - (fullHeight / 2.0) - scene.size.height/4.0)
                        greyGuy.name = "greyGuy"
                        
                        scene.addChild(greyGuy)
                    }
                }
                
                animation = animation + 1
                
                if animation > 1 {
                    animation = 0
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    // MARK: - SKSpriterEntityDelegate
    
    func entity(_ entity: SpriterKit.SKSpriterEntity, pointTriggeredAt position: CGPoint, withAngle angle: CGFloat) {
        let triggerDot = SKShapeNode(circleOfRadius: 10.0)
        triggerDot.fillColor = .red
        triggerDot.position = position
        triggerDot.alpha = 0.5
        self.addChild(triggerDot)
        
        let triggerAngle = SKShapeNode(circleOfRadius: 5.0)
        triggerAngle.fillColor = .yellow
        triggerAngle.position = position.pointOnCircle(withRadius: 7.5, atRadians: angle)
        triggerAngle.alpha = 0.5
        self.addChild(triggerAngle)
    }
    
    func entity(_ entity: SpriterKit.SKSpriterEntity, reachedEventWithName name: String) {
        if let scene = self.scene {
            let eventLabel = SKLabelNode(text: name)
            eventLabel.fontColor = .green
            eventLabel.position = CGPoint(x: entity.position.x, y: eventY)
            
            self.addChild(eventLabel)
            
            eventY -= 30.0
        }
    }

}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameSceneEvents {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameSceneEvents {

    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }

}
#endif

