//
//  SconParser.swift
//  SpriterKit
//
//  Originally sourced within SwiftSpriter @ https://github.com/lumenlunae/SwiftSpriter
//
//  Created by Matt on 8/27/16.
//  Copyright © 2016 BiminiRoad. All rights reserved.
//
//  Trimmed, and changed to work within SpriterKit by Peter on 30/11/24
//

import Foundation

public class SconParser: NSObject, SpriterParser {
    
    typealias JsonDict = [String: AnyObject]

    public var fileName: String?
    public var fileVersion: String?
    public var generator: String?
    public var generatorVersion: String?
    public var spriterData: SpriterData?
        
    public var resourceBundle : Bundle

    /// Initialises the parser to parse the named file, and then parses it.
    /// If any errors occur during parsing then nil is returned.
    /// - Parameter fileName: the name of the file to be parsed.
    public init?(fileName: String, usingBundle bundle: Bundle = Bundle.main) {
        self.fileName = fileName
        self.resourceBundle = bundle
        
        super.init()
        
        do {
            try parse(fileName: fileName)
        } catch {
            print("Error \(error)")
            return nil
        }
    }
    
    /// Initialises the parser to parse the file specified by the url, and then parses it.
    /// If any errors occur during parsing then nil is returned.
    /// - Parameter url: the url of the file to be parsed.
    public init?(url: URL, usingBundle bundle: Bundle = Bundle.main) {
        self.fileName = url.lastPathComponent
        self.resourceBundle = bundle
        
        super.init()
        
        do {
            try parse(url: url)
        } catch {
            print("Error \(error)")
            return nil
        }
    }

    /// Temporary container for all folders whilst parsing.
    private var folders : [SpriterFolder] = []

    public func parse(fileContent: Data) throws {
        
        let dict = try JSONSerialization.jsonObject(with: fileContent, options: []) as! JsonDict
        
        self.fileVersion = dict["scon_version"] as? String
        self.generator = dict["generator"] as? String
        self.generatorVersion = dict["generator_version"] as? String
        
        self.folders = self.parseFolders(dict["folder"] as AnyObject)
        
        let entities = self.parseEntities(dict["entity"] as AnyObject)
                
        self.spriterData = SpriterData(folders: self.folders, entities: entities, resourceBundle: self.resourceBundle)
        
        self.folders.removeAll()
    }
    
    func parseFolders(_ dicts: AnyObject) -> [SpriterFolder] {
        let items = self.parseItems(dicts, dataBlock: { (folder: inout SpriterFolder, folderDict: JsonDict) in
            folder.files = self.parseFiles(folderDict["file"] as AnyObject)
        })
        return items
    }
    
    func parseFiles(_ dict: AnyObject) -> [SpriterFile] {
        let items = self.parseItems(dict) as [SpriterFile]
        return items
    }
    
    func parseEntities(_ dicts: AnyObject) -> [SpriterEntity] {
        let items = self.parseItems(dicts) { (entity: inout SpriterEntity, entityDict: JsonDict) in
            // it's important to parse the object infos first because we need
            // to be able to use them when parsing the animations.
            //
            entity.objectInfos = self.parseObjInfos(entityDict["obj_info"] as AnyObject)
            
            entity.animations = self.parseAnimations(entityDict["animation"] as AnyObject, withinEntity: entity)
        } as [SpriterEntity]
        
        return items
    }
    
    func parseObjInfos(_ dicts: AnyObject) -> [SpriterObjectInfo] {
        let items = self.parseItems(dicts) as [SpriterObjectInfo]
        return items
    }

    func parseAnimations(_ dicts: AnyObject, withinEntity entity: SpriterEntity) -> [SpriterAnimation] {
        let items = self.parseItems(dicts, dataBlock: { (animation: inout SpriterAnimation, animDict: JsonDict) in
            animation.mainline = self.parseMainline(animDict["mainline"] as AnyObject)
            animation.timelines = self.parseTimelines(animDict["timeline"] as AnyObject, withinEntity: entity)
            animation.eventlines = self.parseEventlines(animDict["eventline"] as AnyObject, withinEntity: entity)
        }) as [SpriterAnimation]
        return items
    }
    
    func parseMainline(_ dict: AnyObject) -> SpriterMainline? {
        let item = self.parseItem(dict, block: { (mainline: inout SpriterMainline, mainlineDict: JsonDict) in
            mainline.keys = self.parseMainlineKeys(mainlineDict["key"] as AnyObject)
        }) as SpriterMainline?
        return item
    }
    
    func parseMainlineKeys(_ dicts: AnyObject) -> [SpriterMainlineKey] {
        let items = self.parseItems(dicts, dataBlock: { (key: inout SpriterMainlineKey, keyDict: JsonDict) in
            key.objectRefs = self.parseObjectRefs(keyDict["object_ref"] as AnyObject)
            key.boneRefs = self.parseBoneRefs(keyDict["bone_ref"] as AnyObject)
        }) as [SpriterMainlineKey]
        return items
    }
    
    func parseObjectRefs(_ dicts: AnyObject) -> [SpriterObjectRef] {
        let items = self.parseItems(dicts) as [SpriterObjectRef]
        return items
    }
    
    func parseBoneRefs(_ dicts: AnyObject) -> [SpriterBoneRef] {
        let items = self.parseItems(dicts) as [SpriterBoneRef]
        return items
    }
    
    func parseTimelines(_ dicts: AnyObject, withinEntity entity: SpriterEntity) -> [SpriterTimeline] {
        let items = self.parseItems(dicts, dataBlock: { (timeline: inout SpriterTimeline, timelineDict: JsonDict) in
            timeline.keys = self.parseTimelineKeys(timelineDict["key"] as AnyObject, withinEntity: entity, andTimeline: timeline)
        }) as [SpriterTimeline]
        return items
    }
    
    func parseTimelineKeys(_ dicts: AnyObject, withinEntity entity: SpriterEntity, andTimeline timeline: SpriterTimeline) -> [SpriterTimelineKey] {
        let items = self.parseItems(dicts, dataBlock: {(key: inout SpriterTimelineKey, keyDict: JsonDict) in
            
            if var object = self.parseObject(keyDict["object"] as AnyObject) {
                object.spin = key.spin
                
                // if the object has a default pivot, then adopt the pivot from the file in case it
                // is not a default value.
                //
                if let folderID = object.folderID,
                   let fileID = object.fileID,
                   let folder = self.folders.first(where: { folder in
                       return folder.id == folderID
                   }),
                   let file = folder.file(withID: fileID) {
                    if object.pivot == DEFAULT_PIVOT {
                        object.pivot = file.pivot
                    }
                    
                    // this is done simply to trigger a preload of the texture.
                    _ = folder.texture(ofObject: object, fromBundle: self.resourceBundle)
                }

                key.object = object
            }
            
            if var bone = self.parseBone(keyDict["bone"] as AnyObject) {
                bone.spin = key.spin

                if let info = entity.objectInfo(withName: timeline.name) {
                    bone.size = info.size
                }

                key.bone = bone
            }
        }) as [SpriterTimelineKey]
        return items
    }
    
    func parseEventlines(_ dicts: AnyObject, withinEntity entity: SpriterEntity) -> [SpriterEventline] {
        let items = self.parseItems(dicts, dataBlock: { (eventline: inout SpriterEventline, eventlineDict: JsonDict) in
            eventline.keys = self.parseEventlineKeys(eventlineDict["key"] as AnyObject, withinEntity: entity, andEventline: eventline)
        }) as [SpriterEventline]
        return items
    }
    
    func parseEventlineKeys(_ dicts: AnyObject, withinEntity entity: SpriterEntity, andEventline eventline: SpriterEventline) -> [SpriterEventlineKey] {
        let items = self.parseItems(dicts, dataBlock: {(key: inout SpriterEventlineKey, keyDict: JsonDict) in
        }) as [SpriterEventlineKey]
        return items
    }

    func parseObject(_ dict: AnyObject) -> SpriterObject? {
        let item = self.parseItem(dict as AnyObject) as SpriterObject?
        return item
    }
    
    func parseBone(_ dict: AnyObject) -> SpriterBone? {
        let item = self.parseItem(dict as AnyObject) as SpriterBone?
        return item
    }
    
    func parseItems<T:SpriterParseable>(_ dicts: AnyObject, dataBlock: ((inout T, JsonDict) -> Void)? =  nil) -> [T] {
        guard let dicts = dicts as? [JsonDict] else {
            return []
        }
        var items = [T]()
        for dict in dicts {
            if let item = parseItem(dict as AnyObject, block: dataBlock) {
                items.append(item)
            }
            
        }
        return items
    } 
    
    func parseItem<T:SpriterParseable>(_ dict: AnyObject, block: ((inout T, JsonDict) -> Void)? = nil) -> T? {
        
        guard let jsonDict = dict as? JsonDict else {
            return nil
        }
        
        if var item = T(data: jsonDict as AnyObject) {
            if let block = block {
                block(&item, jsonDict)
            }
            return item
        }
        return nil
    }
}
