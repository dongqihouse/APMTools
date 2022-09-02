//
//  AddView.swift
//  APMTools
//
//  Created by Drayl on 2022/8/31.
//

import SwiftUI

struct AddView: View {
    @State private var isTargeted = false
    
    var text: String
    var callback: ((String) -> Void)?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(style: .init(lineWidth: 3, dash: [5]))
                .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers -> Bool in
                    if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                        let _ = provider.loadObject(ofClass: URL.self) { object, error in
                            if let url = object {
                                callback?(url.path)
                            }
                        }
                        return true
                    }
                    return true
                }
            VStack {
                Image(systemName: "plus.rectangle.on.folder.fill")
                Spacer().frame(height: 10)
                Text(text)
            }
     
        }.foregroundColor(.gray)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(text: "请拖入文件")
            .frame(width: 300, height: 300)
            .background(.white)
    }
}

