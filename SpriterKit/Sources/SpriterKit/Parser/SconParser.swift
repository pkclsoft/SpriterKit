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
        
    public init?(fileName: String) {
        self.fileName = fileName
        
        super.init()
        
        do {
            try parse(fileName: fileName)
        } catch {
            print("Error \(error)")
            return nil
        }
    }
    
    public init?(data: Data) {
        super.init()
        
        do {
            try parse(fileContent: data)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    public func parse(fileContent: Data) throws {
        
        let dict = try JSONSerialization.jsonObject(with: fileContent, options: []) as! JsonDict
        
        self.fileVersion = dict["scon_version"] as? String
        self.generator = dict["generator"] as? String
        self.generatorVersion = dict["generator_version"] as? String
        
        let folders = self.parseFolders(dict["folder"] as AnyObject)
        
        let entities = self.parseEntities(dict["entity"] as AnyObject)
                
        self.spriterData = SpriterData(folders: folders, entities: entities)
    }
    
    func parseAtlases(_ dicts: AnyObject) -> [String]? {
        if let atlasDicts = dicts as? [JsonDict] {
            var atlases = [String]()
            for atlasDict in atlasDicts {
                if let name = atlasDict["name"] as? String {
                    atlases.append(name)
                }
            }
            if atlases.count > 0 {
                return atlases
            }
        }
        return nil
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
            entity.animations = self.parseAnimations(entityDict["animation"] as AnyObject)
            } as [SpriterEntity]
        
        return items
    }
    
    
    func parseAnimations(_ dicts: AnyObject) -> [SpriterAnimation] {
        let items = self.parseItems(dicts, dataBlock: { (animation: inout SpriterAnimation, animDict: JsonDict) in
            animation.mainline = self.parseMainline(animDict["mainline"] as AnyObject)
            animation.timelines = self.parseTimelines(animDict["timeline"] as AnyObject)
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
    
    func parseTimelines(_ dicts: AnyObject) -> [SpriterTimeline] {
        let items = self.parseItems(dicts, dataBlock: { (timeline: inout SpriterTimeline, timelineDict: JsonDict) in
            timeline.keys = self.parseTimelineKeys(timelineDict["key"] as AnyObject)
        }) as [SpriterTimeline]
        return items
    }
    
    func parseTimelineKeys(_ dicts: AnyObject) -> [SpriterTimelineKey] {
        let items = self.parseItems(dicts, dataBlock: {(key: inout SpriterTimelineKey, keyDict: JsonDict) in
            key.object = self.parseObject(keyDict["object"] as AnyObject)
            key.bone = self.parseBone(keyDict["bone"] as AnyObject)
        }) as [SpriterTimelineKey]
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
