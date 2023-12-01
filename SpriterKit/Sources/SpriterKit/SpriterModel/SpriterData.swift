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

/// Provides a singular container for all spriter data as read from the Spriter project file.
public struct SpriterData {
    
    /// An array of folders as specified within the project.  Each folder provides a method by which the sprites
    /// that are used to visualise an entity can be retrieved from an asset catalog.
    var folders: [SpriterFolder]
    
    /// An array of the entities as specifier within the project.
    var entities: [SpriterEntity]
    
    /// Retrieves the entity with the specified ID.
    /// - Parameter entityID: the ID of the entity being requested.
    /// - Returns: A `SpriterEntity` or `nil` if the entity can't be found.
    func entity(withEntityID entityID: Int) -> SpriterEntity? {
        return self.entities.first { entity in
            return entity.id == entityID
        }
    }
    
    /// Retrieves the folder with the specified ID.
    /// - Parameter folderID: the ID of the folder being requested.
    /// - Returns: A `SpriterFolder` or `nil` if the folder can't be found.
    func folder(withFolderID folderID: Int) -> SpriterFolder? {
        return self.folders.first { folder in
            return folder.id == folderID
        }
    }
    
}
