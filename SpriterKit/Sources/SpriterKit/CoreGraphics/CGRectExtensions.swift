//
//  CGRectExtensions.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.
//

import Foundation

public extension CGRect {
    
    /// Returns a `CGPoint` representing the centre of the rectangle `self`.
    /// - Returns: A `CGPoint`.
    func centerOf() -> CGPoint {
        return CGPoint.init(x:self.origin.x + (self.size.width / 2.0), y:self.origin.y + (self.size.height / 2.0))
    }
    
    /// Divides the rectangle by `s`, keeping the it centred on the same point.
    static func / (v: CGRect, s: CGFloat) -> CGRect {
        let newSize = v.size / s
        let newOrigin = CGPoint(x: v.origin.x + (v.size.width - newSize.width) / 2.0, y: v.origin.y + (v.size.height - newSize.height) / 2.0)
        
        return .init(origin: newOrigin, size: newSize)
   }
    
    /// Multiplies the rectangle `v` by `s`, keeping it centred on the same point.
    static func * (v: CGRect, s: CGFloat) -> CGRect {
        return v / (1.0 / s)
    }

}
