//
//  GameScene.swift
//  SpriterKitDemo Shared
//
//  Created by Peter Easdown on 3/12/2023.
//

import SpriteKit
import SpriterKit

class GameScene: SKScene {
    
    var spriterData : SpriterData?
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
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
        if let parser = ScmlParser(fileName: "GreyGuy.scml") {
            self.spriterData = parser.spriterData
        }
        
        if let testGreyGuy = entity(withID: 0, usingAnimationID: 1),
           let scene = self.scene {
            
            // first off, find out roughly how big he is.
            let tggRect = testGreyGuy.calculateAccumulatedFrame()
            
            let ggSize = tggRect.size
            
            let numberAcross = CGFloat(10.0)
            let numberDown = CGFloat(6.0)

            // We want to fill most of the screen with him, say 10 x 6
            //
            let ggScale = (scene.size.height / numberDown) / ggSize.height
            
            let fullWidth = numberAcross * ggSize.width * ggScale
            let fullHeight = numberDown * ggSize.height * ggScale
            
            for x in 0 ..< Int(numberAcross) {
                for y in 0 ..< Int(numberDown) {
                    if let greyGuy = entity(withID: 0, usingAnimationID: 1) {
                        greyGuy.setScale(ggScale)
                        
                        greyGuy.position = CGPoint(x: CGFloat(x) * ggSize.width * ggScale + 0.5 * ggSize.width * ggScale - (fullWidth / 2.0),
                                                   y: CGFloat(y) * ggSize.height * ggScale + 0.5 * ggSize.height * ggScale - (fullHeight / 2.0))
                        greyGuy.name = "greyGuy"
                        
                        scene.addChild(greyGuy)
                    }
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
    
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

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
extension GameScene {

    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }

}
#endif

