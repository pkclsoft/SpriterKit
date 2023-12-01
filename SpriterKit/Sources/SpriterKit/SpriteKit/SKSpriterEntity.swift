//
//  File.swift
//
//
//  Created by Peter Easdown on 30/10/2023.
//

import Foundation
import SpriteKit

/// An entity is essentailly one or more sprites that can be joined and connected by bones.  Each bone and each sprite can be
/// animated independently within the entity via a collection of fields that specify the bone/sprites current position, scale, rotation, and alpha.
///
/// These fields are provided via `SpriterTimelineKey` instances, and these are reached via an animation on the entity.
///
/// So to animate the entity, it must first be constructed as a hierarchy of `SKNode` and `SKSpriteNode` objects, where `SKNode` represents a
/// bone, and `SKSpriteNode` represents a sprite.
///
/// The hierarchy is determined by first traversing the list of `SpriterBoneRef` in an animation to build a skeleton of bones.  The sprites then flesh
/// out the skeleton as they are added to the bones that define their parents.
///
/// With the body of the entity created, the initial state of it's parts can be assigned by extracting from the model, the attributes of each node from the
/// `SpriterBone`s and `SpriterObject`s.
///
/// From there, to animate the entity, the model can be traversed to determine the sequence of keys for each bone and sprite that define their changing
/// fields over time, and  `SKAction`s can be added to the respective nodes to execute those animations.
///
public class SKSpriterEntity : SKNode {
    
    enum EventTarget {
        case bone
        case object
    }
    
    /// The loaded model (from SCML or SCON file)
    var model : SpriterData
    
    /// The model data specific to this entity.
    ///
    var entity : SpriterEntity?
    
    /// The animation data in play.
    ///
    var animation : SpriterAnimation?
    
    /// Each time a frame is started, this is populated with all of the object names that are active for the
    /// frame.  when the next frame starts, it is reset to all false, and then as each object is updated, the
    /// individual flags are set to `true`.  At the end of that loop, if any are still `false` then the nodes
    /// with matching names are removed from the node tree.
    ///
    var activeObject : [String : Bool] = [:]
    
    /// An array of the times for each  mainline key in the animation.
    ///
    var keyTimes : [TimeInterval]?
    
    /// The index into `keyTimes` of the time we are starting from right now.
    ///
    var keyIndex : Int = 0
    
    /// Has the entity been initialised yet?  If not then the first frame will take 0 milliseconds.
    ///
    var initialised : Bool = false
    
    /// This is used to slow down the animation during debugging.
    ///
    let debugTimeFactor = 1.0
    
    /// A label with which to add debug info during the animation.
    ///
    var debugLabel : SKLabelNode = SKLabelNode(text: "0.0")
    
    /// The time at which the last key frame began.
    ///
    var debugTime : TimeInterval = .zero
    
    /// If  `true`, then bones are shown as well.
    ///
    public var showBones : Bool = true
    
    /// Set to true to enable tweened animations.
    ///
    var animate : Bool = true
    
    /// Returns a string used to name a node.  Use this for all nodes to be added to the tree so that
    /// searches will return consistent results.
    /// - Parameters:
    ///   - id: the id associated with the node
    ///   - target: the node type (bone or object)
    /// - Returns: A node name.
    static func nodeName(forID id: Int, andTarget target: EventTarget) -> String {
        return "\(target)_\(id)"
    }
    
    // This will be the root node of the tree, and act as the container for the rest of the nodes.
    //
    var nodeTree : SKNode = SKNode()
    
    /// Initialises a new `SKSpriterEntity` for display on the screen, with the specified animation ready to start as soon as the
    /// entity is added to the scene node tree.
    /// - Parameters:
    ///   - entityID: The ID of the entity inside the model.
    ///   - animationID: The ID of the animation to play.
    ///   - spriterData: The model from which to obtain the entity.
    public init(withEntityID entityID: Int, usingAnimationID animationID: Int, inSpriterData spriterData: SpriterData) {
        
        self.model = spriterData
        
        super.init()
        
        self.addChild(nodeTree)
        
        // This is just a debug tool to show the centre of the root node of the entity.
        // Some spriter models are not centred.
        let circle = SKShapeNode(circleOfRadius: 50.0)
        circle.strokeColor = .clear
        circle.fillColor = .red
        circle.alpha = 0.25
        circle.zPosition = 5000.0
        nodeTree.addChild(circle)
        
        // place the debug label down the bottom.
        debugLabel.fontColor = .yellow
        debugLabel.fontSize = 60.0
        debugLabel.position = CGPoint(x: 0.0, y: -900.0)
        debugLabel.zPosition = 10000.0
        
        nodeTree.addChild(debugLabel)
        
        // reduce the size for now whilst we debug.
        //
        nodeTree.setScale(0.25)
        
        // find the entity and start the specified animation.
        if let entity = spriterData.entity(withEntityID: entityID) {
            self.entity = entity
            
            self.startAnimation(withID: animationID)
        }
    }
    
    // MARK: - Bone Node Hierarchy Manipulation
    
    // This structure is here to support those (hopefully) rare situations where a bone is added or removed
    // from the hierarchy within at the start of a frame.  For whatever reason, Spriter does not keep the
    // bone IDs consistent across the entire animation, and it becomes difficult to keep the node tree intact.
    //
    var timelinePerBone : [Int : Int] = [:]
    
    // MARK: - Animation engine
    
    /// Finds and starts the specified animation for the entity.
    /// - Parameter id: the animation ID
    func startAnimation(withID id: Int) {
        if let entity = self.entity,
           let animation = entity.animation(withID: id) {
            
            // Having found the animation, save it.
            self.animation = animation
            
            // Now traverse the mainline, adding nodes to the `nodeTree`, respecting the hierarchy defined there.
            //
            if let mainline = animation.mainline {
                // grab the key times.
                self.keyTimes = mainline.keyTimes()
                
                // start with the first key.
                self.keyIndex = 0
                
                // initialise the animation timer.
                self.debugTime = Date.timeIntervalSinceReferenceDate
                
                // kick off the animation.
                self.updateToNextKey()
            }
        }
    }
    
    /// Returns the index of the next key time in the `keyTimes` array, wrapping around when the end is reached.
    /// - Returns: An `Int` index into `keyTimes`.
    func nextKeyIndex() -> Int {
        if let times = self.keyTimes,
           self.keyIndex < times.count-1 {
            return self.keyIndex + 1
        } else {
            return 0
        }
    }
    
    /// Returns the duration to the next key frame using `self.keyIndex` to reference the
    /// current key frame.
    /// - Returns: A `TimeInterval` representing the interval in milliseconds to the next key frame.
    func nextDuration() -> TimeInterval {
        if let times = self.keyTimes {
            return duration(followingTime: times[self.keyIndex])
        } else {
            return 0.0
        }
    }
    
    /// Returns the duration to the key frame that follows the specified key frame time.
    /// - Parameter prevTime: the TimeInterval represnting the time at which the duration would commence.
    /// - Returns: A `TimeInterval` representing the interval in milliseconds to the next key frame.
    func duration(followingTime prevTime: TimeInterval) -> TimeInterval {
        if let times = self.keyTimes {
            let nextIndex = self.nextKeyIndex()
            
            if nextIndex == 0 {
                if let animation = self.animation {
                    return animation.interval
                } else {
                    return times[nextIndex + 1]
                }
            } else {
                return (times[nextIndex] - prevTime)
            }
        } else {
            return 0.0
        }
    }
    
    /// A simple utility for formatting floating point numbers for debugging.
    /// - Parameters:
    ///   - of: the number to be formatted
    ///   - digits: the number of digits to follow the decimal point.
    /// - Returns: A `String` representation of the input `CGFloat`.
    func numStr(of: CGFloat, digits: Int = 3) -> String {
        return String(format: "%03.\(digits)f", of)
    }
    
    func traceNodeTree(startingWith: String) {
        if let existingNode = self.nodeTree.childNode(withName: ".//\(startingWith)") as? SKSpriterBone {
            print("\(existingNode.name!):  \(existingNode.reference)")
            
            existingNode.children.forEach { child in
                if let bone = child as? SKSpriterBone {
                    traceNodeTree(startingWith: bone.name!)
                } else if let object = child as? SKSpriterObject {
                    print("\(child.name!):  \(object.reference)")
                }
            }
        }
    }
    
    /// This is the guts of the animation mechanism.  It traverses the model for the animation of the entity, and for the initial frame, creates
    /// the nodes that represent the bones and objects in the model.  Successive frames result in animatiion sequences that tween the
    /// entity from one frame to the next, following the instructions in the model.
    func updateToNextKey() {
        if let animation = self.animation,
           let mainline = animation.mainline {
            let mainlineKeyTime = self.keyTimes![self.keyIndex]
            let key = mainline.key(forTimeInterval: mainlineKeyTime)
            
            // determine the duration of this frame.
            let duration : TimeInterval
            
            // if this is the first time, then it needs to be instantaneous.
            if !initialised {
                duration = 0.0
                initialised = true
            } else {
                duration = nextDuration()  * debugTimeFactor
            }
            
            self.debugLabel.text = "frame time: \(numStr(of: key.time))"
            
            // Now traverse all of the bone references and build up the node tree representing the bones.
            //
            key.boneRefs.forEach { boneRef in
                if let animation = self.animation {
                    do {
                        var boneNode : SKSpriterBone
                        let newNode : Bool
                        
                        // for this bone, find the mapped timeline.
                        let keyFrame = try animation.key(inTimeLineWithID: boneRef.timelineID, andKey: boneRef.keyID, newTime: key.time)
                        
                        // assuming we found one...
                        if let bone = keyFrame.bone {
                            // see if the node already exists in the tree.
                            let boneName = SKSpriterEntity.nodeName(forID: boneRef.timelineID, andTarget: .bone)
                            
                            if let existingNode = self.nodeTree.childNode(withName: ".//\(boneName)") as? SKSpriterBone {
                                boneNode = existingNode
                                
                                if existingNode.timelineID == boneRef.timelineID {
                                    // it does so preserve the previous frame reference as prevReference, and initialise the new
                                    // reference from this timelineKey
                                    //
                                    boneNode.prevReference = boneNode.reference
                                    boneNode.reference = bone
                                }
                                
                                newNode = false
                            } else {
                                // not in the tree so create it anew.
                                //
                                boneNode = SKSpriterBone(withBone: bone, initialTimelineID: boneRef.timelineID)
                                boneNode.name = boneName
                                newNode = true
                                
                                if timelinePerBone[boneRef.id] == nil {
                                    timelinePerBone[boneRef.id] = boneRef.timelineID
                                }
                            }
                            
                            #if DEBUG
                            boneNode.showBones = self.showBones
                            #endif
                            
                            // if the parent exists already (which it should if there is a parent)...
                            if boneRef.parentID != NO_PARENT {
                                if let parent = boneNode.parent as? SKSpriterBone {
                                    // update the bone using information from the parent bone.
                                    //
                                    boneNode.update(withParent: parent)
                                } else {
                                    // get the name of the bones parent (if any).
                                    if let parentTimelineID = timelinePerBone[boneRef.parentID] {
                                        let parentName = SKSpriterEntity.nodeName(forID: parentTimelineID, andTarget: .bone)
                                        
                                        if let parent = nodeTree.childNode(withName: ".//\(parentName)") as? SKSpriterBone {
                                            // update the bone using information from the parent bone.
                                            //
                                            boneNode.update(withParent: parent)
                                        }
                                    }
                                }
                                
                            } else if boneRef.parentID == NO_PARENT {
                                // the bone is a top level bone, so add it to the tree.
                                //
                                if newNode {
                                    nodeTree.addChild(boneNode)
                                }
                                
                                // update it to reflect it's reference data.
                                //
                                boneNode.update(fromReference: boneNode.reference)
                            }
                            
                            // This is where, for this bone, we animate the current frame.
                            //
                            if self.animate {
                                boneNode.run(.customAction(withDuration: duration, actionBlock: { node, elapsed in
                                    let percent = elapsed / duration
                                    
                                    if let bone = node as? SKSpriterBone {
                                        let tween = bone.tween(forPercent: percent)
                                        
                                        bone.update(fromReference: tween)
                                    }
                                }))
                            }
                        }
                    } catch {
                        // this should not be possible.
                    }
                }
            }
            
            // by the time we get here, all of the bones should have been updated.
            //
            
            // Now, iterate through the objects, and add those to the node tree as appropriate.  It's also important to note
            // that some objects can end up being removed from the node tree for a frame.  So we need to track this too.
            //
            // start by resetting the active flag for each object that has previously been added.
            //
            activeObject.keys.forEach { key in
                activeObject[key] = false
            }
            
            key.objectRefs.forEach { objectRef in
                // the ID for an object needs to be unique and consistent for the entire life of an animation.  The objectRef.id is
                // no good for this, as Spriter plays with the order and numbering when objects change z_index and/or sprite asset.
                //
                // So from what I can see, the easiest way to uniquely identify an object consistently for an entire animation is
                // to use the parentID and timelineID.  Below we combine these to form a hash that gives us what we need.
                //
                let objectName = SKSpriterEntity.nodeName(forID: objectRef.timelineID, andTarget: .object)
                
                activeObject[objectName] = true
                
                if let animation = self.animation {
                    do {
                        let timelineKey = try animation.key(inTimeLineWithID: objectRef.timelineID, andKey: objectRef.keyID, newTime: key.time)
                        
                        if var object = timelineKey.object {
                            object.zIndex = objectRef.zIndex
                            
                            var sprite : SKSpriterObject
                            
                            // if the node already exists...
                            if let spriteInTree = self.nodeTree.childNode(withName: ".//\(objectName)") as? SKSpriterObject {
                                sprite = spriteInTree
                                
                                // it does so preserve the previous frame reference as prevReference, and initialise the new
                                // reference from this timelineKey
                                //
                                sprite.prevReference = sprite.reference
                                sprite.reference = object
                            } else {
                                sprite = SKSpriterObject(forSpriterObject: object, usingSpriterModel: self.model, andName: objectName)
                            }
                            
                            if objectRef.parentID != NO_PARENT {
                                // now see if there is a parent (objects should always have bone as a parent...)
                                //
                                if let parent = sprite.parent as? SKSpriterBone {
                                    // the sprite is already in the node tree.  save time by not having to search...
                                    
                                    // update the object using parameters from the parent...
                                    //
                                    sprite.update(withParent: parent)
                                } else {
                                    if let parentTimelineID = timelinePerBone[objectRef.parentID] {
                                        let parentName = SKSpriterEntity.nodeName(forID: parentTimelineID, andTarget: .bone)
                                        
                                        if let parent = nodeTree.childNode(withName: ".//\(parentName)") as? SKSpriterBone {
                                            // found the parent...
                                            
                                            // update the object using parameters from the parent...
                                            //
                                            sprite.update(withParent: parent)
                                        }
                                    }
                                }
                            } else {
                                // The object has no parent bone, so it becomes a child of the root node.
                                //
                                sprite.update(fromReference: sprite.reference)
                                
                                if sprite.parent == nil {
                                    self.nodeTree.addChild(sprite)
                                }
                            }
                            
                            // This is where, for this object, we animate the current frame.
                            //
                            if self.animate {
                                sprite.run(.customAction(withDuration: duration, actionBlock: { node, elapsed in
                                    let percent = elapsed / duration
                                    
                                    if let sprite = node as? SKSpriterObject {
                                        let tween = sprite.tween(forPercent: percent)
                                        
                                        sprite.update(fromReference: tween)
                                    }
                                }))
                            }
                        }
                    } catch {
                        print("this should not be possible")
                    }
                    
                }
            }
            
            // now if there are any objects listed in activeObjects that have their flag set to
            // false, remove them.
            //
            var toRemove : [String] = []
            
            activeObject.keys.forEach { key in
                if let active = activeObject[key],
                   !active {
                    if let sprite = nodeTree.childNode(withName: ".//\(key)") as? SKSpriterObject {
                        sprite.removeFromParent()
                        toRemove.append(key)
                    }
                }
            }
            
            toRemove.forEach { key in
                activeObject.removeValue(forKey: key)
            }
            
            //            self.traceNodeTree(startingWith: "bone_9")
            
            // this is the overall animation "manager".  All it does is wait for the duration of the current
            // key frame, increment the index, and then start the next key frame animation.
            //
            if self.animate {
                self.run(.sequence([
                    // this is all that we need
                    //                .wait(forDuration: duration)
                    // but whilst we debug, this gives us timing on screen...
                    .customAction(withDuration: duration, actionBlock: { node, elapsed in
                        let animationTime = (Date.timeIntervalSinceReferenceDate - self.debugTime) / self.debugTimeFactor * 1000.0
                        
                        let inFrameTime = elapsed / self.debugTimeFactor * 1000.0
                        
                        self.debugLabel.text = "frame: \(self.numStr(of: inFrameTime)), animation: \(self.numStr(of: animationTime))"
                    }),
                    .run {
                        self.keyIndex = self.nextKeyIndex()
                        
                        if self.keyIndex == 0 {
                            if let animation = self.animation,
                               animation.isLooping {
                                self.debugTime = Date.timeIntervalSinceReferenceDate
                                
                                self.updateToNextKey()
                            }
                        } else {
                            self.updateToNextKey()
                        }
                    }
                ]))
            }
        }
    }
    
    public func showNextKeyFrame() {
        self.keyIndex = self.nextKeyIndex()
        
        if self.keyIndex == 0 {
            self.debugTime = Date.timeIntervalSinceReferenceDate
        }
        
        self.updateToNextKey()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
