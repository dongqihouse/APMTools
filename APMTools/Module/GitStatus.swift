//
//  GitStatus.swift
//  Created on 2022/7/18
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2022 Zepp Health. All rights reserved.
//  @author dongqi(dongqi@zepp.com)   
//

import Foundation

struct GitStatus {
    static func checkModifiedImages(path: String) {
        var linkMapContent = ""
        do {
            linkMapContent = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print(error)
            return
        }
        
        let lines = linkMapContent.components(separatedBy: "\n")
        var results = [String]()
        for line in lines {
            if line.contains("modified") {
                let components = line.components(separatedBy: "   ")
                let base = "/Users/qd/Desktop/project/mifit3"
                results.append(base + (components.last ?? ""))
            }
        }
        for (index, path) in results.enumerated() {
            print("🐶压缩中\(index + 1)/\(results.count)")
            // -Q, --no-quit           do not quit apps once finishe
            // --no-imageoptim         disable ImageOptim
            // -a, --imagealpha        enable ImageAlpha
            // --number-of-colors <n>  ImageAlpha palette size, defaults to 256
            // --quality <min>-<max>   ImageAlpha quality range from 0-100, defaults to 65-80
//            let output = shell("/usr/local/bin/imageoptim -Q --no-imageoptim --imagealpha --number-of-colors 16 --quality 40-80 \(path)")
            let output = shell("/usr/local/bin/imageoptim -Q --imagealpha --quality 40-80 \(path)")
            print("🐶压缩完成\(output)")
        }
    }
    
    
    @discardableResult
    static func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe

        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh" // "/bin/bash"
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}
