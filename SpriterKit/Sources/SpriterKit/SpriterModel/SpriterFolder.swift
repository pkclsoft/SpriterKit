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

#if canImport(UIKit)
import UIKit
#endif

/// A SpriterFolder is a folder containing one or more art assets, each of which is represented by a SpriterFile.
/// In this library, the sprite assets are assumed to have been added to an Asset Catalog within Xcode.  Inside
/// the asset catalog, there should be one folder for each of the SpriterFolders defined within the SCML/SCON
/// file exported by Spriter.
///
/// Accessing a sprite within a SpriterFolder should be as easy as callng `SpriterFolder.atlas.textureNamed()`
/// where the name passed in is the `SpriterFile.assetName` property.
///
public class SpriterFolder: SpriterParseable {
    
    var id: Int
    var name: String = ""
    var files: [SpriterFile] = []
    var images: [String: SKTexture] = [:]
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCON parser.
    /// - Parameter data: an object containing one or more elements used to populate the new instance.
    required init?(data: AnyObject) {
        guard let id = data.value(forKey: "id") as? Int else {
            return nil
        }
        
        self.id = id
        
        // Note that not all folders have names in a Spriter project.  These folders get a default
        // name of "unnamed".  The shell script that builds te asset catalog from the Spriter project
        // makes this same assumption.
        if let name = data.value(forKey: "name") as? String {
            self.name = name
        } else {
            self.name = "unnamed"
        }
    }
    
    /// Creates and populates a new instance using properties retrieved from the provided object.  This constructor is
    /// expected to be used by the SCML parser.
    /// - Parameter attributes: a Dictionary containing one or more items used to populate the new instance.
    required init?(withAttributes attributes: [String: String]) {
        guard let id = attributes["id"] else {
            return nil
        }
        
        self.id = id.intValue()
        
        // Note that not all folders have names in a Spriter project.  These folders get a default
        // name of "unnamed".  The shell script that builds te asset catalog from the Spriter project
        // makes this same assumption.
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
    
    #if canImport(UIKit)
    func preload(fileName : String, fromBundle bundle: Bundle = Bundle.main) {
        if let image = UIImage(named: fileName, in: bundle, compatibleWith: nil) {
            self.images[fileName] = SKTexture(image: image)
        }
    }
    #elseif canImport(AppKit)
    func preload(fileName : String, fromBundle bundle: Bundle = Bundle.main) {
        if let image = bundle.image(forResource: fileName) {
            self.images[fileName] = SKTexture(image: image)
        }
    }
    #endif
    
    /// Returns the `SKTexture` corresponding to the specified `SpriterFile` ID.
    /// - Parameter ofObject: the file ID of the texture to seach for
    /// - Returns: The requested texture, `nil` if it is not found.
    func texture(ofObject object: SpriterObject, fromBundle bundle: Bundle = Bundle.main) -> SKTexture? {
        if let file = file(withID: object.fileID) {
            let fileName : String
            
            if self.name == "unnamed" {
                fileName = "\(file.assetName)"
            } else {
                fileName = "\(self.name)_\(file.assetName)"
            }

            if self.images[fileName] == nil {
                preload(fileName: fileName, fromBundle: bundle)
            }
            
            return self.images[fileName]
        } else {
            print("unable to identify texture for: \(self), file: \(object.fileID)")
        }
        
        return nil
    }
}
