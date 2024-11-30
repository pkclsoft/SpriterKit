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
    
    typealias XMLDict = [String: AnyObject]

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

    public func parse(fileContent: Data) throws {
        
        let parser = XMLParser(data: fileContent)
        parser.delegate = self
        
        if parser.parse() {
            self.spriterData = SpriterData(folders: self.folders, entities: self.entities, resourceBundle: self.resourceBundle)
            
            self.entities.removeAll()
            self.folders.removeAll()
        }
    }
    
    // MARK: - XMLParserDelegate

    /// Temporary container for all entities whilst parsing.
    private var entities : [SpriterEntity] = []
    /// Temporary container for all folders whilst parsing.
    private var folders : [SpriterFolder] = []
    
    /// A type to assist the parser in managing the state of the parsing process.
    ///
    enum ParsingState : Equatable {
        
        /// Each state represents a different part of the Spriter project file.
        case none
        case spriterData
        case folder
        case file
        case entity
        case objInfo
        case characterMap
        case frames
        case i
        case map
        case animation
        case gline
        case mainline
        case mainlineKey
        case objectRef
        case boneRef
        case timeline
        case timelineKey
        case eventline
        case eventlineKey
        case object
        case bone
        
        /// Mapping each state to an XML element name.  The comments indicate the level at which
        /// each is expected to be found.
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
                        
                        // 3nd level
                    case .frames:
                        return "frames"

                        // 4th level
                    case .i:
                        return "i"
                        
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
                        
                        // 3rd level
                    case .eventline:
                        return "eventline"
                        
                        // 4th level
                    case .eventlineKey:
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
        
        /// Initialises the parsing state using the XML element name, and in some cases the
        /// previous parsing state because some XML elements are used in more than one
        /// place.
        /// - Parameters:
        ///   - tag: The XML element name / tag
        ///   - previousState: the previous parsing state.
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
            } else if tag == ParsingState.frames.elementTag {
                self = .frames
            } else if tag == ParsingState.i.elementTag {
                self = .i
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
            } else if tag == ParsingState.eventline.elementTag {
                self = .eventline
            } else if tag == ParsingState.eventlineKey.elementTag &&
                        previousState == .eventline {
                self = .eventlineKey
            } else if tag == ParsingState.object.elementTag {
                self = .object
            } else if tag == ParsingState.bone.elementTag {
                self = .bone
            } else {
                self = .none
            }
        }
        
        /// For the current parsing state (self), returns an array of the parsing states that are valid
        /// sub elements.
        /// - Returns: An array of parsing states that are valid sub-elements of self.
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
                    return [.mainline, .timeline, .gline, .eventline]
                case .mainline:
                    return [.mainlineKey]
                case .mainlineKey:
                    return [.objectRef, .boneRef]
                case .timeline:
                    return [.timelineKey]
                case .timelineKey:
                    return [.object, .bone]
                case .objInfo:
                    return [.frames]
                case .frames:
                    return [.i]
                case .eventline:
                    return [.eventlineKey]
                case .file, .objectRef, .boneRef, .object, .bone, .i, .map, .gline, .eventlineKey:
                    return []
            }
        }
        
        /// Returns the parsing state representing the state which is considered a parent of self.  Root
        /// level states will have `.none` as their parent.
        /// - Returns: A parsing state which it the parent of self, or `.none`.
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
                case .frames:
                    return .objInfo
                case .i:
                    return .frames
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
                case .eventline:
                    return .animation
                case .eventlineKey:
                    return .eventline
                case .object:
                    return .timelineKey
                case .bone:
                    return .timelineKey
            }
        }
    }
    
    /// The current parsing state.
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
                    if let objInfo = SpriterObjectInfo(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        
                        self.entities[lastEntity].objectInfos.append(objInfo)
                    }
                    
                case .characterMap:
                    break
                case .frames:
                    break
                case .i:
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
                case .eventline:
                    if let eventline = SpriterEventline(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .eventlines.append(eventline)
                    }
                case .eventlineKey:
                    if let eventlineKey = SpriterEventlineKey(withAttributes: attributeDict) {
                        let lastEntity = self.entities.endIndex-1
                        let lastAnimation = self.entities[lastEntity].animations.endIndex-1
                        let lastEventline = self.entities[lastEntity]
                            .animations[lastAnimation]
                            .eventlines.endIndex-1

                        self.entities[lastEntity]
                            .animations[lastAnimation]
                            .eventlines[lastEventline]
                            .keys.append(eventlineKey)
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
                           let folderID = object.folderID,
                           let fileID = object.fileID,
                           let folder = self.folders.first(where: { folder in
                               return folder.id == folderID
                           }),
                           let file = folder.file(withID: fileID) {
                            object.pivot = file.pivot
                            
                            folder.texture(ofObject: object, fromBundle: self.resourceBundle)
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
                        
                        if let info = self.entities[lastEntity].objectInfo(withName: timeline.name) {
                            bone.size = info.size
                        }

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
