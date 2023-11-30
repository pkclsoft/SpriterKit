//
//  ScmlParser.swift
//  SpriterKit
//
//  Created by Peter on 30/11/23.
//  Copyright © 2023 PKCLsoft. All rights reserved.
//

import Foundation

/// An SCML parser for Spriter projects.
public class ScmlParser: NSObject, SpriterParser, XMLParserDelegate {
    
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
        
        let parser = XMLParser(data: fileContent)
        parser.delegate = self
        
        if parser.parse() {
            self.spriterData = SpriterData(folders: self.folders, entities: self.entities)
        }
    }
    
    // MARK: - XMLParserDelegate
    
    typealias XMLDict = [String: AnyObject]

    private var entities : [SpriterEntity] = []
    private var folders : [SpriterFolder] = []
    private var atlasNames : [String] = []
    
    #if DEBUG
    /// These are needed from the `bone_info` elements of the project if we are going to be able to display
    /// bones.
    private var boneSizes : [String: CGSize] = [:]
    #endif
    
    enum ParsingState : Equatable {
        case none
        case spriterData
        case folder
        case file
        case entity
        case objInfo
        case characterMap
        case map
        case animation
        case gline
        case mainline
        case mainlineKey
        case objectRef
        case boneRef
        case timeline
        case timelineKey
        case object
        case bone
        
        var elementTag : String {
            get {
                switch self {
                    case .none:
                        return "none"
                        
                        // root level
                    case .spriterData:
                        return "spriter_data"
                        
                        // top level
                    case .folder:
                        return "folder"
                        
                        // 2nd level
                    case .file:
                        return "file"
                        
                        // top level
                    case .entity:
                        return "entity"
                        
                        // 2nd level
                    case .objInfo:
                        return "obj_info"

                        // 2nd level
                    case .animation:
                        return "animation"

                        // 2nd level
                    case .characterMap:
                        return "character_map"
                        
                        // 3rd level
                    case .map:
                        return "map"
                        
                        // 3rd level
                    case .gline:
                        return "gline"
                        
                        // 3rd level
                    case .mainline:
                        return "mainline"

                        // 4th level
                    case .mainlineKey:
                        return "key"
                        
                        // 5th level
                    case .objectRef:
                        return "object_ref"
                        
                        // 5th level
                    case .boneRef:
                        return "bone_ref"
                        
                        // 3rd level
                    case .timeline:
                        return "timeline"
                        
                        // 4th level
                    case .timelineKey:
                        return "key"
                        
                        // 5th level
                    case .object:
                        return "object"
                        
                        // 5th level
                    case .bone:
                        return "bone"
                }
            }
        }
        
        init(withElementTag tag: String, withPreviousState previousState: ParsingState) {
            if tag == ParsingState.spriterData.elementTag {
                self = .spriterData
            } else if tag == ParsingState.folder.elementTag {
                self = .folder
            } else if tag == ParsingState.file.elementTag {
                self = .file
            } else if tag == ParsingState.entity.elementTag {
                self = .entity
            } else if tag == ParsingState.objInfo.elementTag {
                self = .objInfo
            } else if tag == ParsingState.characterMap.elementTag {
                self = .characterMap
            } else if tag == ParsingState.map.elementTag {
                self = .map
            } else if tag == ParsingState.animation.elementTag {
                self = .animation
            } else if tag == ParsingState.mainline.elementTag {
                self = .mainline
            } else if tag == ParsingState.gline.elementTag {
                self = .gline
            } else if tag == ParsingState.mainlineKey.elementTag &&
                        previousState == .mainline {
                self = .mainlineKey
            } else if tag == ParsingState.objectRef.elementTag {
                self = .objectRef
            } else if tag == ParsingState.boneRef.elementTag {
                self = .boneRef
            } else if tag == ParsingState.timeline.elementTag {
                self = .timeline
            } else if tag == ParsingState.timelineKey.elementTag &&
                        previousState == .timeline {
                self = .timelineKey
            } else if tag == ParsingState.object.elementTag {
                self = .object
            } else if tag == ParsingState.bone.elementTag {
                self = .bone
            } else {
                self = .none
            }
        }
        
        func validSubElements() -> [ParsingState] {
            switch self {
                case .none:
                    return [.spriterData]
                case .spriterData:
                    return [.folder, .entity]
                case .folder:
                    return [.file]
                case .entity:
                    return [.animation, .objInfo, .characterMap]
                case .characterMap:
                    return [.map]
                case .animation:
                    return [.mainline, .timeline, .gline]
                case .mainline:
                    return [.mainlineKey]
                case .mainlineKey:
                    return [.objectRef, .boneRef]
                case .timeline:
                    return [.timelineKey]
                case .timelineKey:
                    return [.object, .bone]
                case .file, .objectRef, .boneRef, .object, .bone, .objInfo, .map, .gline:
                    return []
            }
        }
        
        func parentState() -> ParsingState {
            switch self {
                case .none:
                    return .none
                case .spriterData:
                    return .none
                case .folder:
                    return .spriterData
                case .file:
                    return .folder
                case .entity:
                    return .spriterData
                case .objInfo:
                    return .entity
                case .characterMap:
                    return .entity
                case .map:
                    return .characterMap
                case .animation:
                    return .entity
                case .gline:
                    return .animation
                case .mainline:
                    return .animation
                case .mainlineKey:
                    return .mainline
                case .objectRef:
                    return .mainlineKey
                case .boneRef:
                    return .mainlineKey
                case .timeline:
                    return .animation
                case .timelineKey:
                    return .timeline
                case .object:
                    return .timelineKey
                case .bone:
                    return .timelineKey
            }
        }
    }
    
    var parsingState : ParsingState = .none
    
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        let stateForElement = ParsingState(withElementTag: elementName, withPreviousState: parsingState)
        
        // only expect top level tags
        //
        if parsingState.validSubElements().contains(where: { state in
            return state == stateForElement
        }) {
            parsingState = stateForElement
            
            switch stateForElement {
                case .none:
                    break
                case .spriterData:
                    self.fileVersion = attributeDict["scml_version"]
                    self.generator = attributeDict["generator"]
                    self.generatorVersion = attributeDict["generator_version"]
                case .folder:
                    if let folder = SpriterFolder(withAttributes: attributeDict) {
                        self.folders.append(folder)
                    }
                case .file:
                    if let file = SpriterFile(withAttributes: attributeDict) {
                        self.folders[self.folders.endIndex-1].files.append(file)
                    }
                case .entity:
                    if let entity = SpriterEntity(withAttributes: attributeDict) {
                        self.entities.append(entity)
                    }
                case .animation:
                    if let animation = SpriterAnimation(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        
                        self.entities[lastEntity].animations.append(animation)
                    }
                case .objInfo:
                    #if DEBUG
                    if let width = attributeDict["w"],
                       let height = attributeDict["h"],
                       let name = attributeDict["name"] {
                        boneSizes[name] = CGSize(width: width.CGFloatValue(), height: height.CGFloatValue())
                    }
                    #else
                    break
                    #endif
                    
                case .characterMap:
                    break
                case .map:
                    break
                case .gline:
                    break
                case .mainline:
                    if let mainline = SpriterMainline(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline = mainline
                    }
                case .mainlineKey:
                    if let mainlineKey = SpriterMainlineKey(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline!
                            .keys.append(mainlineKey)
                    }
                case .objectRef:
                    if let objectRef = SpriterObjectRef(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastKey = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline!.keys.endIndex-1
                        
                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline!
                            .keys[lastKey]
                            .objectRefs.append(objectRef)
                    }
                case .boneRef:
                    if let boneRef = SpriterBoneRef(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastKey = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline!.keys.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .mainline!.keys[lastKey]
                            .boneRefs.append(boneRef)
                    }
                case .timeline:
                    if let timeline = SpriterTimeline(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines.append(timeline)
                    }
                case .timelineKey:
                    if let timelineKey = SpriterTimelineKey(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastTimeline = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimeline]
                            .keys.append(timelineKey)
                    }
                case .object:
                    if var object = SpriterObject(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastTimeline = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines.endIndex-1
                        let lastKey = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimeline].keys.endIndex-1
                        
                        // if the object has a default pivot, then adopt the pivot from the file in case it
                        // is not a default value.
                        //
                        if object.pivot == DEFAULT_PIVOT,
                           let folder = self.folders.first(where: { folder in
                               return folder.id == object.folderID
                           }),
                           let file = folder.file(withID: object.fileID) {
                            object.pivot = file.pivot
                        }
                        
                        object.spin = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimeline]
                            .keys[lastKey].spin

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimeline]
                            .keys[lastKey]
                            .object = object
                    }
                case .bone:
                    if var bone = SpriterBone(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastTimelineIndex = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines.endIndex-1
                        let timeline = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimelineIndex]
                        let lastKey = timeline.keys.endIndex-1
                        
                        #if DEBUG
                        if let size = boneSizes[timeline.name] {
                            bone.size = size
                        }
                        #endif

                        bone.spin = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimelineIndex]
                            .keys[lastKey].spin
                        
                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .timelines[lastTimelineIndex]
                            .keys[lastKey]
                            .bone = bone
                    }
            }
        } else {
            print("\(elementName) at line: \(parser.lineNumber) isn't a valid subelement for \(parsingState.elementTag)")
            
            parser.abortParsing()
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        // SCML files don't seem to contain any "values" that are not attributes or elements.
    }
      
    public func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        parsingState = parsingState.parentState()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
    }

}
