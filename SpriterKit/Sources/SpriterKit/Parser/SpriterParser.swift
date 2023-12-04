//
//  SpriterParser.swift
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
import SpriteKit

/// A SpriterParser is responsible for parsing a Spriter project file into the in-memory structures needed to facilitate
/// the animation of the entities defined therein.
///
/// This protocol defines the minimum functionality need for the parser.  Spriter can save it's project in either
/// SCML (XML) or SCON (JSON) formats, so this protocol provides a way to implement parsers for both
/// formats, producing a common structure for animating.
public protocol SpriterParser {
    
    /// The filename of the project file.
    var fileName: String? { get set }
    
    /// The version of the project file format.
    var fileVersion: String? { get set }
    
    /// The name of the application that generated the project file.
    var generator: String? { get set }
    
    /// The version of Spriter that generated the project file.
    var generatorVersion: String? { get set}
    
    /// The data, once parsed from the project file that represents each of the entities within the project.
    var spriterData: SpriterData? { get set }
    
    /// The bundle from which all resources will be loaded.
    var resourceBundle : Bundle { get set }

    /// Parses the specified file, assuming it can be found within the applications main bundle.
    /// - Parameter fileName: the name of the file to load/parse.
    func parse(fileName: String) throws
    
    /// Parses the bytes within the specified `Data` object as a Spriter project file.
    /// - Parameter fileContent: a `Data` object that should contain a Spriter project file.
    func parse(fileContent: Data) throws
}

extension SpriterParser {
    
    /// Provides a basic interface to load the specified file from the main bundle of the application and parse it.
    /// - Parameter fileName: the name of the file (only works when the file is in the main bundle)
    public func parse(fileName: String) throws {
        
        let filePath = self.resourceBundle.path(forResource: fileName, ofType: "")
        let fileURL = URL(fileURLWithPath: filePath!)
        
        try self.parse(url: fileURL)
        
    }
    
    /// Provides a basic interface to load the specified file from the specified URL.
    /// - Parameter url: the full URL of the file to load
    public func parse(url: URL) throws {
        
        let data = try Data(contentsOf: url)
        
        try self.parse(fileContent: data)
        
    }

}
