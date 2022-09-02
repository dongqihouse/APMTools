//
//  CrashViewModel.swift
//  APMTools
//
//  Created by Drayl on 2022/8/30.
//

import Foundation
import Combine

@MainActor
class CrashViewModel: ObservableObject {
    var appName = ""
    @Published var carshTexts: [String] = []
    
    var filePath = CurrentValueSubject<String, Never>("")
    var dsymPaths = CurrentValueSubject<String, Never>("")
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = Publishers.Zip(filePath, dsymPaths).sink(
            receiveValue: { [weak self] filePath, dsymPaths in
            
                if !filePath.isEmpty && !dsymPaths.isEmpty {
                    self?.parse(path: filePath, dsymPath: dsymPaths)
                }
                
            }
        )
    }
    
    
    func parse(path: String, dsymPath: String) {
        let content = (try? String(contentsOfFile: path)) ?? ""

        let parser = AppleParser()
        let crash: Crash! = parser.parse(content)
        let crashString = crash.symbolicate(dsymPaths: [dsymPath])
        carshTexts = crashString.components(separatedBy: "\n")
        appName = crash.appName ?? ""
    }
    
    
    
    //MARK: - Tools
    
    private func infoString(fromCrash crash: Crash) -> String {
        var info = ""
        var divider = ""
        if let device = crash.device {
            info += "🏷 " + modelToName(device)
            divider = " - "
        }
        if let osVersion = crash.osVersion {
            info += "\(divider)\(osVersion)"
        }
        
        if let appVersion = crash.appVersion {
            info += "\(divider)\(appVersion)"
        }
        
        return info
    }
}
