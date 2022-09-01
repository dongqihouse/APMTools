//
//  UnusedClassViewModel.swift
//  Created on 2022/9/1
//  Description <#文件描述#>
//

import Foundation

class UnusedClassViewModel: ObservableObject {
    @Published var values = [String]()
    
    
    func parse(path: String) {
        do {
            let unusedList = try OTool().run(path: path)
            values = unusedList
        } catch {
            print(error)
        }
        
    }
}
