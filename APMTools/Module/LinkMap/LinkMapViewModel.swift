//
//  LinkMapViewModel.swift
//  Created on 2022/8/22
//  Drayl  
//

import Foundation

class LinkMapViewModel: ObservableObject {
    @Published var filePath: String = ""
    @Published var isLoading: Bool = false
    
    @Published var fileObjects: [LinkMapItem] = []
    @Published var moduleObjects: [LinkMapItem] = []
    
    
    @MainActor
    func set(loading: Bool) {
        self.isLoading = loading
    }
    
    @MainActor
    func set(fileObjects: [LinkMapItem]) {
        self.fileObjects = fileObjects
    }
    
    @MainActor
    func set(moduleObjects: [LinkMapItem]) {
        self.moduleObjects = moduleObjects
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
