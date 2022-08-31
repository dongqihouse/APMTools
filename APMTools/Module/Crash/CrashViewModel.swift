//
//  CrashViewModel.swift
//  APMTools
//
//  Created by Drayl on 2022/8/30.
//

import Foundation

@MainActor
class CrashViewModel: ObservableObject {
    var appName = ""
    @Published var carshTexts: [String] = []
    
    
    func parse(path: String) {
        let content = (try? String(contentsOfFile: path)) ?? ""

        let parser = AppleParser()
        let crash: Crash! = parser.parse(content)
        let crashString = crash.symbolicate(dsymPaths: nil)
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
