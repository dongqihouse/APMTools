//
//  LinkMapViewModel.swift
//  Created on 2022/8/22
//  Drayl  
//

import Foundation

@MainActor
class LinkMapViewModel: ObservableObject {
    @Published var filePath: String = ""
    @Published var isLoading: Bool = false
    
    @Published var fileObjects: [LinkMapItem] = []
    @Published var moduleObjects: [LinkMapItem] = []
    
    /// 0 单文件列表 1模块列表
    @Published var contentSelectedIndex = -1
    
    func set(loading: Bool) {
        self.isLoading = loading
    }
    
    func set(fileObjects: [LinkMapItem]) {
        self.fileObjects = fileObjects
    }
    
    func set(moduleObjects: [LinkMapItem]) {
        self.moduleObjects = moduleObjects
    }
    
    func set(fileUrl: String) {
        self.filePath = fileUrl
    }
    
    func set(contentSelectedIndex: Int) {
        self.contentSelectedIndex = contentSelectedIndex
    }
    
}

protocol LinkMapItem: NSObjectProtocol {
    var name: String { get }
    var size: Int { get }
}


extension ModuleFile: LinkMapItem {
 
}

extension ObjectFile: LinkMapItem {
    
}
