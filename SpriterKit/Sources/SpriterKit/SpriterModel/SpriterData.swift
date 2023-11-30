//
//  SpriterData.swift
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

public struct SpriterData {
    
    var folders: [SpriterFolder]
    var entities: [SpriterEntity]
    
    func entity(withEntityID entityID: Int) -> SpriterEntity? {
        return self.entities.first { entity in
            return entity.id == entityID
        }
    }
    
    func folder(withFolderID folderID: Int) -> SpriterFolder? {
        return self.folders.first { folder in
            return folder.id == folderID
        }
    }
    
}
