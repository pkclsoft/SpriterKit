//
//  SpriterMainlineKey.swift
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

struct SpriterMainlineKey: SpriterParseable {
    
    var id: Int
    var time: TimeInterval = 0
    var objectRefs: [SpriterObjectRef] = []
    var boneRefs: [SpriterBoneRef] = []
    
    // SpriterMainlineKey will take precedence
    // over SpriterTimelineKey, but this should be optional
    var curveType: SpriterCurveType?
    
    init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int else {
                return nil
        }
        
        self.id = id
        
        if let time = data.value(forKey: "time") as? TimeInterval {
            self.time = time / 1000.0
        }
        
        var c1: CGFloat = 0.0
        var c2: CGFloat = 0.0
        var c3: CGFloat = 0.0
        var c4: CGFloat = 0.0

        if let c1Value = data.value(forKey: "c1") as? CGFloat {
            c1 = c1Value
        }
        
        if let c2Value = data.value(forKey: "c2") as? CGFloat {
            c2 = c2Value
        }
        
        if let c3Value = data.value(forKey: "c3") as? CGFloat {
            c3 = c3Value
        }
        
        if let c4Value = data.value(forKey: "c4") as? CGFloat {
            c4 = c4Value
        }
        
        if let curveTypeInt = data.value(forKey: "curve_type") as? Int {
            switch curveTypeInt {
                case 0:
                    self.curveType = .instant
                case 1:
                    self.curveType = .linear
                case 2:
                    self.curveType = .quadratic(c1: c1)
                case 3:
                    self.curveType = .cubic(c1: c1, c2: c2)
                case 4:
                    self.curveType = .quartic(c1: c1, c2: c2, c3: c3)
                case 5:
                    self.curveType = .quintic(c1: c1, c2: c2, c3: c3, c4: c4)
                case 6:
                    self.curveType = .bezier(c1: c1, c2: c2, c3: c3, c4: c4)
                default:
                    break
            }
        }
    }
    
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"] else {
                return nil
        }
        
        self.id = id.intValue()
        
        if let time = attributes["time"] {
            self.time = time.timeIntervalValue()
        }
        
        var c1: CGFloat = 0.0
        var c2: CGFloat = 0.0
        var c3: CGFloat = 0.0
        var c4: CGFloat = 0.0
        
        if let c1Value = attributes["c1"] {
            c1 = c1Value.CGFloatValue()
        }
        
        if let c2Value = attributes["c2"] {
            c2 = c2Value.CGFloatValue()
        }
        
        if let c3Value = attributes["c3"] {
            c3 = c3Value.CGFloatValue()
        }
        
        if let c4Value = attributes["c4"] {
            c4 = c4Value.CGFloatValue()
        }
        
        if let curveTypeStr = attributes["curve_type"] {
            switch curveTypeStr {
                case "instant":
                    self.curveType = .instant
                case "linear":
                    self.curveType = .linear
                case "quadratic":
                    self.curveType = .quadratic(c1: c1)
                case "cubic":
                    self.curveType = .cubic(c1: c1, c2: c2)
                case "quartic":
                    self.curveType = .quartic(c1: c1, c2: c2, c3: c3)
                case "quintic":
                    self.curveType = .quintic(c1: c1, c2: c2, c3: c3, c4: c4)
                case "bezier":
                    self.curveType = .bezier(c1: c1, c2: c2, c3: c3, c4: c4)
                default:
                    break
            }
        }
    }

}
