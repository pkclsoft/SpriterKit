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
    
    var keys: [SpriterMainlineKey] = []
    
    init?(data: AnyObject) {
        
    }
    
    init?(withAttributes attributes: [String: String]) {
        
    }
    
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
