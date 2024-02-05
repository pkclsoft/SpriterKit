//
//  File.swift
//
//
//  Created by Peter Easdown on 30/10/2023.
//

import Foundation
import SpriteKit

/// An entity is essentailly one or more sprites that can be joined and connected by bones.  Each bone and each sprite (object) can be
/// animated independently within the entity via a collection of fields that specify the bone/sprites current position, scale, rotation, and alpha.
///
/// These fields are provided via `SpriterTimelineKey` instances, and these are reached via an animation on the entity.
///
/// So to animate the entity, it must first be constructed as a hierarchy of `SKNode` and `SKSpriteNode` objects, where `SKSpriterBone` represents a
/// bone, and `SKSpriterObject` represents a sprite.
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
    
    /// This simple enumeration provides a convenient mechanism to assist with naming nodes in the SpriteKit node tree.
    enum SpriterNodeType {
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
    
    /// This delegate can be used by the application to monitor events that occur during the animation o the entity.
    public var delegate : SKSpriterEntityDelegate?
    
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
    
    /// This structure is here to support those (hopefully) rare situations where a bone is added or removed
    /// from the hierarchy within at the start of a frame.  For whatever reason, Spriter does not keep the
    /// bone IDs consistent across the entire animation, and it becomes difficult to keep the node tree intact.
    ///
    /// So when bones are first created (normally in the zeroth frame), their timelines are stored in this dictionary.
    /// Timeline IDs remain consistent across the animation for a given bone, even when their bone IDs do not.
    ///
    /// So storing the timeline ID like this allows bones and objects which only know their parents by bone ID, to
    /// lookup the timeline of the bone using the parent ID (which is a bone ID), to reference the correct bone.
    ///
    var timelinePerBone : [Int : Int] = [:]
    
    /// Has the entity been initialised yet?  If not then the first frame will take 0 milliseconds.
    ///
    var initialised : Bool = false
    
    /// This becomes a store of all of the bones in the current animation.  It is used as a fast lookup for successive
    /// frames.
    var bones : [String: SKSpriterBone] = [:]

    /// This becomes a store of all of the objects in the current animation.  It is used as a fast lookup for successive
    /// frames.
    var objects : [String: SKSpriterObject] = [:]

    /// Set to true to enable tweened animations.
    ///
    var animate : Bool = true
    
    /// Set to true to enable tweening between frames.
    ///
    var tweenFrames : Bool = true
    
#if DEBUG
    /// This can be used to slow down the animation during debugging.  A larger number means a slower animation.
    ///
    public let debugTimeFactor = 1.0
    
    /// If true then a text label showing timing information is added to the node tree.
    ///
    public var showDebugLabel : Bool = false
    
    /// A label with which to add debug info during the animation.
    ///
    var debugLabel : SKLabelNode = SKLabelNode(text: "0.0")
    
    /// The time at which the last key frame began.
    ///
    var debugTime : TimeInterval = .zero
    
    /// If  `true`, then bones are shown as well.  It is worth noting that with this set to true, there is a significant
    /// performance impact.
    ///
    public var showBones : Bool = false
#endif
    
    /// Returns a string used to name a node.  Use this for all nodes to be added to the tree so that
    /// searches will return consistent results.
    /// - Parameters:
    ///   - id: the id associated with the node
    ///   - target: the node type (bone or object)
    /// - Returns: A node name.
    static func nodeName(forID id: Int, andTarget target: SpriterNodeType) -> String {
        return "\(target)_\(id)"
    }
    
    /// This will be the root node of the tree, and act as the container for the rest of the nodes.
    ///
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
        
#if DEBUG
        // place the debug label down the bottom.
        if showDebugLabel {
            debugLabel.fontColor = .yellow
            debugLabel.fontSize = 60.0
            debugLabel.position = CGPoint(x: 0.0, y: -300.0)
            debugLabel.zPosition = 10000.0
            
            nodeTree.addChild(debugLabel)
        }
#endif
        
        // find the entity and start the specified animation.
        if let entity = spriterData.entity(withEntityID: entityID) {
            self.entity = entity
            
            self.startAnimation(withID: animationID)
        }
    }
    
    // MARK: - Animation engine
    
    /// Finds and starts the specified animation for the entity.
    /// - Parameter id: the animation ID
    public func startAnimation(withID id: Int) {
        if let entity = self.entity,
           let animation = entity.animation(withID: id) {
            
            // Having found the animation, save it.
            self.animation = animation
            
            // Now grab the mainline, and kick things off.
            //
            if let mainline = animation.mainline {
                // grab the key times for the mainline.
                self.keyTimes = mainline.keyTimes()
                
                // start with the first key.
                self.keyIndex = 0
                
#if DEBUG
                // initialise the animation timer.
                self.debugTime = Date.timeIntervalSinceReferenceDate
#endif
                
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
            // this should never happen.
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
    
#if DEBUG
    /// A simple utility for formatting floating point numbers for debugging.
    /// - Parameters:
    ///   - of: the number to be formatted
    ///   - digits: the number of digits to follow the decimal point.
    /// - Returns: A `String` representation of the input `CGFloat`.
    func numStr(of: CGFloat, digits: Int = 3) -> String {
        return String(format: "%03.\(digits)f", of)
    }
    
    /// Useful method of dumping details about all of the Spriter nodes in the node tree starting at a specific node (by name).
    /// - Parameter startingWith: the name of the node at the top of the tree to be traced.
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
#endif
    
    /// This is the guts of the animation mechanism.  It traverses the model for the animation of the entity, building out (for the initial frame) and updating
    /// (for successive frames) the SpriteKit node tree representation of the Spriter project.  Successive frames result in animatiion sequences that tween the
    /// entity from one frame to the next, following the instructions in the model.
    func updateToNextKey() {
        if let animation = self.animation,
           let mainline = animation.mainline {
            let mainlineKeyTime = self.keyTimes![self.keyIndex]
            
            // Get the mainline key which contains all of the bone and object references.
            let key = mainline.key(forTimeInterval: mainlineKeyTime)
            
            // determine the duration of this frame.
            var duration : TimeInterval
            
            // if this is the first time, then it needs to be instantaneous.
            if !initialised {
                duration = 0.0
                initialised = true
            } else {
                duration = nextDuration()
            }
            
#if DEBUG
            duration *= debugTimeFactor
            self.debugLabel.text = "frame time: \(numStr(of: key.time))"
#endif
            
            // Now traverse all of the bone references and build up or update the node tree representing the bones.
            //
            key.boneRefs.forEach { boneRef in
                do {
                    var boneNode : SKSpriterBone
                    let newNode : Bool
                    
                    // for this bone, find the mapped timeline.
                    let keyFrame = try animation.key(inTimeLineWithID: boneRef.timelineID, andKey: boneRef.keyID, newTime: key.time)
                    
                    // assuming we found one...
                    if let bone = keyFrame.bone {
                        // see if the node already exists in the tree.
                        let boneName = SKSpriterEntity.nodeName(forID: boneRef.timelineID, andTarget: .bone)
                        
                        // Doing a search by name for the bone.  (this may need to be optimised)
                        //
                        if let existingNode = bones[boneName] {
                            boneNode = existingNode
                            
                            // does this bone use the same timeline ID as it has in the past?  It should.  SpriterKit doesn't yet
                            // handle bones that get inserted mid-animation that steal bone IDs.
                            //
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
                            
                            // Store the timeline ID for this bone (if this is the first bone to exist with the specified
                            // bone ID.
                            //
                            if timelinePerBone[boneRef.id] == nil {
                                timelinePerBone[boneRef.id] = boneRef.timelineID
                            }
                            
                            // New bones need to be added to the store for later retrieval.
                            //
                            bones[boneName] = boneNode
                        }
                        
#if DEBUG
                        boneNode.showBones = self.showBones
#endif
                        
                        // does the bone have a parent?
                        if boneRef.parentID != NO_PARENT {
                            // if the parent exists already (which it should if there is a parent)...
                            if let parent = boneNode.parent as? SKSpriterBone {
                                // update the bone using information from the parent bone.
                                //
                                boneNode.update(withParent: parent)
                            } else {
                                // get the name of the bones parent (if any).
                                if let parentTimelineID = timelinePerBone[boneRef.parentID] {
                                    let parentName = SKSpriterEntity.nodeName(forID: parentTimelineID, andTarget: .bone)
                                    
                                    if let parent = bones[parentName] {
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
                        if self.animate && self.tweenFrames {
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
                    print("ERROR: Unable to locate bone key for timeline with ID: \(boneRef.timelineID), andKey: \(boneRef.keyID)")
                }
            }
                                    
            // by the time we get here, all of the bones should have been updated (and their SKActions kicked into gear).
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
                // to use the timelineID.
                //
                let objectName = SKSpriterEntity.nodeName(forID: objectRef.timelineID, andTarget: .object)
                
                var objectIsPoint : Bool = false
                
                if let timeline = animation.timeline(forTimeLineID: objectRef.timelineID) {
                    if timeline.objectType == .point {
                        objectIsPoint = true
                    }
                }
                                
                // flag the object as active for this frame.
                activeObject[objectName] = true
                
                do {
                    // for this object, find the mapped timeline.
                    let timelineKey = try animation.key(inTimeLineWithID: objectRef.timelineID, andKey: objectRef.keyID, newTime: key.time)
                    
                    if var object = timelineKey.object {
                        // update the zIndex in the object from the reference.
                        object.zIndex = objectRef.zIndex
                        
                        // if the object is actually a trigger point, then there is nothing to animate.  Inform the delegate (if there
                        // is one) of the point and angle for the point.
                        //
                        if objectIsPoint {
                            if let del = self.delegate,
                               let parent = self.parent,
                               timelineKey.time == mainlineKeyTime {
                                // to make the position useful to the delegate, convert it to be a position in the
                                // parents coordinate space.
                                //
                                let parentPos = parent.convert(object.position, from: self)
                                
                                del.entity(self, pointTriggeredAt: parentPos, withAngle:object.angle)
                            }
                        } else {
                            // otherwise, we are looking at an object that is actually a sprite...
                            
                            // this will be the SpriteKit node for the object.
                            var sprite : SKSpriterObject
                            
                            // if the node already exists...
                            if let spriteInTree = objects[objectName] {
                                sprite = spriteInTree
                                
                                // it does so preserve the previous frame reference as prevReference, and initialise the new
                                // reference from this timelineKey
                                //
                                sprite.prevReference = sprite.reference
                                sprite.reference = object
                            } else {
                                sprite = SKSpriterObject(forSpriterObject: object, usingSpriterModel: self.model, andName: objectName)
                                
                                objects[objectName] = sprite
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
                                        
                                        if let parent = bones[parentName] {
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
                            if self.animate && self.tweenFrames {
                                sprite.run(.customAction(withDuration: duration, actionBlock: { node, elapsed in
                                    let percent = elapsed / duration
                                    
                                    if let sprite = node as? SKSpriterObject {
                                        let tween = sprite.tween(forPercent: percent)
                                        
                                        sprite.update(fromReference: tween)
                                    }
                                }))
                            }
                        }
                    }
                } catch {
                    print("ERROR: Unable to locate object key for timeline with ID: \(objectRef.timelineID), andKey: \(objectRef.keyID)")
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
                objects.removeValue(forKey: key)
            }
            
            // Now see if there are any time based events for this frame time that need to fire off.
            //
            if let del = self.delegate,
               let events = animation.eventlines(atTime: mainlineKeyTime) {
                events.forEach { eventline in
                    del.entity(self, reachedEventWithName: eventline.name)
                }
            }
            
            // this is the overall animation "manager".  All it does is wait for the duration of the current
            // key frame, increment the index, and then start the next key frame animation.
            //
            if self.animate {
                // if the next index is 0 (meaning we are at the end of the animation whether looping or not),
                // then the duration needs to include the time gap from the end of this frame to the complete
                // animation length.
                //
                if self.nextKeyIndex() == 0 {
                    if let times = self.keyTimes {
                        let prevTime = times[self.keyIndex]
                        duration = (animation.length - prevTime) + duration
                    }
                }
                
                // This action does the work of triggering the next frame animation.
                let commenceNextFrame = SKAction.run {
                    self.keyIndex = self.nextKeyIndex()
                    
                    if self.keyIndex == 0 {
                        if let animation = self.animation,
                           animation.isLooping {
#if DEBUG
                            self.debugTime = Date.timeIntervalSinceReferenceDate
#endif
                            self.updateToNextKey()
                        }
                    } else {
                        self.updateToNextKey()
                    }
                }
                
                // At this point we schedule, on the root node for the entity, an action that first waits for the
                // duration of this frame to expire, and then to kick off the next frame (if there is one).
                //
                // This debug version of the action continuously updates the debugLabel with the timing information
                // so that you can screen record it to see what it happening in slow-mo.
                //
#if DEBUG
                
                self.run(.sequence([
                    .customAction(withDuration: duration, actionBlock: { node, elapsed in
                        let animationTime = ((Date.timeIntervalSinceReferenceDate - self.debugTime) / self.debugTimeFactor).millisecondIntValue()
                        
                        let inFrameTime = (TimeInterval(elapsed) / self.debugTimeFactor).millisecondIntValue()
                        
                        self.debugLabel.text = "frame: \(inFrameTime), animation: \(animationTime))"
                    }),
                    commenceNextFrame
                ]))
#else
                // This is the real action when not runing in DEBUG mode.
                self.run(.sequence([
                    .wait(forDuration: duration),
                    commenceNextFrame
                ]))
#endif
            }
        }
    }
    
    /// Typically only used within a debugging environment, this can be used in conjunction with the animate property being set to false
    /// to see what each keyframe looks like without the tweening.  Useful if you want to compare with what Spriter itself says.
    public func showNextKeyFrame() {
        self.keyIndex = self.nextKeyIndex()
        
        #if DEBUG
        if self.keyIndex == 0 {
            self.debugTime = Date.timeIntervalSinceReferenceDate
        }
        #endif
        
        self.updateToNextKey()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
