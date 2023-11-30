//
//  SpriterEntity.swift
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

struct SpriterEntity: SpriterParseable {
    
    var id: Int = 0
    var name: String
    var animations: [SpriterAnimation] = []
        
    init?(data: AnyObject) {
        guard let name = data.value(forKey: "name") as? String else {
                return nil
        }
        
        self.name = name
        
        if let id = data.value(forKey: "id") as? Int {
            self.id = id
        }
    }
    
    init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"] else {
                return nil
        }

        self.id = id.intValue()
        
        if let name = attributes["name"] {
            self.name = name
        } else {
            self.name = "undefined"
        }
    }

    func animation(withID id: Int) -> SpriterAnimation? {
        return self.animations.first { animation in
            return animation.id == id
        }
    }
}
