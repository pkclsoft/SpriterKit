//
//  SpriterAnimation.swift
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

struct SpriterAnimation: SpriterParseable {
    
    var id: Int
    var name: String
    var length: TimeInterval
    var interval: TimeInterval
    var isLooping: Bool = true
    var mainline: SpriterMainline?
    var timelines: [SpriterTimeline] = []
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int,
              let name = data.value(forKey: "name") as? String,
              let length = data.value(forKey: "length") as? String,
              let interval = data.value(forKey: "interval") as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.length = length.timeIntervalValue()
        self.interval = interval.timeIntervalValue()
        
        if let loopingString = data.value(forKey: "looping") as? String {
            self.isLooping = loopingString.boolValue()
        }
        
        self.mainline = nil
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"],
              let name = attributes["name"],
              let length = attributes["length"],
              let interval = attributes["interval"] else {
            return nil
        }
        
        self.id = id.intValue()
        self.name = name
        self.length = length.timeIntervalValue()
        self.interval = interval.timeIntervalValue()
        
        if let isLooping = attributes["isLooping"] {
            self.isLooping = isLooping.boolValue()
        }
        
        self.mainline = nil
    }
    
    func timeline(forTimeLineID timelineID: Int) -> SpriterTimeline? {
        return timelines.first(where: { timeline in
            return timeline.id == timelineID
        })
    }
    
    enum SpriterAnimationError : Error {
        /// When retrieving a key for a timeline, if the specified timeline ID is invalid, this exception is thrown.
        case UnknownTimelineKey
    }
    
    /// Retrieves a key representing a specific timeline and key at a given time.  The result will be the result of a tween between
    /// the frame indicated by the refKey and the next frame.
    ///
    /// This was ported from: https://github.com/loudoweb/SpriterHaxeEngine/blob/master/spriter/definitions/SpriterAnimation.hx#keyFromRef
    ///
    /// - Parameters:
    ///   - timelineID: the ID of the timeline
    ///   - refKey: the ID of the key frame within that timeline after which the time should indicate
    ///   - newTime: the time within the animation
    /// - Returns: A tweened key representing where the sprite or bone managed by the timeline for a given time into a frame.
    func key(inTimeLineWithID timelineID: Int, andKey refKey: Int, newTime: TimeInterval) throws -> SpriterTimelineKey {
        // get the timeline.
        if let timeline = self.timeline(forTimeLineID: timelineID) {
            // get the key frame indicated by the reference key
            let keyA : SpriterTimelineKey = timeline.keys[refKey]
            
            // if there is only one key, or the curve has no time component, then just return that
            // frame.
            if timeline.keys.count == 1 || keyA.curveType == .instant {
                return keyA
            }
            
            // now determine the next key and get it
            var nextKey : Int = refKey + 1
            
            if nextKey >= timeline.keys.count {
                if isLooping {
                    nextKey = 0
                } else {
                    // if keyA is the final key and the animation does not loop, then just return keyA
                    return keyA
                }
            }
            
            let keyB : SpriterTimelineKey = timeline.keys[nextKey]
            var keyBTime : TimeInterval = keyB.time
            
            if keyBTime < keyA.time {
                keyBTime += length
            }
            
            // return a tween between A and B.
            return keyA.tween(to: keyB, at: keyBTime, currentTime: newTime)
        } else {
            // the timeline ID was invalid.
            throw SpriterAnimationError.UnknownTimelineKey
        }
    }
    
}
