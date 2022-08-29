//
//  CrashView.swift
//  APMTools
//
//  Created by Drayl on 2022/8/29.
//

import SwiftUI

struct CrashView: View {
    
    var body: some View {
        let content = self.crashContent(fromFile: "AppleDemo", ofType: "ips")

        let parser = AppleParser()
        let crash: Crash! = parser.parse(content)
        let crashString = crash.symbolicate(dsymPaths: nil)
        
        Text(crashString)
    }
    
    func crashContent(fromFile file: String, ofType ftype: String) -> String {
        let bundle = Bundle.main
        let path = bundle.path(forResource: file, ofType: ftype)!
        return try! String(contentsOfFile: path)
    }
    
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
    
    let modelMap = parseModels()

    func modelToName(_ model: String) -> String {
        return modelMap[model] ?? model
    }
}
