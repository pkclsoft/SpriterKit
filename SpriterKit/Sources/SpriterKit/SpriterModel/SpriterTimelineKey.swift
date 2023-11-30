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
    
    var id: Int
    var time: TimeInterval = 0
    var spin: SpriterSpinType = .clockwise
    var curveType: SpriterCurveType = .linear
    var isBone : Bool = false
    
    var object: SpriterObject? {
        didSet {
            if object != nil {
                isBone = false
            }
        }
    }
    
    var bone: SpriterBone? {
        didSet {
            if bone != nil {
                isBone = true
            }
        }
    }
    
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
        if let spinInt = attributes["spin"]?.intValue(),
            let spin = SpriterSpinType(rawValue: spinInt) {
            self.spin = spin
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
    
    func tween(to: SpriterTimelineKey, at nextKeyTime: TimeInterval, currentTime: TimeInterval) -> SpriterTimelineKey {
        return linearKey(keyB: to, t: getTWithNextKey(at: nextKeyTime, currentTime: currentTime))
    }

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
