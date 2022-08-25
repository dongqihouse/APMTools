//
//  UnuseClass.swift
//  Created on 2022/7/7
//  Drayl
//

import Foundation


class ModuleFile: NSObject {
    var name = ""
    var size: Int = 0
    
    init(name: String = "", size: Int = 0) {
        self.name = name
        self.size = size
    }
}

class ObjectFile: NSObject {
    /// [  2]
    var file = ""
    /// Objects-normal/arm64/ActiveDeviceConnectedModule.o
    var path = ""
    ///
    var size: Int = 0
    
    var name: String {
        return path.components(separatedBy: "/").last ?? ""
    }
    
    init(file: String = "", path: String = "", size: Int = 0) {
        self.file = file
        self.path = path
        self.size = size
    }
}

struct Section {
    /// 0x108504BA8
    var address = ""
    /// 0x0000D3E0
    var size: Int = 0
    /// __DATA
    var segment = ""
    /// __objc_classrefs
    var section = ""
}

struct Symbol: Hashable {
    /// 0x108504BA8
    var address = ""
    /// 0x00000008
    var size: Int = 0
    /// [  2]
    var file = ""
    /// objc-class-ref or literal string: ActiveDeviceConnectedModule
    var name = ""
}

struct LinkMap {
    /// key 为 [file] 标识 代表Object
    /// 理论Objects 解析应该为一个数组，但是用字典为了好累加Object的Size信息
    var objectFileMap = [String : ObjectFile]()
    var sections = [Section]()
    var symbols = [Symbol]()
}

struct LinkMapUtil {
    
    static func sortedSymbols(from linkMap: LinkMap) -> [ObjectFile] {
        let objectFiles = Array(linkMap.objectFileMap.values).sorted { $0.size > $1.size }
        return objectFiles
    }
    
    static func sortedCombineSymbols(from linkMap: LinkMap) -> [ModuleFile] {
        let objectFiles = Array(linkMap.objectFileMap.values) as [ObjectFile]
        
        var combineMap = [String: ModuleFile]()
        for object in objectFiles {
            let objectName = object.name
            if objectName.contains("(") && objectName.contains(")") {
                guard let fileEnd = objectName.firstIndex(of: "(") else { continue }
                let moduleName = String(objectName[..<fileEnd])
                if let module = combineMap[moduleName] {
                    module.size += object.size
                } else {
                    let module = ModuleFile(name: moduleName, size: object.size)
                    combineMap[moduleName] = module
                }
                
            } else {
                if objectName.contains(".o") { // app 本身
                    if let module = combineMap["App"] {
                        module.size += object.size
                    } else {
                        let module = ModuleFile(name: "App", size: object.size)
                        combineMap["App"] = module
                    }
                } else {
                    // 动态库
                    let module = ModuleFile(name: objectName, size: object.size)
                    combineMap[objectName] = module
                }
               
            }
        }
        let modules = Array(combineMap.values).sorted { $0.size > $1.size }
        return modules
    }
    
    static func analyze(with path: String) async throws -> LinkMap {
        var objectFileMap = [String : ObjectFile]()
        var sections = [Section]()
        var symbols = [Symbol]()
        let linkMapContent = try String(contentsOfFile: path, encoding: .macOSRoman)
        
        let lines = linkMapContent.components(separatedBy: "\n")
        
        var isReachFiles = false
        var isReachSections = false
        var isReachSymbols = false
        
        for line in lines {
            if line.hasPrefix("#") {
                if line.hasPrefix("# Object files:") {
                    isReachFiles = true
                } else if line.hasPrefix("# Sections:") {
                    isReachSections = true
                } else if line.hasPrefix("# Symbols:") {
                    isReachSymbols = true
                }
            } else {
                if isReachFiles && !isReachSymbols && !isReachSections {
//                    [  0] linker synthesized
//                    [  1] dtrace
//                    [  2] /Objects-normal/arm64/ActiveDeviceConnectedModule.o
                    guard let fileEnd = line.firstIndex(of: "]") else { continue }
                    let pathStart = line.index(fileEnd, offsetBy: 1)
                    
                    let file = String(line[...fileEnd])
                    let path = String(line[pathStart...])
                    let name = path.components(separatedBy: "/").last ?? ""
                    objectFileMap[file] = ObjectFile(file: file, path: name)
                } else if isReachFiles && isReachSections && !isReachSymbols {
//                    # Sections:
//                    # Address    Size        Segment    Section
//                    0x1000049C0    0x068D3A9C    __TEXT    __text
//                    0x1068D845C    0x0000A014    __TEXT    __stubs
//                    0x1068E2470    0x00009CFC    __TEXT    __stub_helper
                    let components = line.components(separatedBy: "\t")
                    let sizeHex = components[0]
                    let size = Int(sizeHex.dropFirst(2), radix: 16) ?? 0
                    sections.append(Section(address: components[0], size: size, segment: components[2], section: components[3]))
                } else if isReachFiles && isReachSections && isReachSymbols {
//                    # Symbols:
//                    # Address    Size        File  Name
//                    0x1000049C0    0x00000208    [  2] -[ActiveDeviceConnectedModule connectDeviceWithSourceId:block:]
//                    0x100004BC8    0x00001008    [  2] -[ActiveDeviceConnectedModule deviceNameWithSourceId:]
                    let components = line.components(separatedBy: "\t")
                    let fileAndName = components.last ?? ""
                    guard let fileEnd = fileAndName.firstIndex(of: "]") else { continue }
                    let nameStart = fileAndName.index(fileEnd, offsetBy: 1)
                    
                    let file = String(fileAndName[...fileEnd])
                    let name = String(fileAndName[nameStart...])
                    let sizeHex = components[1]
                    let size = Int(sizeHex.dropFirst(2), radix: 16) ?? 0
                    let address = components[0]
                    symbols.append(Symbol(address: address, size: size, file: file, name: name))
                    objectFileMap[file]?.size += size
                }
                
            }
        }
        
        return LinkMap(objectFileMap: objectFileMap, sections: sections, symbols: symbols)
    }
}
