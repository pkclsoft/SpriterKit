//
//  SpriterFolder.swift
//  SpriterKit
//
//  Originally sourced within SwiftSpriter @ https://github.com/lumenlunae/SwiftSpriter
//
//  Created by Matt on 8/27/16.
//  Copyright © 2016 BiminiRoad. All rights reserved.
//
//  Changed to work within SpriterKit by Peter on 30/11/24
//
//  Refactored by Peter Easdown in 2023 to work within an Xcode 15 environment
//  using Asset Catalogs, and SpriteKit

import Foundation
import SpriteKit

/// A SpriterFolder is a folder containing one or more art assets, each of which is represented by a SpriterFile.
/// In this library, I've chosen to assume that the sprite assets are added to an AssetCatalog within Xcode.  Inside
/// the asset catalog, there should be one folder for each of the SpriterFolders defined within the SCML/SCON
/// file exported by Spriter.
///
/// Accessing a sprite within a SpriterFolder should be as easy as callng `SpriterFolder.atlas.textureNamed()`
/// where the name passed in is the `SpriterFile.assetName` property.
///
struct SpriterFolder: SpriterParseable {
    
    var id: Int = -1
    var name: String = ""
    var files: [SpriterFile] = []
    
    /// The sprite atlas that represents, and contains all of the assets for the SpriterFile objects in this SpriterFolder
    var atlas: SKTextureAtlas {
        get {
            return SKTextureAtlas(named: name)
        }
    }
    
    init?(data: AnyObject) {
        if let name = data.value(forKey: "name") as? String {
            self.name = name
        } else {
            self.name = "unnamed"
        }
        
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
            self.name = "unnamed"
        }
    }
    
    /// Searches for a SpriterFile with the specified ID.
    /// - Parameter id: the file ID to search for
    /// - Returns: The requested `SpriterFile` or `nil` if it is not found.
    func file(withID id: Int) -> SpriterFile? {
        return self.files.first { file in
            return file.id == id
        }
    }
    
    /// Returns the `SKTexture` corresponding to the specified `SpriterFile` ID.
    /// - Parameter ofObject: the file ID of the texture to seach for
    /// - Returns: The requested texture, `nil` if it is not found.
    func texture(ofObject object: SpriterObject) -> SKTexture? {
        if let file = file(withID: object.fileID) {
            let fileName : String
            
            if self.name == "unnamed" {
                fileName = "\(file.assetName)"
            } else {
                fileName = "\(self.name)_\(file.assetName)"
            }
                        
            return self.atlas.textureNamed(fileName)
        } else {
            print("unable to identify texture for: \(self), file: \(object.fileID)")
        }
        
        return nil
    }
}
