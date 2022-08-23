//
//  LinkMapViewModel.swift
//  Created on 2022/8/22
//  Drayl  
//

import Foundation

class LinkMapViewModel: ObservableObject {
    @Published var filePath: String = ""
    @Published var isLoading: Bool = false
    
    @Published var fileObjects: [ModuleFile] = []
    
    
    @MainActor
    func set(loading: Bool) {
        self.isLoading = loading
    }
    
    @MainActor
    func set(fileObjects: [ModuleFile]) {
        self.fileObjects = fileObjects
    }
    
}
