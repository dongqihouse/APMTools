//
//  Otool.swift
//  Created on 2022/7/11
//  Drayl  
//

import Foundation

struct OTool {
    
    static let sectionPrefix = "Contents of (__DATA,"
    static let classListSuffix = "__objc_classlist"
    static let classRefsSuffix = "__objc_classrefs"
    static let classSuperRefsSuffix = "__objc_superrefs"
    
    func run() throws {
        guard let filePath = Bundle.main.path(forResource: "otool_result", ofType: "txt") else { return }
        let linkMapContent = try String(contentsOfFile: filePath, encoding: .macOSRoman)
        
        let lines = linkMapContent.components(separatedBy: "\n")
        
        var isReachClassList = false
        var isReachClassRefs = false
        var isReachClassSupRefs = false
        var classList = [String: String]()
        var classRefs: Set<String> = []
        
        var tempAddresses = [String]()
        
        for line in lines {
           
            if line.hasPrefix(OTool.sectionPrefix) && line.contains(OTool.classListSuffix) {
                isReachClassList = true
                continue
            } else if  line.hasPrefix(OTool.sectionPrefix) && !line.contains(OTool.classListSuffix) {
                isReachClassList = false
            }
            
            if line.hasPrefix(OTool.sectionPrefix) && line.contains(OTool.classRefsSuffix) {
                isReachClassRefs = true
                continue
            } else if  line.hasPrefix(OTool.sectionPrefix) && !line.contains(OTool.classRefsSuffix) {
                isReachClassRefs = false
            }
            
            if line.hasPrefix(OTool.sectionPrefix) && line.contains(OTool.classSuperRefsSuffix) {
                isReachClassSupRefs = true
                continue
            } else if  line.hasPrefix(OTool.sectionPrefix) && !line.contains(OTool.classSuperRefsSuffix) {
                isReachClassSupRefs = false
            }
            
            if isReachClassList {
//                Contents of (__DATA,__objc_classlist) section
//                0000000106277208 0x106c27698  查看当前class的地址
//                    isa        0x106c27670
                if line.contains("000000010") {
                    let components = line.components(separatedBy: " ")
                    guard let address = components.last else { continue }
                    
                    tempAddresses.append(address)
                } else if line.contains("name") {
                    let components = line.components(separatedBy: " ")
                    guard let name = components.last else { continue }
                    guard let address = tempAddresses.last else { continue }
                    classList[address] = name
                    
                }
            } else if isReachClassRefs || isReachClassSupRefs {
                if line.contains("000000010") {
//                    Contents of (__DATA,__objc_classrefs) section
//                    0000000106bf7cb0 0x106c46c98
//                    0000000106bf7cb8 0x106c3ce98
//                    0000000106bf7cc0 0x0 _OBJC_CLASS_$_NSBundle
                    let components = line.components(separatedBy: " ")
                    guard let address = components.last else { continue }
                    if address.contains("0x10") {
                        classRefs.insert(address)
                    }
                }
            }
        }
        
        for ref in classRefs {
            classList[ref] = nil
        }
        
        print(classList.count)
        print(classList)
        
    }
}

/**
 -o print the Objective-C segment

 -v print verbosely (symbolically) when possible

 Contents of (__DATA,__objc_classlist) section **
 Contents of (__DATA,__objc_classrefs) section **
 Contents of (__DATA,__objc_superrefs) section **

 Contents of (__DATA,__objc_catlist) section
 Contents of (__DATA,__objc_protolist) section

 Contents of (__DATA,__objc_selrefs) section  **

 Contents of (__DATA,__objc_imageinfo) section
 
 */
