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
            if (viewModel.carshTexts.isEmpty) {
                AddView { path in
                    viewModel.parse(path: path)
                }
                .frame(width: 500, height: 500)
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
