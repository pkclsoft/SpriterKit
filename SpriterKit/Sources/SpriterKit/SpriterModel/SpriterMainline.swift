//
//  SpriterMainline.swift
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

struct SpriterMainline: SpriterParseable {
    
    /// The keys defined for this SpriterMainline.  Access these via `key(forTimeInterval)`.
    var keys: [SpriterMainlineKey] = []
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    init?(data: AnyObject) {
        
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    init?(withAttributes attributes: [String: String]) {
        
    }
    
    /// Scans all of the keys associated with this mainline and returns an array of the times at which they should trigger.
    /// - Returns: An array of `TimeInterval`s representing the key or frame times in the animation described by this
    /// mainline.
    func keyTimes() -> [TimeInterval] {
        var result : [TimeInterval] = []
        
        self.keys.forEach { key in
            result.append(key.time)
        }
        
        return result.sorted()
    }
    
    /// Find the key with the greatest time that would be triggered before the specified time interval.
    /// - Parameter time: the time interval by which the key would have triggered
    /// - Returns: A `SpriterMainlineKey` representing the key requested.
    func key(forTimeInterval time: TimeInterval) -> SpriterMainlineKey {
        var result : Int = 0
        
        for index: Int in 0 ..< keys.count {
            if keys[index].time <= time {
                result = index
            }
            
            if keys[index].time >= time {
                break
            }
        }
        
        return keys[result]
    }
}
