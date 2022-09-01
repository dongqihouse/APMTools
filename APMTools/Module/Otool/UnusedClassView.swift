//
//  UnuseClass.swift
//  Created on 2022/9/1
//  Description <#文件描述#>  
//

import SwiftUI

struct UnusedClassView: View {
    
    @EnvironmentObject var viewModel: UnusedClassViewModel
    
    var body: some View {
        ZStack {
            List(viewModel.values, id: \.self) {
                Text($0)
            }
            if (viewModel.values.isEmpty) {
                AddView { path in
                    viewModel.parse(path: path)
                }
                .frame(width: 500, height: 500)
            }
            
        }
    }
}

struct UnusedClassView_Previews: PreviewProvider {
    static var previews: some View {
        UnusedClassView()
    }
}
