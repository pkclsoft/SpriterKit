//
//  SpriterTimelineKey.swift
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

struct SpriterTimelineKey: SpriterParseable {
    
    /// The ID of the key.
    var id: Int
    
    /// The time in seconds for this timeline key frame.
    var time: TimeInterval = 0
    
    /// The spin direction to be applied when rotating the bone or object.
    var spin: SpriterSpinType = .clockwise
    
    /// The timing curve defined for this key.
    var curveType: SpriterCurveType = .linear
    
    /// An internal indicator of whether this timeline relates to a bone or an object.
    private var isBone : Bool = false
    
    /// For timeline keys associated with objects, this is the associated object.
    var object: SpriterObject? {
        didSet {
            if object != nil {
                isBone = false
            }
        }
    }
    
    /// For timeline keys associated with bones, this is the associated bone.
    var bone: SpriterBone? {
        didSet {
            if bone != nil {
                isBone = true
            }
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int else {
            return nil
        }
        
        self.id = id
        
        if let time = data.value(forKey: "time") as? String {
            self.time = time.timeIntervalValue()
        }
        
        if let spinInt = data.value(forKey: "spin") as? Int,
           let spin = SpriterSpinType(rawValue: spinInt) {
            self.spin = spin
        }
        
        if let curve = SpriterCurveType(data: data) {
            self.curveType = curve
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"] else {
            return nil
        }
        
        self.id = id.intValue()
        
        if let time = attributes["time"] {
            self.time = time.timeIntervalValue()
        }
        if let spinInt = attributes["spin"]?.intValue(),
           let spin = SpriterSpinType(rawValue: spinInt) {
            self.spin = spin
        }
        
        if let curve = SpriterCurveType(withAttributes: attributes) {
            self.curveType = curve
        }
    }
    
    /// Computes a tween from `self` to `keyB` where keyB starts at `nextKeyTime` and the current time is `currentTime`.
    ///
    /// This has been ported from: https://github.com/loudoweb/SpriterHaxeEngine/blob/master/spriter/definitions/TimelineKey.hx
    ///
    /// - Parameters:
    ///   - to: the destination key.
    ///   - nextKeyTime: the time at which keyB starts
    ///   - currentTime: the time "now"
    /// - Returns: The tweened key.
    func tween(to: SpriterTimelineKey, at nextKeyTime: TimeInterval, currentTime: TimeInterval) -> SpriterTimelineKey {
        return linearKey(keyB: to, t: getTWithNextKey(at: nextKeyTime, currentTime: currentTime))
    }
    
    /// Using the curve type specified for `self`, computes an adjusted time value.
    ///
    /// This has been ported from: https://github.com/loudoweb/SpriterHaxeEngine/blob/master/spriter/definitions/TimelineKey.hx
    ///
    /// - Parameters:
    ///   - nextKeyTime: the start time of the next key.
    ///   - currentTime: the unadjusted current time
    /// - Returns: the adjusted current time.
    func getTWithNextKey(at nextKeyTime: TimeInterval, currentTime: TimeInterval)  -> TimeInterval {
        if curveType == .instant || time == nextKeyTime {
            return 0
        }
        
        var result: TimeInterval = (currentTime - time) / (nextKeyTime - time);
        
        switch (curveType) {
            case SpriterCurveType.instant:
                result = 0.0
            case SpriterCurveType.linear:
                break
            case let SpriterCurveType.quadratic(c1):
                result = SKSpriterUtilities.bezier(0.0, c1, 1.0, result)
            case let SpriterCurveType.cubic(c1, c2):
                result = SKSpriterUtilities.bezier(0.0, c1, c2, 1.0, result)
            case let SpriterCurveType.quartic(c1, c2, c3):
                result = SKSpriterUtilities.bezier(0.0, c1, c2, c3, 1.0, result)
            case let SpriterCurveType.quintic(c1, c2, c3, c4):
                result = SKSpriterUtilities.bezier(0.0, c1, c2, c3, c4, 1.0, result)
            case let SpriterCurveType.bezier(c1, c2, c3, c4):
                result = SKSpriterUtilities.bezier2D(c1, c2, c3, c4, result)
        }
        
        return result
    }
    
    /// Computes a tween from `self` to keyB at time `t`.
    ///
    /// This has been ported from: https://github.com/loudoweb/SpriterHaxeEngine/blob/master/spriter/definitions/TimelineKey.hx
    ///
    /// - Parameters:
    ///   - keyB: the destination key frame
    ///   - t: the time between now and keyB at which to interpolate or tween.
    /// - Returns: A tweened value of `self` towards keyB.
    func linearKey(keyB: SpriterTimelineKey, t: TimeInterval) -> SpriterTimelineKey {
        var result = self
        
        if isBone {
            if result.bone != nil &&
                keyB.isBone &&
                keyB.bone != nil {
                result.bone = result.bone!.tween(to: keyB.bone!, forPercent: t)
            }
        } else {
            if result.object != nil &&
                !keyB.isBone &&
                keyB.object != nil {
                result.object = result.object!.tween(to: keyB.object!, forPercent: t)
            }
        }
        
        return result
    }
    
}
