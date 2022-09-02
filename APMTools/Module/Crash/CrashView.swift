//
//  CrashView.swift
//  APMTools
//
//  Created by Drayl on 2022/8/29.
//

import SwiftUI

struct CrashView: View {
    
    @EnvironmentObject var viewModel: CrashViewModel
    
    var body: some View {
//        if viewModel.carshTexts.isEmpty {
//
//        }
        
        ZStack {
            List(viewModel.carshTexts, id: \.self) {
                Text($0).foregroundColor($0.contains(viewModel.appName) ? .red : .white)
            }
            
            HStack {
                if (viewModel.carshTexts.isEmpty) {
                    AddView(text: "请拖入Crash文件") { path in
                        viewModel.filePath.send(path)
                    }
                    .frame(width: 400, height: 600)
                }
                if (viewModel.carshTexts.isEmpty) {
                    AddView(text: "请拖入Dsym文件") { path in
                        viewModel.dsymPaths.send(path)
                    }
                    .frame(width: 400, height: 600)
                }
            }
            
            
        }
    }

    func modelToName(_ model: String) -> String {
        return modelMap[model] ?? model
    }
}

struct CrashView_Previews: PreviewProvider {
    static var previews: some View {
        CrashView()
    }
}
