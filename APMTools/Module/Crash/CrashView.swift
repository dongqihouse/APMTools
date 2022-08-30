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
        if viewModel.carshTexts.isEmpty {
            viewModel.parse()
        }
        
        return List(viewModel.carshTexts, id: \.self) {
            Text($0).foregroundColor($0.contains(viewModel.appName) ? .red : .white)
        }
    }

    func modelToName(_ model: String) -> String {
        return modelMap[model] ?? model
    }
}
